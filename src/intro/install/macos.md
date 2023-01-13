# macOS

所有工具都可以通过 [Homebrew] 安装:

[Homebrew]: http://brew.sh/

``` text
$ # GDB
$ brew install armmbed/formulae/arm-none-eabi-gcc

$ # OpenOCD
$ brew install openocd

$ # QEMU
$ brew install qemu
```

> **注意** 如果 OpenOCD 崩溃，你可能需要使用如下命令安装最新版本: 
```text
$ brew install --HEAD openocd
```

就这些! 去往 [下个章节].

[下个章节]: verify.md
