# Installing the tools

This page contains OS-agnostic installation instructions for a few of the tools:

### Rust Toolchain

Install rustup by following the instructions at [https://rustup.rs](https://rustup.rs).

**NOTE** Make sure you have a compiler version equal to or newer than `1.31`. `rustc
-V` should return a date newer than the one shown below.

``` console
$ rustc -V
rustc 1.31.1 (b6c32da9b 2018-12-18)
```

For bandwidth and disk usage concerns the default installation only supports
native compilation. To add cross compilation support for the ARM Cortex-M
architectures choose one of the following compilation targets. For the STM32F3DISCOVERY
board used for the examples in this book, use the final `thumbv7em-none-eabihf` target.

Cortex-M0, M0+, and M1 (ARMv6-M architecture):
``` console
$ rustup target add thumbv6m-none-eabi
```

Cortex-M3 (ARMv7-M architecture):
``` console
$ rustup target add thumbv7m-none-eabi
```

Cortex-M4 and M7 without hardware floating point (ARMv7E-M architecture):
``` console
$ rustup target add thumbv7em-none-eabi
```

Cortex-M4F and M7F with hardware floating point (ARMv7E-M architecture):
``` console
$ rustup target add thumbv7em-none-eabihf
```

### `cargo-binutils`

``` console
$ cargo install cargo-binutils

$ rustup component add llvm-tools-preview
```

### `cargo-generate`

We'll use this later to generate a project from a template.

``` console
$ cargo install cargo-generate
```

### OS-Specific Instructions

Now follow the instructions specific to the OS you are using:

- [Linux](install/linux.md)
- [Windows](install/windows.md)
- [macOS](install/macos.md)
