# Writing your first embedded Rust program

> ❌: This section is work in progress. Please refer to
> [embedded-wg#117](https://github.com/rust-lang-nursery/embedded-wg/issues/117)
> for discussion of this section.

In this section we'll walk you through the process of writing, building,
flashing and debugging an embedded Rust program.

## Emulated device

We'll start writing a program for the [LM3S6965], a Cortex-M3 microcontroller.
We have chosen this as our initial target because it can be emulated using QEMU
so you don't need to fiddle with hardware in this section and we can focus on
the tooling and the development process.

[LM3S6965]: http://www.ti.com/product/LM3S6965

### A non standard Rust program

We'll use the [`cortex-m-quickstart`] project template so go generate a new
project from it.

[`cortex-m-quickstart`]: https://github.com/rust-embedded/cortex-m-quickstart#cortex-m-quickstart

``` console
$ cargo generate --git https://github.com/rust-embedded/cortex-m-quickstart
 Project Name: app
 Creating project called `app`...
 Done! New project created /tmp/app

$ cd app
```

**IMPORTANT** We'll use the name "app" for the project name in this tutorial.
Whenever you see the word "app" you should replace it with the name you selected
for your project. Or, you could also name your project "app" and avoid the
substitutions.

For convenience here's the source code of `src/main.rs`:

``` console
$ cat src/main.rs
```

``` rust
#![no_std]
#![no_main]

// pick a panicking behavior
extern crate panic_halt; // you can put a breakpoint on `rust_begin_unwind` to catch panics
// extern crate panic_abort; // requires nightly
// extern crate panic_itm; // logs messages over ITM; requires ITM support
// extern crate panic_semihosting; // logs messages to the host stderr; requires a debugger

use cortex_m_rt::entry;

#[entry]
fn main() -> ! {
    loop {
        // your code goes here
    }
}
```

This program is a bit different from a standard Rust program so let's take a
closer look.

`#![no_std]` indicates that this program will *not* link to the standard crate,
`std`. Instead it will link to its subset: the `core` crate.

`#![no_main]` indicates that this program won't use the standard `main`
interface that most Rust programs use. The main (no pun intended) reason to go
with `no_main` is that using the `main` interface in `no_std` context requires
nightly.

`extern crate panic_halt;`. This crate provides a `panic_handler` that defines
the panicking behavior of the program. More on this later on.

[`#[entry]`] is an attribute provided by the [`cortex-m-rt`] crate that's used
to mark the entry point of the program. As we are not using the standard `main`
interface we need another way to indicate the entry point of the program and
that'd be `#[entry]`.

[`#[entry]`]: https://rust-embedded.github.io/cortex-m-rt/0.6.1/cortex_m_rt_macros/fn.entry.html
[`cortex-m-rt`]: https://crates.io/crates/cortex-m-rt

`fn main() -> !`. Our program will be the *only* process running on the target
hardware so we don't want it to end! We use a divergent function (the `-> !`
bit in the function signature) to ensure at compile time that'll be the case.

### Cross compiling

The next step is to *cross* compile the program for the Cortex-M3 architecture.
That's as simple as running `cargo build --target $TRIPLE` if you know what the
compilation target (`$TRIPLE`) should be. Luckily, the `.cargo/config` in the
template has the answer:

``` console
$ tail -n6 .cargo/config
```

``` toml
[build]
# Pick ONE of these compilation targets
# target = "thumbv6m-none-eabi"    # Cortex-M0 and Cortex-M0+
target = "thumbv7m-none-eabi"    # Cortex-M3
# target = "thumbv7em-none-eabi"   # Cortex-M4 and Cortex-M7 (no FPU)
# target = "thumbv7em-none-eabihf" # Cortex-M4F and Cortex-M7F (with FPU)
```

To cross compile for the Cortex-M3 architecture we have to use
`thumbv7m-none-eabi`. This compilation target has been set as the default so the
two commands below do the same:

``` console
$ cargo build --target thumbv7m-none-eabi

$ cargo build
```

### Inspecting

Now we have a non-native ELF binary in `target/thumbv7m-none-eabi/debug/app`. We
can inspect it using `cargo-binutils`.

With `cargo-readobj` we can print the ELF headers to confirm that this is an ARM
binary.

``` console
$ # `--bin app` is sugar for inspect the binary at `target/$TRIPLE/debug/app`
$ # `--bin app` will also (re)compile the binary, if necessary

$ cargo readobj --bin app -- -file-headers
```

``` text
ELF Header:
  Magic:   7f 45 4c 46 01 01 01 00 00 00 00 00 00 00 00 00
  Class:                             ELF32
  Data:                              2's complement, little endian
  Version:                           1 (current)
  OS/ABI:                            UNIX - System V
  ABI Version:                       0x0
  Type:                              EXEC (Executable file)
  Machine:                           ARM
  Version:                           0x1
  Entry point address:               0x405
  Start of program headers:          52 (bytes into file)
  Start of section headers:          153204 (bytes into file)
  Flags:                             0x5000200
  Size of this header:               52 (bytes)
  Size of program headers:           32 (bytes)
  Number of program headers:         2
  Size of section headers:           40 (bytes)
  Number of section headers:         19
  Section header string table index: 18
```

`cargo-size` can print the size of the linker sections of the binary.

<!-- NOTE this output assumes that rust-embedded/cortex-m-rt#111 has been merged -->

``` console
$ # we use `--release` to inspect the optimized version

$ cargo size --bin app --release -- -A
```

``` text
app  :
section             size        addr
.vector_table       1024         0x0
.text                 92       0x400
.rodata                0       0x45c
.data                  0  0x20000000
.bss                   0  0x20000000
.debug_str          2958         0x0
.debug_loc            19         0x0
.debug_abbrev        567         0x0
.debug_info         4929         0x0
.debug_ranges         40         0x0
.debug_macinfo         1         0x0
.debug_pubnames     2035         0x0
.debug_pubtypes     1892         0x0
.ARM.attributes       46         0x0
.debug_frame         100         0x0
.debug_line          867         0x0
Total              14570
```

> A refresher on ELF linker sections
>
> - `.text` contains the program instructions
> - `.rodata` contains constant values like strings
> - `.data` contains statically allocated variables whose initial values are
>   *not* zero
> - `.bss` also contains statically allocated variables whose initial values
>   *are* zero
> - `.vector_table` is a *non*-standard section that we use to store the vector
>   (interrupt) table
> - `.ARM.attributes` and the `.debug_*` sections contain metadata and will
>   *not* be loaded onto the target when flashing the binary.

**IMPORTANT**: ELF files contain metadata like debug information so their *size
on disk* does *not* accurately reflect the space the program will occupy when
flashed on a device. *Always* use `cargo-size` to check how big a binary really
is.

`cargo-objdump` can be used to disassemble the binary.

``` console
$ cargo objdump --bin app --release -- -disassemble -no-show-raw-insn -print-imm-hex
```

<!-- NOTE this output assumes that rust-embedded/cortex-m-rt#111 has been merged -->

``` text
app:    file format ELF32-arm-little

Disassembly of section .text:
Reset:
     400:       bl      #0x36
     404:       movw    r0, #0x0
     408:       movw    r1, #0x0
     40c:       movt    r0, #0x2000
     410:       movt    r1, #0x2000
     414:       bl      #0x2c
     418:       movw    r0, #0x0
     41c:       movw    r1, #0x45c
     420:       movw    r2, #0x0
     424:       movt    r0, #0x2000
     428:       movt    r1, #0x0
     42c:       movt    r2, #0x2000
     430:       bl      #0x1c
     434:       b       #-0x4 <Reset+0x34>

UserHardFault_:
     436:       b       #-0x4 <UserHardFault_>

UsageFault:
     438:       b       #-0x4 <UsageFault>

__pre_init:
     43a:       bx      lr

HardFault:
     43c:       mrs     r0, msp
     440:       bl      #-0xe

__zero_bss:
     444:       movs    r2, #0x0
     446:       b       #0x0 <__zero_bss+0x6>
     448:       stm     r0!, {r2}
     44a:       cmp     r0, r1
     44c:       blo     #-0x8 <__zero_bss+0x4>
     44e:       bx      lr

__init_data:
     450:       b       #0x2 <__init_data+0x6>
     452:       ldm     r1!, {r3}
     454:       stm     r0!, {r3}
     456:       cmp     r0, r2
     458:       blo     #-0xa <__init_data+0x2>
     45a:       bx      lr
```

### Running

Next, let's see how to run an embedded program on QEMU! This time we'll use the
`hello` example which actually does something.

For convenience here's the source code of `src/main.rs`:

``` console
$ cat examples/hello.rs
```

``` rust
//! Prints "Hello, world!" on the host console using semihosting

#![no_main]
#![no_std]

extern crate panic_halt;

use core::fmt::Write;

use cortex_m_rt::entry;
use cortex_m_semihosting::{debug, hio};

#[entry]
fn main() -> ! {
    let mut stdout = hio::hstdout().unwrap();
    writeln!(stdout, "Hello, world!").unwrap();

    // exit QEMU or the debugger section
    debug::exit(debug::EXIT_SUCCESS);

    loop {}
}
```

This program uses something called semihosting to print text to the *host*
console. When using real hardware this requires a debug session but when using
QEMU this Just Works.

Let's start by compiling the example:

``` console
$ cargo build --example hello
```

The output binary will be located at
`target/thumbv7m-none-eabi/debug/examples/hello`.

To run this binary on QEMU run the following command:

``` console
$ qemu-system-arm \
      -cpu cortex-m3 \
      -machine lm3s6965evb \
      -nographic \
      -semihosting-config enable=on,target=native \
      -kernel target/thumbv7m-none-eabi/debug/examples/hello
Hello, world!
```

The command should successfully exit (exit code = 0) after printing the text. On
*nix you can check that with the following command:

``` console
$ echo $?
0
```

Let me break down that long QEMU command for you:

- `qemu-system-arm`. This is the QEMU emulator. There are a few variants of
  these QEMU binaries; this one does full *system* emulation of *ARM* machines
  hence the name.

- `-cpu cortex-m3`. This tells QEMU to emulate a Cortex-M3 CPU. Specifying the
  CPU model lets us catch some miscompilation errors: for example, running a
  program compiled for the Cortex-M4F, which has a hardware FPU, will make QEMU
  error during its execution.

- `-machine lm3s6965evb`. This tells QEMU to emulate the LM3S6965EVB, a
  evaluation board that contains a LM3S6965 microcontroller.

- `-nographic`. This tells QEMU to not launch its GUI.

- `-semihosting-config (..)`. This tells QEMU to enable semihosting. Semihosting
  lets the emulated device, among other things, use the host stdout, stderr and
  stdin and create files on the host.

- `-kernel $file`. This tells QEMU which binary to load and run on the emulated
  machine.

Typing out that long QEMU command is too much work! We can set a custom runner
to simplify the process. `.cargo/config` has a commented out runner that invokes
QEMU; let's uncomment it:

``` console
$ head -n3 .cargo/config
```

``` toml
[target.thumbv7m-none-eabi]
# uncomment this to make `cargo run` execute programs on QEMU
runner = ["qemu-system-arm", "-cpu", "cortex-m3", "-machine", "lm3s6965evb", "-nographic", "-semihosting-config", "enable=on,target=native", "-kernel"]
```

This runner only applies to the `thumbv7m-none-eabi` target, which is our
default compilation target. Now `cargo run` will compile the program and run it
on QEMU:

``` console
$ cargo run --example hello --release
   Compiling app v0.1.0 (file:///tmp/app)
    Finished release [optimized + debuginfo] target(s) in 0.26s
     Running `qemu-system-arm -cpu cortex-m3 -machine lm3s6965evb -nographic -semihosting-config enable=on,target=native -kernel target/thumbv7m-none-eabi/release/examples/hello`
Hello, world!
```

### Debugging

Debugging is critical to embedded development. Let's see how it's done.

Debugging an embedded device involves *remote* debugging as the program that we
want to debug won't be running on the machine that's running the debugger
program (GDB or LLDB).

Remote debugging involves a client and a server. In a QEMU setup, the client
will be a GDB (or LLDB) process and the server will be the QEMU process that's
also running the embedded program.

In this section we'll use the `hello` example we already compiled.

The first debugging step is to launch QEMU in debugging mode:

``` console
$ qemu-system-arm \
      -cpu cortex-m3 \
      -machine lm3s6965evb \
      -nographic \
      -semihosting-config enable=on,target=native \
      -gdb tcp::3333 \
      -S \
      -kernel target/thumbv7m-none-eabi/debug/examples/hello
```

This command won't print anything to the console and will block the terminal. We
have passed two extra flags this time:

- `-gdb tcp::3333`. This tells QEMU to wait for a GDB connection on TCP
  port 3333.

- `-S`. This tells QEMU to freeze the machine at startup. Without this the
  program would have reached the end of main before we had a chance to launch
  the debugger!

Next we launch GDB in another terminal and tell it to load the debug symbols of
the example:

``` console
$ <gdb> -q target/thumbv7m-none-eabi/debug/examples/hello
```

**NOTE**: <gdb> represents a GDB program capable of debugging ARM binaries. This
could be `gdb`, `arm-none-eabi-gdb` or `gdb-multiarch` depending on your system
-- you may have to try all three.

Then within the GDB shell we connect to QEMU, which is waiting for a connection
on TCP port 3333.

``` console
(gdb) target remote :3333
Remote debugging using :3333
Reset () at $REGISTRY/cortex-m-rt-0.6.1/src/lib.rs:473
473     pub unsafe extern "C" fn Reset() -> ! {
```

You'll see that the process is halted and that the program counter is pointing
to a function named `Reset`. That is the reset handler: what Cortex-M cores
execute upon booting.

This reset handler will eventually call our main function. Let's skip all the
way there using a breakpoint and the `continue` command:

``` console
(gdb) break main
Breakpoint 1 at 0x400: file examples/panic.rs, line 29.

(gdb) continue
Continuing.

Breakpoint 1, main () at examples/hello.rs:17
17          let mut stdout = hio::hstdout().unwrap();
```

We are now close to the code that prints "Hello, world!". Let's move forward
using the `next` command.

``` console
(gdb) next
18          writeln!(stdout, "Hello, world!").unwrap();

(gdb) next
20          debug::exit(debug::EXIT_SUCCESS);
```

At this point you should see "Hello, world!" printed on the terminal that's
running `qemu-system-arm`.

``` console
$ qemu-system-arm (..)
Hello, world!
```

Calling `next` again will terminate the QEMU process.

``` console
(gdb) next
[Inferior 1 (Remote target) exited normally]
```

You can now exit the GDB session.

``` console
(gdb) quit
```

## Real hardware

By now you should be somewhat familiar with the tooling and the development
process. In this section we'll switch to real hardware; the process will remain
largely the same. Let's dive in.

### Know your hardware

Before we begin you need to identify some characteristics of the target device
as these will be used to configure the project:

- The ARM core. e.g. Cortex-M3.

- Does the ARM core include an FPU? Cortex-M4**F** and Cortex-M7**F** cores do.

- How much Flash memory and RAM does the target device has? e.g. 256 KiB of
  Flash and 32 KiB of RAM.

- Where are Flash memory and RAM mapped in the address space? e.g. RAM is
  commonly located at address `0x2000_0000`.

You can find this information in the data sheet or the reference manual of your
device.

In this section we'll be using our reference hardware, the STM32F3DISCOVERY.
This board contains an STM32F303VCT6 microcontroller. This microcontroller has:

- A Cortex-M4F core that includes a single precision FPU

- 256 KiB of Flash located at address 0x0800_0000.

- 40 KiB of RAM located at address 0x2000_0000. (There's another RAM region but
  for simplicity we'll ignore it).

### Configuring

We'll start from scratch with a fresh template instance:

``` console
$ cargo generate --git https://github.com/rust-embedded/cortex-m-quickstart
 Project Name: app
 Creating project called `app`...
 Done! New project created /tmp/app

 $ cd app
```

Step number one is to set a default compilation target in `.cargo/config`.

``` console
$ tail -n5 .cargo/config
```

``` toml
# Pick ONE of these compilation targets
# target = "thumbv6m-none-eabi"    # Cortex-M0 and Cortex-M0+
# target = "thumbv7m-none-eabi"    # Cortex-M3
# target = "thumbv7em-none-eabi"   # Cortex-M4 and Cortex-M7 (no FPU)
target = "thumbv7em-none-eabihf" # Cortex-M4F and Cortex-M7F (with FPU)
```

We'll use `thumbv7em-none-eabihf` as that covers the Cortex-M4F core.

The second step is to enter the memory region information into the `memory.x`
file.

``` console
$ cat memory.x
/* Linker script for the STM32F303VCT6 */
MEMORY
{
  /* NOTE 1 K = 1 KiBi = 1024 bytes */
  FLASH : ORIGIN = 0x08000000, LENGTH = 256K
  RAM : ORIGIN = 0x20000000, LENGTH = 40K
}
```

There's no step three. You can now cross compile programs using `cargo build`
and inspect the binaries using `cargo-binutils` as you did before.

``` console
$ cargo build --example hello
```

### Debugging

Debugging will look a bit different. In fact, the first steps can look different
depending on the target device. In this section we'll show the steps required to
debug a program running on the STM32F3DISCOVERY. This is meant to serve as a
reference; for device specific about debugging check out the [New Book
(temporary name)](https://github.com/rust-embedded/new-book).

As before we'll do remote debugging and the client will be a GDB process. This
time, however, the server will be OpenOCD.

On a terminal run `openocd` to connect to the ST-LINK on the discovery board.
Run this command from the root of the template; `openocd` will pick up the
`openocd.cfg` file which indicates which interface file and target file to use.

``` console
$ cat openocd.cfg
```

``` text
source [find interface/stlink-v2-1.cfg]
source [find target/stm32f3x.cfg]
```

``` console
$ openocd
Open On-Chip Debugger 0.10.0
Licensed under GNU GPL v2
For bug reports, read
        http://openocd.org/doc/doxygen/bugs.html
Info : auto-selecting first available session transport "hla_swd". To override use 'transport select <transport>'.
adapter speed: 1000 kHz
adapter_nsrst_delay: 100
Info : The selected transport took over low-level target control. The results might differ compared to plain JTAG/SWD
none separate
Info : Unable to match requested speed 1000 kHz, using 950 kHz
Info : Unable to match requested speed 1000 kHz, using 950 kHz
Info : clock speed 950 kHz
Info : STLINK v2 JTAG v27 API v2 SWIM v15 VID 0x0483 PID 0x374B
Info : using stlink api v2
Info : Target voltage: 2.913879
Info : stm32f3x.cpu: hardware has 6 breakpoints, 4 watchpoints
```

On another terminal run GDB, also from the root of the template.

``` console
$ <gdb> -q target/thumbv7em-none-eabihf/debug/examples/hello
```

Next connect GDB to OpenOCD, which is waiting for a TCP connection on port 3333.

``` console
(gdb) target remote :3333
Remote debugging using :3333
0x00000000 in ?? ()
```

Now proceed to *flash* (load) the program onto the microcontroller using the
`load` command.

``` console
(gdb) load
Loading section .vector_table, size 0x400 lma 0x8000000
Loading section .text, size 0x1e70 lma 0x8000400
Loading section .rodata, size 0x61c lma 0x8002270
Start address 0x800144e, load size 10380
Transfer rate: 17 KB/sec, 3460 bytes/write.
```

The program is now loaded. This program uses semihosting so before we do any
semihosting call we have to tell OpenOCD to enable semihosting. You can send
commands to OpenOCD using the `monitor` command.

``` console
(gdb) monitor arm semihosting enable
semihosting is enabled
```

> You can see all the OpenOCD commands by invoking the `monitor help` command.

Like before we can skip all the way to `main` using a breakpoint and the
`continue` command.

``` console
(gdb) break main
Breakpoint 1 at 0x8000d18: file examples/hello.rs, line 15.

(gdb) continue
Continuing.
Note: automatically using hardware breakpoints for read-only addresses.

Breakpoint 1, main () at examples/hello.rs:15
15          let mut stdout = hio::hstdout().unwrap();
```

Advancing the program with `next` should produce the same results as before.

``` console
(gdb) next
16          writeln!(stdout, "Hello, world!").unwrap();

(gdb) next
19          debug::exit(debug::EXIT_SUCCESS);
```

At this point you should see "Hello, world!" printed on the OpenOCD console,
among other stuff.

``` console
$ openocd
(..)
Info : halted: PC: 0x08000e6c
Hello, world!
Info : halted: PC: 0x08000d62
Info : halted: PC: 0x08000d64
Info : halted: PC: 0x08000d66
Info : halted: PC: 0x08000d6a
Info : halted: PC: 0x08000a0c
Info : halted: PC: 0x08000d70
Info : halted: PC: 0x08000d72
```

Issuing another `next` will make the processor execute `debug::exit`. This acts
as a breakpoint and halts the process:

``` console
(gdb) next

Program received signal SIGTRAP, Trace/breakpoint trap.
0x0800141a in __syscall ()
```

It also causes this to be printed to the OpenOCD console:

``` console
$ openocd
(..)
Info : halted: PC: 0x08001188
semihosting: *** application exited ***
Warn : target not halted
Warn : target not halted
target halted due to breakpoint, current mode: Thread
xPSR: 0x21000000 pc: 0x08000d76 msp: 0x20009fc0, semihosting
```

However, the process running on the microcontroller has not terminated and you
can resume it using `continue` or a similar command.

You can now exit GDB using the `quit` command.

``` console
(gdb) quit
```

Debugging now requires a few more steps so we have packed all those steps into a
single GDB script named `openocd.gdb`.

``` console
$ cat openocd.gdb
```

``` text
target remote :3333

# print demangled symbols
set print asm-demangle on

# detect unhandled exceptions, hard faults and panics
break DefaultHandler
break UserHardFault
break rust_begin_unwind

monitor arm semihosting enable

load

# start the process but immediately halt the processor
stepi
```

Now running `<gdb> -x openocd.gdb $program` will immediately connect GDB to
OpenOCD, enable semihosting, load the program and start the process.

Alternatively, you can turn `<gdb> -x openocd.gdb` into a custom runner to make
`cargo run` build a program *and* start a GDB session. This runner is included
in `.cargo/config` but it's commented out.

``` console
$ head -n10 .cargo/config
```

``` toml
[target.thumbv7m-none-eabi]
# uncomment this to make `cargo run` execute programs on QEMU
# runner = "qemu-system-arm -cpu cortex-m3 -machine lm3s6965evb -nographic -semihosting-config enable=on,target=native -kernel"

[target.'cfg(all(target_arch = "arm", target_os = "none"))']
# uncomment ONE of these three option to make `cargo run` start a GDB session
# which option to pick depends on your system
runner = "arm-none-eabi-gdb -x openocd.gdb"
# runner = "gdb-multiarch -x openocd.gdb"
# runner = "gdb -x openocd.gdb"
```

``` console
$ cargo run --example hello
(..)
Loading section .vector_table, size 0x400 lma 0x8000000
Loading section .text, size 0x1e70 lma 0x8000400
Loading section .rodata, size 0x61c lma 0x8002270
Start address 0x800144e, load size 10380
Transfer rate: 17 KB/sec, 3460 bytes/write.
(gdb)
```

## I/O

> **TODO**
