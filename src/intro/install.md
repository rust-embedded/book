# 安装工具
这一页包含那些与操作系统无关的工具安装指令：

### Rust 工具链
跟着[https://rustup.rs](https://rustup.rs)的指令安装rustup。

**NOTE** 确保你的编译器版本等于或者大于`1.31`版本。`rustc -V`应该返回一个比下列日期更新的日期。

``` text
$ rustc -V
rustc 1.31.1 (b6c32da9b 2018-12-18)
```
考虑到带宽和磁盘的使用量，默认安装只支持本地环境的编译。为了添加对ARM Cortex-M架构交叉编译的支持，从下列编译目标选择一个。对于这本书里使用的STM32F3DISCOVERY板子，使用`thumbv7em-none-eabihf`目标。

Cortex-M0, M0+, and M1 (ARMv6-M architecture):
``` console
rustup target add thumbv6m-none-eabi
```

Cortex-M3 (ARMv7-M architecture):
``` console
rustup target add thumbv7m-none-eabi
```

Cortex-M4 and M7 without hardware floating point (ARMv7E-M architecture):
``` console
rustup target add thumbv7em-none-eabi
```

Cortex-M4F and M7F with hardware floating point (ARMv7E-M architecture):
``` console
rustup target add thumbv7em-none-eabihf
```

Cortex-M23 (ARMv8-M architecture):
``` console
rustup target add thumbv8m.base-none-eabi
```

Cortex-M33 and M35P (ARMv8-M architecture):
``` console
rustup target add thumbv8m.main-none-eabi
```

Cortex-M33F and M35PF with hardware floating point (ARMv8-M architecture):
``` console
rustup target add thumbv8m.main-none-eabihf
```


### `cargo-binutils`

``` text
cargo install cargo-binutils

rustup component add llvm-tools-preview
```

### `cargo-generate`
我们随后将使用这个来从模板生成一个项目。

``` console
cargo install cargo-generate
```
注意:在某些Linux发行版上(e.g. Ubuntu) 在安装cargo-generate之前，你可能需要安装`libssl-dev`和`pkg-config`

### 操作系统特定指令
现在根据你使用的操作系统，来执行对应的指令:

- [Linux](install/linux.md)
- [Windows](install/windows.md)
- [macOS](install/macos.md)
