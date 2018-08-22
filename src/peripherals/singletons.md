# Singletons

> In software engineering, the singleton pattern is a software design pattern that restricts the instantiation of a class to one object.

https://en.wikipedia.org/wiki/Singleton_pattern

* Old concept
* But how in Rust?


## But why can't we just use global variable(s)?

We could make everything a public static, like this

```rust
static mut THE_SERIAL_PORT: SerialPort = SerialPort;

fn main() {
    let _ = unsafe {
        THE_SERIAL_PORT.read_speed();
    }
}
```

But this has some problems:

* Mutable Global Variable
* Unsafe to touch it, always
* Visible everywhere
* No help from the borrow checker

## How do we do this in Rust?

```rust
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

> take what you need, but only once

```rust
fn main() {
    let serial_1 = unsafe { PERIPHERALS.take_serial() };
    // This panics!
    // let serial_2 = unsafe { PERIPHERALS.take_serial() };
}
```

> small runtime overhead, big impact

## Existing library support

```rust
#[macro_use(singleton)]
extern crate cortex_m;

fn main() {
    // OK if `main` is executed only once
    let x: &'static mut bool =
        singleton!(: bool = false).unwrap();
}
```

[cortex_m docs](https://docs.rs/cortex-m/0.5.2/cortex_m/macro.singleton.html)

```rust
// cortex-m-rtfm v0.3.x
app! {
    resources: {
        static RX: Rx<USART1>;
        static TX: Tx<USART1>;
    }
}
fn init(p: init::Peripherals) -> init::LateResources {
    // Note that this is now an owned value, not a reference
    let usart1: USART1 = p.device.USART1;
}
```

[japaric.io rtfm v3](https://blog.japaric.io/rtfm-v3/)

## But why?

> how do singletons make a difference?

```rust
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

```rust
fn main() {
    let serial_1 = unsafe { PERIPHERALS.take_serial() };

    // you can only read what you have access to
    let _ = serial_1.read_speed();
}
```

This is allowed to change hardware settings:

```rust
fn setup_spi_port(
    spi: &mut SpiPort,
    cs_pin: &mut GpioPin
) -> Result<()> {
    // ...
}
```

This isn't:

```rust
fn read_button(gpio: &GpioPin) -> bool {
    // ...
}
```

> enforce whether code should or should not make changes to hardware
>
> at **compile time**<sup>\*</sup>

<sup>\*</sup>: only works across one application, but for bare metal systems, we usually only have one anyway
