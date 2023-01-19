# macOS

All the tools can be installed using [Homebrew]:

[Homebrew]: http://brew.sh/

``` text
$ # GDB
$ brew install armmbed/formulae/arm-none-eabi-gcc

$ # OpenOCD
$ brew install openocd

$ # QEMU
$ brew install qemu
```

> **NOTE** If OpenOCD crashes you may need to install the latest version using: 
```text
$ brew install --HEAD openocd
```

That's all! Go to the [next section].

[next section]: verify.md
