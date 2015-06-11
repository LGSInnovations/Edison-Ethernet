#!/bin/bash
# This script is meant to be run before the toFlash/flashall.sh script.
# It will set the MAC address of the Edison Ethernet board.

# trap ctrl-c and call ctrl_c()
trap ctrl_c INT

function ctrl_c() {
   echo
   echo
   exit 1;
}

# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

mkdir -p /tmp/ubieth-mnt
mount edison-image-edison.ext4 /tmp/ubieth-mnt > /dev/null 2>&1

while [[ ! "$mac" =~ ^([0-9A-Fa-f]{2}[:-]){5}([0-9a-fA-F]{2})$ ]];
do
   read -p 'Enter new valid MAC Address: ' mac
done

sed -i "s/__MAC_ADDRESS__/${mac}/" /tmp/ubieth-mnt/sbin/first-install.sh

umount /tmp/ubieth-mnt
rmdir /tmp/ubieth-mnt
