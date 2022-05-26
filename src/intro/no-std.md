# 一个 `no_std` Rust环境
嵌入式编程这个词被广泛用于许多不同的编程场景中。小到RAM和ROM只有KB的8位机(像是[ST72325xx](https://www.st.com/resource/en/datasheet/st72325j6.pdf))，大到一个具有32/64位4核Cortex-A53和1GB的RAM的系统，比如树莓派([Model B 3+](https://en.wikipedia.org/wiki/Raspberry_Pi#Specifications))。当编写代码时，取决于你的目标环境和用例，将会有不同的限制和局限。<br>
通常嵌入式编程有两类:

## 主机环境

这类环境类似一个常见的PC环境。意味着有向你提供了一个系统接口[E.G. POSIX](https://en.wikipedia.org/wiki/POSIX)，使你能和不同的系统进行交互，比如文件系统，网络，内存管理，进程，等等。标准库相应地依赖这些接口去实现它们的功能。你可能在RAM/ROM的使用上有一些sysroot的限制，可能还有一些特别的硬件或者I/O。总之感觉像是在一个特定目的的PC环境上编程一样。

## 裸机环境

在一个裸机环境中，先于你的程序被加载前，不存在代码。没有系统提供的软件，我们不能加载标准库。相反地，该程序，以及它使用的crates只能使用硬件(裸机)去运行。使用`no-std`可以防止rust读取标准库。标准库中与平台无关的部分在[libcore](https://doc.rust-lang.org/core/)中。libcore剔除了那些在一个嵌入式环境中非必要的东西。比如用于动态分配的内存分配器。如果你需要这些或者其它的那些功能，通常会有提供这些功能的crates。

### libstd运行时

就像之前提到的，使用[libstd](https://doc.rust-lang.org/std/)需要一些系统集成，这不仅仅是因为[libstd](https://doc.rust-lang.org/std/)提供了一个公共的方法访问操作系统，它也提供了一个运行时环境。这个运行时环境，负责设置堆栈溢出保护，处理命令行参数，在一个程序主函数被激活前启动一个主线程。在一个`no_std`环境中，这个运行时环境也是不可用的。

## 总结
`#![no_std]`是一个crate-level属性，它说明crate将连接至core-crate而不是std-crate。[libcore](https://doc.rust-lang.org/core/) crate是std crate一个平台无关的子集，它对程序将要运行的系统没有做要求。比如，它提供了像是floats,strings和切片的APIs，暴露了像是原子操作和SIMD指令的处理器特性相关的APIs。然而，它缺少涉及到平台集成的那些APIs。由于这些特性，no_std和[libcore](https://doc.rust-lang.org/core/)代码可以用于任何引导程序(stage 0)像是bootloaders，固件或者内核。

### 概述

| feature                                                   | no\_std | std |
|-----------------------------------------------------------|--------|-----|
| heap (dynamic memory)                                     |   *    |  ✓  |
| collections (Vec, HashMap, etc)                           |  **    |  ✓  |
| stack overflow protection                                 |   ✘    |  ✓  |
| runs init code before main                                |   ✘    |  ✓  |
| libstd available                                          |   ✘    |  ✓  |
| libcore available                                         |   ✓    |  ✓  |
| writing firmware, kernel, or bootloader code              |   ✓    |  ✘  |

\* 只有在你使用 `alloc` crate 和一个适合的分配器，比如[alloc-cortex-m]时有效。

\** 只有在你使用 `collections` crate 和配置一个全局默认的分配器时有效。

[alloc-cortex-m]: https://github.com/rust-embedded/alloc-cortex-m

## See Also
* [RFC-1184](https://github.com/rust-lang/rfcs/blob/master/text/1184-stabilize-no_std.md)
