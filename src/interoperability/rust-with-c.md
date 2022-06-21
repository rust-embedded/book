# A little Rust with your C

在C或者C++中使用Rust代码通常由两部分组成。

- 用Rust创造一个C友好的API
- 将你的Rust项目嵌入一个外部的编译系统

除了`cargo`和`meson`，大多数编译系统没有原生Rust支持。因此你最好只用`cargo`编译你的crate和依赖。

## 设置一个项目

像往常一样创建一个新的`cargo`项目。有一些标志可以告诉`cargo`去生成一个系统库，而不是常规的rust目标文件。如果你想要它与你的crate的其它部分不一样，这也允许你为你的库设置一个不同的输出名。

```toml
[lib]
name = "your_crate"
crate-type = ["cdylib"]      # 生成动态链接库
# crate-type = ["staticlib"] # 生成静态链接库
```

## 构建一个`C` API

因为对于Rust编译器来说，C++没有稳定的ABI，因此我们使用`C`表示不同语言间的互用性。在C和C++代码的内部使用Rust时也不例外。

### `#[no_mangle]`

Rust对符号名的修饰与本机的代码链接器所期望的不同。因此，需要告知任何被Rust导出到Rust外部去使用的函数不要被编译器修饰。

### `extern "C"`

默认，任何用Rust写的函数将使用Rust ABI(这也不稳定)。相反，当编译面向外部的FFI APIs，我们需要告诉编译器去使用系统ABI 。 

取决于你的平台，你可能需要针对一个特定的ABI版本，其记录在[这里](https://doc.rust-lang.org/reference/items/external-blocks.html)。

---

把这些部分放在一起，你得到一个函数，其粗略看起来像是这个。

```rust,ignore
#[no_mangle]
pub extern "C" fn rust_function() {

}
```

Just as when using `C` code in your Rust project you now need to transform data
from and to a form that the rest of the application will understand.

## Linking and greater project context.

So then, that's one half of the problem solved.
How do you use this now?

**This very much depends on your project and/or build system**

`cargo` will create a `my_lib.so`/`my_lib.dll` or `my_lib.a` file,
depending on your platform and settings. This library can simply be linked
by your build system.

However, calling a Rust function from C requires a header file to declare
the function signatures.

Every function in your Rust-ffi API needs to have a corresponding header function.

```rust,ignore
#[no_mangle]
pub extern "C" fn rust_function() {}
```

would then become

```C
void rust_function();
```

etc.

There is a tool to automate this process,
called [cbindgen] which analyses your Rust code
and then generates headers for your C and C++ projects from it.

[cbindgen]: https://github.com/eqrion/cbindgen

At this point, using the Rust functions from C
is as simple as including the header and calling them!

```C
#include "my-rust-project.h"
rust_function();
```
