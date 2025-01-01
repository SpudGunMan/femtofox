#!/bin/bash
# one liner to download and install the development environment
# cd ~ && wget https://raw.githubusercontent.com/SpudGunMan/femtofox/refs/heads/labwork/environment-setup/foxbunto_env_setup.sh -O foxbunto_env_setup.sh && sudo bash foxbunto_env_setup.sh install
# touch 29th 249pm
cd ~
if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [ "$VERSION_ID" != "22.04" ] || [ "$NAME" != "Ubuntu" ]; then
        echo "This script is intended for Ubuntu 22.04, exiting..."
        exit 1
    fi
else
    echo "This script is intended for Ubuntu 22.04, exiting..."
    exit 1
fi

# Ensure dialog is installed
if ! command -v dialog &> /dev/null; then
    echo "dialog could not be found, installing..."
    apt update && apt install -y dialog
fi

if [[ $(id -u) != 0 ]]; then
  echo "This script must be run as root; use sudo"
  exit 1
fi

sudoer=$(echo $SUDO_USER)

################ STEPS ################
# now found at bottom as function calls
#######################################

################ TODO ################
# Add more error handling
# Address potential issues in comments
# Package selection with curses
# Switch chroot packages install
# Modify DTS etc to enable SPI1
######################################

install_prerequisites() {
  echo “Setting up Foxbuntu build environment…”
  apt update
  apt install -y git ssh make gcc gcc-multilib g++-multilib module-assistant expect g++ gawk texinfo libssl-dev bison flex fakeroot cmake unzip gperf autoconf device-tree-compiler libncurses5-dev pkg-config bc python-is-python3 passwd openssl openssh-server openssh-client vim file cpio rsync qemu-user-static binfmt-support dialog
}

clone_repos() {
  echo "Cloning repos..."
  #mkdir /home/${sudoer}/
  cd /home/${sudoer}/
  git clone https://github.com/LuckfoxTECH/luckfox-pico.git
  #git clone https://github.com/noon92/femtofox.git
  # SPUD LABWORK BRANCH
  git clone https://github.com/SpudGunMan/femtofox
  cd /home/${sudoer}/femtofox
  git checkout labwork
  cd /home/${sudoer}/
}

build_env() {
  echo "Setting up SDK env..."
  echo "When the menu appears to choose your board choose Luckfox Pico Mini A (1), SDCard (0) and Ubuntu (1)."
  echo "Press any key to continue building the enviroment..."
  read -n 1 -s -r
  cd /home/${sudoer}/luckfox-pico
  ./build.sh env
}

build_sysdrv() {
  echo "Building sysdrv..."
  cd /home/${sudoer}/luckfox-pico
  ./build.sh sysdrv
}

build_uboot() {
  echo "Building uboot..."
  cd /home/${sudoer}/luckfox-pico
  ./build.sh uboot
}

build_rootfs() {
  echo "Building rootfs..."
  cd /home/${sudoer}/luckfox-pico
  ./build.sh rootfs
}

copy_femtofox_kernelcfg() {
  echo "Merging in Foxbuntu modifications..."
  cd /home/${sudoer}/femtofox/foxbuntu/
  # need to change updatefs.sh, kernel stuff here and rootfs stuff later
  # ./updatefs.sh
  rsync -aHAXv --progress --keep-dirlinks --itemize-changes /home/${sudoer}/femtofox/foxbuntu/sysdrv/ /home/${sudoer}/luckfox-pico/sysdrv/
  rsync -aHAXv --progress --keep-dirlinks --itemize-changes /home/${sudoer}/femtofox/foxbuntu/project/ /home/${sudoer}/luckfox-pico/project/
  rsync -aHAXv --progress --keep-dirlinks --itemize-changes /home/${sudoer}/femtofox/foxbuntu/output/image/ /home/${sudoer}/luckfox-pico/output/image/

}

build_kernelconfig() {
  echo "Building kernelconfig... Please exit without making any changes unless you know what you are doing."
  echo "Press any key to continue building the kernel..."
  read -n 1 -s -r
  cd /home/${sudoer}/luckfox-pico
  ./build.sh kernelconfig
  ./build.sh kernel
}

modify_kernel() {
  echo "Building kernel... ."
  echo "After making kernel configuration changes, make sure to save as .config (default) before exiting."
  echo "Press any key to continue building the kernel..."
  read -n 1 -s -r
  cd /home/${sudoer}/luckfox-pico
  ./build.sh kernelconfig
  ./build.sh kernel
  build_rootfs
  build_firmware
  cp /home/${sudoer}/luckfox-pico/sysdrv/out/kernel_drv_ko/* /home/${sudoer}/luckfox-pico/sysdrv/out/rootfs_uclibc_rv1106/lib/modules/5.10.160/
  echo "Entering chroot..."
  mount --bind /proc /home/${sudoer}/luckfox-pico/sysdrv/out/rootfs_uclibc_rv1106/proc
  mount --bind /sys /home/${sudoer}/luckfox-pico/sysdrv/out/rootfs_uclibc_rv1106/sys
  mount --bind /dev /home/${sudoer}/luckfox-pico/sysdrv/out/rootfs_uclibc_rv1106/dev
  mount --bind /dev/pts /home/${sudoer}/luckfox-pico/sysdrv/out/rootfs_uclibc_rv1106/dev/pts
  chroot /home/${sudoer}/luckfox-pico/sysdrv/out/rootfs_uclibc_rv1106 /bin/bash <<EOF
echo "Inside chroot environment..."
echo "Setting up kernel modules..."
depmod -a 5.10.160
echo "Cleaning up chroot..."
apt clean && rm -rf /var/lib/apt/lists/* && rm -rf /tmp/* && rm -rf /var/tmp/* && find /var/log -type f -exec truncate -s 0 {} + && : > /root/.bash_history && history -c
exit
EOF

  umount /home/${sudoer}/luckfox-pico/sysdrv/out/rootfs_uclibc_rv1106/dev/pts
  umount /home/${sudoer}/luckfox-pico/sysdrv/out/rootfs_uclibc_rv1106/proc
  umount /home/${sudoer}/luckfox-pico/sysdrv/out/rootfs_uclibc_rv1106/sys
  umount /home/${sudoer}/luckfox-pico/sysdrv/out/rootfs_uclibc_rv1106/dev
  build_rootfs
  build_firmware
  create_image
}


modify_chroot() {
  echo "Entering chroot... make your changes and then type exit when you are done and it will build the image with your changes."
  echo "Press any key to continue entering chroot..."
  read -n 1 -s -r
  mount --bind /proc /home/${sudoer}/luckfox-pico/sysdrv/out/rootfs_uclibc_rv1106/proc
  mount --bind /sys /home/${sudoer}/luckfox-pico/sysdrv/out/rootfs_uclibc_rv1106/sys
  mount --bind /dev /home/${sudoer}/luckfox-pico/sysdrv/out/rootfs_uclibc_rv1106/dev
  mount --bind /dev/pts /home/${sudoer}/luckfox-pico/sysdrv/out/rootfs_uclibc_rv1106/dev/pts
  chroot /home/${sudoer}/luckfox-pico/sysdrv/out/rootfs_uclibc_rv1106 /bin/bash
  umount /home/${sudoer}/luckfox-pico/sysdrv/out/rootfs_uclibc_rv1106/dev/pts
  umount /home/${sudoer}/luckfox-pico/sysdrv/out/rootfs_uclibc_rv1106/proc
  umount /home/${sudoer}/luckfox-pico/sysdrv/out/rootfs_uclibc_rv1106/sys
  umount /home/${sudoer}/luckfox-pico/sysdrv/out/rootfs_uclibc_rv1106/dev
  build_rootfs
  build_firmware
  create_image
}

update_image() {
  #we still need the chroot scripts function but this will work for now.
  echo "Updating repo..."
  cd /home/${sudoer}/femtofox
  git pull
  cd /home/${sudoer}/
  copy_femtofox_kernelcfg
  build_kernelconfig
  build_rootfs
  build_firmware
  create_image
}

modify_rootfs() {
  echo "Modifying rootfs..."
  cd /home/${sudoer}/luckfox-pico/output/image
  echo "Copying kernel modules..."
  mkdir -p /home/${sudoer}/luckfox-pico/sysdrv/out/rootfs_uclibc_rv1106/lib/modules/5.10.160
  cp /home/${sudoer}/luckfox-pico/sysdrv/out/kernel_drv_ko/* /home/${sudoer}/luckfox-pico/sysdrv/out/rootfs_uclibc_rv1106/lib/modules/5.10.160/
  which qemu-arm-static
  echo "Entering chroot and running commands..."
  cp /usr/bin/qemu-arm-static /home/${sudoer}/luckfox-pico/sysdrv/out/rootfs_uclibc_rv1106/usr/bin/
  mount --bind /proc /home/${sudoer}/luckfox-pico/sysdrv/out/rootfs_uclibc_rv1106/proc
  mount --bind /sys /home/${sudoer}/luckfox-pico/sysdrv/out/rootfs_uclibc_rv1106/sys
  mount --bind /dev /home/${sudoer}/luckfox-pico/sysdrv/out/rootfs_uclibc_rv1106/dev
  mount --bind /dev/pts /home/${sudoer}/luckfox-pico/sysdrv/out/rootfs_uclibc_rv1106/dev/pts
# can i indent with EOF ??
  chroot /home/${sudoer}/luckfox-pico/sysdrv/out/rootfs_uclibc_rv1106 /bin/bash <<EOF
echo "Inside chroot environment..."
echo "tmpfs /run tmpfs rw,nodev,nosuid,size=32M 0 0" | tee -a /etc/fstab

# Temporarily removed for SEGFAULT fix done after upgrade below.
#echo "Installing Meshtastic..."

#wget -qO- https://meshtastic.github.io/meshtastic-deb.asc | tee /etc/apt/keyrings/meshtastic-deb.asc >/dev/null
#if [[ $? -eq 2 ]]; then echo "Error, step failed..."; fi
#echo "deb [arch=all signed-by=/etc/apt/keyrings/meshtastic-deb.asc] https://meshtastic.github.io/deb stable main" | tee /etc/apt/sources.list.d/meshtastic-deb.list >/dev/null

echo "Removing netdevice rules..."

ln -s /dev/null /etc/udev/rules.d/80-net-setup-link.rules

echo "Setting up kernel modules..."

touch /lib/modules/5.10.160/modules.order
touch /lib/modules/5.10.160/modules.builtin
depmod -a 5.10.160
if [[ $? -eq 2 ]]; then echo "Error, step failed..."; fi

echo "Setting localtime to UTC..."

rm /etc/localtime
ln -sf /usr/share/zoneinfo/UTC /etc/localtime

echo "Installing packages..."

# link gcc library
# ln -sf /lib/arm-linux-gnueabihf/libgcc_s.so.1 /usr/lib/libgcc.so
# gcc only seem work when `apt-get reinstall libc6-dev-armhf-cross` is ran in live os

apt update
DEBIAN_FRONTEND=noninteractive apt install -y --option Dpkg::Options::="--force-confold" linux-firmware wireless-tools git python-is-python3 python3.10-venv libgpiod-dev libyaml-cpp-dev libbluetooth-dev openssl libssl-dev libulfius-dev liborcania-dev avahi-daemon protobuf-compiler fonts-noto-color-emoji ninja-build chrony qrencode
if [[ $? -eq 2 ]]; then echo "Error, step failed..."; fi
DEBIAN_FRONTEND=noninteractive apt upgrade -y --option Dpkg::Options::="--force-confold"
if [[ $? -eq 2 ]]; then echo "Error, step failed..."; fi

# Tempfix for SEGFAULT
wget https://github.com/meshtastic/firmware/releases/download/v2.5.11.8e2a3e5/meshtasticd_2.5.11.8e2a3e5_armhf.deb
DEBIAN_FRONTEND=noninteractive apt install -y --option Dpkg::Options::="--force-confold" ./meshtasticd_2.5.11.8e2a3e5_armhf.deb

echo "Installing meshtastic cli..."

pip3 install pytap2 pypubsub meshtastic  
if [[ $? -eq 2 ]]; then echo "Error, step failed..."; fi

echo "Installing meshtastic community projects..." 

echo "Installing meshing around BBS..."

git clone https://github.com/spudgunman/meshing-around.git /opt/meshing-around
# Dependencies for meshing around 
pip3 install requests pyephem geopy maidenhead beautifulsoup4 dadjokes schedule wikipedia googlesearch-python

echo "Installing TC2 BBS..."
git clone https://github.com/TheCommsChannel/TC2-BBS-mesh.git /opt/TC2-BBS-mesh

echo "Installing the shell clients for meshtastic..."

# Curses client for meshtastic
git clone https://github.com/pdxlocations/curses-client-for-meshtastic.git /opt/curses-client-for-meshtastic

echo "Installing additional tools..."
DEBIAN_FRONTEND=noninteractive apt install -y --option Dpkg::Options::="--force-confold" mosquitto mosquitto-clients
systemctl disable mosquitto
DEBIAN_FRONTEND=noninteractive apt install -y --option Dpkg::Options::="--force-confold" gpsd gpsd-clients python-gps
systemctl disable gpsd
DEBIAN_FRONTEND=noninteractive apt install -y --option Dpkg::Options::="--force-confold" screen minicom telnet
DEBIAN_FRONTEND=noninteractive apt install -y --option Dpkg::Options::="--force-confold" telnetd nc socat
systemctl disable telnetd
DEBIAN_FRONTEND=noninteractive apt install -y --option Dpkg::Options::="--force-confold" i2c-tools evtest
#DEBIAN_FRONTEND=noninteractive apt install -y --option Dpkg::Options::="--force-confold" RPi.GPIO gpio


echo "Setting MOTD..."

mv /etc/update-motd.d/10-help-text /etc/update-motd.d/10-help-text.bak
mv /etc/update-motd.d/60-unminimize /etc/update-motd.d/60-unminimize.bak

echo "Setting hostname to femtofox..."

echo "femtofox" | tee /etc/hostname > /dev/null

echo "Configuring autostart of systemd services..."

systemctl enable button
# SPUD TEMPORARY FIX
systemctl disable wifi-mesh-control
##
systemctl disable NetworkManager
systemctl disable NetworkManager-dispatcher
systemctl disable NetworkManager-wait-online
systemctl disable vsftpd.service
systemctl disable ModemManager.service
systemctl disable getty@tty1.service
systemctl disable acpid
systemctl disable acpid.socket
systemctl disable acpid.service
systemctl mask alsa-restore.service
systemctl disable alsa-restore.service
systemctl disable alsa-state.service
systemctl mask sound.target
systemctl disable sound.target
systemctl disable veritysetup.target
systemctl disable systemd-pstore.service

echo "Adding femto and pico users/groups..."

groupmod -n femto pico
usermod -l femto pico
usermod -aG sudo,input femto
echo "femto ALL=(ALL:ALL) ALL" | tee /etc/sudoers.d/femto > /dev/null
chmod 440 /etc/sudoers.d/femto

# this seems messy, user:group should be set cleanly and not corrected after?  OSC: somethings were owned my pico from factory

find / -group pico -exec chgrp femto {} \; 2>/dev/null
find / -user pico -exec chown femto {} \; 2>/dev/null
usermod -d /home/femto -m femto
ls -ld /home/femto
echo 'femto:femto' | chpasswd
sudo chage -d 0 femto
usermod -a -G tty femto
usermod -a -G dialout femto

echo "Cleaning up chroot..."

apt clean && rm -rf /var/lib/apt/lists/* && rm -rf /tmp/* && rm -rf /var/tmp/* && find /var/log -type f -exec truncate -s 0 {} + && : > /root/.bash_history && history -c
exit
EOF

  umount /home/${sudoer}/luckfox-pico/sysdrv/out/rootfs_uclibc_rv1106/dev/pts
  umount /home/${sudoer}/luckfox-pico/sysdrv/out/rootfs_uclibc_rv1106/proc
  umount /home/${sudoer}/luckfox-pico/sysdrv/out/rootfs_uclibc_rv1106/sys
  umount /home/${sudoer}/luckfox-pico/sysdrv/out/rootfs_uclibc_rv1106/dev
}

build_firmware() {
  echo "Building firmware..."
  cd /home/${sudoer}/luckfox-pico/
  ./build.sh firmware
}

create_image() {
  echo "Creating final sdcard img..."
  cd /home/${sudoer}/luckfox-pico/output/image
  sudo /home/${sudoer}/luckfox-pico/output/image/blkenvflash /home/${sudoer}/luckfox-pico/foxbuntu.img
  if [[ $? -eq 2 ]]; then echo "Error, sdcard img failed to build..."; exit 2; else echo "foxbuntu.img build completed."; fi
  du -h /home/${sudoer}/luckfox-pico/foxbuntu.img
}

sdk_install() {
  { echo 'Defaults timestamp_timeout=180' | sudo EDITOR='tee -a' visudo; } > /dev/null 2>&1
  start_time=$(date +%s)
  install_prerequisites
  clone_repos
  build_env
  build_uboot
  copy_femtofox_kernelcfg
  build_kernelconfig
  build_rootfs
  rsync -aHAXv --progress --keep-dirlinks --itemize-changes /home/${sudoer}/femtofox/foxbuntu/sysdrv/out/rootfs_uclibc_rv1106/ /home/${sudoer}/luckfox-pico/sysdrv/out/rootfs_uclibc_rv1106/
  build_firmware
  modify_rootfs
  build_rootfs
  build_firmware
  create_image
  { sudo sed -i '/Defaults timestamp_timeout=180/d' /etc/sudoers; } > /dev/null 2>&1
  end_time=$(date +%s)
  elapsed=$(( end_time - start_time ))
  hours=$(( elapsed / 3600 ))
  minutes=$(( (elapsed % 3600) / 60 ))
  seconds=$(( elapsed % 60 ))
  printf "Environment installation time: %02d:%02d:%02d\n" $hours $minutes $seconds
}

usage() {
  echo "The following functions are available in this script:"
  echo "To install the development environment use the arg 'sdk_install' and is intended to be run ONCE only."
  echo "To modify the chroot and build an updated image use the arg 'modify_chroot'."
  echo "To modify the kernel and build an updated image use the arg 'modify_kernel'."
  echo "other args: install_prerequisites clone_repos build_env build_sysdrv copy_femtofox_kernelcfg build_kernelconfig modify_rootfs build_rootf build_uboot build_firmware get_envblkflash create_image"
  echo "Example:  sudo ~/foxbunto_env_setup.sh sdk_install"
  echo "Example:  sudo ~/foxbunto_env_setup.sh modify_chroot"
  exit 0
}

################### MENU SYSTEM ###################

while true; do
  CHOICE=$(dialog --clear --backtitle "Foxbuntu SDK Builder" \
    --title "Main Menu" \
    --menu "Choose an action:" 20 60 12 \
    1 "Update Image" \
    2 "Modify Chroot" \
    3 "Modify Kernel" \
    4 "Install Prerequisites" \
    5 "Clone Repositories" \
    6 "Build Environment" \
    7 "Build SysDrv" \
    8 "Build U-Boot" \
    9 "Build RootFS" \
    10 "Create Final Image" \
    11 "SDK Install (Run All Steps)" \
    12 "Exit" \
    2>&1 >/dev/tty)

  clear

  case $CHOICE in
    1)
      update_image
      ;;
    2)
      modify_chroot
      ;;
    3)
      modify_kernel
      ;;
    4)
      install_prerequisites
      ;;
    5)
      clone_repos
      ;;
    6)
      build_env
      ;;
    7)
      build_sysdrv
      ;;
    8)
      build_uboot
      ;;
    9)
      build_rootfs
      ;;
    10)
      create_image
      ;;
    11)
      sdk_install
      ;;
    12)
      echo "Exiting..."
      break
      ;;
    *)
      echo "Invalid option, please try again."
      ;;
  esac
done

### Run all functions. Broken out so any individual step can be performed if failed.
# Should add clean functions...
# probably rewrite this as case switch

if [[ $(echo ${1} | egrep -i "^(h|help)$") ]]; then
  usage
elif [[ -z ${1} ]]; then
  usage
elif [[ ${1} == "modify_chroot" ]]; then
  modify_chroot
elif [[ ${1} == "modify_kernel" ]]; then
  modify_kernel
elif [[ ${1} == "update_image" ]]; then
  update_image
elif [[ ${1} == "sdk_install" ]]; then
  sdk_install
else
  ${1}
fi

exit 0