# Frequently Asked Questions

- [Does Rust support my device?](#does-rust-support-my-device)
- [(When) will Rust support AVR?](#when-will-rust-support-the-avr-architecture)
- [(When) will Rust support Xtensa?](#when-will-rust-support-the-xtensa-architecture)

## Does Rust support my device?

### Short answer

As of 2018-09-18 the Rust compiler supports cross compiling to these embedded
architectures (see `rustup target list`):

- ARM Cortex-M (since 1.27)
  - `thumbv6m-none-eabi`, Cortex-M0
  - `thumbv7m-none-eabi`, Cortex-M3
  - `thumbv7em-none-eabi`, Cortex-M4 and Cortex-M7
  - `thumbv7em-none-eabihf`, Cortex-M4F and Cortex-M7F
- ARM Cortex-R (1.30-beta)
  - `armebv7r-none-eabi`, big endian Cortex-R4 and Cortex-R5
  - `armebv7r-none-eabihf`, big endian Cortex-R4F and Cortex-R5F
  - `armv7r-none-eabi`, little endian Cortex-R4 and Cortex-R5
  - `armv7r-none-eabihf`, little endian Cortex-R4F and Cortex-R5F
- ARM Linux
  - ARMv5TE (e.g. ARM926EJ-S),
  - ARMv6 (e.g. ARM11 as found in the Raspberry Pi 1 / Zero),
  - ARMv7-A (e.g. Cortex-A8 as found in the Beaglebones),
  - and ARMv8 (e.g. Cortex-A53 as found in the ODROID-C2) ...
  - ... in GNU and MUSL flavors and in soft float and hard float variants;
  - notably, support for ARMv4T (e.g. ARM7) and older versions is missing.
- RISCV (1.30-beta)
  - `riscv32imac-unknown-none-elf`, RV32I base instruction set with M, A and C
  extensions
  - `riscv32imc-unknown-none-elf`, RV32I base instruction set with M, and C
    extensions

`rustc` also supports code generation for the MSP430 architecture (see `rustc
--print target-list`).

In general, ARM Cortex-M and ARM Linux have the most mature ecosystems whereas
the ARM Cortex-R, MSP430 and RISCV ecosystems are in early stages or not as
mature.

For specific device support check [awesome-embedded-rust].

[awesome-embedded-rust]: https://github.com/rust-embedded/awesome-embedded-rust

### Long answer

We can talk about support at different levels: does the compiler support my
device? does the crate ecosystem support my device?

Let's start with compiler support. The compiler supports architectures or ISA
(Instruction Set Architectures) rather than specific devices. Compiler support
can be further divided in two levels: compilation target support and
architecture support.

#### Compilation target support

By compilation target support we mean that you can readily cross compile a crate
for a certain *compilation target* using Cargo. To keep the default installation
slim only the native compilation target is installed and other targets have to
be installed using the `rustup target` subcommand. If `rustup target list` lists
a compilation target that matches your device then Cargo supports cross
compiling to your device.

For example, let's say we want to know if `rustc` supports cross compiling to
32-bit RISCV. We check `rustup target list`

``` console
$ rustup default 1.29.0
$ rustup target list | grep -i riscv || echo not supported
not supported

$ rustup default nightly-2018-09-18 # this date is just an example
$ rustc -V
rustc 1.30.0-nightly (2224a42c3 2018-09-17)
$ rustup target list | grep -i riscv || echo not supported
riscv32imac-unknown-none-elf
riscv32imc-unknown-none-elf
```

This indicates that 1.29 doesn't support 32-bit RISCV but that 1.30 will.

Once you have installed a compilation target using `rustup target add $T` you'll
be able to cross compile crates to it using `cargo build --target $T`.

``` console
$ rustup target add riscv32imac-unknown-none-elf
$ cargo build --target riscv32imac-unknown-none-elf
```

#### Architecture support

If your device doesn't appear in `rustup target list` that doesn't mean that
`rustc` doesn't support your device at all. It could still support code
generation for your device *architecture*. `rustc` uses LLVM to generate machine
code; if the LLVM backend for your device architecture is enabled in `rustc`
then `rustc` can produce assembly and/or object files for that architecture.

The easiest way to list the architectures that LLVM supports is to run
`cargo objdump -- -version` where `cargo-objdump` is one of [`cargo-binutils`]
subcommands.

[`cargo-binutils`]: https://github.com/rust-embedded/cargo-binutils

``` console
$ rustup default nightly-2018-09-18 # this date is just an example
$ rustup component add llvm-tools-preview
$ cargo install cargo-binutils

$ cargo objdump -- -version
LLVM (http://llvm.org/):
  LLVM version 8.0.0svn
  Optimized build.
  Default target: x86_64-unknown-linux-gnu
  Host CPU: skylake

  Registered Targets:
    aarch64    - AArch64 (little endian)
    aarch64_be - AArch64 (big endian)
    arm        - ARM
    arm64      - ARM64 (little endian)
    armeb      - ARM (big endian)
    hexagon    - Hexagon
    mips       - Mips
    mips64     - Mips64 [experimental]
    mips64el   - Mips64el [experimental]
    mipsel     - Mipsel
    msp430     - MSP430 [experimental]
    nvptx      - NVIDIA PTX 32-bit
    nvptx64    - NVIDIA PTX 64-bit
    ppc32      - PowerPC 32
    ppc64      - PowerPC 64
    ppc64le    - PowerPC 64 LE
    riscv32    - 32-bit RISC-V
    riscv64    - 64-bit RISC-V
    sparc      - Sparc
    sparcel    - Sparc LE
    sparcv9    - Sparc V9
    systemz    - SystemZ
    thumb      - Thumb
    thumbeb    - Thumb (big endian)
    wasm32     - WebAssembly 32-bit
    wasm64     - WebAssembly 64-bit
    x86        - 32-bit X86: Pentium-Pro and above
    x86-64     - 64-bit X86: EM64T and AMD64
```

If your device architecture is not there that means `rustc` doesn't support your
device. It could be that LLVM doesn't support the architecture (e.g. Xtensa,
ESP8266's architecture) or that LLVM's support for the architecture is not
considered stable enough and has not been enabled in `rustc` (e.g. AVR, the
architecture most commonly found in Arduino microcontrollers).

If your device architecture is there then that means that, in principle, `rustc`
supports your device. However, an architecture like ARM can be very broad
covering several ISAs and extensions. Instead, you'll want to work with a
compilation target tailored to your device. Custom compilation targets are out
of scope for this document; you should refer to the [embedonomicon] for more
information.

[embedonomicon]: https://rust-embedded.github.io/embedonomicon/compiler-support.html

#### Crate ecosystem support

Crate ecosystem support can range from generic support for the architecture to
device-specific support. We recommend that you search on crates.io for the
architecture (e.g. ARM or Cortex-M), for the microcontroller vendor (e.g.
STM32), for the target device (e.g. STM32F103) and the target development board
(e.g. STM32F3DISCOVERY). We also suggest that you check the
[awesome-embedded-rust] list and [the crates maintained by the embedded Working
Group][wg-crates].

[wg-crates]: https://github.com/rust-embedded/wg#organization

## (When) will Rust support the AVR architecture?

As of 2018-09-19 the official Rust compiler, `rustc`, relies on LLVM for
generating machine code. It's a requirement that LLVM supports an architecture
for `rustc` to support it.

LLVM does support the AVR architecture but the AVR backend has bugs that prevent
it from being enabled in `rustc`. In particular, the AVR backend should be able
to compile the `core` crate without hitting any LLVM assertion before it's
enabled in `rustc`. A likely outdated list of LLVM bugs that need to be fixed
can be found in [the issue tracker of the the rust-avr fork of rustc][rust-avr].

[rust-var]: https://github.com/avr-rust/rust/issues

TL;DR `rustc` will support the AVR architecture when the LLVM backend is
relatively bug free. As LLVM is a project independent of the Rust project we
can't give you any estimate on when that might happen.

## (When) will Rust support the Xtensa architecture?

As of 2018-09-19 the official Rust compiler, `rustc`, relies on LLVM for
generating machine code. It's a requirement that LLVM supports an architecture
for `rustc` to support it.

There is no support for the Xtensa architecture in LLVM proper. You may be able
to find several forks of LLVM with varying levels of support for the Xtensa
architecture but `rustc` will not be able to use any of those forks due to the
maintenance and infrastructure costs of developing `rustc` against different
versions of LLVM.

TL;DR `rustc` will support the Xtensa architecture when the official LLVM gains
support for the Xtensa architecture. As LLVM is a project independent of the
Rust project we can't give you any estimate on when that might happen.
