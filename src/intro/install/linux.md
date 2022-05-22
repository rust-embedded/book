# Linux

这部分是在某些Linux发行版环境下下的安装指令。

## Packages

- Ubuntu 18.04 或者更新的版本 / Debian stretch 或者更新的版本

> **注意** `gdb-multiarch` 是你将用来调试你的ARM Cortex-M程序的GDB命令

<!-- Debian stretch -->
<!-- GDB 7.12 -->
<!-- OpenOCD 0.9.0 -->
<!-- QEMU 2.8.1 -->

<!-- Ubuntu 18.04 -->
<!-- GDB 8.1 -->
<!-- OpenOCD 0.10.0 -->
<!-- QEMU 2.11.1 -->

``` console
sudo apt install gdb-multiarch openocd qemu-system-arm
```

- Ubuntu 14.04 and 16.04

> **注意** `arm-none-eabi-gdb` 是你将用来调试你的ARM Cortex-M程序的GDB命令

<!-- Ubuntu 14.04 -->
<!-- GDB 7.6 (!) -->
<!-- OpenOCD 0.7.0 (?) -->
<!-- QEMU 2.0.0 (?) -->

``` console
sudo apt install gdb-arm-none-eabi openocd qemu-system-arm
```

- Fedora 27 或者更新的版本

> **注意** `arm-none-eabi-gdb` 是你将用来调试你的ARM Cortex-M程序的GDB命令

<!-- Fedora 27 -->
<!-- GDB 7.6 (!) -->
<!-- OpenOCD 0.10.0 -->
<!-- QEMU 2.10.2 -->

``` console
sudo dnf install arm-none-eabi-gdb openocd qemu-system-arm
```

- Arch Linux

> **注意** `arm-none-eabi-gdb` 是你将用来调试你的ARM Cortex-M程序的GDB命令

``` console
sudo pacman -S arm-none-eabi-gdb qemu-arch-extra openocd
```

## udev 规则

这个规则可以让你在不需要超级用户权限的情况下，使用OpenOCD和Discovery开发板。

生成包含下列内容的 `/etc/udev/rules.d/70-st-link.rules` 文件

``` text
# STM32F3DISCOVERY rev A/B - ST-LINK/V2
ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3748", TAG+="uaccess"

# STM32F3DISCOVERY rev C+ - ST-LINK/V2-1
ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374b", TAG+="uaccess"
```

然后重新加载所有的udev规则

``` console
sudo udevadm control --reload-rules
```

如果开发板已经被插入了你的笔记本，拔下它然后再插上它。

你可以通过运行这个命令检查权限:

``` console
lsusb
```

终端显示的东西看起来像是

```text
(..)
Bus 001 Device 018: ID 0483:374b STMicroelectronics ST-LINK/V2.1
(..)
```

记住bus和device号，使用这些数字创造一个像是 `/dev/bus/usb/<bus>/<device>` 这样的路径。然后像这样使用这个路径:

``` console
ls -l /dev/bus/usb/001/018
```

```text
crw-------+ 1 root root 189, 17 Sep 13 12:34 /dev/bus/usb/001/018
```

```console
getfacl /dev/bus/usb/001/018 | grep user
```

```text
user::rw-
user:you:rw-
```

权限后的 `+` 指出存在一个扩展权限。`getfacl` 命令显示，`user`也就是`你`能使用这个设备。

现在，去往[下个章节].

[下个章节]: verify.md
