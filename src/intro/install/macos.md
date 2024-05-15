# macOS

所有的工具都可以使用[Homebrew]或者[MacPorts]来安装：

[Homebrew]: http://brew.sh/
[MacPorts]: https://www.macports.org/

## 使用[Homebrew]安装工具

``` text
$ # GDB
$ brew install armmbed/formulae/arm-none-eabi-gcc

$ # OpenOCD
$ brew install openocd

$ # QEMU
$ brew install qemu
```

> **注意** 如果OpenOCD崩溃了，你可能需要用以下方法安装最新版本: 

```text
$ brew install --HEAD openocd
```

## 使用[MacPorts]安装工具

``` text
$ # GDB
$ sudo port install arm-none-eabi-gcc

$ # OpenOCD
$ sudo port install openocd

$ # QEMU
$ sudo port install qemu
```


这是全部内容，请转入[下个章节]．

[下个章节]: verify.md
