# 异常

异常和中断，是处理器用来处理异步事件和致命错误(e.g. 执行一个无效的指令)的一种硬件机制。异常意味着抢占且涉及到异常处理程序，即响应触发事件的信号的子例程。

`cortex-m-rt` crate提供了一个 [`exception`] 属性去声明异常处理程序。

[`exception`]: https://docs.rs/cortex-m-rt-macros/latest/cortex_m_rt_macros/attr.exception.html

``` rust,ignore
// SysTick (System计时器)异常的异常处理函数
#[exception]
fn SysTick() {
    // ..
}
```

除了 `exception` 属性，异常处理函数看起来和普通函数一样，但是有一个很大的不同: `exception` 处理函数 *不能* 被软件调用。在先前的例子中，语句 `SysTick();` 将会导致一个编译错误。

这么做是有目的的，因为异常处理函数必须具有一个特性: 在异常处理函数中被声明`static mut`的变量能被安全(safe)地使用。

``` rust,ignore
#[exception]
fn SysTick() {
    static mut COUNT: u32 = 0;

    // `COUNT` 被转换到了 `&mut u32` 类型且它用起来是安全的
    *COUNT += 1;
}
```

就像你可能已经知道的那样，在一个函数里使用`static mut`变量，会让函数变成[*非可重入函数(non-reentrancy)*](https://en.wikipedia.org/wiki/Reentrancy_(computing))。从多个异常/中断处理函数，或者从`main`函数同多个异常/中断处理函数中，直接或者间接地调用一个非可重入(non-reentrancy)函数是未定义的行为。

安全的Rust不能导致未定义的行为出现，所以非可重入函数必须被标记为 `unsafe`。然而，我刚说了`exception`处理函数能安全地使用`static mut`变量。这怎么可能？因为`exception`处理函数 *不* 能被软件调用因此重入(reentrancy)不会发生，所以这才变得可能。

> 注意，`exception`属性，通过将静态变量封装进`unsafe`块中且为我们提供了名字相同的，类型为 `&mut` 的，新的合适的变量，转换了函数中静态变量的定义。因此我们可以通过 `*` 解引用访问变量的值而不需要将它们打包进一个 `unsafe` 块中。

## 一个复杂的例子

这里有个例子，使用系统计时器大概每秒会抛出一个 `SysTick` 异常。异常处理函数使用 `COUNT` 变量追踪它自己被调用了多少次，然后使用半主机模式(semihosting)打印 `COUNT` 的值到主机控制台上。

> **注意**: 你能在任何Cortex-M设备上运行这个例子;你也能在QEMU运行它。

```rust,ignore
#![deny(unsafe_code)]
#![no_main]
#![no_std]

use panic_halt as _;

use core::fmt::Write;

use cortex_m::peripheral::syst::SystClkSource;
use cortex_m_rt::{entry, exception};
use cortex_m_semihosting::{
    debug,
    hio::{self, HStdout},
};

#[entry]
fn main() -> ! {
    let p = cortex_m::Peripherals::take().unwrap();
    let mut syst = p.SYST;

    // 配置系统的计时器每秒去触发一个SysTick异常
    syst.set_clock_source(SystClkSource::Core);
    // 这是关于LM3S6965的配置，其有一个12MHz的默认CPU时钟
    syst.set_reload(12_000_000);
    syst.clear_current();
    syst.enable_counter();
    syst.enable_interrupt();

    loop {}
}

#[exception]
fn SysTick() {
    static mut COUNT: u32 = 0;
    static mut STDOUT: Option<HStdout> = None;

    *COUNT += 1;

    // 惰性初始化(Lazy initialization)
    if STDOUT.is_none() {
        *STDOUT = hio::hstdout().ok();
    }

    if let Some(hstdout) = STDOUT.as_mut() {
        write!(hstdout, "{}", *COUNT).ok();
    }

    // 重要信息 如果运行在真正的硬件上，去掉这个 `if` 块，
    // 否则你的调试器将会以一种不一样的状态结束
    if *COUNT == 9 {
        // 这将终结QEMU进程
        debug::exit(debug::EXIT_SUCCESS);
    }
}
```

``` console
tail -n5 Cargo.toml
```

``` toml
[dependencies]
cortex-m = "0.5.7"
cortex-m-rt = "0.6.3"
panic-halt = "0.2.0"
cortex-m-semihosting = "0.3.1"
```

``` text
$ cargo run --release
     Running `qemu-system-arm -cpu cortex-m3 -machine lm3s6965evb (..)
123456789
```

如果你在Discovery开发板上运行这个例子，你将会在OpenOCD控制台上看到输出。还有，当计数到达9的时候，程序将 *会* 停止。

## 默认异常处理函数

`exception` 属性真正做的是，*覆盖* 了一个特定异常的默认异常处理函数。如果你不覆盖一个特定异常的处理函数，它将会被 `DefaultHandler` 函数处理，其默认的是:

``` rust,ignore
fn DefaultHandler() {
    loop {}
}
```

这个函数是 `cortex-m-rt` crate提供的，且被标记为 `#[no_mangle]` 因此你能在 "DefaultHandler" 上放置一个断点和捕获 *unhandled* 异常。 

可以使用 `exception` 属性覆盖这个 `DefaultHandler`:

``` rust,ignore
#[exception]
fn DefaultHandler(irqn: i16) {
    // 自定义默认处理函数
}
```

`irqn` 参数指出了被服务的是哪个异常。一个负数值指出了被服务的是一个Cortex-M异常;0或者一个正数值指出了被服务的是一个设备特定的异常，也就是中断。

## 硬错误(Hard Fault)处理函数

`HardFault`异常有点特别。当程序进入一个无法工作的状态时，这个异常被触发，因此它的处理函数 *不能* 返回，因为这么做可能导致一个未定义的行为。在用户定义的 `HardFault` 处理函数被调用之前，运行时crate还做了一些工作去提供可调试性。

结果是，`HardFault`处理函数必须有下列的签名: `fn(&ExceptionFrame) -> !` 。处理函数的参数是一个指针，它指向被异常推入栈中的寄存器。这些寄存器是异常被触发那刻，处理器状态的一个记录，能被用来分析一个硬错误。

这里有个执行不合法操作的案例: 读取一个不存在的存储位置。

> **注意**: 这个程序在QEMU上将不会工作，i.e. 它将不会崩溃，因为 `qemu-system-arm -machine lm3s6965evb` 不对读取存储的操作进行检查，且读取无效存储时将会开心地返回 `0`。

```rust,ignore
#![no_main]
#![no_std]

use panic_halt as _;

use core::fmt::Write;
use core::ptr;

use cortex_m_rt::{entry, exception, ExceptionFrame};
use cortex_m_semihosting::hio;

#[entry]
fn main() -> ! {
    // 读取一个无效的存储位置
    unsafe {
        ptr::read_volatile(0x3FFF_FFFE as *const u32);
    }

    loop {}
}

#[exception]
fn HardFault(ef: &ExceptionFrame) -> ! {
    if let Ok(mut hstdout) = hio::hstdout() {
        writeln!(hstdout, "{:#?}", ef).ok();
    }

    loop {}
}
```

`HardFault`处理函数打印了`ExceptionFrame`值。如果你运行这个，你将会看到下面的东西打印到OpenOCD控制台上。

``` text
$ openocd
(..)
ExceptionFrame {
    r0: 0x3ffffffe,
    r1: 0x00f00000,
    r2: 0x20000000,
    r3: 0x00000000,
    r12: 0x00000000,
    lr: 0x080008f7,
    pc: 0x0800094a,
    xpsr: 0x61000000
}
```

`pc`值是异常时程序计数器(Program Counter)的值，它指向触发了异常的指令。

如果你看向程序的反汇编:

``` text
$ cargo objdump --bin app --release -- -d --no-show-raw-insn --print-imm-hex
(..)
ResetTrampoline:
 8000942:       movw    r0, #0xfffe
 8000946:       movt    r0, #0x3fff
 800094a:       ldr     r0, [r0]
 800094c:       b       #-0x4 <ResetTrampoline+0xa>
```

你可以在反汇编中搜索程序计数器`0x0800094a`的值。你将会看到一个读取操作(`ldr r0, [r0]`)导致了异常。`ExceptionFrame`的`r0`字段将告诉你，那时寄存器`r0`的值是`0x3fff_fffe` 。
