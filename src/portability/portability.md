# Portability

> ❌: This section has not yet been written. Please refer to [embedded-wg#119](https://github.com/rust-lang-nursery/embedded-wg/issues/119) for discussion of this section.

## Building something bigger

> drivers that work for more than one chip

![](./assets/embedded-hal.svg)

* Device Crates (one per chip)
* HAL implementation crates (one per chip)
* embedded-hal (only one)
* Driver Crates (one per external component)
