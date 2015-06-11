#!/bin/bash
# Packages the Edison Ethernet Ubilinux rootfs for flashing

SCRIPT_DIR=$(dirname $0)
DEBIANFS="$SCRIPT_DIR/edison-debian-image/edison-image-edison-ext4/"
YOCTOFS="$SCRIPT_DIR/edison-yocto-image/edison-image-edison/ext4/"

DEBIAN=1
YOCTO=0

DEBIAN_DD_COUNT=3145728
YOCTO_DD_COUNT=1048576

MOUNT_DIR="$SCRIPT_DIR/tmp/mnt"
EDISON_EXT4="$SCRIPT_DIR/toFlash/edison-image-edison.ext4"

LOG_FILE="$SCRIPT_DIR/package.log"

function usage() {
   echo
   echo "usage: package.sh <debian|yocto>"
   echo
}

function create_package() {
   DISTRO=$1
   DD_COUNT=$2
   ROOTFS=$3

   echo "********** package.sh **********" > "$LOG_FILE"
   echo "Distro: $DISTRO" >> "$LOG_FILE"
   echo "" >> "$LOG_FILE"
   echo "" >> "$LOG_FILE"

   # Make a tmp directory to mount to
   mkdir -p "$MOUNT_DIR"

   echo
   echo "Creating $DISTRO Image..."

   # Create a 1610MB image, with 512 Block size
   dd if=/dev/zero of="$EDISON_EXT4" bs=512 count="$DD_COUNT" >> "$LOG_FILE"

   # Format as ext4 with
   mke2fs -F -t ext4 "$EDISON_EXT4" >> "$LOG_FILE"

   # Mount the image
   mount -t ext4 -o loop "$EDISON_EXT4" "$MOUNT_DIR" >> "$LOG_FILE"

   echo "Copying rootfs files from repo..."

   # Copy the files from the repo to the mounted image
   cp -rf $ROOTFS/* $MOUNT_DIR/ >> "$LOG_FILE" 2>&1

   # Remove .gitignores
   find "$MOUNT_DIR" -type f -name '.gitignore' -delete >> "$LOG_FILE"

   # Make sure perms are good (these don't matter too much -- they will be re-generated on first-install)
   chmod 0600 $MOUNT_DIR/etc/ssh/ssh_host_dsa_key $MOUNT_DIR/etc/ssh/ssh_host_ecdsa_key $MOUNT_DIR/etc/ssh/ssh_host_rsa_key

   # unmount
   umount "$MOUNT_DIR" >> "$LOG_FILE"

   echo "Done."
}

function debian_package() {
   create_package "Ubilinux/Debian" $DEBIAN_DD_COUNT $DEBIANFS
}

function yocto_package() {
   create_package "Yocto" $YOCTO_DD_COUNT $YOCTOFS
}

if [[ "x$1" == "x" || "x$1" == "x-h" || "x$1" == "x--help" ]];
then
   usage
   exit 1
fi

# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
   echo "ERR: his script must be run as root" 1>&2
   exit 1
fi

# Set the DEBIAN or YOCTO flags
shopt -s nocasematch
if [[ "$1" == "debian" ]];
then
   DEBIAN=1
   YOCTO=0
elif [[ "$1" == "yocto" ]];
then
   DEBIAN=0
   YOCTO=1
fi
shopt -u nocasematch

if [[ $DEBIAN -eq 1 ]];
then

   # Make sure that the rootfs exists in this dir
   if [[ ! $(ls -A "$DEBIANFS" 2>/dev/null) ]];
   then
      echo "ERR: Make sure that you have pulled the edison-debian-image Git submodule."
      echo
      exit 1
   fi

   debian_package

elif [[ $YOCTO -eq 1 ]];
then

   # Make sure that the rootfs exists in this dir
   if [[ ! $(ls -A "$YOCTOFS" 2>/dev/null) ]];
   then
      echo "ERR: Make sure that you have pulled the edison-yocto-image Git submodule."
      echo
      exit 1
   fi

   yocto_package

else

   echo "ERR: No distro defined to package."
   echo
   exit 1
fi

echo
echo "Package created. You may now run toFlash/flashall.sh (as sudo!)"
echo
