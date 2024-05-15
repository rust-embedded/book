# 工具
与微控制器打交道需要使用几种不同的工具，因为我们要处理的架构与笔记本电脑不同，我们必须在 *远程* 设备上运行和调试程序。我们将使用下面列举出来的工具。当没有指定一个最小版本时，最新的版本应该也可以用，但是我们还是列出了我们已经测过的那些版本。
- Rust 1.31, 1.31-beta, 或者一个更新的，支持ARM Cortex-M编译的工具链。
- [`cargo-binutils`](https://github.com/rust-embedded/cargo-binutils) ~0.1.4
- [`qemu-system-arm`](https://www.qemu.org/). 测试的版本: 3.0.0
- OpenOCD >=0.8. 测试的版本: v0.9.0 and v0.10.0
- 有ARM支持的GDB。强烈建议7.12或者更新的版本。测试版本: 7.10, 7.11 和 8.1
- [`cargo-generate`](https://github.com/ashleygwilliams/cargo-generate) 或者 `git`。这些工具都是可选的，但是跟着这本书来使用它们，会更容易。

下面的文档将解释我们为什么使用这些工具。安装指令可以在下一页找到。

## `cargo-generate` 或者 `git`
裸机编程是非标准Rust编程，为了得到正确的程序的内存布局，需要对链接过程进行一些调整，这要求添加一些额外的文件(比如linker scripts)和配置(比如linker flags)。我们已经为你把这些打包进了一个模板里了，你只需要补充缺失的信息(比如项目名和目标硬件的特性)。<br>
我们的模板兼容`cargo-generate`:一个用来从模板生成新的Cargo项目的Cargo子命令。你也能使用`git`,`curl`,`wget`,或者你的网页浏览器下载模板。

## `cargo-binutils`
`cargo-binutils`是一个Cargo命令的子集，它让我们能轻松使用Rust工具链带来的LLVM工具。这些工具包括LLVM版本的`objdump`，`nm`和`size`，用来查看二进制文件。<br>
在GNU binutils之上使用这些工具的好处是，(a)无论你的操作系统是什么，安装这些LLVM工具都可以用同一条命令(`rustup component add llvm-tools-preview`)。(b)像是`objdump`这样的工具，支持所有`rustc`支持的架构--从ARM到x86_64--因为它们都有一样的LLVM后端。

## `qemu-system-arm`

QEMU是一个仿真器。在这个例子里，我们使用能完全仿真ARM系统的改良版QEMU。我们使用QEMU在主机上运行嵌入式程序。多亏了它，你可以在没有任何硬件的情况下，尝试这本书的部分示例。

# 用于调试嵌入式Rust的工具

## 概述

在Rust中调试嵌入式系统需要用到专业的工具，这包括用于管理调试进程的软件，用于观察和控制程序执行的调试器，和用于便捷主机和嵌入式设备之间进行交互的硬件探测器．这个文档会介绍像是Probe-rs和OpenOCD这样的基础软件，以及像是GDB和Probe-rs Visual Studio Code扩展这样常见的调试器．另外，该文档会覆盖像是Rusty-probe，ST-Link，J-Link，和MCU-Link这样的硬件探测器，它们整合在一起可以高效地对嵌入式设备进行调试和编程．

## 驱动调试工具的软件

### Probe-rs

Probe-rs是一个现代化的，以Rust开发的软件，被设计用来配合嵌入式系统中的调试器一起工作．不像OpenOCD，Probe-rs设计的时候就考虑到了简单性，目标是减少在其它调试解决方案中常见的配置重担．
它支持不同的探测器和目标架构，提供一个用于与嵌入式硬件交互的高层接口．Probe-rs直接集成了Rust工具链，并且通过扩展集成进了Visual Studio Code中，允许开发者精简它们的调试工作流程．


### OpenOCD (Open On-Chip Debugger)

OpenOCD是一个用于调试，测试，和编程嵌入式系统的开源软件工具．它提供了一个主机系统和嵌入式硬件之间的接口，支持不同的传输层，比如JTAG和SWD（Serial Wire Debug）．OpenOCD集成了GDB，其是一个调试器．OpenOCD受到了广泛的支持，拥有大量的文档和一个庞大的社区，但是配置可能会很复杂，特别是对于自定义的嵌入式设置．

## Debuggers

调试器允许开发者观察和控制一个程序的执行，以辨别和纠正错误或者bugs．它提供像是设置断点，一行一行地步进代码，和研究变量的值以及内存的状态等功能．调试器本质上是为了通过软件开发和维护，使得开发者可以确保他们的代码的行为在不同环境下就像他们预期的那样运行．

调试器可以知道如何：
 * 与映射到存储上的寄存器交互．
 * 设置断点．
 * 读取和写入映射到存储上的寄存器．
 * 检测什么时候MCU因为一个调试时间被挂了起来．
 * 在遇到一个调试事件后继续MCU的执行．
 * 擦出和写入微控制器的FLASH．

### Probe-rs Visual Studio Code Extension

Probe-rs有一个Visual Studio Code的扩展，提供了不需要额外设置的无缝的调试体验．通过它的帮助，开发者可以使用Rust特定的特性，像是漂亮的打印和详细的错误信息，确保它们的调试过程可以与Rust的生态对齐． 

### GDB (GNU Debugger) 

GDB是一个多用途的调试工具，其允许开发者研究程序的状态，无论其正在运行中还是程序崩溃后．对于嵌入式Rust，GDB通过OpenOCD或者其它的调试服务器链接到目标系统上去和嵌入式代码交互．GDB是高度可配置的，并且支持像是远程调试，变量检测，和条件断点．它可以被用于多个平台，并对Rust特定的调试需求有广泛的支持，比如好看的打印和与IDEs集成．


## 探测器

硬件探头是一个被用于嵌入式系统的开发和调试的设备，其可以使得主机和目标嵌入式设备间的通信变得简单．它通常支持像是JTAG或者SWD这样的协议，可以编程，调试和分析嵌入式系统上的微控制器或者微处理器．硬件探头对于要设置断点，步进代码，和观察内存与处理器的寄存器的开发者来说很重要，可以让开发者们高效地实时地分析和修复问题．

### Rusty-probe

Rusty-probe是一个开源的基于USB的硬件调试探测器，被设计用来辅助probe-rs一起工作．Rusy-Probe和probe-rs的结合为嵌入式Rust应用的开发者提供了一个易用的，成本高效的解决方案．

### ST-Link

ST-Link是一个由STMicroelectronics开发的常见的调试和编程探测器，其主要用于它们的STM32和STM8微控制器系列．它支持通过JTAG或者SWD接口进行调试和编程．因为STMicroelectronics的大量的开发板对其直接支持并且它集成进了主流的IDEs中，所以使得它成为使用STM微控制器的开发者的首选．

### J-Link

J-Link是由SEGGER微控制器开发的，它是一个鲁棒和功能丰富的调试器，其支持大量的CPU内核和设备，不仅仅是ARM，比如RISC-V．因其高性能和可读性而闻名，J-Link支持不同的通信接口，包括JTAG，SWD，和fine-pitch JTAG接口．它因其高级的特性而受到欢迎，比如在flash存储中的无限的断点和它与多种开发环境的兼容性．

### MCU-Link

MCU-Link是一个调试探测器，也可以作为编程器使用，由NXP Semiconductors提供．它支持不同的ARM Cortex微控制器且可以与像是MCUXpresso IDE这样的开发工具进行无缝地交互．MCU-Link因其丰富的功能和易使用而闻名，使它成为像是爱好者，教育者，和专业的开发者们的可行的选项．
