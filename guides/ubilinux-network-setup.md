Setting up the Network Interface for Ubilinux with Yocto Kernel
===============================================================

This will walk you through bringing the ethernet block up on the Edison.

Follow these steps after `screen`'ing into your Edison from your host Linux machine, as described [here](https://software.intel.com/en-us/setting-up-serial-terminal-on-system-with-linux) (i.e., `sudo screen /dev/ttyUSB0 115200`).

1. Login to the edison as `root` with password `edison`.

2. Verify that your Edison sees the `eth0` interface by doing `ifconfig -a`. In `screen`, you can scroll by doing: <kbd>Ctrl</kbd>-<kbd>a</kbd> <kbd>esc</kbd> and then using the up/down arrow keys.

3. Add the `eth0` interface to the `/etc/network/interfaces` file:

	```bash
	vi /etc/network/interfaces
	```

	And add this to the file:

	```bash
	auto eth0
	iface eth0 inet dhcp
	```

	To enable DHCP on `eth0`.

4. Bring up the Ethernet block with: `ifup eth0`.

5. Run `ifconfig` again to get the IP address for `eth0`. Use that IP address to SSH into your edison, without having to use `screen`.

**Known Issue:** For some reason, the Edison will not switch into USB Host mode after a warm reboot (i.e., after running `reboot`). You must start cold by unplugging the Edison and turning it back on again. (For more info, see [here](https://communities.intel.com/thread/57209?start=0&tstart=0))