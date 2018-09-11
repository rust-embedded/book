# Zero Cost Abstractions

## "no runtime cost"?

```rust
use core::mem::size_of;

let _ = size_of::<GpioPin>();     // == 0
let _ = size_of::<InputGpio>();   // == 0
let _ = size_of::<OutputGpio>();  // == 0
let _ = size_of::<()>();          // == 0
```

## Zero Sized Types

```rust
struct GpioPin;
```

> acts real at compile time
>
> doesn't exist in the binary
>
> no RAM, no CPU, no space
>
> Evaporates at compile time

## What if our `OutputGpio` has multiple modes?

> (it does)

---

```rust
pub struct PushPull;  // good for general usage
pub struct OpenDrain; // better for high power LEDs

pub struct OutputGpio<MODE> {
    _mode: MODE
}

impl<MODE> OutputGpio<MODE> {
    fn default() -> OutputGpio<OpenDrain> { ... }
    fn into_push_pull(self) -> OutputGpio<PushPull> { ... }
    fn into_open_drain(self) -> OutputGpio<OpenDrain> { ... }
}
```

---

```rust
/// This kind of LED only works with OpenDrain settings
struct DrainLed {
    pin: OutputGpio<OpenDrain>,
}

impl DrainLed {
    fn new(pin: OutputGpio<OpenDrain>) -> Self { ... }
    fn toggle(&self) -> bool { ... }
}
```

---

```rust
/// This kind of LED works with any output
struct LedDriver<MODE> {
    pin: OutputGpio<MODE>,
}

/// Generically support any OutputGpio variant!
impl<MODE> LedDriver<MODE> {
    fn new(pin: OutputGpio<MODE>) -> LedDriver<MODE> { ... }
    fn toggle(&self) -> bool { ... }
}
```

* Nested zero sized types are still zero sized, no matter how deep you nest it