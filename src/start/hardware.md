# Hardware

By now you should be somewhat familiar with the tooling and the development
process. In this section we'll switch to real hardware; the process will remain
largely the same. Let's dive in.

## Know your hardware

Before we begin you need to identify some characteristics of the target device
as these will be used to configure the project:

- The ARM core. e.g. Cortex-M3.

- Does the ARM core include an FPU? Cortex-M4**F** and Cortex-M7**F** cores do.

- How much Flash memory and RAM does the target device have? e.g. 256 KiB of
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

## Configuring

We'll start from scratch with a fresh template instance. Refer to the
[previous section on QEMU] for a refresher on how to do this without
`cargo-generate`.

[previous section on QEMU]: qemu.md

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

Make sure the `debug::exit()` call is commented out or removed, it is used
only for running in QEMU.

``` rust
#[entry]
fn main() -> ! {
    hprintln!("Hello, world!").unwrap();

    // exit QEMU
    // NOTE do not run this on hardware; it can corrupt OpenOCD state
    // debug::exit(debug::EXIT_SUCCESS);

    loop {}
}
```

You can now cross compile programs using `cargo build`
and inspect the binaries using `cargo-binutils` as you did before. The
`cortex-m-rt` crate handles all the magic required to get your chip running,
as helpfully, pretty much all Cortex-M CPUs boot in the same fashion.

``` console
$ cargo build --example hello
```

## Debugging

Debugging will look a bit different. In fact, the first steps can look different
depending on the target device. In this section we'll show the steps required to
debug a program running on the STM32F3DISCOVERY. This is meant to serve as a
reference; for device specific information about debugging check out [the
Debugonomicon](https://github.com/rust-embedded/debugonomicon).

As before we'll do remote debugging and the client will be a GDB process. This
time, however, the server will be OpenOCD.

As done during the [verify] section connect the discovery board to your laptop /
PC and check that the ST-LINK header is populated.

[verify]: ../intro/install/verify.md

On a terminal run `openocd` to connect to the ST-LINK on the discovery board.
Run this command from the root of the template; `openocd` will pick up the
`openocd.cfg` file which indicates which interface file and target file to use.

``` console
$ cat openocd.cfg
```

``` text
# Sample OpenOCD configuration for the STM32F3DISCOVERY development board

# Depending on the hardware revision you got you'll have to pick ONE of these
# interfaces. At any time only one interface should be commented out.

# Revision C (newer revision)
source [find interface/stlink-v2-1.cfg]

# Revision A and B (older revisions)
# source [find interface/stlink-v2.cfg]

source [find target/stm32f3x.cfg]
```

> **NOTE** If you found out that you have an older revision of the discovery
> board during the [verify] section then you should modify the `openocd.cfg`
> file at this point to use `interface/stlink-v2.cfg`.

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

**NOTE**: `<gdb>` represents a GDB program capable of debugging ARM binaries.
This could be `arm-none-eabi-gdb`, `gdb-multiarch` or `gdb` depending on your
system -- you may have to try all three.

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
