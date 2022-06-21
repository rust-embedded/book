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

让我们一次看一个定义，来解释每个部分。

```rust,ignore
#[repr(C)]
pub struct CoolStruct { ... }
```

默认，Rust不会保证包含在一个`struct`中的数据的大小，padding，或者顺序。为了保证与C代码兼容，我们使用`#[repr(C)]`属性，它指示Rust编译器总是使用和C一样的规则去组织一个结构体中的数据。

```rust,ignore
pub x: cty::c_int,
pub y: cty::c_int,
```

由于C或者C++定义一个`int`或者`char`的方式很灵活，所以建议使用在`cty`中定义的基础类型，它将类型从C映射到Rust中的类型。

```rust,ignore
pub extern "C" fn cool_function( ... );
```

这个语句定义了一个使用C ABI的函数的签名，被叫做`cool_function`。通过定义签名而不定义函数的主体，这个函数的定义将需要在其它地方定义，或者从一个静态库链接进最终的库或者一个二进制文件中

```rust,ignore
    i: cty::c_int,
    c: cty::c_char,
    cs: *mut CoolStruct
```

与我们上面的数据类型一样，我们使用C兼容的定义去定义函数参数的数据类型。为了清晰可见，我们还保留了相同的参数名。

这里我们有个新类型，`*mut CoolStruct` 。


We have one new type here, `*mut CoolStruct`. As C does not have a concept of Rust's references, which would look like this: `&mut CoolStruct`, we instead have a raw pointer. As dereferencing this pointer is `unsafe`, and the pointer may in fact be a `null` pointer, care must be taken to ensure the guarantees typical of Rust when interacting with C or C++ code.

### Automatically generating the interface

Rather than manually generating these interfaces, which may be tedious and error prone, there is a tool called [bindgen] which will perform these conversions automatically. For instructions of the usage of [bindgen], please refer to the [bindgen user's manual], however the typical process consists of the following:

1. Gather all C or C++ headers defining interfaces or datatypes you would like to use with Rust.
2. Write a `bindings.h` file, which `#include "..."`'s each of the files you gathered in step one.
3. Feed this `bindings.h` file, along with any compilation flags used to compile
  your code into `bindgen`. Tip: use `Builder.ctypes_prefix("cty")` /
  `--ctypes-prefix=cty` and `Builder.use_core()` / `--use-core` to make the generated code `#![no_std]` compatible.
4. `bindgen` will produce the generated Rust code to the output of the terminal window. This file may be piped to a file in your project, such as `bindings.rs`. You may use this file in your Rust project to interact with C/C++ code compiled and linked as an external library. Tip: don't forget to use the [`cty`](https://crates.io/crates/cty) crate if your types in the generated bindings are prefixed with `cty`.

[bindgen]: https://github.com/rust-lang/rust-bindgen
[bindgen user's manual]: https://rust-lang.github.io/rust-bindgen/

## 编译你的 C/C++ 代码

As the Rust compiler does not directly know how to compile C or C++ code (or code from any other language, which presents a C interface), it is necessary to compile your non-Rust code ahead of time.

For embedded projects, this most commonly means compiling the C/C++ code to a static archive (such as `cool-library.a`), which can then be combined with your Rust code at the final linking step.

If the library you would like to use is already distributed as a static archive, it is not necessary to rebuild your code. Just convert the provided interface header file as described above, and include the static archive at compile/link time.

If your code exists as a source project, it will be necessary to compile your C/C++ code to a static library, either by triggering your existing build system (such as `make`, `CMake`, etc.), or by porting the necessary compilation steps to use a tool called the `cc` crate. For both of these steps, it is necessary to use a `build.rs` script.

### Rust的 `build.rs` 编译脚本

一个 `build.rs` 脚本是一个用Rust语法编写的文件，它被运行在你的编译机器上，


A `build.rs` script is a file written in Rust syntax, that is executed on your compilation machine, AFTER dependencies of your project have been built, but BEFORE your project is built.

The full reference may be found [here](https://doc.rust-lang.org/cargo/reference/build-scripts.html). `build.rs` scripts are useful for generating code (such as via [bindgen]), calling out to external build systems such as `Make`, or directly compiling C/C++ through use of the `cc` crate.

### 使用外部编译系统

For projects with complex external projects or build systems, it may be easiest to use [`std::process::Command`] to "shell out" to your other build systems by traversing relative paths, calling a fixed command (such as `make library`), and then copying the resulting static library to the proper location in the `target` build directory.

While your crate may be targeting a `no_std` embedded platform, your `build.rs` executes only on machines compiling your crate. This means you may use any Rust crates which will run on your compilation host.

[`std::process::Command`]: https://doc.rust-lang.org/std/process/struct.Command.html

### 使用`cc` crate构建C/C++代码

For projects with limited dependencies or complexity, or for projects where it is difficult to modify the build system to produce a static library (rather than a final binary or executable), it may be easier to instead utilize the [`cc` crate], which provides an idiomatic Rust interface to the compiler provided by the host.

[`cc` crate]: https://github.com/alexcrichton/cc-rs

In the simplest case of compiling a single C file as a dependency to a static library, an example `build.rs` script using the [`cc` crate] would look like this:

```rust,ignore
extern crate cc;

fn main() {
    cc::Build::new()
        .file("foo.c")
        .compile("libfoo.a");
}
```
