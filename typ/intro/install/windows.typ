#import "../../config.typ": *

#h1([Windows],
  offset: whole*2)
<install-windows>

= `arm-none-eabi-gdb`

#let url_arm_gnu = "https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads"
#tr((
en: [
  ARM provides `.exe` installers for Windows. Grab one from #link(url_arm_gnu)[here],
  and follow the instructions. Just before the installation process
  finishes tick/select the "Add path to environment variable" option. Then
  verify that the tools are in your `%PATH%`:
],
de: [
  ARM stellt `.exe`-Installationsprogramme für Windows bereit.
  Laden Sie eines von #link(url_arm_gnu)[hier]
  herunter und befolgen Sie die Anweisungen. Aktivieren Sie kurz vor
  Abschluss des Installationsvorgangs die Option „Add path to environment
  variable". Überprüfen Sie anschließend, ob die Werkzeuge in Ihrem
  `%PATH%` enthalten sind:
],
ja: [
  ARMはWindows向けに`.exe`インストーラを提供しています。#link(url_arm_gnu)[here]から1つを入手して、手順に従って下さい。
  インストールプロセスが終了する直前に"環境変数にパスを追加"オプションを選択します。
  その後、ツールが`%PATH%`にあることを確認します。
],
zh: [
  ARM提供了用于Windows的`.exe`安装程序。从#link(url_arm_gnu)[这里]获取,
  然后按照说明操作。 在完成安装之前，勾选/选择"Add path to environment
  variable"选项。 然后验证环境变量是否添加到 `%PATH%`中:
]))

```text
$ arm-none-eabi-gdb -v
GNU gdb (GNU Tools for Arm Embedded Processors 7-2018-q2-update) 8.1.0.20180315-git
(..)
```

= OpenOCD

#let url_openocd = "https://xpack.github.io/openocd/"
#let bin_path = `C:\Users\USERNAME\AppData\Roaming\xPacks\@xpack-dev-tools\openocd\0.10.0-13.1\.content\bin\`
#tr((
en: [
  There's no official binary release of OpenOCD for Windows but if you're
  not in the mood to compile it yourself, the xPack project provides a
  binary distribution, #link(url_openocd)[here].
  Follow the provided installation instructions. Then update your `%PATH%`
  environment variable to include the path where the binaries were
  installed. (#bin_path, if you've been using the easy install)
],
de: [
  Es gibt kein offizielles Binär-Release von OpenOCD für Windows, aber
  wenn Sie es nicht selbst kompilieren möchten, stellt das xPack-Projekt
  eine Binärdistribution bereit -- zu finden
  #link(url_openocd)[hier]. Befolgen Sie die dort
  aufgeführten Installationsanweisungen. Aktualisieren Sie anschließend
  Ihre Umgebungsvariable `%PATH%`, indem Sie den Pfad hinzufügen, unter
  dem die Binärdateien installiert wurden (z. B. #bin_path,
  falls Sie die einfache Installation verwendet haben).
],
zh: [
  OpenOCD 官方没有提供Windows的二进制版本，
  若你没有心情去折腾编译，#link(url_openocd)[这里]有xPack提供的一个二进制发布.。按照说明进行安装。然后更新你的`%PATH%` 环境变量，将安装目录包括进去。 (#bin_path, 如果使用简易安装)
]))

#tr((
en: [
  Verify that OpenOCD is in your `%PATH%` with:
],
de: [
  Überprüfen Sie mit folgendem Befehl, ob OpenOCD in Ihrem `%PATH%` enthalten ist:
],
zh: [
  使用以下命令验证OpenOCD是否在你的`%PATH%`环境变量中 :
]))

```text
$ openocd -v
Open On-Chip Debugger 0.10.0
(..)
```

= QEMU

#let url_qemu = "https://www.qemu.org/download/#windows"
#tr((
en: [
  Grab QEMU from #link(url_qemu)[the official website].
],
de: [
  Lade QEMU von #link(url_qemu)[der offiziellen Website] herunter.
],
ja: [
  #link(url_qemu)[QEMU公式サイト]からQEMUを入手します。
],
zh: [
  从#link(url_qemu)[官网]获取QEMU。
]))

= #tr((
  en: [ST-LINK USB driver],
  de: [ST-LINK USB driver],
  ja: [ST-LINK USBドライバ],
  zh: [ST-LINK USB driver],
))

#let url_stlink = "http://www.st.com/en/embedded-software/stsw-link009.html"
#tr((
en: [
  You'll also need to install #link(url_stlink)[this USB driver]
  or OpenOCD won't work. Follow the installer instructions and make sure
  you install the right version (32-bit or 64-bit) of the driver.
],
de: [
  Sie müssen außerdem #link(url_stlink)[diesen USB-Treiber]
  installieren, da OpenOCD sonst nicht funktioniert. Befolgen Sie die
  Anweisungen des Installationsprogramms und stellen Sie sicher, dass Sie
  die richtige Version des Treibers (32-Bit oder 64-Bit) installieren.
],
ja: [
  #link(url_stlink)[USBドライバ]もインストールする必要があります。そうでなければOpenOCDは動きません。インストーラの手順に従って下さい。
  そして、正しいドライバのバージョン(32ビットか64ビット)をインストールすることを確認して下さい。
],
zh: [
  你还需要安装这个
  #link(url_stlink)[USB驱动]
  否则OpenOCD将无法工作。按照安装程序的说明，确保你安装了正确版本（32位或64位）的驱动程序。
]))

#tr((
en: [
  That's all! Go to the #link(<verify-installation>)[next section].
],
de: [
  Das war's! Gehen Sie zum #link(<verify-installation>)[nächsten Abschnitt].
],
ja: [
  以上です！#link(<verify-installation>)[次のセクション]に進んで下さい。
],
zh: [
  以上是全部内容！转到 #link(<verify-installation>)[下个章节]。
]))
