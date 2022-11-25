# 附录A: 词汇表

嵌入式生态系统中充满了不同的协议，硬件组件，还有许多与生产商相关的东西，它们都使用自己的缩写和项目名。这个词汇表尝试列出它们以便更好理解它们。

### BSP

板级支持的Crate(Board Support Crate)提供为某个特定板子配置的高级接口。它通常依赖一个[HAL](#hal) crate 。在[存储映射的寄存器那页](../start/registers.md)有更多细节的描述或者看[这个视频](https://youtu.be/vLYit_HHPaY)来获取一个更广泛的概述。

### FPU

浮点单元(Floating-Point Unit)。一个只运行在浮点数上的'数学处理器'。

### HAL

硬件抽象层(Hardware Abstraction Layer) crate为微控制器的功能和外设提供一个开发者友好的接口。它通常在[Peripheral Access Crate (PAC)](#pac)之上被实现。它可能也会实现来自[`embedded-hal`](https://crates.io/crates/embedded-hal) crate的traits 。在[存储映射的寄存器那页](../start/registers.md)上有更多的细节或者看[这个视频](https://youtu.be/vLYit_HHPaY)获取一个更广泛的概述。

### I2C

有时又被称为 `I²C` 或者 Intere-IC 。它是一种用于在单个集成电路中进行硬件通信的协议。看[这里][i2c]来获取更多细节。

[i2c]: https://en.wikipedia.org/wiki/I2c

### PAC

一个外设访问 Crate (Peripheral Access Crate)提供了对一个微控制器的外设的访问。它是一个底层的crates且通常从提供的[SVD](#svd)被直接生成，经常使用[svd2rust](https://github.com/rust-embedded/svd2rust/)。[硬件抽象层](#hal)应该依赖这个crate。在[存储映射的寄存器那页](../start/registers.md)有更细节的描述或者看[这个视频](https://youtu.be/vLYit_HHPaY)获取一个更广泛的概述。

### SPI

串行外设接口。看[这里][spi]获取更多信息。

[spi]: https://en.wikipedia.org/wiki/Serial_peripheral_interface

### SVD

系统视图描述文件(System View Description)是一个XML文件格式，以程序员视角来描述一个微控制器设备。你能在[the ARM CMSIS documentation site](https://www.keil.com/pack/doc/CMSIS/SVD/html/index.html)上获取更多信息。

### UART

通用异步收发器。看[这里][uart]获取更多信息。

[uart]: https://en.wikipedia.org/wiki/Universal_asynchronous_receiver-transmitter

### USART

通用同步异步收发器。看[这里][usart]获取更多信息。

[usart]: https://en.wikipedia.org/wiki/Universal_synchronous_and_asynchronous_receiver-transmitter
