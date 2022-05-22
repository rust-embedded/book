# 硬件

现在你应该有点熟悉工具和开发过程了。这部分我们将转换到真正的硬件上；步骤非常相似。让我们深入进去。

## 认识你的硬件

在我们开始之前，你需要认识你的目标设备的一些特性，因为它们将被用于配置项目:
- ARM 核心。e.g. Cortex-M3 。
- ARM 核心包括一个FPU吗?Cortex-M4**F**和Cortex-M7**F**有。
- 目标设备有多少Flash和RAM？e.g. 256KiB的Flash和32KiB的RAM。
- Flash和RAM映射在地址空间什么位置?e.g. RAM通常位于 `0x2000_0000` 地址处。

你可以在你的设备的数据手册和参考手册上找到这些信息。

这部分，我们会用我们的参考硬件，STM32F3DISCOVERY。这个板子包含一个STM32F303VCT6微控制器。这个微控制器拥有:
- 一个Cortex-M4F核心，它包含一个单精度FPU。
- 位于 0x0800_0000 地址的256KiB的Flash。
- 位于 0x2000_0000 地址的40KiB的RAM。(这里还有其它的RAM区域，但是为了简便，我们将忽略它)。

## 配置

我们将从一个新的模板实例开始。参考[先前的QEMU]章节，了解如何在没有`cargo-generate`的情况下完成它。

[先前的QEMU]: qemu.md

``` text
$ cargo generate --git https://github.com/rust-embedded/cortex-m-quickstart
 Project Name: app
 Creating project called `app`...
 Done! New project created /tmp/app

$ cd app
```

第一步是在`.cargo/config.toml`中设置一个默认编译目标。

``` console
tail -n5 .cargo/config.toml
```

``` toml
# Pick ONE of these compilation targets
# target = "thumbv6m-none-eabi"    # Cortex-M0 and Cortex-M0+
# target = "thumbv7m-none-eabi"    # Cortex-M3
# target = "thumbv7em-none-eabi"   # Cortex-M4 and Cortex-M7 (no FPU)
target = "thumbv7em-none-eabihf" # Cortex-M4F and Cortex-M7F (with FPU)
```

我们将使用`thumbv7em-none-eabihf`，因为它覆盖Cortex-M4F核。

第二步是将存储区域信息(memory region information)输入`memory.x`。

``` text
$ cat memory.x
/* Linker script for the STM32F303VCT6 */
MEMORY
{
  /* NOTE 1 K = 1 KiBi = 1024 bytes */
  FLASH : ORIGIN = 0x08000000, LENGTH = 256K
  RAM : ORIGIN = 0x20000000, LENGTH = 40K
}
```
> **注意**：如果你因为一些理由，在对一个特定构建目标第一次构建后，改变了`memory.x`文件，需要在`cargo build`之前执行`cargo clean`。因为`cargo build`可能不会跟踪`memory.x`的更新。

我们将使用hello示例再次开始，但是首先我们必须做一个小改变。

在`examples/hello.rs`中，确保`debug::exit()`调用被注释掉了或者移除。它只能用于在QEMU中运行时。

```rust,ignore
#[entry]
fn main() -> ! {
    hprintln!("Hello, world!").unwrap();

    // exit QEMU
    // NOTE do not run this on hardware; it can corrupt OpenOCD state
    // debug::exit(debug::EXIT_SUCCESS);

    loop {}
}
```

你能像你之前做的一样，使用`cargo build`检查编译程序，使用`cargo-binutils`观察二进制文件。`cortex-m-rt`库可以处理所有运行芯片所需的魔法，同样有用的是，几乎所有的Cortex-M CPUs都按同样的方式启动。

``` console
cargo build --example hello
```

## 调试

调试将看起来有点不同。事实上，取决于不同的目标设备，第一步可能看起来不一样。在这个章节里，我们将展示，调试一个在STM32F3DISCOVERY上运行的程序，所需要的步骤。这作为一个参考。对于设备，关于调试的，特定的信息，可以看[the
Debugonomicon](https://github.com/rust-embedded/debugonomicon)。

像之前一样，我们将进行远程调试，客户端将是一个GDB进程。不同的是，OpenOCD将是服务器。

就像之前在
As done during the [verify] section connect the discovery board to your laptop /
PC and check that the ST-LINK header is populated.

[verify]: ../intro/install/verify.md

On a terminal run `openocd` to connect to the ST-LINK on the discovery board.
Run this command from the root of the template; `openocd` will pick up the
`openocd.cfg` file which indicates which interface file and target file to use.

``` console
cat openocd.cfg
```

``` text
# Sample OpenOCD configuration for the STM32F3DISCOVERY development board

# Depending on the hardware revision you got you'll have to pick ONE of these
# interfaces. At any time only one interface should be commented out.

# Revision C (newer revision)
source [find interface/stlink.cfg]

# Revision A and B (older revisions)
# source [find interface/stlink-v2.cfg]

source [find target/stm32f3x.cfg]
```

> **NOTE** If you found out that you have an older revision of the discovery
> board during the [verify] section then you should modify the `openocd.cfg`
> file at this point to use `interface/stlink-v2.cfg`.

``` text
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

``` text
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

> **NOTE** If GDB blocks the terminal instead of hitting the breakpoint after
> you issue the `continue` command above, you might want to double check that
> the memory region information in the `memory.x` file is correctly set up
> for your device (both the starts *and* lengths). 

Advancing the program with `next` should produce the same results as before.

``` console
(gdb) next
16          writeln!(stdout, "Hello, world!").unwrap();

(gdb) next
19          debug::exit(debug::EXIT_SUCCESS);
```

At this point you should see "Hello, world!" printed on the OpenOCD console,
among other stuff.

``` text
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

``` text
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
single GDB script named `openocd.gdb`. The file was created during the `cargo generate` step, and should work without any modifications. Let's have a peak:

``` console
cat openocd.gdb
```

``` text
target extended-remote :3333

# print demangled symbols
set print asm-demangle on

# detect unhandled exceptions, hard faults and panics
break DefaultHandler
break HardFault
break rust_begin_unwind

monitor arm semihosting enable

load

# start the process but immediately halt the processor
stepi
```

Now running `<gdb> -x openocd.gdb target/thumbv7em-none-eabihf/debug/examples/hello` will immediately connect GDB to
OpenOCD, enable semihosting, load the program and start the process.

Alternatively, you can turn `<gdb> -x openocd.gdb` into a custom runner to make
`cargo run` build a program *and* start a GDB session. This runner is included
in `.cargo/config.toml` but it's commented out.

``` console
head -n10 .cargo/config.toml
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

``` text
$ cargo run --example hello
(..)
Loading section .vector_table, size 0x400 lma 0x8000000
Loading section .text, size 0x1e70 lma 0x8000400
Loading section .rodata, size 0x61c lma 0x8002270
Start address 0x800144e, load size 10380
Transfer rate: 17 KB/sec, 3460 bytes/write.
(gdb)
```
