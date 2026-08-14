#import "../config.typ": *

#h1((en: [Tooling],
  de: [Werkzeuge],
  ja: [ツール],
  zh: [工具],
), offset: whole)

#tr((
en: [
  Dealing with microcontrollers involves using several different tools as
  we'll be dealing with an architecture different than your laptop's and
  we'll have to run and debug programs on a _remote_ device.
],
de: [
  Der Umgang mit Mikrocontrollern erfordert den Einsatz verschiedener
  Werkzeuge, da wir es mit einer Architektur zu tun haben, die sich von
  der Ihres Laptops unterscheidet, und Programme auf einem
  _entfernten_ Gerät ausführen sowie debuggen müssen.
],
ja: [
  マイクロコントローラを扱う際は、いくつかの異なるツールを利用することになります。あなたのノートPCとは異なるアーキテクチャを扱うことになるでしょうし、_リモート_デバイス上でプログラムを実行しデバッグする必要があります。
],
zh: [
  与微控制器打交道需要使用几种不同的工具，因为我们要处理的架构与笔记本电脑不同，我们必须在 _远程_
]))

#let ln_binutils = link("https://github.com/rust-embedded/cargo-binutils")[`cargo-binutils`]
#let ln_qemu = link("https://www.qemu.org/")[`qemu-system-arm`]
#let ln_generate = link("https://github.com/ashleygwilliams/cargo-generate")[`cargo-generate`]
#tr((
en: [
  We'll use all the tools listed below. Any recent version should work
  when a minimum version is not specified, but we have listed the versions
  we have tested.
  - Rust 1.31, 1.31-beta, or a newer toolchain PLUS ARM Cortex-M
    compilation support.
  - #ln_binutils \~0.1.4
  - #ln_qemu. Tested versions: 3.0.0
  - OpenOCD \>=0.8. Tested versions: v0.9.0 and v0.10.0
  - GDB with ARM support. Version 7.12 or newer highly recommended.
    Tested versions: 7.10, 7.11, 7.12 and 8.1
  - #ln_generate or `git`.
    These tools are optional but will make it easier to follow along with the book.
],
de: [
  Wir werden alle unten aufgeführten Werkzeuge verwenden. Sofern keine
  Mindestversion angegeben ist, sollte jede aktuelle Version
  funktionieren; wir haben jedoch die Versionen aufgelistet, die wir
  getestet haben.
  - Rust 1.31, 1.31-beta oder neuer, SOWIE Unterstützung für die
    Kompilierung für ARM Cortex-M.
  - #ln_binutils \~0.1.4
  - #ln_qemu. Getestete Version: 3.0.0
  - OpenOCD \>=0.8. Getestete Versionen: v0.9.0 und v0.10.0
  - GDB mit ARM-Unterstützung. Version 7.12 oder neuer wird dringend
    empfohlen. Getestete Versionen: 7.10, 7.11, 7.12 und 8.1.
  - #ln_generate oder `git`.
    Diese Werkzeuge sind optional, erleichtern es jedoch, dem Buch zu folgen.
],
ja: [
  下記リストのツールを利用します。最小バージョンが指定されていない場合、新しいバージョンであれば機能するはずです。私たちがテストしたバージョンをリストに示しています。
  - ARM Cortex-Mコンパイルサポートを追加したRust 1.31、1.31-beta以上のツールチェイン。
  - #ln_binutils\~0.1.4
  - #ln_qemu。テストしたバージョン: 3.0.0
  - OpenOCD \>=0.8.テストしたバージョン: v0.9.0とv0.10.0
  - ARMサポートのGDB。バージョン7.12以上を強く推奨。テストしたバージョン:
    7.10、7.11、7.12、8.1
  - \[任意\]
    `git`または#ln_generate。どちらもインストールしていないのであれば、どちらをインストールしてもかまいません。
],
zh: [
  设备上运行和调试程序。我们将使用下面列举出来的工具。当没有指定一个最小版本时，最新的版本应该也可以用，但是我们还是列出了我们已经测过的那些版本。
  - Rust 1.31, 1.31-beta, 或者一个更新的，支持ARM Cortex-M编译的工具链。
  - #ln_binutils \~0.1.4
  - #ln_qemu. 测试的版本: 3.0.0
  - OpenOCD \>=0.8. 测试的版本: v0.9.0 and v0.10.0
  - 有ARM支持的GDB。强烈建议7.12或者更新的版本。测试版本: 7.10, 7.11 和 8.1
  - #ln_generate 或者 `git`。
  这些工具都是可选的，但是跟着这本书来使用它们，会更容易。
]))

#tr((
en: [
  The text below explains why we are using these tools. Installation
  instructions can be found on the next page.
],
de: [
  Der folgende Text erläutert, warum wir diese Werkzeuge verwenden.
  Installationsanweisungen finden Sie auf der nächsten Seite.
],
ja: [
  下記に、なぜこれらのツールを利用するのか、を説明します。インストール方法は、次のページにあります。
],
zh: [
  下面的文档将解释我们为什么使用这些工具。安装指令可以在下一页找到。
]))

= #tr((
  en: [`cargo-generate` OR `git`],
  de: [`cargo-generate` ODER `git`],
  ja: [`cargo-generate`か`git`],
  zh: [`cargo-generate` 或者 `git`],
))

#tr((
en: [
  Bare metal programs are non-standard (`no_std`) Rust programs that
  require some adjustments to the linking process in order to get the
  memory layout of the program right. This requires some additional files
  (like linker scripts) and settings (like linker flags). We have packaged
  those for you in a template such that you only need to fill in the
  missing information (such as the project name and the characteristics of
  your target hardware).
],
de: [
  „Bare-Metal"-Programme sind Rust-Programme ohne Standardbibliothek
  (`no_std`), die Anpassungen am Linker-Vorgang erfordern, um das korrekte
  Speicherlayout des Programms zu gewährleisten. Dies macht zusätzliche
  Dateien (wie Linker-Skripte) und Einstellungen (wie Linker-Flags)
  erforderlich. Wir haben diese Elemente in einer Vorlage zusammengefasst,
  sodass Sie lediglich die noch fehlenden Angaben ergänzen müssen (etwa
  den Projektnamen und die Spezifikationen Ihrer Zielhardware).
],
ja: [
  ベアメタルプログラムは、非標準
  (`no_std`)なRustプログラムであり、プログラムのメモリレイアウトを正しくするために、リンクプロセスをいじる必要があります。
  これには、独特なファイル(リンカスクリプトなど)と設定(リンカフラグ)が必要です。
  プロジェクト名やターゲットハードウェアの特徴などを、空白に入力するだけで済むように、テンプレートを用意しています。
],
zh: [
  裸机编程是非标准Rust编程，为了得到正确的程序的内存布局，需要对链接过程进行一些调整，这要求添加一些额外的文件(比如linker
  scripts)和配置(比如linker
  flags)。我们已经为你把这些打包进了一个模板里了，你只需要补充缺失的信息(比如项目名和目标硬件的特性)。
]))

#tr((
en: [
  Our template is compatible with `cargo-generate`: a Cargo subcommand for
  creating new Cargo projects from templates. You can also download the
  template using `git`, `curl`, `wget`, or your web browser.
],
de: [
  Unsere Vorlage ist mit `cargo-generate` kompatibel -- einem
  Cargo-Unterbefehl zum Erstellen neuer Cargo-Projekte auf Basis von
  Vorlagen. Alternativ können Sie die Vorlage auch mithilfe von `git`,
  `curl`, `wget` oder Ihrem Webbrowser herunterladen.
],
ja: [
  このテンプレートは、`cargo-generate`との互換性があります。`cargo-generate`は、テンプレートからCargoプロジェクトを作成するためのCargoのサブコマンドです。
  このテンプレートは、`git`や`curl`、`wget`、ウェブブラウザを使ってダウンロードできます。
],
zh: [
  我们的模板兼容`cargo-generate`:一个用来从模板生成新的Cargo项目的Cargo子命令。你也能使用`git`,`curl`,`wget`,或者你的网页浏览器下载模板。
]))

= `cargo-binutils`

#tr((
en: [
  `cargo-binutils` is a collection of Cargo subcommands that make it easy
  to use the LLVM tools that are shipped with the Rust toolchain. These
  tools include the LLVM versions of `objdump`, `nm` and `size` and are
  used for inspecting binaries.
],
de: [
  `cargo-binutils` ist eine Sammlung von Cargo-Unterbefehlen, die die
  Verwendung der mit der Rust-Toolchain ausgelieferten LLVM-Werkzeuge
  vereinfachen. Zu diesen Werkzeugen gehören die LLVM-Varianten von
  `objdump`, `nm` und `size`, die zur Untersuchung von Binärdateien dienen.
],
ja: [
  `cargo-binutils`は、Rustツールチェインとともに配布されているLLVMツールを簡単に使うためのCargoサブコマンド一式です。
  これらのツールは、LLVMの`objdump`や`nm`、`size`を含んでおり、バイナリを調査するために使われます。
],
zh: [
  `cargo-binutils`是一个Cargo命令的子集，它让我们能轻松使用Rust工具链带来的LLVM工具。这些工具包括LLVM版本的`objdump`，`nm`和`size`，用来查看二进制文件。
  在GNU
]))

#{
let cmd = `rustup component add llvm-tools`
tr((
  en: [
  The advantage of using these tools over GNU binutils is that (a)
  installing the LLVM tools is the same one-command installation
  (#cmd) regardless of your OS and (b) tools
  like `objdump` support all the architectures that `rustc` supports --
  from ARM to x86_64 -- because they both share the same LLVM backend.
],
de: [
  Der Vorteil dieser Werkzeuge gegenüber den GNU-Binutils liegt darin,
  dass (a) die Installation der LLVM-Werkzeuge unabhängig vom
  Betriebssystem stets mit demselben einzelnen Befehl
  (#cmd) erfolgt und (b) Werkzeuge wie
  `objdump` alle von `rustc` unterstützten Architekturen abdecken -- von
  ARM bis x86_64 --, da sie auf demselben LLVM-Backend basieren.
],
ja: [
  GNU binutilsではなく、これらのツールを利用する利点は次の通りです。 (a)
  LLVMツールのインストールは、OSに関わらず、共通のコマンド1つ(cmd)で済みます。
  (b)
  `objdump`などのツールは、`rustc`がサポートする全てのアーキテクチャ(ARMからx86\_64まで)をサポートします。これは、同じLLVMバックエンドを共有しているためです。
],
zh: [
  binutils之上使用这些工具的好处是，(a)无论你的操作系统是什么，安装这些LLVM工具都可以用同一条命令(#cmd)。(b)像是`objdump`这样的工具，支持所有`rustc`支持的架构--从ARM到x86\_64--因为它们都有一样的LLVM后端。
]))
}

= `qemu-system-arm`

#tr((
en: [
  QEMU is an emulator. In this case we use the variant that can fully
  emulate ARM systems. We use QEMU to run embedded programs on the host.
  Thanks to this you can follow some parts of this book even if you don't
  have any hardware with you!
],
de: [
  QEMU ist ein Emulator. In diesem Fall verwenden wir die Variante, die
  ARM-Systeme vollständig emulieren kann. Wir nutzen QEMU, um
  Embedded-Programme auf dem Host-System auszuführen. Auf diese Weise
  können Sie einige Teile dieses Buches auch dann nachvollziehen, wenn Sie
  keine Hardware zur Hand haben!
],
ja: [
  QEMUはエミュレータです。今回は、ARMシステムを完全にエミュレートできるものを使います。
  私たちは、ホスト上で組込みプログラムを実行するためにQEMUを利用します。
  このおかげで、ハードウェアを持っていなくても、この本のいくつかの部分を試すことができます。
],
zh: [
  QEMU是一个仿真器。在这个例子里，我们使用能完全仿真ARM系统的改良版QEMU。我们使用QEMU在主机上运行嵌入式程序。多亏了它，你可以在没有任何硬件的情况下，尝试这本书的部分示例。
]))

#h1((en: [Tooling for Embedded Rust Debugging],
  de: [Werkzeuge für das Debugging von Embedded Rust],
  zh: [用于调试嵌入式Rust的工具],
), offset: whole)

= #tr((
  en: [Overview],
  de: [Überblick],
  zh: [概述],
))

#tr((
en: [
  Debugging embedded systems in Rust requires specialized tools including
  software to manage the debugging process, debuggers to inspect and
  control program execution, and hardware probes to facilitate interaction
  between the host and the embedded device. This document outlines
  essential software tools like Probe-rs and OpenOCD, which simplify and
  support the debugging process, alongside prominent debuggers such as GDB
  and the Probe-rs Visual Studio Code extension. Additionally, it covers
  key hardware probes such as Rusty-probe, ST-Link, J-Link, and MCU-Link,
  which are integral for effective debugging and programming of embedded devices.
],
de: [
  Das Debugging eingebetteter Systeme in Rust erfordert spezialisierte
  Werkzeuge, darunter Software zur Steuerung des Debugging-Prozesses,
  Debugger zur Überwachung und Kontrolle der Programmausführung sowie
  Hardware-Probes, die die Interaktion zwischen dem Host-System und dem
  eingebetteten Gerät ermöglichen. Dieses Dokument stellt wesentliche
  Software-Werkzeuge wie Probe-rs und OpenOCD vor, die den
  Debugging-Prozess vereinfachen und unterstützen, sowie bekannte Debugger
  wie GDB und die Probe-rs-Erweiterung für Visual Studio Code. Zudem
  werden wichtige Hardware-Probes wie Rusty-probe, ST-Link, J-Link und
  MCU-Link behandelt, die für das effiziente Debugging und Programmieren
  eingebetteter Geräte unerlässlich sind.
],
zh: [
  在Rust中调试嵌入式系统需要用到专业的工具，这包括用于管理调试进程的软件，用于观察和控制程序执行的调试器，和用于便捷主机和嵌入式设备之间进行交互的硬件探测器．这个文档会介绍像是Probe-rs和OpenOCD这样的基础软件，以及像是GDB和Probe-rs
  Visual Studio
  Code扩展这样常见的调试器．另外，该文档会覆盖像是Rusty-probe，ST-Link，J-Link，和MCU-Link这样的硬件探测器，它们整合在一起可以高效地对嵌入式设备进行调试和编程．
]))

= #tr((
  en: [Software that drives debugging tools],
  de: [Software, die Debugging-Werkzeuge steuert],
  zh: [驱动调试工具的软件],
))

== Probe-rs

#tr((
en: [
  Probe-rs is a modern, Rust-focused software designed to work with
  debuggers in embedded systems. Unlike OpenOCD, Probe-rs is built with
  simplicity in mind and aims to reduce the configuration burden often
  found in other debugging solutions. It supports various probes and
  targets, providing a high-level interface for interacting with embedded
  hardware. Probe-rs integrates directly with Rust tooling, and integrates
  with Visual Studio Code through its extension, allowing developers to
  streamline their debugging workflow.
],
de: [
  Probe-rs ist eine moderne, auf Rust ausgerichtete Software für das
  Debugging in Embedded-Systemen. Im Gegensatz zu OpenOCD wurde Probe-rs
  mit dem Fokus auf Einfachheit entwickelt und zielt darauf ab, den bei
  anderen Debugging-Lösungen oft hohen Konfigurationsaufwand zu
  reduzieren. Es unterstützt diverse Debug-Probes sowie Zielsysteme und
  bietet eine komfortable Schnittstelle für die Interaktion mit
  Embedded-Hardware. Probe-rs lässt sich direkt in die Rust-Toolchain
  sowie -- dank einer entsprechenden Erweiterung -- in Visual Studio Code
  integrieren, wodurch Entwickler ihren Debugging-Workflow optimieren können.
],
zh: [
  Probe-rs是一个现代化的，以Rust开发的软件，被设计用来配合嵌入式系统中的调试器一起工作．不像OpenOCD，Probe-rs设计的时候就考虑到了简单性，目标是减少在其它调试解决方案中常见的配置重担．
  它支持不同的探测器和目标架构，提供一个用于与嵌入式硬件交互的高层接口．Probe-rs直接集成了Rust工具链，并且通过扩展集成进了Visual
  Studio Code中，允许开发者精简它们的调试工作流程．
]))

== OpenOCD (Open On-Chip Debugger)

#tr((
en: [
  OpenOCD is an open-source software tool used for debugging, testing, and
  programming embedded systems. It provides an interface between the host
  system and embedded hardware, supporting various transport layers like
  JTAG and SWD (Serial Wire Debug). OpenOCD integrates with GDB, which is
  a debugger. OpenOCD is widely supported, with extensive documentation
  and a large community, but may require complex configuration, especially
  for custom embedded setups.
],
de: [
  OpenOCD ist ein Open-Source-Softwaretool für das Debugging, Testen und
  Programmieren eingebetteter Systeme. Es stellt eine Schnittstelle
  zwischen dem Host-System und der eingebetteten Hardware bereit und
  unterstützt verschiedene Übertragungsprotokolle wie JTAG und SWD (Serial
  Wire Debug). OpenOCD lässt sich in GDB, einen Debugger, integrieren. Das
  Werkzeug ist weit verbreitet, verfügt über eine umfangreiche
  Dokumentation sowie eine große Community, kann jedoch -- insbesondere
  bei kundenspezifischen Embedded-Konfigurationen -- eine komplexe
  Einrichtung erfordern.
],
zh: [
  OpenOCD是一个用于调试，测试，和编程嵌入式系统的开源软件工具．它提供了一个主机系统和嵌入式硬件之间的接口，支持不同的传输层，比如JTAG和SWD（Serial
  Wire
  Debug）．OpenOCD集成了GDB，其是一个调试器．OpenOCD受到了广泛的支持，拥有大量的文档和一个庞大的社区，但是配置可能会很复杂，特别是对于自定义的嵌入式设置．
]))

= #tr((
  en: [Debuggers],
  de: [Debugger],
  zh: [Debuggers],
))

#tr((
en: [
  A debugger allows developers to inspect and control the execution of a
  program in order to identify and correct errors or bugs. It provides
  functionalities such as setting breakpoints, stepping through code line
  by line, and examining the values of variables and memory states.
  Debuggers are essential for thorough software development and
  maintenance, enabling developers to ensure that their code behaves as
  intended under various conditions.
],
de: [
  Ein Debugger ermöglicht es Entwicklern, die Ausführung eines Programms
  zu untersuchen und zu steuern, um Fehler oder Bugs zu identifizieren und
  zu beheben. Er bietet Funktionen wie das Setzen von Haltepunkten
  (Breakpoints), das schrittweise Durchlaufen des Codes sowie die
  Überprüfung von Variablenwerten und Speicherzuständen. Debugger sind für
  eine gründliche Softwareentwicklung und -wartung unerlässlich, da sie
  Entwicklern helfen sicherzustellen, dass sich ihr Code unter
  verschiedenen Bedingungen wie vorgesehen verhält.
],
zh: [
  调试器允许开发者观察和控制一个程序的执行，以辨别和纠正错误或者bugs．它提供像是设置断点，一行一行地步进代码，和研究变量的值以及内存的状态等功能．调试器本质上是为了通过软件开发和维护，使得开发者可以确保他们的代码的行为在不同环境下就像他们预期的那样运行．
]))

#tr((
en: [
  Debuggers know how to:
  - Interact with the memory mapped registers. 
  - Set Breakpoints/Watchpoints.
  - Read and write to the memory mapped registers.
  - Detect when the MCU has been halted for a debug event.
  - Continue MCU execution after a debug event has been encountered.
  - Erase and write to the microcontroller's FLASH.
],
de: [
  Debugger bieten folgende Möglichkeiten:
  - Auf die im Speicher abgebildeten Register zugreifen.
  - Haltepunkte/Überwachungspunkte setzen.
  - In/aus im Speicher abgebildeten Registern lesen und schreiben.
  - Erkennen, wenn die MCU aufgrund eines Debug-Ereignisses angehalten wurde.
  - Die MCU-Ausführung nach dem Auftreten eines Debug-Ereignisses fortsetzen.
  - Den Flash-Speicher des Mikrocontrollers löschen und beschreiben.
],
zh: [
  调试器可以知道如何：
  - 与映射到存储上的寄存器交互．
  - 设置断点．
  - 读取和写入映射到存储上的寄存器．
  - 检测什么时候MCU因为一个调试时间被挂了起来．
  - 在遇到一个调试事件后继续MCU的执行．
  - 擦出和写入微控制器的FLASH．
]))

== Probe-rs Visual Studio Code Extension

#tr((
en: [
  Probe-rs has a Visual Studio Code extension, providing a seamless
  debugging experience without extensive setup. Through this connection,
  developers can use Rust-specific features like pretty printing and
  detailed error messages, ensuring that their debugging process aligns
  with the Rust ecosystem.
],
de: [
  Probe-rs bietet eine Visual Studio Code-Erweiterung, die ein nahtloses
  Debugging-Erlebnis ohne aufwendige Einrichtung ermöglicht. Dank dieser
  Integration können Entwickler Rust-spezifische Funktionen wie
  Pretty-Printing und detaillierte Fehlermeldungen nutzen und so
  sicherstellen, dass ihr Debugging-Prozess optimal auf das Rust-Ökosystem
  abgestimmt ist.
],
zh: [
  Probe-rs有一个Visual Studio
  Code的扩展，提供了不需要额外设置的无缝的调试体验．通过它的帮助，开发者可以使用Rust特定的特性，像是漂亮的打印和详细的错误信息，确保它们的调试过程可以与Rust的生态对齐．
]))

== TRACE32

#tr((
en: [
  TRACE32 is a professional debugging and tracing solution developed by
  Lauterbach for embedded systems. It supports a wide range of processor
  architectures, including ARM and RISC-V, and connects to target hardware
  via JTAG, SWD, and various trace interfaces. TRACE32 provides advanced
  debugging capabilities such as multicore debugging, complex breakpoints,
  and real-time trace analysis. It works with standard ELF/DWARF debug
  information, making it compatible with Rust binaries built using
  conventional toolchains.
],
de: [
  TRACE32 ist eine von Lauterbach für Embedded-Systeme entwickelte
  professionelle Debugging- und Tracing-Lösung. Sie unterstützt eine
  Vielzahl von Prozessorarchitekturen, darunter ARM und RISC-V, und stellt
  die Verbindung zur Zielhardware über JTAG, SWD sowie diverse
  Trace-Schnittstellen her. TRACE32 bietet leistungsstarke
  Debugging-Funktionen wie Multicore-Debugging, komplexe Breakpoints und
  Echtzeit-Trace-Analyse. Da das System auf
  Standard-ELF/DWARF-Debuginformationen basiert, ist es mit
  Rust-Binärdateien kompatibel, die mit herkömmlichen Werkzeugen erstellt wurden.
]))

== GDB (GNU Debugger)

#tr((
en: [
  GDB is a versatile debugging tool that allows developers to examine the
  state of programs while they run or after they crash. For embedded Rust,
  GDB connects to the target system via OpenOCD or other debugging servers
  to interact with the embedded code. GDB is highly configurable and
  supports features like remote debugging, variable inspection, and
  conditional breakpoints. It can be used on a variety of platforms, and
  has extensive support for Rust-specific debugging needs, such as pretty
  printing and integration with IDEs.
],
de: [
  GDB ist ein vielseitiges Debugging-Werkzeug, das es Entwicklern
  ermöglicht, den Zustand von Programmen während der Laufzeit oder nach
  einem Absturz zu untersuchen. Im Bereich Embedded Rust verbindet sich
  GDB über OpenOCD oder andere Debugging-Server mit dem Zielsystem, um mit
  dem Embedded-Code zu interagieren. GDB ist hochgradig konfigurierbar und
  unterstützt Funktionen wie Remote-Debugging, Variableninspektion und
  bedingte Haltepunkte. Es ist auf einer Vielzahl von Plattformen
  einsetzbar und bietet umfassende Unterstützung für Rust-spezifische
  Debugging-Anforderungen, wie etwa Pretty-Printing und die Integration in IDEs.
],
zh: [
  GDB是一个多用途的调试工具，其允许开发者研究程序的状态，无论其正在运行中还是程序崩溃后．对于嵌入式Rust，GDB通过OpenOCD或者其它的调试服务器链接到目标系统上去和嵌入式代码交互．GDB是高度可配置的，并且支持像是远程调试，变量检测，和条件断点．它可以被用于多个平台，并对Rust特定的调试需求有广泛的支持，比如好看的打印和与IDEs集成．
]))

= #tr((
  en: [Probes],
  de: [Probes],
  zh: [探测器],
))

#tr((
en: [
  A hardware probe is a device used in the development and debugging of
  embedded systems to facilitate communication between a host computer and
  the target embedded device. It typically supports protocols like JTAG or
  SWD, enabling it to program, debug, and analyze the microcontroller or
  microprocessor on the embedded system. Hardware probes are crucial for
  developers to set breakpoints, step through code, and inspect memory and
  processor registers, effectively allowing them to diagnose and fix
  issues in real-time.
],
de: [
  Eine Hardware-Sonde ist ein Gerät, das bei der Entwicklung und dem
  Debugging eingebetteter Systeme eingesetzt wird, um die Kommunikation
  zwischen einem Host-Computer und dem eingebetteten Zielsystem zu
  ermöglichen. Sie unterstützt typischerweise Protokolle wie JTAG oder SWD
  und ermöglicht so das Programmieren, Debuggen und Analysieren des
  Mikrocontrollers oder Mikroprozessors auf dem eingebetteten System.
  Hardware-Sonden sind für Entwickler unverzichtbar, um Haltepunkte
  (Breakpoints) zu setzen, den Code schrittweise auszuführen sowie
  Speicher und Prozessorregister zu untersuchen; dies erlaubt es ihnen,
  Probleme effizient in Echtzeit zu diagnostizieren und zu beheben.
],
zh: [
  硬件探头是一个被用于嵌入式系统的开发和调试的设备，其可以使得主机和目标嵌入式设备间的通信变得简单．它通常支持像是JTAG或者SWD这样的协议，可以编程，调试和分析嵌入式系统上的微控制器或者微处理器．硬件探头对于要设置断点，步进代码，和观察内存与处理器的寄存器的开发者来说很重要，可以让开发者们高效地实时地分析和修复问题．
]))

== Rusty-probe

#tr((
en: [
  Rusty-probe is an open-sourced USB-based hardware debugging probe
  designed to work with probe-rs. The combination of Rusty-Probe and
  probe-rs provides an easy-to-use, cost-effective solution for developers
  working with embedded Rust applications.
],
de: [
  Rusty-probe ist ein Open-Source-Hardware-Debugging-Interface auf
  USB-Basis, das für den Einsatz mit probe-rs entwickelt wurde. Die
  Kombination aus Rusty-Probe und probe-rs bietet Entwicklern, die mit
  Embedded-Rust-Anwendungen arbeiten, eine benutzerfreundliche und
  kostengünstige Lösung.
],
zh: [
  Rusty-probe是一个开源的基于USB的硬件调试探测器，被设计用来辅助probe-rs一起工作．Rusy-Probe和probe-rs的结合为嵌入式Rust应用的开发者提供了一个易用的，成本高效的解决方案．
]))

== ST-Link

#tr((
en: [
  The ST-Link is a popular debugging and programming probe developed by
  STMicroelectronics primarily for their STM32 and STM8 microcontroller
  series. It supports both debugging and programming via JTAG or SWD
  (Serial Wire Debug) interfaces. ST-Link is widely used due to its direct
  support from STMicroelectronics' extensive range of development boards
  and its integration into major IDEs, making it a convenient choice for
  developers working with STM microcontrollers.
],
de: [
  Der ST-Link ist ein weit verbreiteter Debugging- und Programmieradapter,
  der von STMicroelectronics primär für die Mikrocontroller-Serien STM32
  und STM8 entwickelt wurde. Er unterstützt sowohl das Debugging als auch
  die Programmierung über JTAG- oder SWD-Schnittstellen (Serial Wire
  Debug). Dank der direkten Unterstützung durch das umfangreiche Angebot
  an Entwicklungsboards von STMicroelectronics sowie der Integration in
  gängige Entwicklungsumgebungen (IDEs) ist der ST-Link weit verbreitet
  und stellt eine komfortable Wahl für Entwickler dar, die mit
  STM-Mikrocontrollern arbeiten.
],
zh: [
  ST-Link是一个由STMicroelectronics开发的常见的调试和编程探测器，其主要用于它们的STM32和STM8微控制器系列．它支持通过JTAG或者SWD接口进行调试和编程．因为STMicroelectronics的大量的开发板对其直接支持并且它集成进了主流的IDEs中，所以使得它成为使用STM微控制器的开发者的首选．
]))

== J-Link

#tr((
en: [
  J-Link, developed by SEGGER Microcontroller, is a robust and versatile
  debugger supporting a wide range of CPU cores and devices beyond just
  ARM, such as RISC-V. Known for its high performance and reliability,
  J-Link supports various communication interfaces, including JTAG, SWD,
  and fine-pitch JTAG interfaces. It is favored for its advanced features
  like unlimited breakpoints in flash memory and its compatibility with a
  multitude of development environments.
],
de: [
  J-Link, entwickelt von SEGGER Microcontroller, ist ein robuster und
  vielseitiger Debugger, der neben ARM auch eine breite Palette weiterer
  CPU-Kerne und Bausteine -- wie etwa RISC-V -- unterstützt. J-Link ist
  für seine hohe Leistungsfähigkeit und Zuverlässigkeit bekannt und
  unterstützt diverse Kommunikationsschnittstellen, darunter JTAG, SWD
  sowie Fine-Pitch-JTAG-Schnittstellen. Geschätzt wird das System zudem
  für seine erweiterten Funktionen, wie etwa unbegrenzte Breakpoints im
  Flash-Speicher, sowie für seine Kompatibilität mit einer Vielzahl von
  Entwicklungsumgebungen.
],
zh: [
  J-Link是由SEGGER微控制器开发的，它是一个鲁棒和功能丰富的调试器，其支持大量的CPU内核和设备，不仅仅是ARM，比如RISC-V．因其高性能和可读性而闻名，J-Link支持不同的通信接口，包括JTAG，SWD，和fine-pitch
  JTAG接口．它因其高级的特性而受到欢迎，比如在flash存储中的无限的断点和它与多种开发环境的兼容性．
]))

== MCU-Link

#tr((
en: [
  MCU-Link is a debugging probe that also functions as a programmer,
  provided by NXP Semiconductors. It supports a variety of ARM Cortex
  microcontrollers and interfaces seamlessly with development tools like
  MCUXpresso IDE. MCU-Link is particularly notable for its versatility and
  affordability, making it an accessible option for hobbyists, educators,
  and professional developers alike.
],
de: [
  MCU-Link ist ein von NXP Semiconductors bereitgestellter
  Debugging-Adapter, der auch als Programmiergerät fungiert. Er
  unterstützt eine Vielzahl von ARM-Cortex-Mikrocontrollern und lässt sich
  nahtlos in Entwicklungsumgebungen wie die MCUXpresso IDE integrieren.
  MCU-Link zeichnet sich besonders durch seine Vielseitigkeit und
  Kosteneffizienz aus und ist damit eine attraktive Lösung für
  Hobbyanwender, Lehrkräfte und professionelle Entwickler gleichermaßen.
],
zh: [
  MCU-Link是一个调试探测器，也可以作为编程器使用，由NXP
  Semiconductors提供．它支持不同的ARM Cortex微控制器且可以与像是MCUXpresso
  IDE这样的开发工具进行无缝地交互．MCU-Link因其丰富的功能和易使用而闻名，使它成为像是爱好者，教育者，和专业的开发者们的可行的选项．
]))
