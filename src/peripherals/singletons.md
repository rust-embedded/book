# 单例

> 在软件工程中，单例模式是一个软件设计模式，其限制了一个类到一个对象的实例化。
>
> *Wikipedia: [Singleton Pattern]*

[Singleton Pattern]: https://en.wikipedia.org/wiki/Singleton_pattern


## 但是为什么我们不能只是使用全局变量呢？

可以像这样，我们可以使每个东西都变成公共静态的(public static):

```rust,ignore
static mut THE_SERIAL_PORT: SerialPort = SerialPort;

fn main() {
    let _ = unsafe {
        THE_SERIAL_PORT.read_speed();
    };
}
```

但是这个带来了一些问题。它是一个可替换的全局变量，在Rust，与这些交互总是不安全的。这些变量在你的整个程序间也是可见的，意味着借用检查器不能帮你跟踪引用和这些变量的所有者。

## 我们在Rust中要怎么做?

与其只是让我们的外设变成一个全局变量，我们不如决定使用一个全局变量，在这个例子里其被叫做 `PERIPHERALS`，我们的每个外设其包含一个`Option<T>`。

```rust,ignore
struct Peripherals {
    serial: Option<SerialPort>,
}
impl Peripherals {
    fn take_serial(&mut self) -> SerialPort {
        let p = replace(&mut self.serial, None);
        p.unwrap()
    }
}
static mut PERIPHERALS: Peripherals = Peripherals {
    serial: Some(SerialPort),
};
```

这个结构体允许我们获得我们外设的一个实例。如果我们尝试调用`take_serial()`获得多个实例，我们的代码将会抛出运行时恐慌(panic)！

```rust,ignore
fn main() {
    let serial_1 = unsafe { PERIPHERALS.take_serial() };
    // This panics!
    // let serial_2 = unsafe { PERIPHERALS.take_serial() };
}
```

Although interacting with this structure is `unsafe`, once we have the `SerialPort` it contained, we no longer need to use `unsafe`, or the `PERIPHERALS` structure at all.

This has a small runtime overhead because we must wrap the `SerialPort` structure in an option, and we'll need to call `take_serial()` once, however this small up-front cost allows us to leverage the borrow checker throughout the rest of our program.

## Existing library support

Although we created our own `Peripherals` structure above, it is not necessary to do this for your code. the `cortex_m` crate contains a macro called `singleton!()` that will perform this action for you.

```rust,ignore
#[macro_use(singleton)]
extern crate cortex_m;

fn main() {
    // OK if `main` is executed only once
    let x: &'static mut bool =
        singleton!(: bool = false).unwrap();
}
```

[cortex_m docs](https://docs.rs/cortex-m/latest/cortex_m/macro.singleton.html)

Additionally, if you use [`cortex-m-rtic`](https://github.com/rtic-rs/cortex-m-rtic), the entire process of defining and obtaining these peripherals are abstracted for you, and you are instead handed a `Peripherals` structure that contains a non-`Option<T>` version of all of the items you define.

```rust,ignore
// cortex-m-rtic v0.5.x
#[rtic::app(device = lm3s6965, peripherals = true)]
const APP: () = {
    #[init]
    fn init(cx: init::Context) {
        static mut X: u32 = 0;
         
        // Cortex-M peripherals
        let core: cortex_m::Peripherals = cx.core;
        
        // Device specific peripherals
        let device: lm3s6965::Peripherals = cx.device;
    }
}
```

## But why?

But how do these Singletons make a noticeable difference in how our Rust code works?

```rust,ignore
impl SerialPort {
    const SER_PORT_SPEED_REG: *mut u32 = 0x4000_1000 as _;

    fn read_speed(
        &self // <------ This is really, really important
    ) -> u32 {
        unsafe {
            ptr::read_volatile(Self::SER_PORT_SPEED_REG)
        }
    }
}
```


There are two important factors in play here:

* Because we are using a singleton, there is only one way or place to obtain a `SerialPort` structure
* To call the `read_speed()` method, we must have ownership or a reference to a `SerialPort` structure

These two factors put together means that it is only possible to access the hardware if we have appropriately satisfied the borrow checker, meaning that at no point do we have multiple mutable references to the same hardware!

```rust,ignore
fn main() {
    // missing reference to `self`! Won't work.
    // SerialPort::read_speed();

    let serial_1 = unsafe { PERIPHERALS.take_serial() };

    // you can only read what you have access to
    let _ = serial_1.read_speed();
}
```

## Treat your hardware like data

Additionally, because some references are mutable, and some are immutable, it becomes possible to see whether a function or method could potentially modify the state of the hardware. For example,

This is allowed to change hardware settings:

```rust,ignore
fn setup_spi_port(
    spi: &mut SpiPort,
    cs_pin: &mut GpioPin
) -> Result<()> {
    // ...
}
```

This isn't:

```rust,ignore
fn read_button(gpio: &GpioPin) -> bool {
    // ...
}
```

This allows us to enforce whether code should or should not make changes to hardware at **compile time**, rather than at runtime. As a note, this generally only works across one application, but for bare metal systems, our software will be compiled into a single application, so this is not usually a restriction.
