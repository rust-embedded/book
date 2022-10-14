# 存储映射的寄存器

只有通过执行常规的Rust代码并在RAM间移动数据，嵌入式系统才能继续运行下去。如果我们想要获取或者发出信息(点亮一个LED，发现一个按钮按下或者在总线上与芯片外设通信)，我们不得不深入了解外设和它们的"存储映射的寄存器"。

你可能会发现，访问你的微控制器外设所需要的代码，已经被写进了下面的某个抽象层中了。

<p align="center">
<img title="Common crates" src="../assets/crates.png">
</p>

* Micro-architecture Crate(微架构Crate) - 这个库拥有任何对于微控制器的处理器内核来说经常会用到的程序，也包括对于在这些微控制器中的通用外设来说有用的程序。比如 [cortex-m] crate提供给你可以使能和关闭中断的函数，其对于所有的Cortex-M微控制器都是一样的。它也提供你访问'SysTick'外设的能力，在所有的Cortex-M微控制器中都包括了这个外设功能。
* Peripheral Access Crate(PAC)(外设访问Crate) - 这种crate是在被不同存储器封装的寄存器上再进行的一次封装，寄存器由你正在使用的微控制器的产品号定义的。比如，[tm4c123x]针对TI的Tiva-C TM4C123系列，[stm32f30x]针对ST的STM32F30x系列。这块，你将根据你的微控制器的技术手册写的每个外设操作指令，直接和寄存器交互。
* HAL Crate - 这些crates为你的处理器提供了一个更友好的API，通常是通过实现在[embedded-hal]中定义的一些常用的traits来实现的。比如，这个crate可能提供一个`Serial`结构体，它的构造函数需要一组合适的GPIO端口和一个波特率，它为了发送数据提供一些 `write_byte` 函数。查看 [可移植性] 可以看到更多关于 [embedded-hal] 的信息。
* Board Crate(开发板crate) - 这些Crate通过预配置不同的外设和GPIO管脚再进行了一层抽象以适配你正在使用的特定的开发者工具或者开发板，比如对于STM32F3DISCOVERY开发板来说，是[stm32f3-discovery]

[cortex-m]: https://crates.io/crates/cortex-m
[tm4c123x]: https://crates.io/crates/tm4c123x
[stm32f30x]: https://crates.io/crates/stm32f30x
[embedded-hal]: https://crates.io/crates/embedded-hal
[可移植性]: ../portability/index.md
[stm32f3-discovery]: https://crates.io/crates/stm32f3-discovery
[Discovery]: https://rust-embedded.github.io/discovery/

## 开发板Crate (Board Crate)

如果你是嵌入式Rust新手，board crate是一个完美的开始。它们很好地抽象出了，在开始学习这个项目时，需要耗费心力了解的硬件细节，使得标准工作变得简单，像是打开或者关闭LED。不同的板子间，它们提供的功能变化很大。因为这本书是不假设我们使用的是何种板子，所以这本书不会提到board crate。

如果你想要用STM32F3DISCOVERY开发板做实验，强烈建议看一下[stm32f3-discovery]开发板crate，它提供了点亮LEDs，访问它的指南针，蓝牙和其它的功能。[Discovery]书对于一个board crate的用法提供一个很好的介绍。

但是如果你正在使用一个还没有提供专用的board crate的系统，或者你需要的一些功能，现存的crates不提供，那我们需要从底层的微架构crates开始。

## Micro-architecture crate

让我们看一下SysTick外设，SysTick外设存在于所有的Cortex-M微控制器中。我们能在[cortex-m] crate中找到一个相当底层的API，我们能像这样使用它：

```rust,ignore
#![no_std]
#![no_main]
use cortex_m::peripheral::{syst, Peripherals};
use cortex_m_rt::entry;
use panic_halt as _;

#[entry]
fn main() -> ! {
    let peripherals = Peripherals::take().unwrap();
    let mut systick = peripherals.SYST;
    systick.set_clock_source(syst::SystClkSource::Core);
    systick.set_reload(1_000);
    systick.clear_current();
    systick.enable_counter();
    while !systick.has_wrapped() {
        // Loop
    }

    loop {}
}
```
`SYST`结构体上的功能，相当接近ARM技术手册为这个外设定义的功能。在这个API中没有关于 '延迟X毫秒' 的功能 - 我们不得不通过使用一个 `while` 循环来粗略地实现它。注意，我们调用了`Peripherals::take()`才能访问我们的`SYST`结构体 - 这是一个特别的程序，保障了在我们的整个程序中只存在一个`SYST`结构体实例，更多的信息可以看[外设]部分。

[外设]: ../peripherals/index.md

## 使用一个外设访问Crate (PAC)

如果我们把自己只局限于每个Cortex-M拥有的基本外设，那我们的嵌入式软件开发将不会走得太远。我们准备需要写一些特定于我们正在使用的微控制器的代码。在这个例子里，让我们假设我们有一个TI的TM4C123 - 一个有256KiB Flash的中等规模的80MHz的Cortex-M4。我们用[tm4c123x] crate去使用这个芯片。

```rust,ignore
#![no_std]
#![no_main]

use panic_halt as _; // panic handler

use cortex_m_rt::entry;
use tm4c123x;

#[entry]
pub fn init() -> (Delay, Leds) {
    let cp = cortex_m::Peripherals::take().unwrap();
    let p = tm4c123x::Peripherals::take().unwrap();

    let pwm = p.PWM0;
    pwm.ctl.write(|w| w.globalsync0().clear_bit());
    // Mode = 1 => Count up/down mode
    pwm._2_ctl.write(|w| w.enable().set_bit().mode().set_bit());
    pwm._2_gena.write(|w| w.actcmpau().zero().actcmpad().one());
    // 528 cycles (264 up and down) = 4 loops per video line (2112 cycles)
    pwm._2_load.write(|w| unsafe { w.load().bits(263) });
    pwm._2_cmpa.write(|w| unsafe { w.compa().bits(64) });
    pwm.enable.write(|w| w.pwm4en().set_bit());
}

```

我们访问 `PWM0` 外设的方法和我们之前访问 `SYST` 的方法一样，除了我们调用的是 `tm4c123x::Peripherals::take()` 之外。因为这个crate是使用[svd2rust]自动生成的，访问我们寄存器字段的函数的参数是一个闭包，而不是一个数值参数。虽然这看起来像是有了更多的代码了，但是Rust编译器能使用这个闭包为我们执行一系列检查，且产生的机器码十分接近手写的汇编码！如果自动生成的代码不能确保某个访问函数其所有可能的参数都能发挥作用(比如，如果寄存器被SVD定义为32位，但是没有说明某些32位值是否有特殊含义)，则该函数被标记为 `unsafe` 。我们能在上面看到这样的例子，我们使用 `bits()` 函数设置 `load` 和 `compa` 子域。

### 读取

`read()` 函数返回一个对象，这个对象提供了对这个寄存器中不同子域的只读访问，由厂商提供的这个芯片的SVD文件定义。在 [tm4c123x documentation][tm4c123x documentation R] 中你能找到在这个特别的返回类型 `R` 上所有可用的函数，其与特定芯片中的特定外设的特定寄存器有关。

```rust,ignore
if pwm.ctl.read().globalsync0().is_set() {
    // Do a thing
}
```

### 写入

`write()`函数使用一个只有一个参数的闭包。通常我们把这个参数叫做 `w`。然后这个参数提供对这个寄存器中不同的子域的读写访问，由厂商关于这个芯片的SVD文件提供。再一次，在 [tm4c123x documentation][tm4c123x documentation W] 中你能找到 `W` 所有可用的函数，其与特定芯片中的特定外设的特定寄存器有关。注意所有我们没有设置的子域将会被设置一个默认值 - 任何在这个寄存器中的现存的内容将会丢失。


```rust,ignore
pwm.ctl.write(|w| w.globalsync0().clear_bit());
```

### 修改

如果我们希望只改变这个寄存器中某个特定的子域而让其它子域不变，我们能使用`modify`函数。这个函数使用一个具有两个参数的闭包 - 一个用来读取，一个用来写入。通常我们分别称它们为 `r` 和 `w` 。 `r` 参数能被用来查看这个寄存器现在的内容，`w` 参数能被用来修改寄存器的内容。

```rust,ignore
pwm.ctl.modify(|r, w| w.globalsync0().clear_bit());
```

`modify` 函数在这里真正展示了闭包的能量。在C中，我们不得不读取一些临时值，修改成正确的比特，然后再把值写回。这意味着出现错误的范围非常大。

```C
uint32_t temp = pwm0.ctl.read();
temp |= PWM0_CTL_GLOBALSYNC0;
pwm0.ctl.write(temp);
uint32_t temp2 = pwm0.enable.read();
temp2 |= PWM0_ENABLE_PWM4EN;
pwm0.enable.write(temp); // 哦 不! 错误的变量!
```

[svd2rust]: https://crates.io/crates/svd2rust
[tm4c123x documentation R]: https://docs.rs/tm4c123x/0.7.0/tm4c123x/pwm0/ctl/struct.R.html
[tm4c123x documentation W]: https://docs.rs/tm4c123x/0.7.0/tm4c123x/pwm0/ctl/struct.W.html

## 使用一个HAL crate

一个芯片的HAL crate通常通过为PAC暴露的基础结构体们实现一个自定义Trait来发挥作用。经常这个trait将会为某个外设定义一个被称作 `constrain()` 的函数或者为像是有多个管脚的GPIO端口这类东西定义一个`split()`函数。这个函数将会使用基础外设结构体，然后返回一个具有更高抽象的API的新对象。这个API还可以做一些事，像是让Serial port的 `new` 函数变成需要某些`Clock`结构体的函数，这个结构体只能通过调用配置PLLs并设置所有的时钟频率的函数来生成。在这时，生成一个Serial port对象而不先配置时钟速率是不可能的，对于Serial port对象来说错误地将波特率转换为时钟滴答数也是不可能发生的。一些crates甚至为每个GPIO管脚的状态定义了特定的 traits，在把管脚传递进外设前，要求用户去把一个管脚设置成正确的状态(通过选择Alternate Function模式) 。所有这些都没有运行时开销的！

让我们看一个例子:

```rust,ignore
#![no_std]
#![no_main]

use panic_halt as _; // panic handler

use cortex_m_rt::entry;
use tm4c123x_hal as hal;
use tm4c123x_hal::prelude::*;
use tm4c123x_hal::serial::{NewlineMode, Serial};
use tm4c123x_hal::sysctl;

#[entry]
fn main() -> ! {
    let p = hal::Peripherals::take().unwrap();
    let cp = hal::CorePeripherals::take().unwrap();

    // 将SYSCTL结构体封装成一个有更高抽象API的对象
    let mut sc = p.SYSCTL.constrain();
    // 选择我们的晶振配置
    sc.clock_setup.oscillator = sysctl::Oscillator::Main(
        sysctl::CrystalFrequency::_16mhz,
        sysctl::SystemClock::UsePll(sysctl::PllOutputFrequency::_80_00mhz),
    );
    // 设置PLL
    let clocks = sc.clock_setup.freeze();

    // 把GPIO_PORTA结构体封装成一个有更高抽象API的对象
    // 注意它需要借用 `sc.power_control` 因此它能自动开启GPIO外设。
    let mut porta = p.GPIO_PORTA.split(&sc.power_control);

    // 激活UART
    let uart = Serial::uart0(
        p.UART0,
        // 传送管脚
        porta
            .pa1
            .into_af_push_pull::<hal::gpio::AF1>(&mut porta.control),
        // 接收管脚
        porta
            .pa0
            .into_af_push_pull::<hal::gpio::AF1>(&mut porta.control),
        // 不需要RTS或者CTS
        (),
        (),
        // 波特率
        115200_u32.bps(),
        // 输出处理
        NewlineMode::SwapLFtoCRLF,
        // 我们需要时钟频率去计算波特率除法器(divisors)
        &clocks,
        // 我们需要这个去启动UART外设
        &sc.power_control,
    );

    loop {
        writeln!(uart, "Hello, World!\r\n").unwrap();
    }
}
```
