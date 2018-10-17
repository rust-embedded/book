# Tooling

This section contains details about the tools we'll be using.

## `cargo-generate` OR `git`

Bare metal programs are non-standard (`no_std`) Rust programs that require some
fiddling with the linking process to get the memory layout of the program
right. All this requires unusual files (like linker scripts) and unusual
settings (like linker flags). We have packaged all that for you in templates
so that you only need to fill in the blanks such as the project name and the
characteristics of your target hardware.

Our templates are compatible with [`cargo-generate`](https://github.com/ashleygwilliams/cargo-generate): a Cargo subcommand for
creating new Cargo projects from templates. You can also download the
template using `git`, `curl`, `wget`, or your web browser.

The cortex-m template is available [here](https://github.com/rust-embedded/cortex-m-quickstart).

## `cargo-binutils`

`cargo-binutils` is a collection of Cargo subcommands that make it easy to use
the LLVM tools that are shipped with the Rust toolchain. These tools include the
LLVM versions of `objdump`, `nm` and `size` and are used for inspecting
binaries.

The advantage of using these tools over GNU binutils is that (a) installing the
LLVM tools is the same one-command installation (`rustup component add
llvm-tools-preview`) regardless of your OS and (b) tools like `objdump` support
all the architectures that `rustc` supports -- from ARM to x86_64 -- because
they both share the same LLVM backend.

## `qemu-system-arm`

QEMU is an emulator. In this case we use the variant that can fully emulate ARM
systems. We use QEMU to run embedded programs on the host. Thanks to this you
can follow some parts of this book even if you don't have any hardware with you!

## OpenOCD

> **TODO** What is this, what is it used for, and why are we using this tool?

## GDB

Debugging is very important skill for embedded development as you may not always
have the luxury to log stuff to the host console. In some cases, you may not
have LEDs to blink on your hardware!

In general, LLDB works as well as GDB when it comes to debugging but we haven't
found an LLDB counterpart to GDB's `load` command, which uploads the program to
the target hardware, so currently we recommend that you use GDB.
