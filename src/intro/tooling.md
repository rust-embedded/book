# 工具
与微控制器打交道需要使用几种不同的工具，因为我们要处理的架构与笔记本电脑不同，我们必须在*远程*设备上运行和调试程序。我们将使用下面列举出来的工具。当一个最小版本没有被指定时，最近的版本应该可以工作，但是我们已经列出我们已经测过的那些版本。
- Rust 1.31, 1.31-beta, 或者一个更新的，支持ARM Cortex-M编译的工具链。
- [`cargo-binutils`](https://github.com/rust-embedded/cargo-binutils) ~0.1.4
- [`qemu-system-arm`](https://www.qemu.org/). 测试的版本: 3.0.0
- OpenOCD >=0.8. 测试的版本: v0.9.0 and v0.10.0
- 有ARM支持的GDB。高度建议7.12或者更新的版本。测试版本: 7.10, 7.11 和 8.1
- [`cargo-generate`](https://github.com/ashleygwilliams/cargo-generate) 或者 `git`

这些工具都是可选的，但是跟着书来使用它们，会更容易。下面的文档解释我们为什么使用这些工具。安装指令可以在下一页找到。

## `cargo-generate` OR `git`
裸板编程是non-strandard Rust编程，为了获取正确的程序的内存布局，需要对链接过程进行一些调整，这要求添加一些额外的文件(比如linker scripts)和配置(比如linker flags)。我们已经为你把这些打包进一个模板里，你只需要补充缺失的信息(比如项目名和你的目标硬件的特性)。<br>
我们的模板兼容`cargo-generate`:一个用来从模板生成新的Cargo项目的Cargo子命令。你也能使用`git`,`curl`,`wget`,或者你的网页浏览器下载模板。

## `cargo-binutils`
`cargo-binutils`是一个Cargo子命令集合，它使得能轻松使用Rust工具链带来的LLVM工具。这些工具包括LLVM版本的`objdump`,`nm`和`size`，用来查看二进制文件。<br>
在GNU binutils之上使用这些工具的好处是，(a)无论你的操作系统是什么，安装这些LLVM工具是相同的一条命令(`rustup component add llvm-tools-preview`)。(b)像是`objdump`这样的工具支持所有`rustc`支持的架构--从ARM到x86_64--因为它们都有一样的LLVM后端。

## `qemu-system-arm`

QEMU是一个仿真器。在这个例子里，我们使用能完全仿真ARM系统的变种版。我们使用QEMU在主机上运行嵌入式程序。多亏了它，你可以在没有任何硬件的情况下，尝试这本书的部分例子。

## GDB
调试器是嵌入式开发的一个非常重要的组件，你可能不总是有机会将内容记录到主机控制台。在某些情况里，你可能甚至没有LEDs点亮你的硬件！<br>
通常，提到调试，LLDB和GDB的功能一样，但是我们还没找到与GDB的`load`命令对应的LLDB命令，它将程序上传到目标硬件，因此我们现在推荐你使用GDB。

## OpenOCD
GDB不能直接和你的STM32F3DISCOVERY开发板上的ST-Link调试硬件通信。它需要一个转译者，the Open On-Chip Debugger，OpenOCD就是这样的转译者。OpenOCD是一个运行在你的笔记本/个人电脑上的程序，它在基于远程调试的TCP/IP协议和ST-Link的USB协议间进行转译。
OpenOCD也执行其它一些翻译中重要的工作，用于调试你的STM32FDISCOVERY开发板上的ARM Cortex-M微控制器:
* 他知道如何与ARM CoreSight调试外设使用的内存映射寄存器交互。这些CoreSight寄存器的功能有:
  * 断点操作
  * 读取和写入CPU寄存器
  * 发现CPU什么时候因为一个调试事件被挂载
  * 在遇到一个调试事件后继续CPU的执行。
  * etc.
* 它也知道如何擦除和写入微控制器的FLASH
