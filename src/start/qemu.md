# QEMU
我们将开始为[LM3S6965]编写程序，一个Cortex-M3微控制器。我们选择这个作为我们的第一个目标，因为它能使用[QEMU仿真](https://wiki.qemu.org/Documentation/Platforms/ARM#Supported_in_qemu-system-arm)，因此本节中，你不需要摆弄硬件，我们注意力可以集中在工具和开发过程上。

[LM3S6965]: http://www.ti.com/product/LM3S6965

**重要**
在这个引导里，我们将使用"app"这个名字来代指项目名。无论何时你看到单词"app"，你应该用你选择的项目名来替代"app"。或者你也可以选择把你的项目命名为"app"，避免替代。

## 生成一个非标准的 Rust program
我们将使用[`cortex-m-quickstart`]项目模板来生成一个新项目。生成的项目将包含一个最基本的应用:对于一个新的嵌入式rust应用来说，是一个很好的开始。另外，项目将包含一个`example`文件夹，文件夹中有许多独立的应用，突出了一些关键的嵌入式rust的功能。

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

### 使用 `git`

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

### 要么使用

抓取最新的 `cortex-m-quickstart` 模板，解压它。

```console
curl -LO https://github.com/rust-embedded/cortex-m-quickstart/archive/master.zip
unzip master.zip
mv cortex-m-quickstart-master app
cd app
```

或者你可以浏览[`cortex-m-quickstart`]，点击绿色的 "Clone or download" 按钮，然后点击 "Download ZIP" 。

然后像在 “使用 `git`” 那里的第二部分写的那样填充 `Cargo.toml` 。

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

这个程序与标准Rust程序有一点不同，因此让我们走近点看看。

`#![no_std]`指出这个程序将 *不会* 链接标准crate`std`。反而它将会链接到它的子集: `core` crate。

`#![no_main]`指出这个程序将不会使用标准的且被大多数Rust程序使用的`main`接口。使用`no_main`的主要理由是，因为在`no_std`上下文中使用`main`接口要求开发版的rust 。

`use panic_halt as _;`。这个crate提供了一个`panic_handler`，它定义了程序陷入`panic`时的行为。我们将会在这本书的[运行时恐慌(Panicking)](panicking.md)章节中覆盖更多的细节。

[`#[entry]`][entry] 是一个由[`cortex-m-rt`]提供的属性，它用来标记程序的入口。当我们不使用标准的`main`接口时，我们需要其它方法来指示程序的入口，那就是`#[entry]`。

[entry]: https://docs.rs/cortex-m-rt-macros/latest/cortex_m_rt_macros/attr.entry.html
[`cortex-m-rt`]: https://crates.io/crates/cortex-m-rt

`fn main() -> !`。我们的程序将会是运行在目标板子上的 *唯一* 的进程，因此我们不想要它结束！我们使用一个[divergent function](https://doc.rust-lang.org/rust-by-example/fn/diverging.html) (函数签名中的 `-> !` )来确保在编译时就是这么回事儿。

## 交叉编译

下一步是为Cortex-M3架构*交叉*编译程序。如果你知道编译目标(`$TRIPLE`)应该是什么，那就和运行`cargo build --target $TRIPLE`一样简单。幸运地，模板中的`.cargo/config.toml`有这个答案:
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
为了交叉编译Cortex-M3架构我们不得不使用`thumbv7m-none-eabi`。当安装Rust工具时，target不会自动被安装，如果你还没有做，现在可以去添加那个target到工具链上。
``` console
rustup target add thumbv7m-none-eabi
```
因为`thumbv7m-none-eabi`编译目标在你的`.cargo/config.toml`中被设置成默认值，下面的两个命令是一样的效果:
```console
cargo build --target thumbv7m-none-eabi
cargo build
```

## 检查

现在我们在`target/thumbv7m-none-eabi/debug/app`中有一个非主机环境的ELF二进制文件。我们能使用`cargo-binutils`检查它。

使用`cargo-readobj`我们能打印ELF头，确认这是一个ARM二进制。

```console
cargo readobj --bin app -- --file-headers
```

注意:
* `--bin app` 是一个用来检查`target/$TRIPLE/debug/app`的语法糖
* `--bin app` 如果有需要，也会重新编译二进制项。

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

`cargo-size` 能打印二进制项的linker部分的大小。

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
> - `.ARM.attributes` 和 `.debug_*` sections包含元数据，当烧录二进制文件时，它们不会被加载到目标上的。

**重要**: ELF文件包含像是调试信息这样的元数据，因此它们在*硬盘上的尺寸*没有正确地反应了程序被烧录到设备上时将占据的空间的大小。要*一直*使用`cargo-size`检查一个二进制项的大小。

`cargo-objdump` 能用来反编译二进制项。

```console
cargo objdump --bin app --release -- --disassemble --no-show-raw-insn --print-imm-hex
```

> **注意** 如果上面的命令抱怨 `Unknown command line argument` 看下面的bug报告:https://github.com/rust-embedded/book/issues/269

> **注意** 在你的系统上这个输出可能不一样。rustc, LLVM 和库的新版本能产出不同的汇编。我们截取了一些指令

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

接下来，让我们看一个嵌入式程序是如何在QEMU上运行的！此刻我们将使用 `hello` 示例，来做些真正的事。

为了方便起见，这是`examples/hello.rs`的源码:

```rust,ignore
//! 使用semihosting在主机调试台上打印 "Hello, world!"

#![no_main]
#![no_std]

use panic_halt as _;

use cortex_m_rt::entry;
use cortex_m_semihosting::{debug, hprintln};

#[entry]
fn main() -> ! {
    hprintln!("Hello, world!").unwrap();

    // 退出 QEMU
    // NOTE 不要在硬件上运行这个;它会打破OpenOCD的状态
    debug::exit(debug::EXIT_SUCCESS);

    loop {}
}
```

这个程序使用一些被叫做semihosting的东西去打印文本到主机调试台上。当使用的是真实的硬件时，这需要一个调试对话，但是当使用的是QEMU时这就可以工作了。

通过编译示例，让我们开始

```console
cargo build --example hello
```

输出的二进制项将位于`target/thumbv7m-none-eabi/debug/examples/hello`。

为了在QEMU上运行这个二进制项，执行下列的命令:

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

这个命令应该在打印文本之后成功地退出 (exit code = 0)。你可以使用下列的指令检查下:

```console
echo $?
```

```text
0
```

让我们看看QEMU命令:

+ `qemu-system-arm`。这是QEMU仿真器。这些QEMU有一些改良版的二进制项；这个仿真器能做ARM机器的全系统仿真。

+ `-cpu cortex-m3`。这告诉QEMU去仿真一个Cortex-M3 CPU。指定CPU模型会让我们捕捉到一些误编译错误:比如，运行一个为Cortex-M4F编译的程序，它具有一个硬件FPU，在执行时将会使QEMU报错。
+ `-machine lm3s6965evb`。这告诉QEMU去仿真 LM3S6965EVB，一个包含LM3S6965微控制器的评估板。
+ `-nographic`。这告诉QEMU不要启动它的GUI。
+ `-semihosting-config (..)`。这告诉QEMU使能半主机模式。半主机模式允许被仿真的设备，使用主机的stdout，stderr，和stdin，并在主机上创建文件。
+ `-kernel $file`。这告诉QEMU在仿真机器上加载和运行哪个二进制项。

输入这么长的QEMU命令太费功夫了！我们可以设置一个自定义运行器(runner)简化步骤。`.cargo/config.toml` 有一个被注释掉的，可以调用QEMU的运行器。让我们去掉注释。
```console
head -n3 .cargo/config.toml
```
```toml
[target.thumbv7m-none-eabi]
# uncomment this to make `cargo run` execute programs on QEMU
runner = "qemu-system-arm -cpu cortex-m3 -machine lm3s6965evb -nographic -semihosting-config enable=on,target=native -kernel"
```
这个运行器只会应用于 `thumbv7m-none-eabi` 目标，它是我们的默认编译目标。现在 `cargo run` 将会编译程序且在QEMU上运行它。
```console
cargo run --example hello --release
```
```text
   Compiling app v0.1.0 (file:///tmp/app)
    Finished release [optimized + debuginfo] target(s) in 0.26s
     Running `qemu-system-arm -cpu cortex-m3 -machine lm3s6965evb -nographic -semihosting-config enable=on,target=native -kernel target/thumbv7m-none-eabi/release/examples/hello`
Hello, world!
```

## 调试
对于嵌入式开发来说，调试非常重要。让我们来看下如何完成它。

因为我们想要调试的程序所运行的机器上并没有运行一个调试器程序(GDB或者LLDB)，所以调试一个嵌入式设备就涉及到了 *远程* 调试

远程调试涉及一个客户端和一个服务器。在QEMU的情况中，客户端将是一个GDB(或者LLDM)进程且服务器将会是运行着嵌入式程序的QEMU进程。

在这部分，我们将使用我们已经编译的 `hello` 示例。

调试的第一步是在调试模式中启动QEMU：

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

这个命令将不打印任何东西到调试台上，且将会阻塞住终端。此刻我们还传递了两个额外的标志。
+ `-gdb tcp::3333`。这告诉QEMU在3333的TCP端口上等待一个GDB连接。
+ `-S`。这告诉QEMU在启动时，冻结机器。没有这个，在我们有机会启动调试器之前，程序有可能已经到达了主程序的底部了!

接下来我们在另一个终端启动GDB，且告诉它去加载示例的调试符号。
```console
gdb-multiarch -q target/thumbv7m-none-eabi/debug/examples/hello
```

**注意**: 你可能需要另一个gdb版本而不是 `gdb-multiarch`，取决于你在安装章节中安装了哪个。这个可能是 `arm-none-eabi-gdb` 或者只是 `gdb`。

然后在GDB shell中，我们连接QEMU，QEMU正在等待一个在3333 TCP端口上的连接。
```console
target remote :3333
```

```text
Remote debugging using :3333
Reset () at $REGISTRY/cortex-m-rt-0.6.1/src/lib.rs:473
473     pub unsafe extern "C" fn Reset() -> ! {
```

你将看到，进程被挂起了，程序计数器正指向一个名为 `Reset` 的函数。那是 reset 句柄：Cortex-M 内核在启动时执行的中断函数。

> 注意在一些配置中，可能不会像上面一样，显示`Reset() at $REGISTRY/cortex-m-rt-0.6.1/src/lib.rs:473`，gdb可能打印一些警告，比如:
>
>`core::num::bignum::Big32x40::mul_small () at src/libcore/num/bignum.rs:254`
> `    src/libcore/num/bignum.rs: No such file or directory.`
>
> 那是一个已知的小bug，你可以安全地忽略这些警告，你非常大可能已经Reset()了。

这个reset句柄最终将调用我们的主函数，让我们使用一个断点和`continue`命令跳过所有的步骤。为了设置断点，让我们首先看下我们想要在我们代码哪里打断点，使用`list`指令

```console
list main
```
这将显示从examples/hello.rs文件来的源代码。
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
我们想要在"Hello, world!"之前添加一个断点，在13行那里。我们可以使用`break`命令

```console
break 13
```

我们现在能使用`continue`命令指示gdb运行到我们的主函数。

```console
continue
```

```text
Continuing.

Breakpoint 1, hello::__cortex_m_rt_main () at examples\hello.rs:13
13          hprintln!("Hello, world!").unwrap();
```

我们现在靠近打印"Hello, world!"的代码。让我们使用`next`命令继续前进。

``` console
next
```

```text
16          debug::exit(debug::EXIT_SUCCESS);
```

在这里，你应该看到 "Hello, world!" 被打印到正在运行 `qemu-system-arm` 的终端上。

```text
$ qemu-system-arm (..)
Hello, world!
```

再次调用`next`将会终止QEMU进程。

```console
next
```

```text
[Inferior 1 (Remote target) exited normally]
```

你现在能退出GDB的会话了。

``` console
quit
```
