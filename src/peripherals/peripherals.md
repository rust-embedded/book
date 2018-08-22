# Peripherals

Most Microcontrollers have more than just a CPU and RAM, they also come with a bunch of stuff called Peripherals which are useful for interacting with other hardware, like sensors, bluetooth radios, screens, or touch pads. These peripherals are great because you can offload a lot of the processing to them, so you don't have to handle everything in software. Kind of like offloading graphics processing to a video card, so your CPU can spend it's time doing something else important, or doing nothing so it can save power.

However, unlike graphics cards, which typically have a Software API like Vulkan, Metal, OpenGL, or DirectX, peripherals are exposed to our CPU with a hardware interface, which is mapped to a chunk of the memory. Because of this, we call these Memmory Mapped Peripherals.

> `0x2000_0000` is a real place
>
> `0x0000_0000` is too

* Both of these addresses are a real thing
* Linear memory address, from 0 to 0xFFFF_FFFF (32 bit processors)
* Only a couple hundred kilobytes of it are used for actual memory
