# 单例

> 在软件工程中，单例模式是一个软件设计模式，其限制了一个类到一个对象的实例化。
>
> *Wikipedia: [Singleton Pattern]*

[Singleton Pattern]: https://en.wikipedia.org/wiki/Singleton_pattern


## 为什么不可以使用全局变量？

可以像这样，我们可以使每个东西都变成公共静态的(public static):

```rust,ignore
static mut THE_SERIAL_PORT: SerialPort = SerialPort;

fn main() {
    let _ = unsafe {
        THE_SERIAL_PORT.read_speed();
    };
}
```

但是这个带来了一些问题。它是一个可变的全局变量，在Rust，与这些变量交互总是unsafe的。这些变量在你所有的程序间也是可见的，意味着借用检查器不能帮你跟踪这些变量的引用和所有权。

## 在Rust中要怎么做?

与其只是让我们的外设变成一个全局变量，我们不如创造一个结构体，在这个例子里其被叫做 `PERIPHERALS`，这个全局变量对于我们的每个外设，它都有一个与之对应的 `Option<T>` ．

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

这个结构体允许我们获得一个外设的实例。如果我们尝试调用`take_serial()`获得多个实例，我们的代码将会抛出运行时恐慌(panic)！

```rust,ignore
fn main() {
    let serial_1 = unsafe { PERIPHERALS.take_serial() };
    // 这里造成运行时恐慌！
    // let serial_2 = unsafe { PERIPHERALS.take_serial() };
}
```

虽然与这个结构体交互是`unsafe`，然而一旦我们获得了它包含的 `SerialPort`，我们将不再需要使用`unsafe`，或者`PERIPHERALS`结构体。

这个带来了少量的运行时开销，因为我们必须打包 `SerialPort` 结构体进一个option中，且我们将需要调用一次 `take_serial()`，但是这种少量的前期成本，能使我们在接下来的程序中使用借用检查器(borrow checker) 。

## 已存在的库支持

虽然我们在上面生成了我们自己的 `Peripherals` 结构体，但这并不是必须的。`cortex_m` crate 包含一个被叫做 `singleton!()` 的宏，它可以为你完成这个任务。

```rust,ignore
use cortex_m::singleton;

fn main() {
    // OK 如果 `main` 只被执行一次
    let x: &'static mut bool =
        singleton!(: bool = false).unwrap();
}
```

[cortex_m docs](https://docs.rs/cortex-m/latest/cortex_m/macro.singleton.html)

另外，如果你使用 [`cortex-m-rtic`](https://github.com/rtic-rs/cortex-m-rtic)，它将获取和定义这些外设的整个过程抽象了出来，你将获得一个`Peripherals`结构体，其包含了所有你定义了的项的一个非 `Option<T>` 的版本。

```rust,ignore
// cortex-m-rtic v0.5.x
#[rtic::app(device = lm3s6965, peripherals = true)]
const APP: () = {
    #[init]
    fn init(cx: init::Context) {
        static mut X: u32 = 0;
         
        // Cortex-M外设
        let core: cortex_m::Peripherals = cx.core;
        
        // 设备特定的外设
        let device: lm3s6965::Peripherals = cx.device;
    }
}
```

## 为什么？

但是这些单例模式是如何使我们的Rust代码在工作方式上产生很大不同的?

```rust,ignore
impl SerialPort {
    const SER_PORT_SPEED_REG: *mut u32 = 0x4000_1000 as _;

    fn read_speed(
        &self // <------ 这个真的真的很重要
    ) -> u32 {
        unsafe {
            ptr::read_volatile(Self::SER_PORT_SPEED_REG)
        }
    }
}
```


这里有两个重要因素:

* 因为我们正在使用一个单例模式，所以我们只有一种方法或者地方去获得一个 `SerialPort` 结构体。
* 为了调用 `read_speed()` 方法，我们必须拥有一个 `SerialPort` 结构体的所有权或者一个引用。

这两个因素放在一起意味着，只有当我们满足了借用检查器的条件时，我们才有可能访问硬件，也意味着在任何时候不可能存在多个对同一个硬件的可变引用(&mut)！

```rust,ignore
fn main() {
    // 缺少对`self`的引用！将不会工作。
    // SerialPort::read_speed();

    let serial_1 = unsafe { PERIPHERALS.take_serial() };

    // 你只能读取你有权访问的内容
    let _ = serial_1.read_speed();
}
```

## 像对待数据一样对待硬件

另外，因为一些引用是可变的，一些是不可变的，就可以知道一个函数或者方法是否有能力修改硬件的状态。比如，

这个函数可以改变硬件的配置:

```rust,ignore
fn setup_spi_port(
    spi: &mut SpiPort,
    cs_pin: &mut GpioPin
) -> Result<()> {
    // ...
}
```

这个不行:

```rust,ignore
fn read_button(gpio: &GpioPin) -> bool {
    // ...
}
```

这允许我们在**编译时**而不是运行时强制代码是否应该或者不应该对硬件进行修改。要注意，这通常在只有一个应用的情况下起作用，但是对于裸机系统来说，我们的软件将被编译进一个单一应用中，因此这通常不是一个限制。

