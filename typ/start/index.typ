#import "../config.typ": *

#h1((en: [Getting Started],
  de: [Erste Schritte],
  ja: [入門],
  zh: [开始],
))
<getting-started>

#let ln_f3 = link("http://www.st.com/en/evaluation-tools/stm32f3discovery.html")[STM32F3DISCOVERY]
#tr((
en: [
  In this section we'll walk you through the process of writing, building,
  flashing and debugging embedded programs. You will be able to try most
  of the examples without any special hardware as we will show you the
  basics using QEMU, a popular open-source hardware emulator. The only
  section where hardware is required is, naturally enough, the
  #link(<getting-started-hardware>)[Hardware] section, where we use OpenOCD to
  program an #ln_f3.
],
de: [
  In diesem Abschnitt führen wir Sie Schritt für Schritt durch den Prozess
  des Schreibens, Kompilierens, Flashen und Debuggens von
  Embedded-Programmen. Sie können die meisten der Beispiele ohne spezielle
  Hardware ausprobieren, da wir Ihnen die Grundlagen mithilfe von QEMU,
  einem beliebten Open-Source-Hardware-Emulator, vermitteln. Der einzige
  Abschnitt, in dem Hardware erforderlich ist, ist natürlich der Abschnitt
  #link(<getting-started-hardware>)[Hardware], wo wir OpenOCD verwenden, um ein
  #ln_f3 zu programmieren.
],
ja: [
  このセクションでは、組込みプログラムを書いて、ビルドして、フラッシュに書き込み、デバッグする、という一連のプロセスを説明します。
  ほとんどの例を特別なハードウェアなしで試すことができます。有名なオープンソースハードウェアエミュレータであるQEMUを使うからです。
  ハードウェアが必要となる唯一のセクションは、当然ながら、OpenOCDを使って#ln_f3;にプログラムする#link(<getting-started-hardware>)[Hardware]セクションです。
],
zh: [
  在这部分里，你将会经历编写，编译，烧录和调试嵌入式程序。大多数的例子都不需要特定的硬件就可以试试，因为我们将要向你展示一个开源硬件仿真器，QEMU的基本使用。唯一需要硬件的部分，那就是，#link(<getting-started-hardware>)[硬件]那一章，我们会使用OpenOCD去编程一个#ln_f3。
]))