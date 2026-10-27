#import "../../config.typ": *

#h1([macOS],
  offset: whole*2)
<install-macos>

#let brew_ln = link("http://brew.sh/")[Homebrew]
#let ports_ln = link("https://www.macports.org/")[MacPorts]

#tr((
en: [
  All the tools can be installed using #brew_ln or #ports_ln:
],
de: [
  Alle Werkzeuge können mit #brew_ln oder #ports_ln installiert werden:
],
ja: [
  #todoupd("ja")
  全てのツールは、#brew_ln;を使ってインストールできます。
],
zh: [
  所有的工具都可以使用#brew_ln;或者#ports_ln;来安装：
]))

= #tr((
  en: [Install tools with #brew_ln],
  de: [Werkzeuge mit #brew_ln installieren],
  zh: [使用#brew_ln;安装工具],
))

```text
$ # GDB
$ brew install arm-none-eabi-gdb

$ # OpenOCD
$ brew install openocd

$ # QEMU
$ brew install qemu
```

#quote(block: true)[
#tr((
en: [
  *NOTE* If OpenOCD crashes you may need to install the latest
  version using:
],
de: [
  *HINWEIS* Falls OpenOCD abstürzt, müssen Sie möglicherweise die
  neueste Version installieren; verwenden Sie dazu:
],
zh: [
  *注意* 如果OpenOCD崩溃了，你可能需要用以下方法安装最新版本:
]))
]

```text
$ brew install --HEAD openocd
```

= #tr((
  en: [Install tools with #ports_ln],
  de: [Werkzeuge mit #ports_ln installieren],
  zh: [使用#ports_ln;安装工具],
))

```text
$ # GDB
$ sudo port install arm-none-eabi-gcc

$ # OpenOCD
$ sudo port install openocd

$ # QEMU
$ sudo port install qemu
```

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
  这是全部内容，请转入#link(<verify-installation>)[下个章节]．
]))
