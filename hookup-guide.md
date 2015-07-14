Hookup Guide for LAN9512 Ethernet block
=======================================

##Plug in the Board##
Once you have [installed support for the SMSC LAN9512](https://github.com/LGSInnovations/Edison-Ethernet/blob/master/README.md) on your Intel Edison, you may connect the Edison blocks together. While connecting and using the hardware, keep the following points in mind: 
* When operating properly, the "Full-Duplex" LED on the Ethernet block will be illuminated. 
* Blocks can be stacked without any sort of mounting hardware. However, this can cause undue mechanical stress on the connectors. To alleviate this, use hardware such as that found in the [Sparkfun Edison Hardware Pack](https://www.sparkfun.com/products/13187) to securely mount your Edison blocks.
* The SMSC LAN9512 communicates with the Intel Edison over USB-OTG. Do not connect any other blocks that use the Intel Edison's USB-OTG capability. Disconnect the Ethernet block when flashing your Edison's firmware. 
* The Ethernet block cannot power the Edison. A power source such as the [Sparkfun Base Block](https://www.sparkfun.com/products/13045) in your block stack is required. 
* If an overcurrent condition is detected in a device connected to the downstream USB port on the Ethernet Block, the port will be shut down. Usually, the port will reset itself after a few seconds. In some circumstances, you may need to completely power-down the Ethernet Block and re-apply power to reset the port. 
* Version 1.0 of the Ethernet block is too wide to accomodate a USB cable plugged into a board such as the Sparkfun Base Block if the Base Block and the Ethernet Block are right next to each other in your block stack. To remedy this, connect a block with no external connectors (such as an empty [Sparkfun GPIO block](https://www.sparkfun.com/products/13038)) between the Base Block and the Ethernet Block. 
* Version 1.0 of the Ethernet Block operates close to the maximum current supply capacity of the 3.3V rails of the Intel Edison. Use caution when connecting blocks that use the 3.3V rails and power them with an external 3.3V supply if possible. 
