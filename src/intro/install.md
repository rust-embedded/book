> **⚠️: This section still references `beta` Rust**
>
> Contents should be updated to work on `stable` Rust when possible

> **⚠️: This section was last checked on 2018-09-13**

# Setting up a development environment

Dealing with microcontrollers involves several tools as we'll be dealing with an architecture
different than your laptop's and we'll have to run and debug programs on a *remote* device.

<!-- NOTE(japaric) I'm not sure we are going to need the user to download *all* -->
<!-- these docs so I'm going to comment out this section. If it turns out we do -->
<!-- need some doc I think it would be best to link it from the section where -->
<!-- it's needed -->

<!-- ## Documentation -->

<!-- Tooling is not everything though. Without documentation is pretty much impossible to work with microcontrollers. -->

<!-- We'll be referring to all these documents throughout this book: -->

<!-- *HEADS UP* All these links point to PDF files and some of them are hundreds of pages long and -->
<!-- several MBs in size. -->

<!-- - [STM32F3DISCOVERY User Manual][um] -->
<!-- - [STM32F303VC Datasheet][ds] -->
<!-- - [STM32F303VC Reference Manual][rm] -->
<!-- - [LSM303DLHC] -->
<!-- - [L3GD20] -->

<!-- [L3GD20]: http://www.st.com/resource/en/datasheet/l3gd20.pdf -->
<!-- [LSM303DLHC]: http://www.st.com/resource/en/datasheet/lsm303dlhc.pdf -->
<!-- [ds]: http://www.st.com/resource/en/datasheet/stm32f303vc.pdf -->
<!-- [rm]: http://www.st.com/resource/en/reference_manual/dm00043574.pdf -->
<!-- [um]: http://www.st.com/resource/en/user_manual/dm00063382.pdf -->

## Tools

We'll use all the tools listed below. Where a minimum version is not specified, any recent version should work but we have listed the version we have tested.

- Rust 1.30, 1.30-beta, nightly-2018-09-13, or a newer toolchain PLUS ARM
  Cortex-M compilation support.
- [`cargo-generate`](https://github.com/ashleygwilliams/cargo-generate) ~0.1.1
- [`cargo-binutils`](https://github.com/rust-embedded/cargo-binutils) ~0.1.4
- [`qemu-system-arm`](https://www.qemu.org/). Tested versions: 3.0.0
- OpenOCD >=0.8. Tested versions: v0.9.0 and v0.10.0
- GDB with ARM support. Version 7.12 or newer highly recommended. Tested
  versions: 7.10, 7.11, 7.12 and 8.1

Next, follow OS-agnostic installation instructions for a few of the tools:

### Rust toolchain

Install rustup by following the instructions at [https://rustup.rs](https://rustup.rs).

Then switch to the beta channel.

``` console
$ rustup default beta
```

**NOTE** Make sure you have a beta equal to or newer than `1.30-beta`. `rustc
-V` should return a date newer than the one shown below:

``` console
$ rustc -V
rustc 1.30.0-beta (????????? 2018-09-1?)
```

For bandwidth and disk usage reasons the default installation only supports
native compilation. To add cross compilation support for the ARM Cortex-M
architecture install the following compilation targets.

``` console
$ rustup target add thumbv6m-none-eabi thumbv7m-none-eabi thumbv7em-none-eabi thumbv7em-none-eabihf
```

### `cargo-generate`

Follow [these installation
instructions](https://github.com/ashleygwilliams/cargo-generate/tree/v0.1.1#installation).

### `cargo-binutils`

``` console
$ cargo install cargo-binutils

$ rustup component add llvm-tools-preview
```

### OS specific instructions

Now follow the instructions specific to the OS you are using:

- [Linux](/intro/install/linux.html)
- [Windows](/intro/install/windows.html)
- [macOS](/intro/install/macos.html)
