# Design Contracts

In

```rust
use gpio::{InputGpio, OutputGpio};

struct GpioPin;

impl GpioPin {
    fn into_input(self) -> InputGpio {
        self.set_input_mode();
        InputGpio
    }
    fn into_output(self) -> OutputGpio {
        self.set_output_mode();
        OutputGpio
    }
}
```

* Use type transitions to enforce setup steps
* Like the builder pattern in "normal" Rust

```rust
impl LedPin {
    fn new(pin: OutputGpio) -> Self { ... }
    fn toggle(&mut self) -> bool { ... }
}

fn main() {
    let gpio_1 = unsafe { PERIPHERALS.take_gpio_1() };
    // This won't work, the types are wrong!
    // let led_1 = LedPin::new(gpio_1);
    let mut led_1 = LedPin::new(gpio_1.into_output());
    let _ = led_1.toggle();
}
```

* You have to have the right types to have the interfaces you want

## Enforce design contracts

> entirely at compile time
>
> no runtime cost
>
> no room for human error
