Edison Ethernet Block
=====================

This project gives the Intel Edison ethernet capibility in applications where wired connections are necessary or more reliable.

Currently, there are two common Linux distros used on the Intel Edison: Yocto Linux and Ubilinux. The Edison Ethernet project has support for both and is created from forking those distros.

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