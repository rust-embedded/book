# 熟悉你的硬件

让我们来熟悉下我们将使用的硬件。

## STM32F3DISCOVERY (the "F3")

<p align="center">
<img title="F3" src="../assets/f3.jpg">
</p>

这个板子包含什么？

+ 一个[STM32F303VCT6](https://www.st.com/en/microcontrollers/stm32f303vc.html)微控制器。这个微控制器包含
  + 一个单核的ARM Cortex-M4F 处理器，支持单精度浮点运算，72MHz的最大时钟频率。
  + 256 KiB的"Flash"存储。
  + 48 KiB的RAM
  + 多种多样的外设，比如计时器，I2C，SPI和USART
  + 通用GPIO和板子两侧的其它类型引脚
  + 一个写着“USB USER”的USB接口
+ [LSM303DLHC](https://www.st.com/en/mems-and-sensors/lsm303dlhc.html)芯片上的一个[加速度计](https://en.wikipedia.org/wiki/Accelerometer)。

+ [LSM303DLHC](https://www.st.com/en/mems-and-sensors/lsm303dlhc.html)芯片上的一个[磁力计](https://en.wikipedia.org/wiki/Magnetometer)。

+ [L3GD20](https://www.pololu.com/file/0J563/L3GD20.pdf)芯片上的一个[陀螺仪](https://en.wikipedia.org/wiki/Gyroscope).

+ 摆得像一个指南针形状样的8个用户LEDs。


- A second microcontroller: a [STM32F103](https://www.st.com/en/microcontrollers/stm32f103cb.html). This microcontroller is actually part of an on-board programmer / debugger and is connected to the USB port named "USB ST-LINK".

For a more detailed list of features and further specifications of the board take a look at the [STMicroelectronics](https://www.st.com/en/evaluation-tools/stm32f3discovery.html) website.

A word of caution: be careful if you want to apply external signals to the board. The microcontroller STM32F303VCT6 pins take a nominal voltage of 3.3 volts. For further information consult the [6.2 Absolute maximum ratings section in the manual](https://www.st.com/resource/en/datasheet/stm32f303vc.pdf)
