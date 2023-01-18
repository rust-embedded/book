# Windows

## `arm-none-eabi-gdb`

ARM提供了用于Windows的`.exe`安装程序。从[这里][gcc]获取, 然后按照说明操作。
在完成安装之前，勾选/选择"Add path to environment variable"选项。
然后验证环境变量是否添加到 `%PATH%`中:

``` text
$ arm-none-eabi-gdb -v
GNU gdb (GNU Tools for Arm Embedded Processors 7-2018-q2-update) 8.1.0.20180315-git
(..)
```

[gcc]: https://developer.arm.com/open-source/gnu-toolchain/gnu-rm/downloads

## OpenOCD

OpenOCD 官方没有提供Windows的二进制版本， 若你没有心情去折腾编译，[这里][openocd]有xPack提供的一个二进制发布.。按照说明进行安装。然后更新你的`%PATH%` 环境变量，将安装目录包括进去。 (`C:\Users\USERNAME\AppData\Roaming\xPacks\@xpack-dev-tools\openocd\0.10.0-13.1\.content\bin\`,
如果使用简易安装) 

[openocd]: https://xpack.github.io/openocd/

使用以下命令验证OpenOCD是否在你的`%PATH%`环境变量中 :

``` text
$ openocd -v
Open On-Chip Debugger 0.10.0
(..)
```

## QEMU

从[官网][qemu]获取QEMU。

[qemu]: https://www.qemu.org/download/#windows

## ST-LINK USB driver

你还需要安装这个 [USB驱动] 否则OpenOCD将无法工作。按照安装程序的说明，确保你安装了正确版本（32位或64位）的驱动程序。

[USB驱动]: http://www.st.com/en/embedded-software/stsw-link009.html

以上是全部内容！转到 [下一节]。

[下一节]: verify.md
