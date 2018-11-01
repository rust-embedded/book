# Tooling

This section contains details about the tools we'll be using.

## `cargo-generate` OR `git`

Bare metal programs are non-standard (`no_std`) Rust programs that require some
fiddling with the linking process to get the memory layout of the program
right. All this requires unusual files (like linker scripts) and unusual
settings (like linker flags). We have packaged all that for you in a template
so that you only need to fill in the blanks such as the project name and the
characteristics of your target hardware.

Our template is compatible with `cargo-generate`: a Cargo subcommand for
creating new Cargo projects from templates. You can also download the
template using `git`, `curl`, `wget`, or your web browser.

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

## GDB

Debugging is very important skill for embedded development as you may not always
have the luxury to log stuff to the host console. In some cases, you may not
have LEDs to blink on your hardware!

In general, LLDB works as well as GDB when it comes to debugging but we haven't
found an LLDB counterpart to GDB's `load` command, which uploads the program to
the target hardware, so currently we recommend that you use GDB.

## OpenOCD

GDB isn't able to communicate directly with the ST-Link debugging hardware on
your STM32F3DISCOVERY development board. It needs a translator and the Open
On-Chip Debugger, OpenOCD, is that translator. OpenOCD is a program that runs
on your laptop/PC and translates between GDB's TCP/IP based remote debug
protocol and ST-Link's USB based protocol.

OpenOCD also performs other important work as part of its translation for the
debugging of the ARM Cortex-M based microcontroller on your STM32F3DISCOVERY
development board:
* It knows how to interact with the memory mapped registers used by the ARM
  CoreSight debug peripheral. It is these CoreSight registers that allow for:
  * Breakpoint/Watchpoint manipulation
  * Reading and writing of the CPU registers
  * Detecting when the CPU has been halted for a debug event
  * Continuing CPU execution after a debug event has been encountered
  * etc.
* It also knows how to erase and write to the microcontroller's FLASH

