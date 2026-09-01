# QEMU

We'll start writing a program for the [LM3S6965], a Cortex-M3 microcontroller.
We have chosen this as our initial target because it [can be emulated](https://wiki.qemu.org/Documentation/Platforms/ARM#Supported_in_qemu-system-arm) using QEMU
so you don't need to fiddle with hardware in this section and we can focus on
the tooling and the development process.

[LM3S6965]: http://www.ti.com/product/LM3S6965

**IMPORTANT**
We'll use the name "app" for the project name in this tutorial.
Whenever you see the word "app" you should replace it with the name you selected
for your project. Or, you could also name your project "app" and avoid the
substitutions.

## Creating a non standard Rust program

We'll use the [`cortex-m-quickstart`] project template to generate a new
project from it. The created project will contain a barebone application: a good
starting point for a new embedded rust application. In addition, the project will
contain an `examples` directory, with several separate applications, highlighting
some of the key embedded rust functionality. 

[`cortex-m-quickstart`]: https://github.com/rust-embedded/cortex-m-quickstart

### Using `cargo-generate`
First install cargo-generate
```console
cargo install cargo-generate
```
Then generate a new project
```console
cargo generate --git https://github.com/knurling-rs/app-template
```

```text
 Project Name: app
 Creating project called `app`...
 Done! New project created /tmp/app
```

```console
cd app
```

### Using `git`

Clone the repository

```console
git clone https://github.com/rust-embedded/cortex-m-quickstart app
cd app
```

And then fill in the placeholders in the `Cargo.toml` file

```toml
[package]
authors = ["{{authors}}"] # "{{authors}}" -> "John Smith"
edition = "2018"
name = "{{project-name}}" # "{{project-name}}" -> "app"
version = "0.1.0"

# ..

[[bin]]
name = "{{project-name}}" # "{{project-name}}" -> "app"
test = false
bench = false
```

### Using neither

Grab the latest snapshot of the `cortex-m-quickstart` template and extract it.

```console
curl -LO https://github.com/rust-embedded/cortex-m-quickstart/archive/master.zip
unzip master.zip
mv cortex-m-quickstart-master app
cd app
```

Or you can browse to [`cortex-m-quickstart`], click the green "Clone or
download" button and then click "Download ZIP".

Then fill in the placeholders in the `Cargo.toml` file as done in the second
part of the "Using `git`" version.

## Program Overview

The template puts each of its programs in `src/bin`, and puts the code they
share in `src/lib.rs`. For convenience here are the most important parts of
`src/bin/hello.rs`:

```rust,ignore
#![no_main]
#![no_std]

use app as _; // global logger + panicking-behavior + memory layout

#[cortex_m_rt::entry]
fn main() -> ! {
    defmt::println!("Hello, world!");

    app::exit()
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

`use app as _;` pulls in the library half of the template, `src/lib.rs`. We never
call into it directly, but linking it in is what gives the program its global
logger, its memory layout, and a `panic_handler` that defines the panicking
behavior of the program. We will cover panicking in more detail in the
[Panicking](panicking.md) chapter of the book.

[`#[cortex_m_rt::entry]`][entry] is an attribute provided by the [`cortex-m-rt`] crate that's used
to mark the entry point of the program. As we are not using the standard `main`
interface we need another way to indicate the entry point of the program and
that'd be `#[entry]`.

[entry]: https://docs.rs/cortex-m-rt/latest/cortex_m_rt/attr.entry.html
[`cortex-m-rt`]: https://crates.io/crates/cortex-m-rt

`fn main() -> !`. Our program will be the *only* process running on the target
hardware so we don't want it to end! We use a [divergent function](https://doc.rust-lang.org/rust-by-example/fn/diverging.html) (the `-> !`
bit in the function signature) to ensure at compile time that'll be the case.
`app::exit()` also diverges: rather than returning, it asks the debug host (QEMU,
in our case) to terminate the whole emulated machine.

## Cross compiling

First of all we will need the memory layout for the target microcontroller, the
LM3S6965 in our case. Otherwise the build will fail to link the image. Create a
file named `memory.x` at the root of the project and paste the following content:

```text
MEMORY
{
  /* NOTE 1 K = 1 KiBi = 1024 bytes */
  /* TODO Adjust these memory regions to match your device memory layout */
  /* These values correspond to the LM3S6965, one of the few devices QEMU can emulate */
  FLASH : ORIGIN = 0x00000000, LENGTH = 256K
  RAM : ORIGIN = 0x20000000, LENGTH = 64K
}

/* This is where the call stack will be allocated. */
/* The stack is of the full descending type. */
/* You may want to use this variable to locate the call stack and static
   variables in different memory regions. Below is shown the default value */
/* _stack_start = ORIGIN(RAM) + LENGTH(RAM); */

/* You can use this symbol to customize the location of the .text section */
/* If omitted the .text section will be placed right after the .vector_table
   section */
/* This is required only on microcontrollers that store some configuration right
   after the vector table */
/* _stext = ORIGIN(FLASH) + 0x400; */

/* Example of putting non-initialized variables into custom RAM locations. */
/* This assumes you have defined a region RAM2 above, and in the Rust
   sources added the attribute `#[link_section = ".ram2bss"]` to the data
   you want to place there. */
/* Note that the section will not be zero-initialized by the runtime! */
/* SECTIONS {
     .ram2bss (NOLOAD) : ALIGN(4) {
       *(.ram2bss);
       . = ALIGN(4);
     } > RAM2
   } INSERT AFTER .bss;
*/
```

The next step is to *cross* compile the program for the Cortex-M3 architecture.
That's as simple as running `cargo build --target $TRIPLE` if you know what the
compilation target (`$TRIPLE`) should be. The `.cargo/config.toml` in the
template lists the choices:

```console
grep -A6 '^\[build\]' .cargo/config.toml
```

```toml
[build]
# TODO(3) Adjust the compilation target.
# Select the correct target for your processor:
target = "thumbv6m-none-eabi"    # Cortex-M0 and Cortex-M0+
# target = "thumbv7m-none-eabi"    # Cortex-M3
# target = "thumbv7em-none-eabi"   # Cortex-M4 and Cortex-M7 (no FPU)
# target = "thumbv7em-none-eabihf" # Cortex-M4F and Cortex-M7F (with FPU)
```

To cross compile for the Cortex-M3 architecture we have to use
`thumbv7m-none-eabi`, so comment out the `thumbv6m-none-eabi` line that the
template selects by default and uncomment the `thumbv7m-none-eabi` one. This is
`TODO(3)` in the template; the remaining `TODO`s concern real hardware and can be
left alone for this chapter.

That target is not automatically installed when installing the Rust toolchain, so
it would now be a good time to add it to the toolchain, if you haven't done it
yet:

``` console
rustup target add thumbv7m-none-eabi
```

 Since the `thumbv7m-none-eabi` compilation target has been set as the default in 
 your `.cargo/config.toml` file, the two commands below do the same:

```console
cargo build --target thumbv7m-none-eabi
cargo build
```

## Inspecting

Now we have a non-native ELF binary in `target/thumbv7m-none-eabi/debug/hello`.
We can inspect it using `cargo-binutils`. (The template does not build a binary
named after the project, so we inspect one of the programs in `src/bin`.)

With `cargo-readobj` we can print the ELF headers to confirm that this is an ARM
binary.

``` console
cargo readobj --bin hello -- --file-headers
```

Note that:
* `--bin hello` is sugar for inspect the binary at `target/$TRIPLE/debug/hello`
* `--bin hello` will also (re)compile the binary, if necessary


``` text
ELF Header:
  Magic:   7f 45 4c 46 01 01 01 03 00 00 00 00 00 00 00 00
  Class:                             ELF32
  Data:                              2's complement, little endian
  Version:                           1 (current)
  OS/ABI:                            UNIX - GNU
  ABI Version:                       0
  Type:                              EXEC (Executable file)
  Machine:                           ARM
  Version:                           0x1
  Entry point address:               0x401
  Start of program headers:          52 (bytes into file)
  Start of section headers:          910896 (bytes into file)
  Flags:                             0x5000200
  Size of this header:               52 (bytes)
  Size of program headers:           32 (bytes)
  Number of program headers:         6
  Size of section headers:           40 (bytes)
  Number of section headers:         22
  Section header string table index: 20
```

`cargo-size` can print the size of the linker sections of the binary.


```console
cargo size --bin hello --release -- -A
```
we use `--release` to inspect the optimized version

``` text
hello  :
section              size        addr
.vector_table        1024         0x0
.text                3816       0x400
.rodata               628      0x12e8
.data                  56  0x2000fbb8
.gnu.sgstubs            0      0x15a0
.bss                   12  0x2000fbf0
.uninit              1024  0x2000fbfc
.defmt                  6         0x0
.debug_loc           3831         0x0
.debug_abbrev        2736         0x0
.debug_info         29645         0x0
.debug_aranges       2312         0x0
.debug_ranges        3200         0x0
.debug_str          58040         0x0
.comment              139         0x0
.ARM.attributes        48         0x0
.debug_frame         1456         0x0
.debug_line         11262         0x0
Total              119235
```

> A refresher on ELF linker sections
>
> These are the sections that are loaded onto the device:
>
> - `.vector_table` is a *non*-standard section that we use to store the vector
>   (interrupt) table
> - `.text` contains the program instructions
> - `.rodata` contains constant values like strings
> - `.data` contains statically allocated variables whose initial values are
>   *not* zero
> - `.bss` also contains statically allocated variables whose initial values
>   *are* zero
> - `.uninit` holds statics that must *not* be initialized at startup; here it is
>   the buffer `defmt-rtt` logs into
> - `.gnu.sgstubs` holds secure gateway veneers, the entry points through which
>   non-secure code calls into secure code on ARMv8-M devices with TrustZone. The
>   Cortex-M3 has no TrustZone, so the linker leaves this section empty
>
> The rest is metadata. It stays in the ELF file on your host and is *not* loaded
> onto the target when flashing the binary:
>
> - `.defmt` is another *non*-standard section; it stores the log strings that
>   `defmt` keeps on the host instead of on the device, which is why it has no
>   address and costs no flash
> - `.debug_info` is the bulk of the DWARF debug data: the tree of types,
>   functions and variables that make up the program
> - `.debug_abbrev` describes the shape of the entries in `.debug_info`
> - `.debug_str` is the string table that those entries share
> - `.debug_line` maps instruction addresses back to source files and line
>   numbers, which is what lets a debugger show you source code as you step
> - `.debug_loc` records where each variable lives -- in which register, or where
>   on the stack -- at each point in the program
> - `.debug_ranges` records the address ranges of scopes that are not contiguous
> - `.debug_aranges` maps address ranges to compilation units, so a debugger can
>   find the right one without searching all of `.debug_info`
> - `.debug_frame` describes how to walk back up the call stack, which is what
>   turns a halted program into a backtrace
> - `.comment` records which compiler and linker produced the binary
> - `.ARM.attributes` records the architecture, ABI and FPU the code was built
>   for, so that the linker can reject incompatible objects
>
> You may be surprised that `.data` and `.bss` sit near the *end* of RAM rather
> than at `0x20000000`. That is `flip-link` doing its job: it places the statics
> at the top so that the call stack grows away from them.

**IMPORTANT**: ELF files contain metadata like debug information so their *size
on disk* does *not* accurately reflect the space the program will occupy when
flashed on a device. *Always* use `cargo-size` to check how big a binary really
is.

`cargo-objdump` can be used to disassemble the binary.

```console
cargo objdump --bin hello --release -- --disassemble --no-show-raw-insn --print-imm-hex
```

> **NOTE** if the above command complains about `Unknown command line argument` see
> the following bug report: https://github.com/rust-embedded/book/issues/269

That disassembles the whole program, which runs to some 1500 lines -- most of it
formatting and logging machinery pulled in by the dependencies. To read a single
function instead, name it with `--disassemble-symbols`. Adding `-C` demangles the
Rust symbol names, which is what makes the call targets legible:

```console
cargo objdump --bin hello --release -- --disassemble-symbols=__stext,main -C --no-show-raw-insn --print-imm-hex
```

> **NOTE** this output can differ on your system. New versions of rustc, LLVM
> and libraries can generate different assembly.

```text

hello:	file format elf32-littlearm

Disassembly of section .text:

00000400 <__stext>:
     400:      	bl	0xabc <_defmt_timestamp> @ imm = #0x6b8
     404:      	ldr	r0, [pc, #0x20]         @ 0x428 <__stext+0x28>
     406:      	ldr	r1, [pc, #0x24]         @ 0x42c <__stext+0x2c>
     408:      	movs	r2, #0x0
     40a:      	cmp	r1, r0
     40c:      	beq	0x412 <__stext+0x12>    @ imm = #0x2
     40e:      	stm	r0!, {r2}
     410:      	b	0x40a <__stext+0xa>     @ imm = #-0xa
     412:      	ldr	r0, [pc, #0x1c]         @ 0x430 <__stext+0x30>
     414:      	ldr	r1, [pc, #0x1c]         @ 0x434 <__stext+0x34>
     416:      	ldr	r2, [pc, #0x20]         @ 0x438 <__stext+0x38>
     418:      	cmp	r1, r0
     41a:      	beq	0x422 <__stext+0x22>    @ imm = #0x4
     41c:      	ldm	r2!, {r3}
     41e:      	stm	r0!, {r3}
     420:      	b	0x418 <__stext+0x18>    @ imm = #-0xc
     422:      	bl	0x448 <main>            @ imm = #0x22
     426:      	udf	#0x0

00000448 <main>:
     448:      	push	{r7, lr}
     44a:      	mov	r7, sp
     44c:      	bl	0x43c <hello::__cortex_m_rt_main> @ imm = #-0x14
```

Those two functions are the whole boot sequence. `__stext` is the reset handler,
the first thing the core runs. It calls the `__pre_init` hook, zeroes `.bss` (the
first loop), copies the initial values of `.data` from flash into RAM (the second
loop), and then calls `main`. Note that the zeroing loop stops at the end of
`.bss` and leaves `.uninit` alone, exactly as that section's name promises. The
`udf` -- a deliberate undefined instruction -- sits after the call to trap the
program if `main` ever returns, which is why the entry point has to diverge.

`main` is a three-instruction trampoline into the `#[entry]` function, which
`cortex-m-rt` renames to `hello::__cortex_m_rt_main`. Only global symbols can be
named on the command line and that one is local to the crate, so to read the body
of your own `main` you have to follow the `bl` in the full disassembly.

> **NOTE** the `bl` to `_defmt_timestamp` at `0x400` really is the call to
> `__pre_init`. Both functions are empty, so the linker folds them onto a single
> address -- together with `DefaultPreInit` and `__defmt_default_timestamp` -- and
> the disassembler prints whichever of those names it happens to find first.

## Running

Next, let's see how to run an embedded program on QEMU! This time we'll use the
`hello` program, which actually does something. By default, it uses [`defmt`]
and RTT to print text.

[`defmt`]: https://defmt.ferrous-systems.com/

> **NOTE** `defmt` is a third-party dependency (i.e. non-core) widely used in the
> Embedded Rust ecosystem.

In order to read and decode the messages produced by `defmt` in the host, we need to
switch the RTT transport output to semihosting. When using real hardware this requires
a debug session but when using QEMU this Just Works.

Let's switch the dependencies:

```console
cargo remove defmt-rtt
cargo add defmt-semihosting
```

Open `src/lib.rs` and replace `use defmt_rtt as _;` by `use defmt_semihosting as _;`

Now we can build the program:

```console
cargo build --bin hello
```

The output binary will be located at
`target/thumbv7m-none-eabi/debug/hello`.

For a program that printed plain text, the following command would be enough to
run the binary on QEMU:

```console
qemu-system-arm \
  -cpu cortex-m3 \
  -machine lm3s6965evb \
  -nographic \
  -semihosting-config enable=on,target=native \
  -kernel target/thumbv7m-none-eabi/debug/hello
```

`defmt`, though, does not send plain text. To keep the program on the device
small it sends compact binary frames and leaves the log strings on the host, so
the command above prints a handful of unreadable bytes rather than a greeting.
To turn those frames back into text we use [`qemu-run`], which we installed in
the [installation](../intro/install.md) chapter:

[`qemu-run`]: https://crates.io/crates/qemu-run

```console
qemu-run --machine lm3s6965evb --cpu cortex-m3 target/thumbv7m-none-eabi/debug/hello
```

```text
Hello, world!
```

`qemu-run` starts `qemu-system-arm` for you with the flags shown above, then
decodes the `defmt` data the program sends over semihosting.

The command should successfully exit (exit code = 0) after printing the text. On
*nix you can check that with the following command:

```console
echo $?
```

```text
0
```

Let's break down the QEMU command that `qemu-run` builds for us:

- `qemu-system-arm`. This is the QEMU emulator. There are a few variants of
  these QEMU binaries; this one does full *system* emulation of *ARM* machines
  hence the name.

- `-cpu cortex-m3`. This tells QEMU to emulate a Cortex-M3 CPU. Specifying the
  CPU model lets us catch some miscompilation errors: for example, running a
  program compiled for the Cortex-M4F, which has a hardware FPU, will make QEMU
  error during its execution.

- `-machine lm3s6965evb`. This tells QEMU to emulate the LM3S6965EVB, an
  evaluation board that contains a LM3S6965 microcontroller.

- `-nographic`. This tells QEMU to not launch its GUI.

- `-semihosting-config (..)`. This tells QEMU to enable semihosting. Semihosting
  lets the emulated device, among other things, use the host stdout, stderr and
  stdin and create files on the host.

- `-kernel $file`. This tells QEMU which binary to load and run on the emulated
  machine.

Typing out that command every time is too much work! We can set a custom runner
to simplify the process. The template ships a runner that flashes real hardware
with `probe-rs`; replace it with one that runs the program on QEMU instead:

```console
head -n4 .cargo/config.toml
```

```toml
[target.'cfg(all(target_arch = "arm", target_os = "none"))']
# TODO(2) replace `$CHIP` with your chip's name (see `probe-rs chip list` output)
runner = ["probe-rs", "run", "--chip", "$CHIP", "--log-format=oneline"]
# If you have an nRF52, you might also want to add "--allow-erase-all" to the list
```

```toml
[target.'cfg(all(target_arch = "arm", target_os = "none"))']
runner = ["qemu-run", "--machine", "lm3s6965evb", "--cpu", "cortex-m3"]
```

Now `cargo run` will compile the program and run it on QEMU:

```console
cargo run --bin hello --release
```

```text
   Compiling app v0.1.0 (file:///tmp/app)
    Finished `release` profile [optimized + debuginfo] target(s) in 0.26s
     Running `qemu-run --machine lm3s6965evb --cpu cortex-m3 target/thumbv7m-none-eabi/release/hello`
Hello, world!
```

The template also defines a `rb` alias, so `cargo rb hello` is shorthand for
`cargo run --bin hello`.

> **NOTE** This runner suits the programs in this chapter, which all log with
> `defmt`. Some later chapters -- [Semihosting], [Panicking] and [Exceptions] --
> still print with `cortex-m-semihosting`'s `hprintln!` instead. That is plain
> text rather than `defmt` frames, and `qemu-run` will try to decode it as frames
> and display nothing at all, so switch the runner back to plain
> `qemu-system-arm` before working through those:
>
> ```toml
> [target.'cfg(all(target_arch = "arm", target_os = "none"))']
> runner = "qemu-system-arm -cpu cortex-m3 -machine lm3s6965evb -nographic -semihosting-config enable=on,target=native -kernel"
> ```

[Semihosting]: semihosting.md
[Panicking]: panicking.md
[Exceptions]: exceptions.md

## Debugging

Debugging is critical to embedded development. Let's see how it's done.

Debugging an embedded device involves *remote* debugging as the program that we
want to debug won't be running on the machine that's running the debugger
program (GDB or LLDB).

Remote debugging involves a client and a server. In a QEMU setup, the client
will be a GDB (or LLDB) process and the server will be the QEMU process that's
also running the embedded program.

In this section we'll use the `hello` program we already compiled.

The first debugging step is to launch QEMU in debugging mode. `qemu-run` forwards
any `--arg` it is given on to QEMU, so we can keep using it and still get our
`defmt` output decoded:

```console
qemu-run \
  --machine lm3s6965evb \
  --cpu cortex-m3 \
  --arg gdb=tcp::3333 \
  --arg S \
  target/thumbv7m-none-eabi/debug/hello
```

This command won't print anything to the console and will block the terminal. We
have passed two extra flags this time, which `qemu-run` turns into `-gdb tcp::3333`
and `-S`:

- `-gdb tcp::3333`. This tells QEMU to wait for a GDB connection on TCP
  port 3333.

- `-S`. This tells QEMU to freeze the machine at startup. Without this the
  program would have reached the end of main before we had a chance to launch
  the debugger!

Next we launch GDB in another terminal and tell it to load the debug symbols of
the example:

```console
gdb-multiarch -q target/thumbv7m-none-eabi/debug/hello
```

**NOTE**: you might need another version of gdb instead of `gdb-multiarch` depending
on which one you installed in the installation chapter. This could also be
`arm-none-eabi-gdb` or just `gdb`.

Then within the GDB shell we connect to QEMU, which is waiting for a connection
on TCP port 3333.

```console
target remote :3333
```

```text
Remote debugging using :3333
0x00000400 in core::num::imp::flt2dec::strategy::grisu::format_exact_opt ()
```

You'll see that the process is halted, with the program counter pointing at
address `0x400`. That is the reset handler: what Cortex-M cores execute upon
booting.

> Note the nonsensical symbol name. `cortex-m-rt` writes the reset handler in
> assembly, so that address carries no debug info and GDB attaches whatever
> unrelated symbol happens to be nearby. The exact name you see will differ. That
> is a known glitch and you can safely ignore it; you are at the reset handler.


This reset handler will eventually call our main function. Let's skip all the
way there using a breakpoint and the `continue` command. To set the breakpoint, let's first take a look where we would like to break in our code, with the `list` command.

```console
list main
```
This will show the source code, from the file src/bin/hello.rs.

```text
1       #![no_main]
2       #![no_std]
3
4       use app as _; // global logger + panicking-behavior + memory layout
5
6       #[cortex_m_rt::entry]
7       fn main() -> ! {
8           defmt::println!("Hello, world!");
9
10          app::exit()
```
We would like to add a breakpoint just before the "Hello, world!", which is on line 8. We do that with the `break` command:

```console
break 8
```
We can now instruct gdb to run up to our main function, with the `continue` command:

```console
continue
```

```text
Continuing.

Breakpoint 1, hello::__cortex_m_rt_main () at src/bin/hello.rs:8
8           defmt::println!("Hello, world!");
```

We are now close to the code that prints "Hello, world!". Let's move forward
using the `next` command.

``` console
next
```

```text
10          app::exit()
```

At this point you should see "Hello, world!" printed on the terminal that's
running `qemu-run`.

```text
$ qemu-run (..)
Hello, world!
```

Calling `next` again will terminate the QEMU process.

```console
next
```

```text
[Inferior 1 (Remote target) exited normally]
```

You can now exit the GDB session.

``` console
quit
```
