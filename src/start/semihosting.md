# 半主机模式

半主机模式是一种可以让嵌入式设备在主机上进行I/O操作的的机制，主要被用来记录信息到主机控制台上。半主机模式需要一个debug会话，除此之外几乎没有其它要求了，因此它非常易于使用。缺点是它非常慢：每个写操作需要几毫秒的时间，其取决于你的硬件调试器(e.g. ST-LINK)。

[`cortex-m-semihosting`] crate 提供了一个API去在Cortex-M设备上执行半主机操作。下面的程序是"Hello, world!"的半主机版本。

[`cortex-m-semihosting`]: https://crates.io/crates/cortex-m-semihosting

```rust,ignore
#![no_main]
#![no_std]

use panic_halt as _;

use cortex_m_rt::entry;
use cortex_m_semihosting::hprintln;

#[entry]
fn main() -> ! {
    hprintln!("Hello, world!").unwrap();

    loop {}
}
```

如果你在硬件上运行这个程序，你将会在OpenOCD的logs中看到"Hello, world!"信息。

``` text
$ openocd
(..)
Hello, world!
(..)
```

你首先需要从GDB使能OpenOCD中的半主机模式。
``` console
(gdb) monitor arm semihosting enable
semihosting is enabled
```

QEMU理解半主机操作，因此上面的程序不需要启动一个debug会话，也能在`qemu-system-arm`中工作。注意你需要传递`-semihosting-config`标志给QEMU去使能支持半主机模式；这些标识已经被包括在模板的`.cargo/config.toml`文件中了。

``` text
$ # this program will block the terminal
$ cargo run
     Running `qemu-system-arm (..)
Hello, world!
```

`exit`半主机操作也能被用于终止QEMU进程。重要：**不要**在硬件上使用`debug::exit`；这个函数会关闭你的OpenOCD对话，这样你将不能执行其它程序调试操作，除了重启它。

```rust,ignore
#![no_main]
#![no_std]

use panic_halt as _;

use cortex_m_rt::entry;
use cortex_m_semihosting::debug;

#[entry]
fn main() -> ! {
    let roses = "blue";

    if roses == "red" {
        debug::exit(debug::EXIT_SUCCESS);
    } else {
        debug::exit(debug::EXIT_FAILURE);
    }

    loop {}
}
```

``` text
$ cargo run
     Running `qemu-system-arm (..)

$ echo $?
1
```

最后一个提示：你可以将运行时恐慌(panicking)的行为设置成 `exit(EXIT_FAILURE)`。这将允许你编写可以在QEMU上运行通过的 `no_std` 测试。

为了方便，`panic-semihosting` crate有一个 "exit" 特性。当它使能的时候，在主机stderr上打印恐慌(painc)信息后会调用 `exit(EXIT_FAILURE)` 。

```rust,ignore
#![no_main]
#![no_std]

use panic_semihosting as _; // features = ["exit"]

use cortex_m_rt::entry;
use cortex_m_semihosting::debug;

#[entry]
fn main() -> ! {
    let roses = "blue";

    assert_eq!(roses, "red");

    loop {}
}
```

``` text
$ cargo run
     Running `qemu-system-arm (..)
panicked at 'assertion failed: `(left == right)`
  left: `"blue"`,
 right: `"red"`', examples/hello.rs:15:5

$ echo $?
1
```

**注意**: 为了在`panic-semihosting`上使能这个特性，编辑你的`Cargo.toml`依赖，`panic-semihosting`改写成:

``` toml
panic-semihosting = { version = "VERSION", features = ["exit"] }
```

`VERSION`是想要的版本。关于依赖features的更多信息查看Cargo book的[`specifying dependencies`]部分。

[`specifying dependencies`]:
https://doc.rust-lang.org/cargo/reference/specifying-dependencies.html
