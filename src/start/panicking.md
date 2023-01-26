# 运行时恐慌(Panicking)

运行时恐慌是Rust语言的一个核心部分。像是索引这样的内建的操作为了存储安全性是运行时检查的。当尝试越界索引时，这会导致运行时恐慌(panic)。

在标准库中，运行时恐慌的行为被定义成：展开(unwinds)恐慌的线程的栈，除非用户自己选择在恐慌时终止程序。

然而在没有标准库的程序中，运行时恐慌的行为是未被定义了的。通过声明一个 `#[painc_handler]` 函数可以选择一个运行时恐慌的行为。

这个函数在一个程序的依赖图中必须只出现一次，且必须有这样的签名: `fn(&PanicInfo) -> !`，`PanicInfo`是一个包含关于发生运行时恐慌的位置信息的结构体。

[`PanicInfo`]: https://doc.rust-lang.org/core/panic/struct.PanicInfo.html

鉴于嵌入式系统的范围从面向用户的系统到安全关键系统，没有一个运行时恐慌行为能满足所有场景，但是有许多常用的行为。这些常用的行为已经被打包进了一些crates中，这些crates中定义了 `#[panic_handler]`函数。比如:

- [`panic-abort`]. 这个运行时恐慌会导致终止指令被执行。
- [`panic-halt`]. 这个运行时恐慌会导致程序，或者现在的线程，通过进入一个无限循环中而挂起。
- [`panic-itm`]. 运行时恐慌的信息会被ITM记录，ITM是一个ARM Cortex-M的特殊的外设。
- [`panic-semihosting`]. 使用半主机技术，运行时恐慌的信息被记录到主机上。

[`panic-abort`]: https://crates.io/crates/panic-abort
[`panic-halt`]: https://crates.io/crates/panic-halt
[`panic-itm`]: https://crates.io/crates/panic-itm
[`panic-semihosting`]: https://crates.io/crates/panic-semihosting

在crates.io上搜索 [`panic-handler`]，你甚至可以找到更多的crates。

[`panic-handler`]: https://crates.io/keywords/panic-handler

仅仅通过链接到相关的crate中，一个程序就可以简单地从这些行为中选择一个运行时恐慌行为。将运行时恐慌的行为作为一行代码放进一个应用的源码中，不仅仅是因为可以作为文档使用，而且能根据编译配置改变运行时恐慌的行为。比如:

``` rust,ignore
#![no_main]
#![no_std]

// dev配置: 更容易调试运行时恐慌; 可以在 `rust_begin_unwind` 上放一个断点
#[cfg(debug_assertions)]
use panic_halt as _;

// release配置: 最小化应用的二进制文件的大小
#[cfg(not(debug_assertions))]
use panic_abort as _;

// ..
```

在这个例子里，当使用dev配置编译的时候(`cargo build`)，crate链接到 `panic-halt` crate上，但是当使用release配置编译时(`cargo build --release`)，crate链接到`panic-abort` crate上。

> `use panic_abort as _` 形式的 `use` 语句，被用来确保 `panic_abort` 运行时恐慌函数被包含进我们最终的可执行程序里，同时让编译器清楚地知道我们不会从这个crate显式地使用任何东西。没有 `_` 重命名，编译器将会警告我们有一个未使用的导入。有时候你可能会看到 `extern crate panic_abort`，这是Rust 2018之前的版本使用的更旧的写法，现在应该只被用于 "sysroot" crates (与Rust一起发布的crates)，比如 `proc_macro`，`alloc`，`std` 和 `test` 。

## 一个例子

这里有一个尝试越界访问数组的例子。操作的结果导致了一个运行时恐慌(panic)。

```rust,ignore
#![no_main]
#![no_std]

use panic_semihosting as _;

use cortex_m_rt::entry;

#[entry]
fn main() -> ! {
    let xs = [0, 1, 2];
    let i = xs.len() + 1;
    let _y = xs[i]; // out of bounds access

    loop {}
}
```

这个例子选择了`panic-semihosting`行为，运行时恐慌的信息会被打印至使用了半主机模式的主机控制台上。

``` text
$ cargo run
     Running `qemu-system-arm -cpu cortex-m3 -machine lm3s6965evb (..)
panicked at 'index out of bounds: the len is 3 but the index is 4', src/main.rs:12:13
```

你可以尝试将行为改成`panic-halt`，确保在这个案例里没有信息被打印。
