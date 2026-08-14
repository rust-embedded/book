#import "../../config.typ": *

#h1([Linux],
  offset: whole*2)
<install-linux>

#tr((
en: [
  Here are the installation commands for a few Linux distributions.
],
de: [
  Hier sind die Installationsbefehle für einige Linux-Distributionen.
],
ja: [
  いくつかのLinuxディストリビューションのインストールコマンドを示します。
],
zh: [
  这部分是在某些Linux发行版下的安装指令。
]))

= #tr((
  en: [Packages],
  de: [Pakete],
  ja: [Packages],
  zh: [依赖包],
))

#tr((
en: [
  - Ubuntu 18.04 or newer / Debian stretch or newer
],
de: [
  - Ubuntu 18.04 oder neuer / Debian Stretch oder neuer
],
ja: [
  - Ubuntu 18.04以上 / Debian stretch以降
],
zh: [
  - Ubuntu 18.04 或者更新的版本 / Debian stretch 或者更新的版本
]))

#quote(block: true)[
#tr((
en: [
  *NOTE* `gdb-multiarch` is the GDB command you'll use to debug
  your ARM Cortex-M programs
],
de: [
  *HINWEIS* `gdb-multiarch` ist der GDB-Befehl, den Sie zum
  Debuggen Ihrer ARM-Cortex-M-Programme verwenden werden.
],
ja: [
  *注記* `gdb-multiarch`は、ARM
  Cortex-Mプログラムをデバッグするために使用するGDBのコマンドです。
],
zh: [
  * 注意* `gdb-multiarch` 是你将用来调试你的ARM
]))
]

```console
sudo apt install gdb-multiarch openocd qemu-system-arm
```

#let _and_ = tr((
  en: [ and ],
  de: [ und ],
  ja: [と],
), default: [ and ])

- Ubuntu 14.04#_and_;16.04

#quote(block: true)[
#tr((
en: [
  *NOTE* `arm-none-eabi-gdb` is the GDB command you'll use to debug
  your ARM Cortex-M programs
],
de: [
  *HINWEIS* `arm-none-eabi-gdb` ist der GDB-Befehl, den Sie zum
  Debuggen Ihrer ARM-Cortex-M-Programme verwenden werden.
],
ja: [
  *注記* `arm-none-eabi-gdb`は、ARM
  Cortex-Mプログラムをデバッグするために使用するGDBのコマンドです。
],
zh: [
  *注意* `arm-none-eabi-gdb` 是你将用来调试你的ARM
  Cortex-M程序的GDB命令
]))
]

```console
sudo apt install gdb-arm-none-eabi openocd qemu-system-arm
```

#tr((
en: [
  - Fedora 27 or newer
],
de: [
  - Fedora 27 oder neuer
],
ja: [
  - Fedora 27以上
],
zh: [
  - Fedora 27 或者更新的版本
]))

```console
sudo dnf install gdb openocd qemu-system-arm
```

- Arch Linux

#quote(block: true)[
#tr((
en: [
  *NOTE* `arm-none-eabi-gdb` is the GDB command you'll use to debug
  ARM Cortex-M programs
],
de: [
  *HINWEIS* `arm-none-eabi-gdb` ist der GDB-Befehl, den Sie zum
  Debuggen von ARM-Cortex-M-Programmen verwenden.
],
ja: [
  *注記* `arm-none-eabi-gdb`は、ARM
  Cortex-Mプログラムをデバッグするために使用するGDBのコマンドです。
],
zh: [
  *注意* `arm-none-eabi-gdb` 是你将用来调试你的ARM Cortex-M程序的GDB命令
]))
]

```console
sudo pacman -S arm-none-eabi-gdb qemu-system-arm openocd
```

= #tr((
  en: [udev rules],
  de: [udev-Regeln],
  ja: [udevルール],
  zh: [udev 规则],
))
<linux-udev-rules>

#tr((
en: [
  This rule lets you use OpenOCD with the Discovery board without root privilege.
],
de: [
  Diese Regel ermöglicht die Nutzung von OpenOCD mit dem Discovery Board ohne Root-Rechte.
],
ja: [
  このルールにより、ルート権限なしで、OpenOCDをDiscoveryボードに対して使えるようにします。
],
zh: [
  这个规则可以让你在不使用超级用户权限的情况下，使用OpenOCD和Discovery开发板。
]))

#let file_stlink = `/etc/udev/rules.d/70-st-link.rules`
#tr((
en: [
  Create the file #file_stlink with the contents shown below.
],
de: [
  Erstellen Sie die Datei #file_stlink mit dem unten stehenden Inhalt.
],
ja: [
  #todoupd("ja")
  下記の内容で、`/etc/udev/rules.d`ディレクトリにファイルを作成します。
],
zh: [
  生成包含下列内容的 #file_stlink 文件
]))

```text
# STM32F3DISCOVERY rev A/B - ST-LINK/V2
ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3748", TAG+="uaccess"

# STM32F3DISCOVERY rev C+ - ST-LINK/V2-1
ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374b", TAG+="uaccess"
```

#tr((
en: [
  Then reload all the udev rules with:
],
de: [
  Laden Sie anschließend alle udev-Regeln neu mit:
],
ja: [
  その後、全てのudevルールをリロードします。
],
zh: [
  然后重新加载所有的udev规则
]))

```console
sudo udevadm control --reload-rules
```

#tr((
en: [
  If you had the board plugged to your laptop, unplug it and then plug it again.
],
de: [
  Wenn Sie die Platine an Ihren Laptop angeschlossen hatten, ziehen Sie
  den Stecker heraus und schließen Sie ihn dann erneut an.
],
ja: [
  既にボードをノートPCに接続している場合、一度抜いてから、もう一度接続します。
],
zh: [
  如果你已经把开发板插入到笔记本中了，请拔下它然后再插上它。
]))

#tr((
en: [
  You can check the permissions by running this command:
],
de: [
  Sie können die Berechtigungen überprüfen, indem Sie diesen Befehl ausführen:
],
ja: [
  これらのコマンド実行することで、パーミッションを確認できます。
],
zh: [
  你可以通过运行这个命令检查权限:
]))

```console
lsusb
```

#tr((
en: [
  Which should show something like
],
de: [
  Was so etwas wie
],
zh: [
  终端可能有如下显示
]))

```text
(..)
Bus 001 Device 018: ID 0483:374b STMicroelectronics ST-LINK/V2.1
(..)
```
#if lang == "de" [
  anzeigen sollte.
]

#tr((
en: [
  Take note of the bus and device numbers. Use those numbers to create a
  path like `/dev/bus/usb/<bus>/<device>`. Then use this path like so:
],
de: [
  Notieren Sie sich die Bus- und Gerätenummern. Verwenden Sie diese
  Nummern, um einen Pfad wie `/dev/bus/usb/<bus>/<device>` zu bilden.
  Verwenden Sie diesen Pfad anschließend wie folgt:
],
zh: [
  记住bus和device号，使用这些数字组合成一个像是
  `/dev/bus/usb/<bus>/<device>` 这样的路径。然后像这样使用这个路径:
]))

```console
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

#tr((
en: [
  The `+` appended to permissions indicates the existence of an extended
  permission. The `getfacl` command tells the user `you` can make use of
  this device.
],
de: [
  Das angehängte „+" bei den Berechtigungen weist auf eine erweiterte
  Berechtigung hin. Der Befehl „getfacl" teilt dem Benutzer mit, dass er
  dieses Gerät verwenden darf.
],
ja: [
  #todoupd("ja")
  パーミッションに追加された`+`は、パーミッションが拡張されたことを意味しています。
],
zh: [
  权限后的 `+` 指出存在一个扩展权限。`getfacl`
  命令显示，`user`也就是`你`，可以使用这个设备。
]))

#tr((
en: [
  Now, go to the #link(<verify-installation>)[next section].
],
de: [
  Fahren Sie nun mit dem #link(<verify-installation>)[nächsten Abschnitt] fort.
],
ja: [
  それでは、#link(<verify-installation>)[次のセクション]に進んで下さい。
],
zh: [
  现在，去往#link(<verify-installation>)[下个章节].
]))
