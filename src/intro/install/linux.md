> **⚠️: This section was last checked on 2018-09-13

# Linux

Here are the installation commands for a few Linux distributions.

## Packages

- Ubuntu 18.04 or newer / Debian stretch or newer

> **NOTE** `gdb-multiarch` is the GDB command you'll use to debug your ARM
> Cortex-M programs

<!-- Debian stretch -->
<!-- GDB 7.12 -->
<!-- OpenOCD 0.9.0 -->
<!-- QEMU 2.8.1 -->

<!-- Ubuntu 18.04 -->
<!-- GDB 8.1 -->
<!-- OpenOCD 0.10.0 -->
<!-- QEMU 2.11.1 -->

``` console
$ sudo apt-get install \
  gdb-multiarch \
  openocd \
  qemu-system-arm
```

- Ubuntu 14.04 and 16.04

> **NOTE** `arm-none-eabi-gdb` is the GDB command you'll use to debug your ARM
> Cortex-M programs

<!-- Ubuntu 14.04 -->
<!-- GDB 7.6 (!) -->
<!-- OpenOCD 0.7.0 (?) -->
<!-- QEMU 2.0.0 (?) -->

``` console
$ sudo apt-get install \
  gdb-arm-none-eabi \
  openocd \
  qemu-system-arm
```

- Fedora 27 or newer

> **NOTE** `arm-none-eabi-gdb` is the GDB command you'll use to debug your ARM
> Cortex-M programs

<!-- Fedora 27 -->
<!-- GDB 7.6 (!) -->
<!-- OpenOCD 0.10.0 -->
<!-- QEMU 2.10.2 -->

``` console
$ sudo dnf install \
  arm-none-eabi-gdb \
  openocd \
  qemu-system-arm
```

- Arch Linux

> **NOTE** `arm-none-eabi-gdb` is the GDB command you'll use to debug ARM
> Cortex-M programs

``` console
$ sudo pacman -S \
  arm-none-eabi-gdb \
  qemu-system-arm

$ yaourt -S openocd
```

## udev rules

These rules let you use OpenOCD with the Discovery board without root privilege.

Create this file in `/etc/udev/rules.d` with the contents shown below.

``` console
$ cat /etc/udev/rules.d/99-st-link.rules
```

``` text
# STM32F3DISCOVERY rev A/B - ST-LINK/V2
ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3748", MODE:="0666"

# STM32F3DISCOVERY rev C+ - ST-LINK/V2-1
ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374b", MODE:="0666"
```

Then reload the udev rules with:

``` console
$ sudo udevadm control --reload-rules
```

If you had the board plugged to your laptop, unplug it and then plug it again.

You can check the permissions by running these commands:

``` console
$ lsusb
(..)
Bus 001 Device 018: ID 0483:374b STMicroelectronics ST-LINK/V2.1
(..)
```

Take note of the bus and device numbers. Use those numbers in the following
command:

``` console
$ # the format of the path is /dev/bus/usb/<bus>/<device>
$ ls -l /dev/bus/usb/001/018
crw-rw-rw- 1 root root 189, 17 Sep 13 12:34 /dev/bus/usb/001/018
```

The permissions should be `crw-rw-rw-`; this indicates that all users can make
use of this device.

Now, go to the [next section].

[next section]: /intro/install/verify.html
