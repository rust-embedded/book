# Rust配点C

在一个Rust项目中使用C或者C++，由两个主要部分组成:

+ 使用Rust封装要暴露的C API来用
+ 编译要和Rust代码集成的C或者C++代码

因为对于目标的Rust编译器，C++没有一个稳定的ABI，当将Rust和C或者C++结合时，建议使用`C`。

## 定义接口

从Rust消费C或者C++代码之前，必须定义(在Rust中)在被链接的代码中存在什么数据类型和函数签名。在C或者C++中，你要包括一个头文件(`.h`或者`.hpp`)，其定义了这个数据。在Rsut中，必须手动地将这些定义翻译成Rust，或者使用一个工具去生成这些定义。

首先，我们将介绍如何将这些定义从C/C++手动转换为Rust。

### 封装C函数和数据类型

通常，用C或者C++写的库会提供一个头文件，头文件定义了所有的类型和用于公共接口的函数。一个示例文件可能如下所示:

```C
/* 文件: cool.h */
typedef struct CoolStruct {
    int x;
    int y;
} CoolStruct;

void cool_function(int i, char c, CoolStruct* cs);
```

当翻译成Rust时，这个接口将看起来像是:

```rust,ignore
/* File: cool_bindings.rs */
#[repr(C)]
pub struct CoolStruct {
    pub x: cty::c_int,
    pub y: cty::c_int,
}

pub extern "C" fn cool_function(
    i: cty::c_int,
    c: cty::c_char,
    cs: *mut CoolStruct
);
```

让我们一次看一个语句，来解释每个部分。

```rust,ignore
#[repr(C)]
pub struct CoolStruct { ... }
```

默认，Rust不会保证包含在一个`struct`中的数据的大小，填充，或者顺序。为了保证与C代码兼容，我们使用`#[repr(C)]`属性，它指示Rust编译器总是使用和C一样的规则去组织一个结构体中的数据。

```rust,ignore
pub x: cty::c_int,
pub y: cty::c_int,
```

由于C或者C++定义一个`int`或者`char`的方式很灵活，所以建议使用在`cty`中定义的基础类型，它将类型从C映射到Rust中的类型。

```rust,ignore
pub extern "C" fn cool_function( ... );
```

这个语句定义了一个使用C ABI的函数的签名，被叫做`cool_function`。通过定义签名而不定义函数的主体，这个函数的定义将需要在其它地方定义，或者从一个静态库链接进最终的库或者一个二进制文件中。

```rust,ignore
    i: cty::c_int,
    c: cty::c_char,
    cs: *mut CoolStruct
```

与我们上面的数据类型一样，我们使用C兼容的定义去定义函数参数的数据类型。为了清晰可见，我们还保留了相同的参数名。

这里我们有个新类型，`*mut CoolStruct` 。因为C没有Rust中的引用的概念，其看起来像是这个: `&mut CoolStruct`，所以我们使用一个裸指针。因为解引用这个指针是`unsafe`的，且实际上指针可能是一个`null`指针，因此当与C或者C++代码交互时必须要小心对待那些Rust做出的安全保证。

### 自动产生接口

有一个叫做[bindgen]的工具，它可以自动执行这些转换，而不用手动生成这些接口那么繁琐且容易出错。关于[bindgen]使用的指令，请参考[bindgen user's manual]，然而经典的过程有下面几步:

1. 收集所有定义了你可能在Rust中用到的数据类型或者接口的C或者C++头文件。
2. 写一个`bindings.h`文件，其`#include "..."`每一个你在步骤一中收集的文件。
3. 将这个`bindings.h`文件和任何用来编译你代码的编译标识发给`bindgen`。贴士: 使用`Builder.ctypes_prefix("cty")` / `--ctypes-prefix=cty` 和 `Builder.use_core()` / `--use-core` 去使生成的代码兼容`#![no_std]`
4. `bindgen`将会在终端窗口输出生成的Rust代码。这个文件可能会被通过管道发送给你项目中的一个文件，比如`bindings.rs` 。你可能要在你的Rust项目中使用这个文件来与被编译和链接成一个外部库的C/C++代码交互。贴士: 如果你的类型在生成的绑定中被前缀了`cty`，不要忘记使用[`cty`](https://crates.io/crates/cty) crate 。

[bindgen]: https://github.com/rust-lang/rust-bindgen
[bindgen user's manual]: https://rust-lang.github.io/rust-bindgen/

## 编译你的 C/C++ 代码

因为Rust编译器并不直接知道如何编译C或者C++代码(或者从其它语言来的代码，其提供了一个C接口)，所以必须要静态编译你的非Rust代码。

对于嵌入式项目，这通常意味着把C/C++代码编译成一个静态库文档(比如 `cool-library.a`)，然后其能在最后链接阶段与你的Rust代码组合起来。

如果你要使用的库已经作为一个静态库文档被发布，那就没必要重新编译你的代码。只需按照上面所述转换提供的接口头文件，且在编译/链接时包含静态库文档。

如果你的代码作为一个源项目(source project)存在，将你的C/C++代码编译成一个静态库将是必须的，要么通过使用你现存的编译系统(比如 `make`，`CMake`，等等)，要么通过使用一个被叫做`cc` crate的工具移植必要的编译步骤。关于这两个，都必须使用一个`build.rs`脚本。

### Rust的 `build.rs` 编译脚本

一个 `build.rs` 脚本是一个用Rust语法编写的文件，它被运行在你的编译机器上，发生在你项目的依赖项被编译**之后**，但是在你的项目被编译**之前** 。

可能能在[这里](https://doc.rust-lang.org/cargo/reference/build-scripts.html)发现完整的参考。`build.rs` 脚本能用来生成代码(比如通过[bindgen])，调用外部编译系统，比如`Make`，或者直接通过使用`cc` crate来直接编译C/C++ 。

### 使用外部编译系统

对于有复杂的外部项或者编译系统的项目，使用[`std::process::Command`]通过遍历相对路径来向其它编译系统"输出"，调用一个固定的命令(比如 `make library`)，然后拷贝最终的静态库到`target`编译文件夹中恰当的位置，可能是最简单的方法。

虽然你的crate目标可能是一个`no_std`嵌入式平台，但你的`build.rs`只运行在负责编译你的crate的机器上。这意味着你能使用任何Rust crates，其将运行在你的编译主机上。

[`std::process::Command`]: https://doc.rust-lang.org/std/process/struct.Command.html

### 使用`cc` crate构建C/C++代码

对于具有有限的依赖项或者复杂度的项目，或者对于那些难以修改编译系统去生成一个静态库(而不是一个二进制文件或者可执行文件)的项目，使用[`cc` crate]可能更容易，它提供了一个符合Rust语法的接口，这个接口是关于主机提供的编译器的。

[`cc` crate]: https://github.com/alexcrichton/cc-rs

在把一个C文件编译成一个静态库的依赖项的最简单的场景下，可以使用[`cc` crate]，示例`build.rs`脚本看起来像这样:

```rust,ignore
extern crate cc;

fn main() {
    cc::Build::new()
        .file("foo.c")
        .compile("libfoo.a");
}
```
