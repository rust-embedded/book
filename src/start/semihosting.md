# 半主机模式

半主机模式是一种让嵌入式设备在主机上进行I/O操作的的机制，主要被用来记录信息到主机控制台上。半主机模式需要一个debug会话，除此之外几乎没有其它要求了，因此它非常易于使用。缺点是它非常慢：取决于你的硬件调试器(e.g. ST-LINK)，每个写操作需要几毫秒的时间。

[`cortex-m-semihosting`] crate 提供一个API去在Cortex-M设备上执行半主机操作。下面的程序是"Hello, world!"的半主机版本。

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

QEMU理解半主机操作，因此上面的程序不需要启动一个debug会话，也能在`qemu-system-arm`中工作。注意你需要传递`-semihosting-config`标志给QEMU去使能半主机支持；这些标识已经被包括在模板的`.cargo/config.toml`文件中了。

``` text
$ # this program will block the terminal
$ cargo run
     Running `qemu-system-arm (..)
Hello, world!
```

`exit`半主机操作也能被用于终止QEMU进程。重要：**不要**在硬件上使用`debug::exit`；这个函数会关闭你的OpenOCD对话，除了重启它，你将不能执行更多的程序调试操作。

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

最后一个提醒：你将
One last tip: you can set the panicking behavior to `exit(EXIT_FAILURE)`. This
will let you write `no_std` run-pass tests that you can run on QEMU.

For convenience, the `panic-semihosting` crate has an "exit" feature that when
enabled invokes `exit(EXIT_FAILURE)` after logging the panic message to the host
stderr.

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

**注意**: To enable this feature on `panic-semihosting`, edit your
`Cargo.toml` dependencies section where `panic-semihosting` is specified with:

``` toml
panic-semihosting = { version = "VERSION", features = ["exit"] }
```

where `VERSION` is the version desired. For more information on dependencies
features check the [`specifying dependencies`] section of the Cargo book.

[`specifying dependencies`]:
https://doc.rust-lang.org/cargo/reference/specifying-dependencies.html
