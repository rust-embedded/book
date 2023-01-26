# macOS

所有的工具都可以用[Homebrew]来安装:

[Homebrew]: http://brew.sh/

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

以上是全部内容！转到 [下个章节]。

[下个章节]: verify.md
