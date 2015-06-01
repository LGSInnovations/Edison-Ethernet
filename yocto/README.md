Customizing the Yocto Kernel
============================

This tutorial is to help build the full yocto kernel for the Intel Edison.  It is largely based on work done by
[Shawn Hymel](http://shawnhymel.com/585/creating-a-custom-linux-kernel-for-the-edison/)

This step-by-step assumes you are on some newer version of Ubuntu, preferably 14.04 forward with access to the
internet and access to apt repositories.

Setup your environment:
```bash
sudo apt-get install build-essential git diffstat gawk chrpath texinfo libtool gcc-multilib libsdl1.2-dev
sudo apt-get install libqt4-core:i386 ligqt4-gui:i386
```

Setup git (if not already setup):
```bash
git config --global user.email "you@example.com"
git config --global user.name "Your Name"
```

1. Get the file at: http://downloadmirror.intel.com/24910/eng/edison-src-ww18-15.tgz
	a. At a shell execute:  `wget http://downloadmirror.intel.com/24910/eng/edison-src-ww18-15.tgz`
	b. You can also find the file at: https://downloadcenter.intel.com/SearchResult.aspx?lang=eng&keyword=edison
	c. The file will likely be called `edison-src-ww18-15.tgz`

2. Once the file is downloaded extract the contents to your preferred workspace.
```bash
cd ~
tar xvzf edison-src-ww18-15.tgz
```

3. Go into the directory
```bash
--> cd ~/edison-src
```

Inside ~/edison-src should have a structure of:
```bash
you@yourcomputer$ ll
Makefile -> meta-intel-edison/utils/Makefile.mk
meta-intel-edison/
```

4. Setup the build tree by pulling source from remote repos
```bash
make setup
```

Inside ~/edison-src should now have a structure of:
```bash
you@yourcomputer$ ll
bbcache
Makefile -> meta-intel-edison/utils/Makefile.mk
meta-intel-edison/
out/
pub/
```

5. source the shell environment [note this is for 64-bit linux builds!]
```bash
cd ~/edison-src/out/linux64
source poky/oe-init-build-env
```

*Some systems (mostly those behind a firewall) will have problems fetching some packages.  They are on the github repo.  Download the directory and move the files to edison-src/bbcache/downloads.  Make sure to return to the right directory before baking your bits.*

An example might be:
```bash
cp ~/Downloads/Edison-Ethernet/packages/* ~/edison-src/bbcache/downloads/
```
**NOTE**: Remove the README

6) bitbake your shiny new edison image.  This could take hours the first time.
```bash
bitbake edison-image
```

Alternatively, use the makefile by simply typing (in the `edison-src` dir):
```bash
make
```


7) Configure the kernel with your new feature
```bash
bitbake linux-yocto -c menuconfig
```

8) use the menuconfig to add the LAN9512 that you need, or copy the .config file from the github repo.
If using the menuconfig you can navigate to the below <ESC> <ESC> goes back, <ENTER> goes forward, <SPACE>
selects.

Device Drivers --->
	[*] Network Device Support --->
		USB Network Adapters --->
			< >SMSC LAN95XX based USB 2.0 10/100 ethernet devices
		
Press <<space>> until you see a <*> for the SMSC LAN95XX. Save the configuration.

BTW, while you're in there you can add I2C support:
Device Drivers --->
	-*- I2C support --->
		I2C Hardware Bus support --->
			[ ] PMIC I2C Adapter

Press <<space>> until you see a <*> for the PMIC I2C Adapter. Save the configuration.

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

12) The edison kernel is in edison-image-edison.hddimg

13) If using ubilinux download their setup from: http://www.emutexlabs.com/ubilinux
--> Pick the ubilinux for Intel Edison or
--> wget http://www.emutexlabs.com/files/ubilinux/ubilinux-edison-150309.tar.gz
