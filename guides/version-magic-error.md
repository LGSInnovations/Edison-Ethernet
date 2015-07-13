Version Magic Error
===================

When building a kernel module, it is stampped with a version. The kernel employs a scheme called version magic to ensure that you are using the correct module version.

If the kernel version extensions are slightly different, the module will most likely work, you just have to rebuild the module with the correct target version.

Because Ubilinux and Yocto have different kernel version extensions, you will have to trick BitBake to create the correct module version. Below is a table with the Linux version and it's kernel version:

| Distro                           | Kernel Version            |
| :------------------------------- |:------------------------- |
| Release 2.1 Yocto complete image | 3.10.17-poky-edison+      |
| Release 2.1 Linux Source Files   | 3.10.17-yocto-standard    |
| Ubilinux "Wheezy", 150309        | 3.10.17-yocto-standard-r2 |

## Rebuilding the Right Version ##

To add a kernel module, you must build from source, using `bitbake linux-yocto -c menuconfig` to add in the necessary module.

You then have two options:
1. Flash your system with the new image, losing all your config.
2. Drop the kernel module into your existing system.

This guide will show you how to accomplish step 2, with the appropriate version. We will build for Ubilinux (`3.10.17-yocto-standard-r2`) in this example.

1. Edit the kernel recipe:

	```bash
	vi ~/edison-src/meta-intel-edison/meta-intel-edison-bsp/recipes-kernel/linux/linux-yocto_3.10.bbappend
	```

	Add the following:

	```bash
	LINUX_VERSION_EXTENSION = "-yocto-standard-r2"
	```

	This will overwrite the `CONFIG_LOCALVERSION=` inside of the kernel's `.config` file.

2. Change directories to the root of the source:
	
	```bash
	cd ~/edison-src/
	```
3. Run the make command:

	```bash
	make
	```

	This is important because bitbaking this way will clean up the bitbake configuration and will bitbake the modules/kernel with the version change. If you just run bitbake like normal, it won't see the version change and won't do anything.

4. Copy the module to your home directory:

	```bash
	cd ~/edison-src/out/current/build/tmp/work/edison-poky-linux/edison-image/1.0-r0/rootfs/lib/modules/
	```

	Now that you are here, do an `ls` to check the kernel version. It should be '*-yocto-standard-r2'

	```bash
	$ ls
	3.10.17-yocto-standard-r2
	```

	Copy the new module to your home directory (it might be nice to append the module name with the version):

	```bash
	cp 3.10.17-yocto-standard-r2/kernel/drivers/net/usb/smsc95xx.ko ~/smsc95xx.ko.3.10.17-yocto-standard-r2
	```

5. Follow the module installation instructions [here](installation.md).

--------------------------------------------------------------------

If you get this error message after dropping in your module, this means that you don't have the versions synced up correctly. Try carefully running through the steps in this guide again.

```bash
# insmod smsc95xx.ko
[  145.429168] smsc95xx: version magic '3.10.17-yocto-standard SMP preemt mod_unload ATOM ' should be '3.10.17-yocto-standard-rw SMP preemt mod_unload ATOM '
Error: could not insert module smsc95xx.ko: Invalid module format
# uname -r
3.10.17-yocto-standard-r2
```