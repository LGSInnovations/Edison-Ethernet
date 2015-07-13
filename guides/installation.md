Installing the smsc95xx.ko Module
=================================

These steps can be used after (1) downloading the release binaries, or (2) building your own modules from source.

## Getting the Module to the Edison ##

There are three possible ways to get the module onto the Edison, some better than others:

1. Use WiFi and `curl`
2. Use a USB drive.
3. Access the Edison's mass-storage. **[Yocto only!]**

#### Using WiFi ####

#### USB Drive ####

#### Edison's Mass-Storage [Yocto only!] ####

## Installing the Module on the Edison ##

Now that you have the module on the Edison, we need to install it so the kernel knows where to find it.

Use the following commands:

```bash
# Create a logical place to store it in the kernel dir
mkdir -p /lib/modules/$(uname -r)/kernel/drivers/net/usb

# Move the module to that directory
mv smsc95xx.ko /lib/modules/$(uname -r)/kernel/drivers/net/usb/

# Probe all modules to generate the modules.dep and map files
# This allows you to run `modprobe smsc95xx` from anywhere.
# This also allows the system to bring up the LAN chip on boot.
depmod -a

# Enable the driver
modprobe smsc95xx
```

You should now see the `smsc95xx` module in the `lsmod` list.

Similarly, running `lsusb` should show something like:

```bash
Bus 001 Device 003: ID 0424:ec00 Standard Microsystems Corp. SMSC9512/9514 Fast Ethernet Adapter
Bus 002 Device 001: ID 1d6b:0003 Linux Foundation 3.0 root hub
Bus 001 Device 002: ID 0424:9512 Standard Microsystems Corp. LAN9500 Ethernet 10/100 Adapter / SMSC9512/9514 Hub
Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
```

If the Ethernet is plugged in, you should see the Full-Duplex LED light up on the board.