# Summary

<!--

Definition of the organization of this book is still a work in process.

Refer to https://github.com/rust-lang-nursery/embedded-wg/issues/115 for
more information and coordination

-->

- [Introduction](./intro/introduction.md)
    - [Installation](./intro/install.md)
        - [Linux](./intro/install/linux.md)
        - [MacOS](./intro/install/macos.md)
        - [Windows](./intro/install/windows.md)
        - [Verify Installation](./intro/install/verify.md)
    - [Tooling](./intro/tooling.md)
    - [Hardware](./intro/hardware.md)
    - [`no_std`](./intro/no-std.md)
- [Blinking your first LED](./blinky/blinky.md)
- [Peripherals](./peripherals/peripherals.md)
    - [Arbitrary Memory](./peripherals/arbitrary.md)
    - [A first attempt in Rust](./peripherals/a-first-attempt.md)
    - [The Borrow Checker](./peripherals/borrowck.md)
    - [Singletons](./peripherals/singletons.md)
    - [Peripherals in Rust](./peripherals/rusty.md)
- [Static Guarantees](./static-guarantees/static-guarantees.md)
    - [Strong Types](./static-guarantees/strong-types.md)
    - [Design Contracts](./static-guarantees/design-contracts.md)
    - [Zero Cost Abstractions](./static-guarantees/zero-cost-abstractions.md)
- [Portability](./portability/portability.md)
    - [The Trait System](./portability/traits.md)
    <!-- TODO: Define more sections -->
- [Concurrency](./concurrency/concurrency.md)
    <!-- TODO: Define Sections -->
- [Collections](./collections/collections.md)
    <!-- TODO: Define Sections -->
- [Tips for embedded C developers](./c-tips/c-tips.md)
    <!-- TODO: Define Sections -->
- [Interoperability](./interoperability/interoperability.md)
    - [A little C with your Rust](./interoperability/c-with-rust.md)
    - [A little Rust with your C](./interoperability/rust-with-c.md)
