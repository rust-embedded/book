# QEMU
我们将开始为[LM3S6965]编写程序，一个Cortex-M3微控制器。我们选择这个作为我们的第一个目标办，因为他能使用[QEMU仿真](https://wiki.qemu.org/Documentation/Platforms/ARM#Supported_in_qemu-system-arm)，因此本节中，你不需要摆弄硬件，我们注意力可以集中在工具和开发过程上。

[LM3S6965]: http://www.ti.com/product/LM3S6965

**重要**
在这个引导里，我们将使用"app"这个名字来代指项目名。无论何时你看到单词"app"你应该用你选择的项目名来替代它。或者你也能命名你的项目为"app"，避免替代。

## 生成一个非标准的 Rust program
我们将使用[`cortex-m-quickstart`]项目模板来生成一个新项目。生成的项目将包含一个最基本的应用:对于一个新的嵌入式rust应用来说，是一个很好的起点。另外，项目将包含一个`example`文件夹，文件夹中有许多独立的应用，突出一些关键的嵌入式rust功能。

[`cortex-m-quickstart`]: https://github.com/rust-embedded/cortex-m-quickstart

### 使用 `cargo-generate`
首先安装 cargo-generate
```console
cargo install cargo-generate
```
然后生成一个新项目
```console
cargo generate --git https://github.com/rust-embedded/cortex-m-quickstart
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

克隆仓库

```console
git clone https://github.com/rust-embedded/cortex-m-quickstart app
cd app
```

然后补充`Cargo.toml`文件中的占位符

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

## 项目概览

为了便利，这是`src/main.rs`中源码最重要的部分。

```rust,ignore
#![no_std]
#![no_main]

use panic_halt as _;

use cortex_m_rt::entry;

#[entry]
fn main() -> ! {
    loop {
        // your code goes here
    }
}
```

这个程序与标准Rust程序有一点不同，因此让我们走进点看看。

`#![no_std]`指出这个程序将*不会*链接标准crate`std`。反而它将会链接到它的子集: `core`crate。

`#![no_main]`指出这个程序将不会使用标准的大多数Rust程序使用的`main`接口。使用`no_main`的主要理由是在`no_std`上下文中使用`main`接口要求nightly(译者注：原文是`requires nightly`，不知道有什么合适的翻译，主要的理由是`main`接口对程序的运行环境有要求，比如，它假设命令行参数存在，这不适合`no_std`环境)。

`use panic_halt as _;`。这个crate提供了一个`panic_handler`，它定义了程序陷入`panic`时的行为。我们将会在这本书的[Panicking](panicking.md)章节中覆盖更多的细节。

[`#[entry]`][entry] 是一个由[`cortex-m-rt`]提供的属性，它用来标记程序的入口。当我们不使用标准的`main`接口时，我们需要其它方法来指示程序的入口，那就是`#[entry]`。

[entry]: https://docs.rs/cortex-m-rt-macros/latest/cortex_m_rt_macros/attr.entry.html
[`cortex-m-rt`]: https://crates.io/crates/cortex-m-rt

`fn main() -> !`。我们的程序将会是运行在目标板子上的*唯一*的进程，因此我们不想要它结束！我们使用一个[divergent function](https://doc.rust-lang.org/rust-by-example/fn/diverging.html) (函数签名中的 `-> !` 位)确保在编译时就是这么回事儿。

## 交叉编译
下一步是位Cortex-M3架构*交叉*编译程序。如果你知道编译目标(`$TRIPLE`)应该是什么，那就和运行`cargo build --target $TRIPLE`一样简单。幸运地，模板中的`.cargo/config.toml`有这个答案:
```console
tail -n6 .cargo/config.toml
```
```toml
[build]
# Pick ONE of these compilation targets
# target = "thumbv6m-none-eabi"    # Cortex-M0 and Cortex-M0+
target = "thumbv7m-none-eabi"    # Cortex-M3
# target = "thumbv7em-none-eabi"   # Cortex-M4 and Cortex-M7 (no FPU)
# target = "thumbv7em-none-eabihf" # Cortex-M4F and Cortex-M7F (with FPU)
```
为了交叉编译Cortex-M3架构我们不得不使用`thumbv7m-none-eabi`。当安装Rust工具时，target不会自动被安装，如果你还没有做，现在是个好时机添加那个target到工具链上。
``` console
rustup target add thumbv7m-none-eabi
```
因为`thumbv7m-none-eabi`编译目标在你的`.cargo/config.toml`中被设置成默认值，下面的两个命令是一样的效果:
```console
cargo build --target thumbv7m-none-eabi
cargo build
```

## 检查

现在我们在`target/thumbv7m-none-eabi/debug/app`中有一个非原生的ELF二进制文件。我们能使用`cargo-binutils`检查它。

使用`cargo-readobj`我们能打印ELF头，确认这是一个ARM二进制。

```console
cargo readobj --bin app -- --file-headers
```

注意:
* `--bin app` 是一个用来检查`target/$TRIPLE/debug/app`的语法糖
* `--bin app` 如果需要，将也会重新编译二进制。

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

`cargo-size` 能打印二进制文件的linker部分的大小。

```console
cargo size --bin app --release -- -A
```

我们使用`--release`检查优化的版本

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

> ELF linker sections的新手
>
> - `.text` 包含程序指令
> - `.rodata` 包含像是字符串这样的常量
> - `.data` 包含静态分配的初始值*非*零的变量
> - `.bss` 也包含静态分配的初始值*是*零的变量
> - `.vector_table` 是一个我们用来存储向量(中断)表的*非*标准的section
> - `.ARM.attributes` 和 `.debug_*` sections包含元数据，当烧录二进制文件时，其将不会被加载到目标上的。

**重要**: ELF文件包含像是调试信息这样的元数据，因此它们在*硬盘上的尺寸*不是正确地反应了程序当被烧录到设备上时将占据的空间的大小。*总是*使用`cargo-size`检查一个二进制文件有多大。

`cargo-objdump` 能用来反编译二进制文件。

```console
cargo objdump --bin app --release -- --disassemble --no-show-raw-insn --print-imm-hex
```

> **注意** 如果上面的命令抱怨 `Unknown command line argument` 看下面的bug报告:https://github.com/rust-embedded/book/issues/269

> **注意** 这个输出可能在你的系统上不同。rustc, LLVM 和库的新版本能产出不同的汇编。我们截取了一些指令

```text
app:  file format ELF32-arm-little

Disassembly of section .text:
main:
     400: bl  #0x256
     404: b #-0x4 <main+0x4>

Reset:
     406: bl  #0x24e
     40a: movw  r0, #0x0
     < .. truncated any more instructions .. >

DefaultHandler_:
     656: b #-0x4 <DefaultHandler_>

UsageFault:
     657: strb  r7, [r4, #0x3]

DefaultPreInit:
     658: bx  lr

__pre_init:
     659: strb  r7, [r0, #0x1]

__nop:
     65a: bx  lr

HardFaultTrampoline:
     65c: mrs r0, msp
     660: b #-0x2 <HardFault_>

HardFault_:
     662: b #-0x4 <HardFault_>

HardFault:
     663: <unknown>
```

## 运行

接下来，让我们看一个嵌入式程序是如何在QEMU上运行！这时我们将使用 `hello` 例子，来做些真正的事。

为了方便起见，这是`examples/hello.rs`的源码:

```rust,ignore
//! 在主机调试台上打印 "Hello, world!"

#![no_main]
#![no_std]

use panic_halt as _;

use cortex_m_rt::entry;
use cortex_m_semihosting::{debug, hprintln};

#[entry]
fn main() -> ! {
    hprintln!("Hello, world!").unwrap();

    // 退出 QEMU
    // NOTE 不要在硬件上运行这个;它会打破OpenOCD状态
    debug::exit(debug::EXIT_SUCCESS);

    loop {}
}
```

This program uses something called semihosting to print text to the *host*
console. When using real hardware this requires a debug session but when using
QEMU this Just Works.

Let's start by compiling the example:

```console
cargo build --example hello
```

The output binary will be located at
`target/thumbv7m-none-eabi/debug/examples/hello`.

To run this binary on QEMU run the following command:

```console
qemu-system-arm \
  -cpu cortex-m3 \
  -machine lm3s6965evb \
  -nographic \
  -semihosting-config enable=on,target=native \
  -kernel target/thumbv7m-none-eabi/debug/examples/hello
```

```text
Hello, world!
```

The command should successfully exit (exit code = 0) after printing the text. On
*nix you can check that with the following command:

```console
echo $?
```

```text
0
```

Let's break down that QEMU command:

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
to simplify the process. `.cargo/config.toml` has a commented out runner that invokes
QEMU; let's uncomment it:

```console
head -n3 .cargo/config.toml
```

```toml
[target.thumbv7m-none-eabi]
# uncomment this to make `cargo run` execute programs on QEMU
runner = "qemu-system-arm -cpu cortex-m3 -machine lm3s6965evb -nographic -semihosting-config enable=on,target=native -kernel"
```

This runner only applies to the `thumbv7m-none-eabi` target, which is our
default compilation target. Now `cargo run` will compile the program and run it
on QEMU:

```console
cargo run --example hello --release
```

```text
   Compiling app v0.1.0 (file:///tmp/app)
    Finished release [optimized + debuginfo] target(s) in 0.26s
     Running `qemu-system-arm -cpu cortex-m3 -machine lm3s6965evb -nographic -semihosting-config enable=on,target=native -kernel target/thumbv7m-none-eabi/release/examples/hello`
Hello, world!
```

## Debugging

Debugging is critical to embedded development. Let's see how it's done.

Debugging an embedded device involves *remote* debugging as the program that we
want to debug won't be running on the machine that's running the debugger
program (GDB or LLDB).

Remote debugging involves a client and a server. In a QEMU setup, the client
will be a GDB (or LLDB) process and the server will be the QEMU process that's
also running the embedded program.

In this section we'll use the `hello` example we already compiled.

The first debugging step is to launch QEMU in debugging mode:

```console
qemu-system-arm \
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

```console
gdb-multiarch -q target/thumbv7m-none-eabi/debug/examples/hello
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
Reset () at $REGISTRY/cortex-m-rt-0.6.1/src/lib.rs:473
473     pub unsafe extern "C" fn Reset() -> ! {
```


You'll see that the process is halted and that the program counter is pointing
to a function named `Reset`. That is the reset handler: what Cortex-M cores
execute upon booting.

>  Note that on some setup, instead of displaying the line `Reset () at $REGISTRY/cortex-m-rt-0.6.1/src/lib.rs:473` as shown above, gdb may print some warnings like : 
>
>`core::num::bignum::Big32x40::mul_small () at src/libcore/num/bignum.rs:254`
> `    src/libcore/num/bignum.rs: No such file or directory.`
> 
> That's a known glitch. You can safely ignore those warnings, you're most likely at Reset(). 


This reset handler will eventually call our main function. Let's skip all the
way there using a breakpoint and the `continue` command. To set the breakpoint, let's first take a look where we would like to break in our code, with the `list` command.

```console
list main
```
This will show the source code, from the file examples/hello.rs. 

```text
6       use panic_halt as _;
7
8       use cortex_m_rt::entry;
9       use cortex_m_semihosting::{debug, hprintln};
10
11      #[entry]
12      fn main() -> ! {
13          hprintln!("Hello, world!").unwrap();
14
15          // exit QEMU
```
We would like to add a breakpoint just before the "Hello, world!", which is on line 13. We do that with the `break` command:

```console
break 13
```
We can now instruct gdb to run up to our main function, with the `continue` command:

```console
continue
```

```text
Continuing.

Breakpoint 1, hello::__cortex_m_rt_main () at examples\hello.rs:13
13          hprintln!("Hello, world!").unwrap();
```

We are now close to the code that prints "Hello, world!". Let's move forward
using the `next` command.

``` console
next
```

```text
16          debug::exit(debug::EXIT_SUCCESS);
```

At this point you should see "Hello, world!" printed on the terminal that's
running `qemu-system-arm`.

```text
$ qemu-system-arm (..)
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
