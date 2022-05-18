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

Then reload all the udev rules with:

``` console
sudo udevadm control --reload-rules
```

If you had the board plugged to your laptop, unplug it and then plug it again.

You can check the permissions by running this command:

``` console
lsusb
```

Which should show something like

```text
(..)
Bus 001 Device 018: ID 0483:374b STMicroelectronics ST-LINK/V2.1
(..)
```

Take note of the bus and device numbers. Use those numbers to create a path like
`/dev/bus/usb/<bus>/<device>`. Then use this path like so:

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

The `+` appended to permissions indicates the existence of an extended
permission. The `getfacl` command tells the user `you` can make use of
this device.

Now, go to the [next section].

[next section]: verify.md
