# 一个 `no_std` Rust环境

嵌入式编程这个词被广泛用于许多不同的编程场景中。小到RAM和ROM只有KB的8位机(像是[ST72325xx](https://www.st.com/resource/en/datasheet/st72325j6.pdf))，大到一个具有32/64位4核Cortex-A53和1GB RAM的系统，比如树莓派([Model B 3+](https://en.wikipedia.org/wiki/Raspberry_Pi#Specifications))。当编写代码时，取决于你的目标环境和用例，将会有不同的限制和局限。<br>
通常嵌入式编程有两类:

## 主机环境下

这类环境与一个常见的PC环境类似。意味着向你提供了一个系统接口[比如 POSIX](https://en.wikipedia.org/wiki/POSIX)，使你能和不同的系统进行交互，比如文件系统，网络，内存管理，进程，等等。标准库相应地依赖这些接口去实现了它们的功能。可能有某种sysroot并限制了对RAM/ROM的使用，可能还有一些特别的硬件或者I/O。总之感觉像是在专用的PC环境上编程一样。

## 裸机环境下

在一个裸机环境中，程序被加载前，环境中不存在代码。没有系统提供的软件，我们不能加载标准库。相反地，程序和它使用的crates只能使用硬件(裸机)去运行。使用`no-std`可以防止rust读取标准库。标准库中与平台无关的部分在[libcore](https://doc.rust-lang.org/core/)中。libcore剔除了那些在一个嵌入式环境中非必要的东西。比如用于动态分配的内存分配器。如果你需要这些或者其它的某些功能，通常会有提供这些功能的crates。

### libstd运行时

就像之前提到的，使用[libstd](https://doc.rust-lang.org/std/)需要一些系统集成，这不仅仅是因为[libstd](https://doc.rust-lang.org/std/)使用了一个公共的方法访问操作系统，它也提供了一个运行时环境。这个运行时环境，负责设置堆栈溢出保护，处理命令行参数，并在一个程序的主函数被激活前启动一个主线程。在一个`no_std`环境中，这个运行时环境也是不可用的。

## 总结
`#![no_std]`是一个crate层级的属性，它说明crate将连接至core-crate而不是std-crate。[libcore](https://doc.rust-lang.org/core/) crate是std crate的一个的子集，其与平台无关，它对程序将要运行的系统没有做要求。比如，它提供了像是floats，strings和切片的APIs，暴露了像是与原子操作和SIMD指令相关的处理器功能的APIs。然而，它缺少涉及到平台集成的那些APIs。由于这些特性，no_std和[libcore](https://doc.rust-lang.org/core/)代码可以用于任何引导程序(stage 0)像是bootloaders，固件或者内核。

### 概述

| 特性                                                      | no\_std | std |
|-----------------------------------------------------------|--------|-----|
| 堆 (动态内存)                                               |   *    |  ✓  |
| collections (Vec, HashMap, 等)                             |  **    |  ✓  |
| 堆栈溢出保护                                                |   ✘    |  ✓  |
| 在 main 之前运行初始化代码                                   |   ✘    |  ✓  |
| 能用 libstd                                                |   ✘    |  ✓  |
| 能用 libcore                                                |   ✓    |  ✓  |
| 编写固件、内核或 bootloader 代码                              |   ✓    |  ✘  |

\* 只有在你使用了 `alloc` crate 并设置了一个适合的分配器后，比如[alloc-cortex-m]后可用。

\** 只有在你使用了 `collections` crate 并配置了一个全局默认的分配器后可用。

[alloc-cortex-m]: https://github.com/rust-embedded/alloc-cortex-m

## 参见
* [RFC-1184](https://github.com/rust-lang/rfcs/blob/master/text/1184-stabilize-no_std.md)
