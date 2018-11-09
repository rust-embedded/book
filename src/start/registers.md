# Memory-mapped Registers







Going back to our home computer example, our I/O controller needs to operate
in the same fashion as the RAM, as it sits on the same bus. Here though,
instead of having a full 64 Ki (65,536) addressable locations, it might only
have three or four addressable locations. These locations are known as
*memory-mapped registers*. By writing data to these registers, the processor
can affect the operation of the hardware. What happens when you do this is
entirely down to the design of the peripheral. For example, on an I/O
peripheral, each bit of one register might correspond to the output level of an
I/O pin allowing us to turn on some LEDs, while some other register might
allow us to set whether each pin is an Input pin or an Output pin. On a UART
peripheral, we might instead expect to see one register which lets us set the
baud rate of our serial connection, one for data we wish to send over the
serial connection and another which lets us read any buffered data that has
been received.

