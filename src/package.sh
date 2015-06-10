#!/bin/bash
# Packages the Edison Ethernet Ubilinux rootfs for flashing by doing the following:
#
# 	1. Make sure that you are using sudo!
# 	2. clone the edison-${dist}-image git repo
#	3. create an `edison-image-edison.ext4` image
#	4. mount the `edison-image-edison.ext4` image
#	5. copy the rootfs from the local repo
#	6. umount the image
#	7. 


# find . -type f -name '.gitignore' -delete

# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi