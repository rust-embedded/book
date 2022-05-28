# 存储映射的寄存器

嵌入式系统只能通过执行普通的Rust代码和在RAM间移动数据来运行下去。如果我们想要获取或者发出信息(点亮一个LED，发现一个按钮按下或者在总线上与芯片外设通信)，我们不得不深入了解外设和它们的"存储映射的寄存器"。

你可能发现，访问你的微控制器外设所需要的代码已经写进了下面某个抽象层中。

<p align="center">
<img title="Common crates" src="../assets/crates.png">
</p>

* Micro-architecture Crate(微架构Crate) - 这种Crate提供对你正在使用的微控制器的处理器核心，和任何使用这个特定类型处理器核心的微控制器的常见外设来说，有用的程序。比如 [cortex-m] crate提供你可以使能和关闭中断的函数，其对于所有的Cortex-M微控制器都是一样的。它也提供你访问'SysTick'外设的能力，在所有的Cortex-M微控制器中都包括了这个能力。
* Peripheral Access Crate(PAC)(外设访问Crate) - 这种crate是在不同存储器封装的寄存器上再进行的一次封装，其由你正在使用的微控制器的产品号定义的。比如，[tm4c123x]针对TI的Tiva-C TM4C123系列，[stm32f30x]针对ST的STM32F30x系列。这块，你将根据你的微控制器的技术手册写的每个外设操作指令，直接和寄存器交互。
* HAL Crate - 这些crates为你的处理器提供了一个更友好的API，通常是通过实现在[embedded-hal]中定义的一些常用的traits来实现的。比如，这个crate可能提供一个`Serial`结构体，它的构造函数获取一组合适的GPIO口和一个波特率，它为了发送数据提供一些 `write_byte` 函数。查看 [Portability] 可以看到更多关于 [embedded-hal] 的信息。
* Board Crate(开发板crate) - 这个通过预先配置的不同的外设和GPIO管脚再进行了一层抽象去适配你正在使用的特定的开发者工具或者开发板，比如对于STM32F3DISCOVERY开发板来说，是[stm32f3-discovery]

[cortex-m]: https://crates.io/crates/cortex-m
[tm4c123x]: https://crates.io/crates/tm4c123x
[stm32f30x]: https://crates.io/crates/stm32f30x
[embedded-hal]: https://crates.io/crates/embedded-hal
[Portability]: ../portability/index.md
[stm32f3-discovery]: https://crates.io/crates/stm32f3-discovery
[Discovery]: https://rust-embedded.github.io/discovery/

## 开发板Crate (Board Crate)

如果你是嵌入式Rust新手，board crate是一个完美的起点。它们很好地抽象出了，在开始学习这个项目时，需要耗费心力了解的硬件细节，使得标准工作变得简单，像是打开或者关闭LED。不同的板子间，它们提供的功能变化很大。因为这本书是不假设我们使用的是何种板子，所以board crate不会被这本书涉及。

如果你想要用STM32F3DISCOVERY开发板做实验，强烈建议看一下[stm32f3-discovery]开发板crate，它提供了功能点亮LEDs，访问它的指南针，蓝牙和其它的。[Discovery]书对于一个board crate的用法提供一个很好介绍。

但是如果你正在使用一个还没有提供专用的board crate的系统，或者你需要一些功能现存的crates不提供，那我们需要从底层的微架构crates开始。

## Micro-architecture crate

让我们看一下对于所有的Cortex-M微控制器来说很常见的SysTick外设。我们能在[cortex-m] crate中找到一个相当底层的API，我们能像这样使用它：

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
`SYST`结构体上的功能，相当接近ARM技术手册为这个外设定义的功能。在这个API中没有关于 '延迟X毫秒' 的功能 - 我们不得不使用一个 `while` 循环自己粗略地实现它。注意，我们调用了`Peripherals::take()`才能访问我们的`SYST`结构体 - 这是一个特别的程序，保障了在我们的整个程序中只存在一个`SYST`结构体实例，更多的信息可以看[外设]部分。

[外设]: ../peripherals/index.md

## Using a Peripheral Access Crate (PAC)

We won't get very far with our embedded software development if we restrict ourselves to only the basic peripherals included with every Cortex-M. At some point, we're going to need to write some code that's specific to the particular micro-controller we're using. In this example, let's assume we have an Texas Instruments TM4C123 - a middling 80MHz Cortex-M4 with 256 KiB of Flash. We're going to pull in the [tm4c123x] crate to make use of this chip.

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

We've accessed the `PWM0` peripheral in exactly the same way as we accessed the `SYST` peripheral earlier, except we called `tm4c123x::Peripherals::take()`. As this crate was auto-generated using [svd2rust], the access functions for our register fields take a closure, rather than a numeric argument. While this looks like a lot of code, the Rust compiler can use it to perform a bunch of checks for us, but then generate machine-code which is pretty close to hand-written assembler! Where the auto-generated code isn't able to determine that all possible arguments to a particular accessor function are valid (for example, if the SVD defines the register as 32-bit but doesn't say if some of those 32-bit values have a special meaning), then the function is marked as `unsafe`. We can see this in the example above when setting the `load` and `compa` sub-fields using the `bits()` function.

### Reading

The `read()` function returns an object which gives read-only access to the various sub-fields within this register, as defined by the manufacturer's SVD file for this chip. You can find all the functions available on special `R` return type for this particular register, in this particular peripheral, on this particular chip, in the [tm4c123x documentation][tm4c123x documentation R].

```rust,ignore
if pwm.ctl.read().globalsync0().is_set() {
    // Do a thing
}
```

### Writing

The `write()` function takes a closure with a single argument. Typically we call this `w`. This argument then gives read-write access to the various sub-fields within this register, as defined by the manufacturer's SVD file for this chip. Again, you can find all the functions available on the 'w' for this particular register, in this particular peripheral, on this particular chip, in the [tm4c123x documentation][tm4c123x Documentation W]. Note that all of the sub-fields that we do not set will be set to a default value for us - any existing content in the register will be lost.

```rust,ignore
pwm.ctl.write(|w| w.globalsync0().clear_bit());
```

### Modifying

If we wish to change only one particular sub-field in this register and leave the other sub-fields unchanged, we can use the `modify` function. This function takes a closure with two arguments - one for reading and one for writing. Typically we call these `r` and `w` respectively. The `r` argument can be used to inspect the current contents of the register, and the `w` argument can be used to modify the register contents.

```rust,ignore
pwm.ctl.modify(|r, w| w.globalsync0().clear_bit());
```

The `modify` function really shows the power of closures here. In C, we'd have to read into some temporary value, modify the correct bits and then write the value back. This means there's considerable scope for error:

```C
uint32_t temp = pwm0.ctl.read();
temp |= PWM0_CTL_GLOBALSYNC0;
pwm0.ctl.write(temp);
uint32_t temp2 = pwm0.enable.read();
temp2 |= PWM0_ENABLE_PWM4EN;
pwm0.enable.write(temp); // Uh oh! Wrong variable!
```

[svd2rust]: https://crates.io/crates/svd2rust
[tm4c123x documentation R]: https://docs.rs/tm4c123x/0.7.0/tm4c123x/pwm0/ctl/struct.R.html
[tm4c123x documentation W]: https://docs.rs/tm4c123x/0.7.0/tm4c123x/pwm0/ctl/struct.W.html

## Using a HAL crate

The HAL crate for a chip typically works by implementing a custom Trait for the raw structures exposed by the PAC. Often this trait will define a function called `constrain()` for single peripherals or `split()` for things like GPIO ports with multiple pins. This function will consume the underlying raw peripheral structure and return a new object with a higher-level API. This API may also do things like have the Serial port `new` function require a borrow on some `Clock` structure, which can only be generated by calling the function which configures the PLLs and sets up all the clock frequencies. In this way, it is statically impossible to create a Serial port object without first having configured the clock rates, or for the Serial port object to mis-convert the baud rate into clock ticks. Some crates even define special traits for the states each GPIO pin can be in, requiring the user to put a pin into the correct state (say, by selecting the appropriate Alternate Function Mode) before passing the pin into Peripheral. All with no run-time cost!

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

    // Wrap up the SYSCTL struct into an object with a higher-layer API
    let mut sc = p.SYSCTL.constrain();
    // Pick our oscillation settings
    sc.clock_setup.oscillator = sysctl::Oscillator::Main(
        sysctl::CrystalFrequency::_16mhz,
        sysctl::SystemClock::UsePll(sysctl::PllOutputFrequency::_80_00mhz),
    );
    // Configure the PLL with those settings
    let clocks = sc.clock_setup.freeze();

    // Wrap up the GPIO_PORTA struct into an object with a higher-layer API.
    // Note it needs to borrow `sc.power_control` so it can power up the GPIO
    // peripheral automatically.
    let mut porta = p.GPIO_PORTA.split(&sc.power_control);

    // Activate the UART.
    let uart = Serial::uart0(
        p.UART0,
        // The transmit pin
        porta
            .pa1
            .into_af_push_pull::<hal::gpio::AF1>(&mut porta.control),
        // The receive pin
        porta
            .pa0
            .into_af_push_pull::<hal::gpio::AF1>(&mut porta.control),
        // No RTS or CTS required
        (),
        (),
        // The baud rate
        115200_u32.bps(),
        // Output handling
        NewlineMode::SwapLFtoCRLF,
        // We need the clock rates to calculate the baud rate divisors
        &clocks,
        // We need this to power up the UART peripheral
        &sc.power_control,
    );

    loop {
        writeln!(uart, "Hello, World!\r\n").unwrap();
    }
}
```
