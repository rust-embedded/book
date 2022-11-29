# 使用Rust的C

在C或者C++中使用Rust代码通常由两部分组成。

- 用Rust生成一个C友好的API
- 将你的Rust项目嵌入一个外部的编译系统

除了`cargo`和`meson`，大多数编译系统没有原生Rust支持。因此你最好只用`cargo`编译你的crate和依赖。

## 设置一个项目

像往常一样创建一个新的`cargo`项目。有一些标志可以告诉`cargo`去生成一个系统库，而不是常规的rust目标文件。如果你想要它与crate的其它部分不一样，你也可以为你的库设置一个不同的输出名。

```toml
[lib]
name = "your_crate"
crate-type = ["cdylib"]      # 生成动态链接库
# crate-type = ["staticlib"] # 生成静态链接库
```

## 构建一个`C` API

因为对于Rust编译器来说，C++没有稳定的ABI，因此对于不同语言间的互操性我们使用`C`。在C和C++代码的内部使用Rust时也不例外。

### `#[no_mangle]`

Rust对符号名的修饰与主机的代码链接器所期望的不同。因此，需要告知任何被Rust导出到Rust外部去使用的函数不要被编译器修饰。

### `extern "C"`

默认，任何用Rust写的函数将使用Rust ABI(这也不稳定)。当编译面向外部的FFI APIs时，我们需要告诉编译器去使用系统ABI 。 

取决于你的平台，你可能想要针对一个特定的ABI版本，其记录在[这里](https://doc.rust-lang.org/reference/items/external-blocks.html)。

---

把这些部分放在一起，你得到一个函数，其粗略看起来像是这个。

```rust,ignore
#[no_mangle]
pub extern "C" fn rust_function() {

}
```

就像在Rust项目中使用`C`代码时那样，现在需要把数据转换为应用中其它部分可以理解的形式。

## 链接和更大的项目上下文

问题只解决了一半。

你现在要如何使用它?

**这很大程度上取决于你的项目或者编译系统**

`cargo`将生成一个`my_lib.so`/`my_lib.dll`或者`my_lib.a`文件，取决于你的平台和配置。可以通过编译系统简单地链接这个库。

然而，从C调用一个Rust函数要求一个头文件去声明函数的签名。

在Rust-ffi API中的每个函数需要有一个相关的头文件函数。

```rust,ignore
#[no_mangle]
pub extern "C" fn rust_function() {}
```

将会变成

```C
void rust_function();
```

等等。

这里有个工具可以自动化这个过程，叫做[cbindgen]，其会分析你的Rust代码然后为C和C++项目生成头文件。

[cbindgen]: https://github.com/eqrion/cbindgen

此时从C中使用Rust函数非常简单，只需包含头文件和调用它们！

```C
#include "my-rust-project.h"
rust_function();
```
