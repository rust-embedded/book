# 硬件

现在你应该有点熟悉工具和开发过程了。在这部分我们将切换到真正的硬件上；步骤非常相似。让我们深入下去。

## 认识你的硬件

在我们开始之前，你需要了解下你的目标设备的一些特性，因为你将用它们来配置项目:
- ARM 内核。比如 Cortex-M3 。
- ARM 内核包括一个FPU吗?Cortex-M4**F**和Cortex-M7**F**有。
- 目标设备有多少Flash和RAM？比如 256KiB的Flash和32KiB的RAM。
- Flash和RAM映射在地址空间的什么位置?比如 RAM通常位于 `0x2000_0000` 地址处。

你可以在你的设备的数据手册和参考手册上找到这些信息。

这部分，要使用我们的参考硬件，STM32F3DISCOVERY。这个板子包含一个STM32F303VCT6微控制器。这个微控制器拥有:
- 一个Cortex-M4F核心，它包含一个单精度FPU。
- 位于 0x0800_0000 地址的256KiB的Flash。
- 位于 0x2000_0000 地址的40KiB的RAM。(这里还有其它的RAM区域，但是为了方便起见，我们将忽略它)。

## 配置

我们将使用一个新的模板实例从零开始。对于新手，请参考[先前的QEMU]章节，了解如何在没有`cargo-generate`的情况下完成配置。

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

我们将使用 `thumbv7em-none-eabihf`，因为它包括了Cortex-M4F内核．
> **注意**：你可能还记得先前的章节，我们必须要安装所有的目标平台，这个平台是一个新的．
> 所以，不要忘了为这个平台运行安装步骤 `rustup target add thumbv7em-none-eabihf` ．

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
> **注意**：如果你因为某些理由，在对某个编译目标首次编译后，改变了`memory.x`文件，需要在`cargo build`之前执行`cargo clean`。因为`cargo build`可能不会跟踪`memory.x`的更新。

我们将再次使用hello示例作为开始，但是首先我们必须做一个小改变。

在`examples/hello.rs`中，确保`debug::exit()`调用被注释掉了或者移除掉了。它只能用于在QEMU中运行的情况。

```rust,ignore
#[entry]
fn main() -> ! {
    hprintln!("Hello, world!").unwrap();

    // 退出 QEMU
    // 注意 不要在硬件上运行这个；它会打破OpenOCD的状态
    // debug::exit(debug::EXIT_SUCCESS);

    loop {}
}
```

你可以像你之前做的一样，使用`cargo build`检查编译程序，使用`cargo-binutils`观察二进制项。`cortex-m-rt`库可以处理所有让芯片运行起来所需的魔法，几乎所有的Cortex-M CPUs都按同样的方式启动。

``` console
cargo build --example hello
```

## 调试

调试会看起来有点不一样。事实上，取决于不同的目标设备，第一步可能看起来不一样。在这个章节里，我们将展示，调试一个在STM32F3DISCOVERY上运行的程序，所需要的步骤。这作为一个参考。关于调试有关的设备特定的信息，可以看[the Debugonomicon](https://github.com/rust-embedded/debugonomicon)。

像之前一样，我们将进行远程调试，客户端将是一个GDB进程。不同的是，OpenOCD将是服务器。

像是在[安装验证]中做的那样，把你的笔记本/个人电脑和discovery开发板连接起来，检查ST-LINK的短路帽是否被安装了。

[安装验证]: ../intro/install/verify.md

在一个终端上运行 `openocd` 连接到你的开发板上的 ST-LINK 。从模板的根目录运行这个命令；`openocd` 将会选择 `openocd.cfg` 文件，它指出了所使用的接口文件(interface file)和目标文件(target file)。

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

> **注意** 如果你在[安装验证]章节中，发现你的discovery开发板是一个更旧的版本，那么你应该修改你的 `openocd.cfg` 文件，注释掉 `interface/stlink.cfg`，让它去使用 `interface/stlink-v2.cfg` 。

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

在另一个终端，也是从模板的根目录，运行GDB。

``` text
gdb-multiarch -q target/thumbv7em-none-eabihf/debug/examples/hello
```

**注意**: 像之前一样，你可能需要另一个版本的gdb而不是`gdb-multiarch`，取决于你在之前的章节安装了什么工具。这也可能使用的是`arm-none-eabi-gdb`或者只是`gdb` 。

接下来把GDB连接到OpenOCD，它正在等待一个在端口3333上的TCP链接。

``` console
(gdb) target remote :3333
Remote debugging using :3333
0x00000000 in ?? ()
```

接下来使用`load`命令，继续 *flash*(加载) 程序到微控制器上。

``` console
(gdb) load
Loading section .vector_table, size 0x400 lma 0x8000000
Loading section .text, size 0x1518 lma 0x8000400
Loading section .rodata, size 0x414 lma 0x8001918
Start address 0x08000400, load size 7468
Transfer rate: 13 KB/sec, 2489 bytes/write.
```

程序现在被加载了。这个程序使用半主机模式，因此在我们调用半主机模式之前，我们必须告诉OpenOCD使能半主机。你可以使用 `monitor` 命令，发送命令给OpenOCD 。

``` console
(gdb) monitor arm semihosting enable
semihosting is enabled
```

> 通过调用 `monitor help` 命令，你能看到所有的OpenOCD命令。

像我们之前一样，使用一个断点和 `continue` 命令我们可以跳过所有的步骤到 `main` 。

``` console
(gdb) break main
Breakpoint 1 at 0x8000490: file examples/hello.rs, line 11.
Note: automatically using hardware breakpoints for read-only addresses.

(gdb) continue
Continuing.

Breakpoint 1, hello::__cortex_m_rt_main_trampoline () at examples/hello.rs:11
11      #[entry]
```

> **注意** 如果在你使用了上面的`continue`命令后，GDB阻塞住了终端而不是停在了断点处，你可能需要检查下`memory.x`文件中的存储分区的信息，对于你的设备来说是否被正确的设置了起始位置**和**大小 。

使用`step`步进main函数里。

``` console
(gdb) step
halted: PC: 0x08000496
hello::__cortex_m_rt_main () at examples/hello.rs:13
13          hprintln!("Hello, world!").unwrap();
```

在使用了`next`让函数继续执行之后，你应该看到 "Hello, world!" 被打印到了OpenOCD控制台上。

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
消息只打印一次，然后进入定义在19行的无限循环中: `loop {}`

使用 `quit` 命令，你现在可以退出 GDB 了。

``` console
(gdb) quit
A debugging session is active.

        Inferior 1 [Remote target] will be detached.

Quit anyway? (y or n)
```

现在调试比之前多了点步骤，因此我们要把所有步骤打包进一个名为 `openocd.gdb` 的GDB脚本中。这个文件在 `cargo generate` 步骤中被生成，因此不需要任何修改了。让我们看一下:

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

现在运行 `<gdb> -x openocd.gdb target/thumbv7em-none-eabihf/debug/examples/hello` 将会立即把GDB和OpenOCD连接起来，使能半主机，加载程序和启动进程。

另外，你能将 `<gdb> -x openocd.gdb` 放进一个自定义的 runner 中，使 `cargo run` 能编译程序并启动一个GDB会话。这个 runner 在 `.cargo/config.toml` 中，但是它被注释掉了。

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
