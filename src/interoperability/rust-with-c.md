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

因为C++没有稳定的ABI

Because C++ has no stable ABI for the Rust compiler to target, we use `C` for
any interoperability between different languages. This is no exception when using Rust
inside of C and C++ code.

### `#[no_mangle]`

The Rust compiler mangles symbol names differently than native code linkers expect.
As such, any function that Rust exports to be used outside of Rust needs to be told
not to be mangled by the compiler.

### `extern "C"`

By default, any function you write in Rust will use the
Rust ABI (which is also not stabilized).
Instead, when building outwards facing FFI APIs we need to
tell the compiler to use the system ABI.

Depending on your platform, you might want to target a specific ABI version, which are
documented [here](https://doc.rust-lang.org/reference/items/external-blocks.html).

---

Putting these parts together, you get a function that looks roughly like this.

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
