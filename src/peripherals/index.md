# 外设

## 什么是外设?

大多数微处理器不仅有一个CPU，RAM，或者Flash存储器 - 它们包含硅片被用来与微处理器的外部系统交互的部分，通过传感器，电机控制器，或者人机接口比如一个显示器或者键盘直接和间接地与它们周围的世界交互。这些组件统称为外设。

这些外设很有用因为它们允许一个开发者将处理工作给它们来做，避免必须在软件中处理每件事。就像一个桌面开发者如何将图形处理工作让给一个显卡那样，嵌入式开发者能将一些任务让给外设去做，让CPU可以把时间放在做其它更重要的事上，或者为了省电啥事也不做。

如果你看向从1970s或者1980s的旧型号的家庭电脑的主板(其实，昨日的桌面PCs与今日的嵌入式系统没太大区别)，你将看到:

* 一个处理器
* 一个RAM芯片
* 一个ROM芯片
* 一个I/O控制器

RAM芯片，ROM芯片和I/O控制器(这个系统中的外设)将会通过一系列并行的迹(traces)又被称为一个"总线"被加进处理器中。这个总线搬运地址信息，其用来选择处理器希望跟总线上哪个设备通信，还有一个用来搬运实际数据的数据总线。在我们的嵌入式微控制器中，应用了相同的概念 - 只是所有的东西被打包到一片硅片上。

然而，不像显卡，显卡通常有像是Vulkan，Metal，或者OpenGL这样的一个软件API。外设暴露给微控制器的是一个硬件接口，其被映射到一块存储区域。

## 线性的真实存储空间

在一个微控制器上，往一些任意别的地址写一些数据，比如 `0x4000_0000` 或者 `0x0000_0000`，
On a microcontroller, writing some data to some other arbitrary address, such as `0x4000_0000` or `0x0000_0000`, may also be a completely valid action.

On a desktop system, access to memory is tightly controlled by the MMU, or Memory Management Unit. This component has two major responsibilities: enforcing access permission to sections of memory (preventing one process from reading or modifying the memory of another process); and re-mapping segments of the physical memory to virtual memory ranges used in software. Microcontrollers do not typically have an MMU, and instead only use real physical addresses in software.

Although 32 bit microcontrollers have a real and linear address space from `0x0000_0000`, and `0xFFFF_FFFF`, they generally only use a few hundred kilobytes of that range for actual memory. This leaves a significant amount of address space remaining. In earlier chapters, we were talking about RAM being located at address `0x2000_0000`. If our RAM was 64 KiB long (i.e. with a maximum address of 0xFFFF) then addresses `0x2000_0000` to `0x2000_FFFF` would correspond to our RAM. When we write to a variable which lives at address `0x2000_1234`, what happens internally is that some logic detects the upper portion of the address (0x2000 in this example) and then activates the RAM so that it can act upon the lower portion of the address (0x1234 in this case). On a Cortex-M we also have our Flash ROM mapped in at address `0x0000_0000` up to, say, address `0x0007_FFFF` (if we have a 512 KiB Flash ROM). Rather than ignore all remaining space between these two regions, Microcontroller designers instead mapped the interface for peripherals in certain memory locations. This ends up looking something like this:

![](../assets/nrf52-memory-map.png)

[Nordic nRF52832 Datasheet (pdf)]

## Memory Mapped Peripherals

Interaction with these peripherals is simple at a first glance - write the right data to the correct address. For example, sending a 32 bit word over a serial port could be as direct as writing that 32 bit word to a certain memory address. The Serial Port Peripheral would then take over and send out the data automatically.

Configuration of these peripherals works similarly. Instead of calling a function to configure a peripheral, a chunk of memory is exposed which serves as the hardware API. Write `0x8000_0000` to a SPI Frequency Configuration Register, and the SPI port will send data at 8 Megabits per second. Write `0x0200_0000` to the same address, and the SPI port will send data at 125 Kilobits per second. These configuration registers look a little bit like this:

![](../assets/nrf52-spi-frequency-register.png)

[Nordic nRF52832 Datasheet (pdf)]

This interface is how interactions with the hardware are made, no matter what language is used, whether that language is Assembly, C, or Rust.

[Nordic nRF52832 Datasheet (pdf)]: http://infocenter.nordicsemi.com/pdf/nRF52832_PS_v1.1.pdf
