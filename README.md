Edison Ethernet Block
=====================

This project gives the Intel Edison ethernet capibility in applications where wired connections are necessary or more reliable.

Currently, there are two common Linux distros used on the Intel Edison: Yocto Linux and Ubilinux. The Edison Ethernet project has support for both and is created from forking those distros.

## Distro Support ##

We currently support a Debian based distro, based on Ubilinux, and the Yocto distro. Both are built with the Yocto 3.10 kernel, bitbaked with driver support for the LAN9512/SMSC95xx USB-to-Ethernet chip.

#### Ubilinux/Debian ####

Popular for its familiar package manager (`apt-get`), this build has support for the Edison Ethernet block as well as support for MAC spoofing using a tool called [macchanger](https://github.com/alobbs/macchanger).

#### Yocto ####

This Linux distro is great for lightweight projects as it has a rootfs size of about 500MB. Although it has support for the Edison Ethernet block, it does not currently have easy support for MAC spoofing through macchanger.

## Installation and Setup ##

To start using the Edison Ethernet block, there are four options, increasing in time/difficulty:

1. Download the binary release of the `smsc95xx.ko` driver and add it to your kernel modules.
2. Download pre-packaged images of this project ready to flash with the smsc95xx.ko module baked in.
3. Clone the Edison-Ethernet git project to avoid using bitbake, but still allowing you flexibility to add/remove files from the rootfs. Build the debian or yocto image and then flash using `./flashall.sh`.
4. Build from source using `bitbake` and `menuconfig` and flash your device using `./flashall.sh`.

#### Option 1 - Binary Release ####

Download the release corresponding to your board. Extract the files.

Inside the release, there is a directory called `modules`. You'll find different kernel versions inside. To know which kernel module to install on your Edison, run `uname -r` and pick the corresponding directory inside the release. If your kernel version is not available, create an issue and we will release one for that version. You can also make your own by following [these](guides/version-magic-error.md) instructions.

Once you know which kernel version to use, follow [these](guides/installation.md) instructions to copy and install on your Edison.

#### Option 2 - Pre-packed Images ####

Download the release corresponding to your board. Extract the files.

Inside the release, there is a directory called `images`. You'll find two tarballs: `yocto.tar.gz` and `debian.tar.gz`. Extract your choice of distro and use `sudo ./flashall.sh` as normal.

#### Option 3 - Leverage This Project ####

See *Contributing to this Project* below.

#### Option 4 - Build from Source ####

Follow [these](guides) instructions. *Be aware that this will take at least 5+ hours.*

## Contributing to this Project ##

We use Git Submodules in our repo, if you've never used that tool before, make sure to read about it [here](https://git-scm.com/book/en/v2/Git-Tools-Submodules).


#### Development Environment ####

All developent must be on a Linux machine. Because of the naming convention of files in the decompressed rootfs of Linux, Mac OS and Windows will groan about invalid file names. We use [Ubuntu 14.04.02](http://releases.ubuntu.com/14.04/) for our host environment.

#### Getting the Source ####

Source code / files can be cloned as follows:

```bash
git clone --recursive https://github.com/LGSInnovations/Edison-Ethernet.git # The '--recursive' flag will also clone the submodules 
```

#### Packaging Your Changes ####

After you have changed things to your liking, use the `package.sh` script in `Edison-Ethernet/src/` to package your `edison-image-edison.ext4` rootfs so you can run `sudo ./flashall.sh`. Make sure that you have pulled in the latest changes in the `edison-debain-image` and/or `edison-yocto-image` submodules.