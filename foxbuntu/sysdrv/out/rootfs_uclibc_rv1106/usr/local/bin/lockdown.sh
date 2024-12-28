# this script is intended to be called via exernal methods such as usb or network

#disable ssh
systemctl stop sshd
systemctl disable sshd

#disable telnet
systemctl stop telnetd
systemctl disable telnetd

#disable ftp
systemctl stop vsftpd

#disable http
systemctl stop avahi-daemon


