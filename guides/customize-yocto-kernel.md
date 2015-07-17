Customizing the Yocto Kernel
============================

This tutorial is to help build the full Yocto Kernel for the Intel Edison.  It is largely based on work done by [Shawn Hymel](http://shawnhymel.com/585/creating-a-custom-linux-kernel-for-the-edison/).

This step-by-step assumes you are on some newer version of Ubuntu as the host machine, preferably 14.04 forward with access to the internet and access to apt repositories.

**Note:** The build part of this tutorial can take up to 4 hours.

##Setting Up Your Environment##

1. Install Dependencies:
	```bash
	sudo apt-get install build-essential git diffstat gawk chrpath texinfo libtool gcc-multilib libsdl1.2-dev dfu-util libqt4-core:i386 libqt4-gui:i386
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
	**NOTE**: Remove the README (`rm ~/edison-src/bbcache/downloads/README`)

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
		 make image
		 ```

		 **NOTE**: If your bitbake fails, (possibly with `swig-3.0.5` not being found) just run `make image` again, and it will start from there.

After a number of hours (e.g., 4 or 5) come back to configure the kernel.

----------------------------------------------------------------------

##Configuring the Kernel##

1. Configure the kernel with your new feature (this may take some time):
	```bash
	source ~/edison-src/out/linux64/poky/oe-init-build-env
	bitbake linux-yocto -c menuconfig
	```

2. Use the `menuconfig` to add the LAN9512 that you need, or copy the `.config` file from this repo. If using the `menuconfig` you can navigate to the below <kbd>esc</kbd> <kbd>esc</kbd> goes back, <kbd>enter</kbd> goes forward, <kbd>space</kbd> selects.

	```
	Device Drivers --->
		[*] Network Device Support --->
			USB Network Adapters --->
				< >SMSC LAN95XX based USB 2.0 10/100 ethernet devices
	```
		
 	Press <kbd>space</kbd> until you see a <*> for the SMSC LAN95XX. Save the configuration.

	Also, while you're in there you can add I2C support:
	```
	Device Drivers --->
		-*- I2C support --->
			I2C Hardware Bus support --->
				[ ] PMIC I2C Adapter
	```

	Press <kbd>space</kbd> until you see a <*> for the PMIC I2C Adapter. Save the configuration.

	Exit out.
	```bash
	cp edison-src/out/linux64/build/tmp/work/edison-poky-linux/linux-yocto/3.10.17+gitAUTO*/linux-edison-standard-build/.config \\
	edison-src/meta-intel-edison/meta-intel-edison-bsp/recipes-kernel/linux/files/defconfig
	```
	
3. Bake your Edison again, either using `make` or `bitbake` as above.
	```
	cd ~/edison-src
	make
	```

	or

	```bash
	cd ~/edison-src/out/linux64
	source poky/oe-init-build-env
	bitbake edison-image
	```

4. Run the `postBuild.sh` script to clean up the `toFlash` directory as follows:

	```bash
	~/edison-src/meta-intel-edison/utils/flash/postBuild.sh ~/edison-src/out/linux64/build
	```

	Alternatively, you can use your favorite text editor to edit `postBuild.sh` to the following:
	```bash
	line 9: build_dir=$top_repo_dir/out/linux64/build
	```

	And then execute the `postBuild.sh` script without the build directory argument:
	```bash
	~/edison-src/meta-intel-edison/utils/flash/postBuild.sh
	```

5. Your files will be ready in `~/edison-src/out/linux64/build/toFlash`.

6. You may now either flash your Edison with Yocto and follow the Yocto Network Interface setup, or you can use the Yocto kernel in the Ubilinux distro to give yourself a more fleshed out Linux distro with `apt-get`.

7. Flashing your Edison with Yocto:
	
	```bash
	sudo ~/edison-src/out/linux64/build/toFlash/flashall.sh
	```

	And then plug your Edison in via the OTG port of the SparkFun base-board.