Customizing the Yocto Kernel
============================

This tutorial is to help build the full Yocto Kernel for the Intel Edison.  It is largely based on work done by [Shawn Hymel](http://shawnhymel.com/585/creating-a-custom-linux-kernel-for-the-edison/).

This step-by-step assumes you are on some newer version of Ubuntu as the host machine, preferably 14.04 forward with access to the internet and access to apt repositories.

**Note:** The build part of this tutorial can take up to 4 hours.

##Setting Up Your Environment##

1. Install Dependencies:
	```bash
	sudo apt-get install build-essential git diffstat gawk chrpath texinfo libtool gcc-multilib libsdl1.2-dev dfutils libqt4-core:i386 ligqt4-gui:i386
	```

2. Setup git (if not already setup):
	```bash
	git config --global user.email "you@example.com"
	git config --global user.name "Your Name"
	```

##Building the Yocto Kernel:##

1. Get the file at: http://downloadmirror.intel.com/24910/eng/edison-src-ww18-15.tgz
	- At a shell execute:  `wget http://downloadmirror.intel.com/24910/eng/edison-src-ww18-15.tgz` in your home folder.
	- You can also find the file at: https://downloadcenter.intel.com/SearchResult.aspx?lang=eng&keyword=edison
	- The file will likely be called `edison-src-ww18-15.tgz`

2. Once the file is downloaded extract the contents to your preferred workspace.
	```bash
	cd ~
	tar xvzf edison-src-ww18-15.tgz
	```

3. Go into the directory `~/edison-src`:
	```bash
	cd ~/edison-src
	```

 It should have a structure of:
	```bash
	.
	+-- Makefile -> meta-intel-edison/utils/Makefile.mk
	+-- meta-intel-edison/
	```

4. Setup the build tree by pulling source from remote repos
	```bash
	make setup
	```

 Now, `~/edison-src` should now have a structure of:
	```bash
	.
	+-- bbcache/
	+-- Makefile -> meta-intel-edison/utils/Makefile.mk
	+-- meta-intel-edison/
	+-- out/
	+-- pub/
	```

 *5. Some systems (mostly those behind a firewall) will have problems fetching some packages.  They are on in this repo at `Edison-Ethernet/packages/`.  Download the directory and move the files to `~/edison-src/bbcache/downloads`.*

 An example of downloading these packages from the repo might be:
	```bash
	cp ~/Edison-Ethernet/packages/* ~/edison-src/bbcache/downloads/
	```
	**NOTE**: Remove the README (`rm ~/edison-src/README`)

6. bitbake your shiny new edison image.  **This could take hours the first time.** This can be done in two ways:
	1. Sourcing the shell environment and then running `bitbake`.

		 ```bash
		 cd ~/edison-src/out/linux64
		 source poky/oe-init-build-env
		 ```
		 This will automatically put you in the `~/edison-src/build` directory. Then run:
		 ```bash
		 bitbake edison-image
		 ```
	2. Using the Makefile. *(make sure you are in the `~/edison-src` directory).*

		 **Option 2:** 
		 ```bash
		 make
		 ```

After a number of hours (e.g., 4) come back to configure the kernel.

----------------------------------------------------------------------

##Configuring the Kernel##

1. Configure the kernel with your new feature:
	```bash
	bitbake linux-yocto -c menuconfig
	```

2. Use the `menuconfig` to add the LAN9512 that you need, or copy the `.config` file from this repo. If using the `menuconfig` you can navigate to the below <kbd>esc</kbd><kbd>esc</kdb> goes back, <kbd>enter</kbd> goes forward, <kbd>space</kbd> selects.

Device Drivers --->
	[*] Network Device Support --->
		USB Network Adapters --->
			< >SMSC LAN95XX based USB 2.0 10/100 ethernet devices
		
Press <kbd>space</kbd> until you see a <*> for the SMSC LAN95XX. Save the configuration.

BTW, while you're in there you can add I2C support:
Device Drivers --->
	-*- I2C support --->
		I2C Hardware Bus support --->
			[ ] PMIC I2C Adapter

Press <kbd>space</kbd> until you see a <*> for the PMIC I2C Adapter. Save the configuration.

Exit out.
```bash
cp edison-src/out/linux64/build/tmp/work/edison-poky-linux/linux-yocto/3.10.17+gitAUTO*/linux-edison-standard-build/.config \\
	edison-src/meta-intel-edison/meta-intel-edison-bsp/recipes-kernel/linux/files/defconfig
```
	
9) bake your edison again
```bash
cd ~/edison-src/out/linux64
source poky/oe-init-build-env
bitbake edison-image
```

10) use your favorite text editor to edit postBuild.sh to the following:

`line 9: build_dir=$top_repo_dir/out/linux64/build`

or

execute the existing postBuild.sh with an argument that is the full path to the build dir

`edison-src/meta-intel-edison/utils/flash/postBuild.sh edison-src/out/linux64/build`

11) Your files will be ready in `edison-src/out/linux64/build/toFlash`

12) The edison kernel is in `edison-image-edison.hddimg`

13) If using ubilinux download their setup from: http://www.emutexlabs.com/ubilinux
--> Pick the ubilinux for Intel Edison or
--> wget http://www.emutexlabs.com/files/ubilinux/ubilinux-edison-150309.tar.gz

14) Replace the `edison-image-edison.hddimg` from the ubilinux distribution with your new kernel, or you can mount the kernel with
```bash
mkdir /tmp/hddimg
mount /path/to/edison-image-edison.hddimg
```
Once mounted, you can change whatever files you need to.  Typically `vmlinuz` and `ldlinux.sys`.

-----------------------------------------------------------------------

##Setting up the Network Interface for Yocto##

This walks through assigning your LAN9512 an IP address and enabling ssh.

Follow these steps after `screen`'ing into your Edison from your host Linux machine, as described [here](https://software.intel.com/en-us/setting-up-serial-terminal-on-system-with-linux) (i.e., `sudo screen /dev/ttyUSB0 115200`).

1. Create an interfaces file for use with `ifup` and `ifconfig`. For a brief description of the `ifup` command, see [here](http://www.computerhope.com/unix/ifup.htm) or the man page.
	1. Create the `/etc/network` directory: `mkdir /etc/network`.
	2. Create the `/etc/network/interfaces` file: `touch /etc/network/interfaces`.
2. Find the name of the LAN9512 adapter. A very simple way is to use the `ifconfig` command with the `-a` flag to show all connected and disconnected interfaces. With the LAN9512 disconnected, run `ifconfig -a`. Then, connect the adapter and run `ifconfig -a` again. Note the name of the newly added interface. Mine was `enp0s17u1u1`.
	- For extra information, use the `dmesg` tool to view the kernel log and verify that the kernel found the device. You can run `dmesg | grep -i network` to find when the kernel recognized the network device, and when it gave it a name.
3. Edit the `/etc/network/interfaces` file and add the configuration: `vi /etc/network/interfaces`

	Add the following: *(be sure to double check the interface name)*
	```bash
	auto enp0s17u1u1
	iface enp0s17u1u1 inet dhcp
	```
4. Bring the network interface up with `ifup` and the interface name. Ignore any errors from `run-parts` about directories not existing.

	Run: `ifup enp0s17u1u1`
	This should tell you something about discovering the network interface and assigning it an IP address (using DHCP).

5. You can now test that your card is setup properly by running `ping xx.xx.xx.xx` on the Edison's IP address from your host Linux machine.

6. You must now either run `edison_configure --setup` but do not enable wifi. You will be asked to give a root password and name your Edison. If you do not provide a root password, you will have to edit the `/lib/systemd/system/sshd.socket` file, as shown below:

	*Allowing ssh without a root password:*
	```bash
	vi /lib/systemd/system/sshd.socket
	```

	In this file, comment out the line: `BindToDevice=usb0` using a `#`.

	Then reboot by running: `reboot`.

	(more info [here](https://communities.intel.com/message/254323#254323)).

7. You should now be able to ssh into your Edison!

	*Bonus:* Running `edison_configure` sets up your Edison to broadcast it's hostname, so instead of ssh'ing into your Edison's IP address, try using `<your hostname>.local`, e.g., `edison.local`
