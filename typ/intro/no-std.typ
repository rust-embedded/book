#import "../config.typ": *

#h1((en: [A `no_std` Rust Environment],
  de: [Eine `no_std`-Rust-Umgebung],
  ja: [Rustの`no_std`環境],
  zh: [一个 `no_std` Rust环境],
), offset: whole)

#let ln_st72325 = link("https://www.st.com/resource/en/datasheet/st72325j6.pdf")[ST72325xx]
#let ln_rpi = link("https://en.wikipedia.org/wiki/Raspberry_Pi#Specifications")[Modell B 3+]
#tr((
en: [
  The term Embedded Programming is used for a wide range of different
  classes of programming. Ranging from programming 8-Bit MCUs (like the
  #ln_st72325 with just a few KB of RAM and ROM,
  up to systems like the Raspberry Pi (#ln_rpi)
  which has a 32/64-bit 4-core Cortex-A53 \@ 1.4 GHz and 1GB of RAM.
  Different restrictions/limitations will apply when writing code
  depending on what kind of target and use case you have.
],
de: [
  Der Begriff „Embedded Programming" (Programmierung eingebetteter
  Systeme) umfasst ein breites Spektrum unterschiedlichster
  Programmierbereiche. Das Spektrum reicht von der Programmierung von
  8-Bit-Mikrocontrollern (wie dem
  #ln_st72325 mit nur wenigen Kilobyte RAM und ROM
  bis hin zu Systemen wie dem Raspberry Pi (#ln_rpi),
  der über einen 32/64-Bit-Quad-Core-Prozessor (Cortex-A53 mit 1,4 GHz)
  und 1 GB RAM verfügt. Je nach Zielsystem und Anwendungsfall gelten bei
  der Programmierung unterschiedliche Einschränkungen und
  Rahmenbedingungen.
],
ja: [
  組込みプログラミングという用語は、様々な分野のプログラミングに使用されます。
  たった数キロバイトのRAMかROMが付随する8ビットMCU
  (例えば、#ln_st72325)から、32/64ビットの4コア
  Cortex-A53 \@ 1.4GHzと1GBのRAMが搭載されたRaspberry
  Pi(#ln_rpi)のようなシステムまで、幅広いです。
  どのような種類の目的とユースケースがあるか、によって、コードを書くときに異なる制限/限界が課されます。
],
zh: [
  嵌入式编程这个词被广泛用于许多不同的编程场景中。小到RAM和ROM只有KB的8位机(像是#ln_st72325)，大到一个具有32/64位4核Cortex-A53和1GB
  RAM的系统，比如树莓派(#ln_rpi)。当编写代码时，取决于你的目标环境和用例，将会有不同的限制和局限。
]))

#tr((
en: [
  There are two general Embedded Programming classifications:
],
de: [
  Es gibt zwei grundlegende Kategorien der Programmierung eingebetteter Systeme:
],
ja: [
  2つの一般的な組込みプログラミングの分類があります。
],
zh: [
  通常嵌入式编程有两类:
]))

= #tr((
  en: [Hosted Environments],
  de: [Hosted Environments],
  ja: [ホストされた環境],
  zh: [主机环境下],
))

#let ln_posix = "https://en.wikipedia.org/wiki/POSIX"
#tr((
en: [
  These kinds of environments are close to a normal PC environment. What
  this means is that you are provided with a System Interface
  #link(ln_posix)[E.G. POSIX] that provides
  you with primitives to interact with various systems, such as file
  systems, networking, memory management, threads, etc. Standard libraries
  in turn usually depend on these primitives to implement their
  functionality. You may also have some sort of sysroot and restrictions
  on RAM/ROM-usage, and perhaps some special HW or I/Os. Overall it feels
  like coding on a special-purpose PC environment.
],
de: [
  Derartige Umgebungen ähneln einer herkömmlichen PC-Umgebung. Das
  bedeutet, dass Ihnen eine Systemschnittstelle (z. B.
  #link(ln_posix)[POSIX]) zur Verfügung
  steht, die Grundfunktionen (Primitive) für die Interaktion mit
  verschiedenen Systemkomponenten bietet -- etwa Dateisystemen,
  Netzwerkfunktionen, Speicherverwaltung, Threads usw.
  Standardbibliotheken wiederum basieren in der Regel auf diesen
  Grundfunktionen, um ihre Funktionalität zu implementieren. Zudem können
  eine spezifische System-Root-Umgebung (sysroot) sowie Einschränkungen
  bei der RAM- oder ROM-Nutzung vorliegen; auch spezielle Hardware oder
  Ein-/Ausgabeschnittstellen (I/Os) können vorhanden sein. Insgesamt
  vermittelt die Programmierung den Eindruck, in einer auf einen
  speziellen Einsatzzweck ausgerichteten PC-Umgebung zu arbeiten.
],
ja: [
  この分類の環境は、普通のPCの環境に近いです。
  これの意味するところは、#link("https://en.wikipedia.org/wiki/POSIX")[POSIX]のようなシステムインタフェースが提供されている、ということです。システムインタフェースは、ファイルシステムやネットワーク、メモリ管理、スレッドといった多様なシステムとやりとりするための基本要素を提供します。
  通常、標準ライブラリは、その機能を実装するために、これらの基本要素に依存します。
  また、sysrootや、RAM/ROM利用の制限、そしておそらく特別なハードウェアやIOがあるかもしれません。
  全体としては、特殊な用途のPC環境でコーディングをするようなものです。
],
zh: [
  这类环境与一个常见的PC环境类似。意味着向你提供了一个系统接口#link(ln_posix)[比如 POSIX]，使你能和不同的系统进行交互，比如文件系统，网络，内存管理，进程，等等。标准库相应地依赖这些接口去实现了它们的功能。可能有某种sysroot并限制了对RAM/ROM的使用，可能还有一些特别的硬件或者I/O。总之感觉像是在专用的PC环境上编程一样。
]))

= #tr((
  en: [Bare Metal Environments],
  de: [Rein physische Umgebung],
  ja: [ベアメタル環境],
  zh: [裸机环境下],
))

#let ln_core = link("https://doc.rust-lang.org/core/")[libcore]
#tr((
en: [
  In a bare metal environment no code has been loaded before your program.
  Without the software provided by an OS we can not load the standard
  library. Instead the program, along with the crates it uses, can only
  use the hardware (bare metal) to run. To prevent rust from loading the
  standard library use `no_std`. The platform-agnostic parts of the
  standard library are available through #ln_core. libcore also excludes
  things which are not always desirable in an embedded environment. One of
  these things is a memory allocator for dynamic memory allocation. If you
  require this or any other functionalities there are often crates which
  provide these.
],
de: [
  In einer rein physischen Umgebung wird vor Ihrem Programm kein Code
  geladen. Ohne die vom Betriebssystem bereitgestellte Software kann die
  Standardbibliothek nicht geladen werden. Stattdessen kann das Programm
  zusammen mit den verwendeten Crates ausschließlich die Hardware (Bare
  Metal) nutzen. Um zu verhindern, dass Rust die Standardbibliothek lädt,
  verwenden Sie `no_std`. Die plattformunabhängigen Teile der
  Standardbibliothek sind über #ln_core verfügbar. libcore
  schließt außerdem Funktionen aus, die in eingebetteten Umgebungen nicht
  immer erwünscht sind. Eine dieser Funktionen ist ein Speicherallokator
  für die dynamische Speicherverwaltung. Falls Sie diese oder andere
  Funktionalitäten benötigen, stehen Ihnen häufig entsprechende Crates zur Verfügung.
],
ja: [
  #todoupd("ja")
  ベアメタル環境では、高機能なOSが動作していて、私たちのコードをホスティングしてくれる、ということはありません。
  これは、基本要素がないことを意味しており、それ故に、デフォルトでは標準ライブラリもありません。
  コードに`no_std`のマーキングをすることで、そのコードが、ベアメタル環境で実行できることを示します。
  no_stdなコードからは、Rustの#link("https://doc.rust-lang.org/std/")[libstd]とメモリの動的確保が使えません。
  しかしながら、no_stdなコードでも#ln_core;を使うことができます。libcoreは、ほんの数種類のシンボルを提供することで、いかなる環境でも容易に利用することができます
  (詳細は、#ln_core;を参照して下さい)。
],
zh: [
  在一个裸机环境中，程序被加载前，环境中不存在代码。没有系统提供的软件，我们不能加载标准库。相反地，程序和它使用的crates只能使用硬件(裸机)去运行。使用`no-std`可以防止rust读取标准库。标准库中与平台无关的部分在#link("https://doc.rust-lang.org/core/")[libcore]中。libcore剔除了那些在一个嵌入式环境中非必要的东西。比如用于动态分配的内存分配器。如果你需要这些或者其它的某些功能，通常会有提供这些功能的crates。
]))

== #tr((
  en: [The libstd Runtime],
  de: [Die libstd-Laufzeitumgebung],
  ja: [libstdランタイム],
  zh: [libstd运行时],
))

#let ln_std = link("https://doc.rust-lang.org/std/")[libstd]
#tr((
en: [
  As mentioned before using
  #ln_std requires some sort of
  system integration, but this is not only because
  #ln_std is just providing a
  common way of accessing OS abstractions, it also provides a runtime.
  This runtime, among other things, takes care of setting up stack
  overflow protection, processing command line arguments, and spawning the
  main thread before a program's main function is invoked. This runtime
  also won't be available in a `no_std` environment.
],
de: [
  Wie bereits erwähnt, erfordert die Verwendung von
  #ln_std eine gewisse
  Systemintegration; dies liegt jedoch nicht nur daran, dass
  #ln_std eine einheitliche
  Schnittstelle zu Betriebssystem-Abstraktionen bereitstellt, sondern auch
  daran, dass es eine Laufzeitumgebung (Runtime) mitliefert. Diese
  Laufzeitumgebung kümmert sich unter anderem um die Einrichtung eines
  Stack-Overflow-Schutzes, die Verarbeitung von Kommandozeilenargumenten
  sowie das Starten des Haupt-Threads, bevor die `main`-Funktion des
  Programms aufgerufen wird. In einer `no_std`-Umgebung steht diese
  Laufzeitumgebung nicht zur Verfügung.
],
ja: [
  上述の通り、#ln_std;の利用には、いくらかのシステムインテグレーションが必要です。しかし、これは#ln_std;がOSの抽象にアクセスするための共通の方法を提供しているだけでなく、ランタイムも提供しているためです。
  ランタイムは、とりわけ、スタックオーバーフロープロテクションの準備、コマンドライン引数の処理、メインスレッドの生成、をプログラムのメイン関数が呼び出される前に処理します。
  このランタイムも、`no_std`環境では利用できません。
],
zh: [
  就像之前提到的，使用#ln_std;需要一些系统集成，这不仅仅是因为#ln_std;使用了一个公共的方法访问操作系统，它也提供了一个运行时环境。这个运行时环境，负责设置堆栈溢出保护，处理命令行参数，并在一个程序的主函数被激活前启动一个主线程。在一个`no_std`环境中，这个运行时环境也是不可用的。
]))

= #tr((
  en: [Summary],
  de: [Zusammenfassung],
  ja: [まとめ],
  zh: [总结],
))

#let ln_core = link("https://doc.rust-lang.org/core/")[libcore]
#tr((
en: [
  `#![no_std]` is a crate-level attribute that indicates that the crate
  will link to the core-crate instead of the std-crate. The
  #ln_core crate in turn is a
  platform-agnostic subset of the std crate which makes no assumptions
  about the system the program will run on. As such, it provides APIs for
  language primitives like floats, strings and slices, as well as APIs
  that expose processor features like atomic operations and SIMD
  instructions. However it lacks APIs for anything that involves platform
  integration. Because of these properties no_std and
  #ln_core code can be used for
  any kind of bootstrapping (stage 0) code like bootloaders, firmware or kernels.
],
de: [
  `#![no_std]` ist ein Attribut auf Crate-Ebene, das angibt, dass das
  Crate gegen das `core`-Crate anstatt gegen das `std`-Crate gelinkt wird.
  Das #ln_core;-Crate wiederum ist
  eine plattformunabhängige Teilmenge des `std`-Crates, die keinerlei
  Annahmen über das System trifft, auf dem das Programm ausgeführt wird.
  Dementsprechend stellt es APIs für Sprachprimitive wie Gleitkommazahlen,
  Strings und Slices bereit sowie APIs, die Prozessorfunktionen wie
  atomare Operationen und SIMD-Befehle zugänglich machen. Es fehlen jedoch
  APIs für Funktionen, die eine Plattformintegration erfordern. Aufgrund
  dieser Eigenschaften eignen sich `no_std`- und
  #ln_core;-Code für jegliche Art
  von Bootstrapping-Code (Stufe 0), wie etwa Bootloader, Firmware oder Kernel.
],
ja: [
  `#![no_std]`は、クレートレベルの属性で、そのクレートがstdクレートの代わりにcoreクレートとリンクすることを意味します。
  #ln_core;クレートは、プラットフォームに依存しないstdクレートのサブセットです。libcoreクレートは、プログラムが動作するシステムについて前提を置きません。
  libcoreクレートは、浮動小数点、文字列やスライスといった言語の基本要素となるAPIと、アトミック操作やSIMD命令といったプロセッサの機能を公開するAPIとを、提供します。一方、プラットフォームインテグレーションを伴うようなAPIは欠如しています。
  これらの特性のため、no\_stdと#ln_core;のコードは、ブートローダー、ファームウェア、カーネルといったあらゆるブートストラップ
  (ステージ0)のコードにも利用できます。
],
zh: [
  `#![no_std]`是一个crate层级的属性，它说明crate将连接至core-crate而不是std-crate。#ln_core crate是std
  crate的一个的子集，其与平台无关，它对程序将要运行的系统没有做要求。比如，它提供了像是floats，strings和切片的APIs，暴露了像是与原子操作和SIMD指令相关的处理器功能的APIs。然而，它缺少涉及到平台集成的那些APIs。由于这些特性，no_std和#ln_core;代码可以用于任何引导程序(stage
  0)像是bootloaders，固件或者内核。
]))

== #tr((
  en: [Overview],
  de: [Überblick],
  ja: [概略],
  zh: [概述],
))

#figure(
  kind: table,
  table(
    columns: (1fr, 11.11%, 6.94%),
    align: center,
    table.header(
      tr((
        en: [feature],
        de: [Eigenschaft],
        ja: [機能],
        zh: [特性],
      )),
      [no_std],
      [std],
    ),
    tr((
      en: [heap (dynamic memory)],
      de: [heap (dynamischer Speicher)],
      ja: [ヒープ (動的メモリ)],
      zh: [堆 (dynamic memory)],
    )),
    [\*], [✓],
    tr((
      en: [collections (Vec, BTreeMap, etc)],
      de: [collections (Vec, BTreeMap, usw.)],
      ja: [コレクション (Vec, HashMap, など)],
      zh: [容器 (Vec, BTreeMap, etc)],
    )),
    [\*\*], [✓],
    tr((
      en: [stack overflow protection],
      de: [Schutz vor Stack-Überlauf],
      ja: [スタックオーバーフロープロテクション],
      zh: [栈溢出保护],
    )),
    [✘], [✓],
    tr((
      en: [runs init code before main],
      de: [führt Initialisierungscode vor der main-Funktion aus],
      ja: [main関数前の初期化コード実行],
      zh: [在进入main之前运行的初始化代码],
    )),
    [✘], [✓],
    tr((
      en: [libstd available],
      de: [libstd verfügbar],
      ja: [libstdの利用],
      zh: [libstd available],
    )),
    [✘], [✓],
    tr((
      en: [libcore available],
      de: [libcore verfügbar],
      ja: [libcoreの利用],
      zh: [libcore available],
    )),
    [✓], [✓],
    tr((
      en: [writing firmware, kernel, or bootloader code],
      de: [schreibt firmware, kernel, oder bootloader code],
      ja: [ファームウェア、カーネル、ブートローダーのコードを書く],
      zh: [编写固件，内核，或者引导程序],
    )),
    [✓], [✘],
  )
)

#let ln_cortex = link("https://github.com/rust-embedded/alloc-cortex-m")[alloc-cortex-m]
#tr((
en: [
  \* Only if you use the `alloc` crate and use a suitable allocator like #ln_cortex.
],
de: [
  \* Nur wenn Sie das `alloc`-Crate und einen geeigneten Allocator wie #ln_cortex verwenden.
],
ja: [
  \* `alloc`クレートを使い、\[alloc-cortex-m\]のような適切なアロケータを使った場合のみ
],
zh: [
  \* 只有在你使用了 `alloc` crate
  并设置了一个适合的分配器后，比如#ln_cortex;后可用．
]))

#tr((
en: [
  \*\* Only if you use the `collections` crate and configure a global default allocator.
],
de: [
  \*\* Nur wenn Sie das `collections`-Crate verwenden und einen globalen Standard-Allocator konfigurieren.
],
ja: [
  \*\* `collections`クレートを使い、グローバルなデフォルトアロケータを設定した場合のみ
],
zh: [
  \*\* 只有在你使用了 `collections` crate
  并配置了一个全局默认的分配器后可用．
]))

#tr((
en: [
  \*\* HashMap and HashSet are not available due to a lack of a secure random number generator.
],
de: [
  \*\* HashMap und HashSet stehen aufgrund des Fehlens eines sicheren
  Zufallszahlengenerators nicht zur Verfügung.
],
zh: [
  \*\* 由于缺少安全的随机数产生器，所以无法使用HashMap和HashSet．
]))

= #tr((
  en: [See Also],
  de: [Siehe auch],
  ja: [参照],
  zh: [参见],
))

- #link("https://github.com/rust-lang/rfcs/blob/master/text/1184-stabilize-no_std.html")[RFC-1184]
