# 附录A: 词汇表

嵌入式生态系统充满了不同的协议，硬件组件，还有许多与生产商相关的东西，它们都使用自己的缩写和项目名。这个词汇表尝试列出它们以便更高理解它们。

### BSP

一个板级支持Crate(Board Support Crate)提供一个为某个特定板子配置的高级接口。它通常依赖一个[HAL](#hal) crate 。在[存储映射的寄存器那页](../start/registers.md)有更多细节的描述或者看[这个视频](https://youtu.be/vLYit_HHPaY)来获取一个更广泛的概述。

### FPU

浮点单元(Floating-Point Unit)。一个只运行在浮点数上的'数学处理器'。

### HAL

一个硬件抽象层(Hardware Abstraction Layer) crate提供了一个

A Hardware Abstraction Layer crate provides a developer friendly interface to a microcontroller's
features and peripherals. It is usually implemented on top of a [Peripheral Access Crate (PAC)](#pac).
It may also implement traits from the [`embedded-hal`](https://crates.io/crates/embedded-hal) crate.
There is a more detailed description on the [memory-mapped registers page](../start/registers.md)
or for a broader overview see [this video](https://youtu.be/vLYit_HHPaY).

### I2C

有时又被称为 `I²C` 或者 Intere-IC 。它是一种用于在单个集成电路中进行硬件通信的协议。看[这里][i2c]来获取更多细节。

[i2c]: https://en.wikipedia.org/wiki/I2c

### PAC

A Peripheral Access Crate provides access to a microcontroller's peripherals. It is one of
the lower level crates and is usually generated directly from the provided [SVD](#svd), often
using [svd2rust](https://github.com/rust-embedded/svd2rust/). The [Hardware Abstraction Layer](#hal)
would usually depend on this crate.
There is a more detailed description on the [memory-mapped registers page](../start/registers.md)
or for a broader overview see [this video](https://youtu.be/vLYit_HHPaY).

### SPI

串行外设接口。看[这里][spi]获取更多信息。

[spi]: https://en.wikipedia.org/wiki/Serial_peripheral_interface

### SVD

系统视图描述文件(System View Description)是一个XML文件格式，被用来描述一个微控制器设备的程序员视角。你能在[the ARM CMSIS documentation site](https://www.keil.com/pack/doc/CMSIS/SVD/html/index.html)上获取更多信息。

### UART

通用异步收发器。看[这里][uart]获取更多信息。

[uart]: https://en.wikipedia.org/wiki/Universal_asynchronous_receiver-transmitter

### USART

通用同步异步收发器。看[这里][usart]获取更多信息。

[usart]: https://en.wikipedia.org/wiki/Universal_synchronous_and_asynchronous_receiver-transmitter
