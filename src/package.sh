#!/bin/bash
# Packages the Edison Ethernet Ubilinux rootfs for flashing by doing the following:
#
#  1. Make sure that you are using sudo!
#  2. clone the edison-${dist}-image git repo
#  3. create an `edison-image-edison.ext4` image
#  4. mount the `edison-image-edison.ext4` image
#  5. copy the rootfs from the local repo
#  6. umount the image
#  7. 

SCRIPT_DIR=$(dirname $0)
DEBIANFS="$SCRIPT_DIR/edison-debian-image/edison-image-edison-ext4/"
YOCTOFS="$SCRIPT_DIR/edison-yocto-image/edison-image-edison/ext4/"

DEBIAN=1
YOCTO=0

MOUNT_DIR="$SCRIPT_DIR/tmp/mnt"
EDISON_EXT4="$SCRIPT_DIR/toFlash/edison-image-edison.ext4"
# find . -type f -name '.gitignore' -delete

function usage() {
   echo
   echo "usage: package.sh <debian|yocto>"
   echo
}

function debian_package() {
   mkdir -p "$MOUNT_DIR"

   # Create a 1610MB image, with 512 Block size
   dd if=/dev/zero of="$EDISON_EXT4" bs=512 count=3145728

   # Format as ext4 with
   mke2fs -F -t ext4 -i 512 "$EDISON_EXT4"

   # Mount the image
   mount -t ext4 -o loop "$EDISON_EXT4" "$MOUNT_DIR"

   # Copy the files from the repo to the mounted image
   cp -rf "${DEBIANFS}/*" "${MOUNT_DIR}/"

   # Remove .gitignores
   find "$MOUNT_DIR" -type f -name '.gitignore' -delete

   # unmount
   umount "$MOUNT_DIR"

}

function yocto_package() {
   mkdir -p "$SCRIPT_DIR/tmp/mnt"
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