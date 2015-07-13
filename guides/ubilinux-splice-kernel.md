Using the Customized Yocto Kernel in Ubilinux
=============================================

After having BitBaked the Yocto Kernel with SMSC LAN95XX driver support for the Ethernet block, you can take the Yocto kernel and its modules and splice them into the Ubilinux distro.

This allows you to use the LAN9512 Ethernet block with a Debian-based Linux distro, with better support for installing packages.

1. Download the Ubilinux distro from [here](http://www.emutexlabs.com/ubilinux). Choose the Intel Edison.
	- Alternatively, run `wget http://www.emutexlabs.com/files/ubilinux/ubilinux-edison-150309.tar.gz` on your Linux host machine.

2. Extract the archive with:
	
	```bash
	tar xvf ~/ubilinux-edison-150309.tar.gz
	cd ubilinux-150309/toFlash
	```

3. The Edison kernel is in `edison-image-edison.hddimg`, the filesystem is in `edison-image-edison.ext4`. Move the kernel (`*.hddimg`) out of the directory:

	```bash
	mv edison-image-edison.hddimg ../edison-image-edison.hddimg.ubi
	```

4. Copy the Yocto Edison kernel to here:

	```bash
	cp ~/edison-src/out/current/build/toFlash/edison-image-edison.hddimg .
	```

5. Next, you will need to mount the Ubilinux filesystem and replace its kernel modules with the Yocto kernel modules:

	```bash
	sudo mkdir /mnt/ubi
	sudo mount edison-image-edison.ext4 /mnt/ubi
	sudo rm -rf /mnt/ubi/lib/modules/3.10.17-yocto-standard-r2
	sudo cp -r ~/edison-src/out/current/build/tmp/work/edison-poky-linux/edison-image/1.0-r0/rootfs/lib/modules/* /mnt/ubi/lib/modules/
	sudo umount /mnt/ubi
	```
6. Now that you've copied the Yocto kernel and its modules, you can flash your Edison as follows:

	```bash
	cd ~/ubilinux-150309/toFlash
	sudo ./flashall.sh
	```

	And then plug your Edison in via the OTG port of the SparkFun base-board.

7. When booting on the Edison, make sure that all the kernel modules got loaded (there are about 5 of them), otherwise `lsmod` will return no modules, and `lsusb` will return `-99`. Note that thedefault password for the _root_ account is "edison."
