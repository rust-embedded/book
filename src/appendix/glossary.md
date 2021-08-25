# Appendix A: Glossary

The embedded ecosystem is full of different protocols, hardware components and
vendor-specific things that use their own terms and abbreviations. This Glossary
attempts to list them with pointers for understanding them better.

### BSP

A Board Support Crate provides a high level interface configured for a specific developer
board. It usually depends on a [HAL](#hal) crate.
There is a more detailed description on the [memory mapper registers page](../start/registers.md).

### FPU

Floating-point Unit. A 'math processor' running only operations on floating-point numbers.

### HAL

A Hardware Abstraction Layer crate provides a developer friendly interface to a microcontroller's
features and peripherals. It is usually implemented on top of a [Peripheral Access Crate (PAC)](#pac).
It may also implement traits from the [`embedded-hal`](https://crates.io/crates/embedded-hal) crate.
There is a more detailed description on the [memory mapper registers page](../start/registers.md).

### I2C

Sometimes referred to as `I² C` or Inter-IC. It is a protocol meant for hardware communication
within a single integrated circuit. See [i2c.info] for more details

[i2c.info]: https://i2c.info/

### PAC

A Peripheral Access Crate provides access to a microcontroller's peripherals. It is one of
the lower level crates and is usually generated directly from the provided [SVD](#svd), often
using [svd2rust](https://github.com/rust-embedded/svd2rust/). The [Hardware Abstraction Layer](#hal)
would usually depend on this crate.
There is a more detailed description on the [memory mapper registers page](../start/registers.md).

### SPI

Serial Peripheral Interface

### SVD

System View Description is an XML file format used to describe the programmers view of a
microcontroller device. You can read more about it on
[the ARM CMSIS documentation site](https://www.keil.com/pack/doc/CMSIS/SVD/html/index.html).

### UART

Universal asynchronous receiver-transmitter

### USART

Universal synchronous and asynchronous receiver-transmitter
