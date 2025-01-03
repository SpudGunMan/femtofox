#!/bin/bash

################ TODO ################
# Add more error handling
# Address potential issues in comments
# Package selection with curses
# Switch chroot packages install
# Modify DTS etc to enable SPI1
######################################

if [[ $(id -u) != 0 ]]; then
  echo "This script must be run as root; use sudo"
  exit 1
fi

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

sudoer=$(echo $SUDO_USER)

# Check if 'dialog' is installed, install it if missing
if ! command -v dialog &> /dev/null; then
  echo "The 'dialog' package is required to run this script. Press any key to install it."
  read -n 1 -s -r
  apt update && apt install -y dialog
fi

install_prerequisites() {
  echo "Setting up Foxbuntu build environment..."
  apt update
  apt install -y git ssh make gcc gcc-multilib g++-multilib module-assistant expect g++ gawk texinfo libssl-dev bison flex fakeroot cmake unzip gperf autoconf device-tree-compiler libncurses5-dev pkg-config bc python-is-python3 passwd openssl openssh-server openssh-client vim file cpio rsync qemu-user-static binfmt-support dialog
}

#clone_repos() {
#  echo "Cloning repos..."
#  cd /home/${sudoer}/
#  git clone https://github.com/LuckfoxTECH/luckfox-pico.git
#  git clone https://github.com/noon92/femtofox.git
#}

clone_repos() {
  echo "Cloning repos..."
  cd /home/${sudoer}/ || return 1  # Ensure we successfully change the directory

  # Helper function to retry cloning a repo
  clone_with_retries() {
    local repo_url="$1"
    local retries=3
    local count=0
    local success=0

    while [ $count -lt $retries ]; do
      echo "Attempting to clone $repo_url (Attempt $((count + 1))/$retries)"
      git clone "$repo_url" && success=1 && break
      count=$((count + 1))
      echo "Retrying..."
    done

    if [ $success -eq 0 ]; then
      echo "Failed to clone $repo_url after $retries attempts."
      return 1
    fi
  }

  # Clone both repos
  clone_with_retries "https://github.com/LuckfoxTECH/luckfox-pico.git" || return 1
  clone_with_retries "https://github.com/noon92/femtofox.git" || return 1

  return 0  # Indicate success if all repos cloned
}

build_env() {
  echo "Setting up SDK env..."
  echo "When the menu appears to choose your board choose Luckfox Pico Mini A (1), SDCard (0) and Ubuntu (1)."
  echo "Press any key to continue building the environment..."
  read -n 1 -s -r
  cd /home/${sudoer}/luckfox-pico
  ./build.sh env
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

build_firmware() {
  echo "Building firmware..."
  cd /home/${sudoer}/luckfox-pico/
  ./build.sh firmware
}

sync_foxbuntu_changes() {
  SOURCE_DIR=/home/${sudoer}/femtofox/foxbuntu
  DEST_DIR=/home/${sudoer}/luckfox-pico

  # Ensure the source is updated
  cd "$SOURCE_DIR" || exit
  git pull

  # Get a list of all Git-tracked files in the source
  cd "$SOURCE_DIR" || exit
  git ls-files > /tmp/source_files.txt
  
  echo "Merging in Foxbuntu modifications..."
  rsync -aHAXv --progress --keep-dirlinks --itemize-changes /home/${sudoer}/femtofox/foxbuntu/sysdrv/ /home/${sudoer}/luckfox-pico/sysdrv/
  rsync -aHAXv --progress --keep-dirlinks --itemize-changes /home/${sudoer}/femtofox/foxbuntu/project/ /home/${sudoer}/luckfox-pico/project/
  rsync -aHAXv --progress --keep-dirlinks --itemize-changes /home/${sudoer}/femtofox/foxbuntu/output/image/ /home/${sudoer}/luckfox-pico/output/image/   
  
  # Remove files in the destination that are no longer in the source repository
  while read -r file; do
      src_file="$SOURCE_DIR/$file"
      dest_file="$DEST_DIR/$file"

      if [ ! -f "$src_file" ] && [ -f "$dest_file" ]; then
          echo "Deleting $dest_file as it is no longer in the git repository."
          rm -f "$dest_file"
      fi
  done < /tmp/source_files.txt

  # Clean up
  rm /tmp/source_files.txt

  echo "Synchronization complete."  
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

inject_chroot() {
  chroot_script=${CHROOT_SCRIPT:-/home/${sudoer}/femtofox.chroot}
  if [[ ! -f $chroot_script ]]; then
    echo "Error: Chroot script $chroot_script not found."
    exit 1
  fi

  cp "$chroot_script" /home/${sudoer}/luckfox-pico/sysdrv/out/rootfs_uclibc_rv1106/tmp/chroot_script.sh
  chmod +x /home/${sudoer}/luckfox-pico/sysdrv/out/rootfs_uclibc_rv1106/tmp/chroot_script.sh

  echo "Press any key to continue entering chroot..."
  read -n 1 -s -r

  echo "Entering chroot and running commands..."

  mount --bind /proc /home/${sudoer}/luckfox-pico/sysdrv/out/rootfs_uclibc_rv1106/proc
  mount --bind /sys /home/${sudoer}/luckfox-pico/sysdrv/out/rootfs_uclibc_rv1106/sys
  mount --bind /dev /home/${sudoer}/luckfox-pico/sysdrv/out/rootfs_uclibc_rv1106/dev
  mount --bind /dev/pts /home/${sudoer}/luckfox-pico/sysdrv/out/rootfs_uclibc_rv1106/dev/pts
  chroot /home/${sudoer}/luckfox-pico/sysdrv/out/rootfs_uclibc_rv1106 /tmp/chroot_script.sh
  umount /home/${sudoer}/luckfox-pico/sysdrv/out/rootfs_uclibc_rv1106/dev/pts
  umount /home/${sudoer}/luckfox-pico/sysdrv/out/rootfs_uclibc_rv1106/proc
  umount /home/${sudoer}/luckfox-pico/sysdrv/out/rootfs_uclibc_rv1106/sys
  umount /home/${sudoer}/luckfox-pico/sysdrv/out/rootfs_uclibc_rv1106/dev
  rm /home/${sudoer}/luckfox-pico/sysdrv/out/rootfs_uclibc_rv1106/tmp/chroot_script.sh
  build_rootfs
  build_firmware
  create_image
}


update_image() {
  echo "Updating repo..."
  cd /home/${sudoer}/femtofox
  git pull
  cd /home/${sudoer}/
  sync_foxbuntu_changes
  build_kernelconfig
  build_rootfs
  build_firmware
  create_image
}

install_rootfs() {
  echo "Modifying rootfs..."
  cd /home/${sudoer}/luckfox-pico/output/image
  echo "Copying kernel modules..."
  mkdir -p /home/${sudoer}/luckfox-pico/sysdrv/out/rootfs_uclibc_rv1106/lib/modules/5.10.160
  cp /home/${sudoer}/luckfox-pico/sysdrv/out/kernel_drv_ko/* /home/${sudoer}/luckfox-pico/sysdrv/out/rootfs_uclibc_rv1106/lib/modules/5.10.160/
  which qemu-arm-static

  chroot_script=${CHROOT_SCRIPT:-/home/${sudoer}/femtofox.chroot}
  if [[ ! -f $chroot_script ]]; then
    echo "Error: Chroot script $chroot_script not found."
    exit 1
  fi

  cp "$chroot_script" /home/${sudoer}/luckfox-pico/sysdrv/out/rootfs_uclibc_rv1106/tmp/chroot_script.sh
  chmod +x /home/${sudoer}/luckfox-pico/sysdrv/out/rootfs_uclibc_rv1106/tmp/chroot_script.sh

  echo "Entering chroot and running commands..."
  cp /usr/bin/qemu-arm-static /home/${sudoer}/luckfox-pico/sysdrv/out/rootfs_uclibc_rv1106/usr/bin/
  mount --bind /proc /home/${sudoer}/luckfox-pico/sysdrv/out/rootfs_uclibc_rv1106/proc
  mount --bind /sys /home/${sudoer}/luckfox-pico/sysdrv/out/rootfs_uclibc_rv1106/sys
  mount --bind /dev /home/${sudoer}/luckfox-pico/sysdrv/out/rootfs_uclibc_rv1106/dev
  mount --bind /dev/pts /home/${sudoer}/luckfox-pico/sysdrv/out/rootfs_uclibc_rv1106/dev/pts

  chroot /home/${sudoer}/luckfox-pico/sysdrv/out/rootfs_uclibc_rv1106 /tmp/chroot_script.sh

  umount /home/${sudoer}/luckfox-pico/sysdrv/out/rootfs_uclibc_rv1106/dev/pts
  umount /home/${sudoer}/luckfox-pico/sysdrv/out/rootfs_uclibc_rv1106/proc
  umount /home/${sudoer}/luckfox-pico/sysdrv/out/rootfs_uclibc_rv1106/sys
  umount /home/${sudoer}/luckfox-pico/sysdrv/out/rootfs_uclibc_rv1106/dev

  rm /home/${sudoer}/luckfox-pico/sysdrv/out/rootfs_uclibc_rv1106/tmp/chroot_script.sh
}

create_image() {
  echo "Creating final sdcard img..."
  cd /home/${sudoer}/luckfox-pico/output/image

  # File to modify
  ENVFILE=".env.txt"

  # Check if the file contains '6G(rootfs)'
  if grep -q '6G(rootfs)' "$ENVFILE"; then
      # Replace '6G(rootfs)' with '100G(rootfs)'
      sed -i 's/6G(rootfs)/100G(rootfs)/' "$ENVFILE"
      echo "Updated rootfs size from stock (6G) to 100G."
  else
      echo "No changes made to rootfs size because it has already been modified."
  fi

  /home/${sudoer}/luckfox-pico/sysdrv/tools/pc/uboot_tools/mkenvimage -s 0x8000 -p 0x0 -o env.img .env.txt

  /home/${sudoer}/luckfox-pico/output/image/blkenvflash /home/${sudoer}/luckfox-pico/foxbuntu.img
  if [[ $? -eq 2 ]]; then echo "Error, sdcard img failed to build..."; exit 2; else echo "foxbuntu.img build completed."; fi
  ls -la /home/${sudoer}/luckfox-pico/foxbuntu.img
  du -h /home/${sudoer}/luckfox-pico/foxbuntu.img
}

sdk_install() {
  echo "Installing Foxbuntu SDK Disk Image Builder..."
  # get the luckfox build environment
  if [ -d /home/${sudoer}/femtofox ]; then
      echo "WARNING: ~/femtofox exists, this script will DESTROY and recreate it."
      echo "Press Ctrl+C to cancel, or Enter to continue."
      read
      rm -rf /home/${sudoer}//femtofox
  fi
  if [ -d /home/${sudoer}/luckfox-pico ]; then
      echo "WARNING: ~/luckfox-pico exists, this script will DESTROY and recreate it."
      echo "Press Ctrl+C to cancel, or Enter to continue."
      read
      rm -rf /home/${sudoer}/luckfox-pico
  fi

  start_time=$(date +%s)
  install_prerequisites

  clone_repos || {
    echo "Failed to clone repositories. Exiting SDK installation."
    return 1
  }

  build_env
  build_uboot
  sync_foxbuntu_changes
  build_kernelconfig
  build_rootfs
  rsync -aHAXv --progress --keep-dirlinks --itemize-changes /home/${sudoer}/femtofox/foxbuntu/sysdrv/out/rootfs_uclibc_rv1106/ /home/${sudoer}/luckfox-pico/sysdrv/out/rootfs_uclibc_rv1106/
  build_firmware
  install_rootfs
  build_rootfs
  build_firmware
  create_image
  end_time=$(date +%s)
  elapsed=$(( end_time - start_time ))
  hours=$(( elapsed / 3600 ))
  minutes=$(( (elapsed % 3600) / 60 ))
  seconds=$(( elapsed % 60 ))
  printf "Environment installation time: %02d:%02d:%02d\\n" $hours $minutes $seconds
}

usage() {
  echo "The following functions are available in this script:"
  echo "To install the development environment use the arg 'sdk_install' and is intended to be run ONCE only."
  echo "To modify the chroot and build an updated image use the arg 'modify_chroot'."
  echo "To modify the kernel and build an updated image use the arg 'modify_kernel'."
  echo "other args: build_env sync_foxbuntu_changes build_kernelconfig install_rootfs build_rootfs build_uboot build_firmware create_image"
  echo "Example:  sudo ~/foxbunto_env_setup.sh sdk_install"
  echo "Example:  sudo ~/foxbunto_env_setup.sh modify_chroot"
  exit 0
}
################### MENU SYSTEM ###################

if [[ "${1}" =~ ^(-h|--help|h|help)$ ]]; then
  usage
elif [[ -z ${1} ]]; then
  if ! command -v dialog &> /dev/null; then
    echo "The 'dialog' package is required to load the menu."
    echo "Please install it using: sudo apt install dialog"
    exit 1
  fi
  while true; do
    CHOICE=$(dialog --clear --no-cancel --backtitle "Foxbuntu SDK Builder" \
      --title "Main Menu" \
      --menu "Choose an action:" 20 60 12 \
      1 "Get Image Updates" \
      2 "Modify Kernel Menu" \
      3 "Enter and Modify Chroot" \
      4 "Inject Chroot Script" \
      5 "Manual Build Environment" \
      6 "Manual Build U-Boot" \
      7 "Manual Build RootFS" \
      8 "Manual Build Firmware" \
      9 "Manual Create Final Image" \
      "" "" \
      10 "SDK Install (Run this first.)" \
      "" "" \
      11 "Exit" \
      2>&1 >/dev/tty)

    clear

    case $CHOICE in
      1) update_image ;;
      2) modify_kernel ;;
      3) modify_chroot ;;
      4) inject_chroot ;;
      5) build_env ;;
      6) build_uboot ;;
      7) build_rootfs ;;
      8) build_firmware ;;
      9) create_image ;;
      10) sdk_install ;;
      11) echo "Exiting..."; break ;;
      *) echo "Invalid option, please try again." ;;
    esac

    # Pause after executing a command
    echo "Menu selection completed. Press any key to return to the menu."
    read -n 1 -s -r
  done
else
  if [[ "${1}" == "--chroot-script" ]]; then
    CHROOT_SCRIPT=${2}
  fi
  if declare -f "${1}" > /dev/null; then
    "${1}"
  else
    echo "Error: Function '${1}' not found."
    usage
    exit 1
  fi
fi

exit 0
