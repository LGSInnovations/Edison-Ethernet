Setting up the Network Interface for Yocto
==========================================

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

	**Known Issue:** For some reason, the Edison will not switch into USB Host mode except for every other reboot. Try doing a cold restart by unplugging and plugging power back in. (For more info, see [here](https://communities.intel.com/thread/57209?start=0&tstart=0))