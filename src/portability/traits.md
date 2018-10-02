# The Trait System

```rust
/// Single digital push-pull output pin
pub trait OutputPin {
    /// Drives the pin low
    fn set_low(&mut self);

    /// Drives the pin high
    fn set_high(&mut self);
}
```

[rust-embedded/embedded-hal](https://github.com/rust-embedded/embedded-hal/blob/master/src/digital.rs)

```rust
impl<MODE> OutputPin for OutputGpio<MODE> {
    fn set_low(&mut self) {
        self.set_pin_low()
    }

    fn set_high(&mut self) {
        self.set_pin_high()
    }
}
```

> this goes in your chip crate


```rust
impl<SPI, CS, E> L3gd20<SPI, CS>
where
    SPI: Transfer<u8, Error = E> + Write<u8, Error = E>,
    CS: OutputPin,
{
    /// Creates a new driver from a SPI peripheral
    /// and a NCS (active low chip select) pin
    pub fn new(spi: SPI, cs: CS) -> Result<Self, E> {
        // ...
    }
    // ...
}
```

[japaric/l3gd20](https://github.com/japaric/l3gd20/blob/master/src/lib.rs)

## N\*M >>> N+M

> to re-use a driver, just implement the embedded-hal interface