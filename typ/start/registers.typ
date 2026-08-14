#import "../config.typ": *

#h1((en: [Memory Mapped Registers],
  de: [Im Speicher abgebildete Register],
  ja: [メモリマップドレジスタ],
  zh: [存储映射的寄存器(Memory-Mapped Registers)],
), offset: whole, )
<memory-mapped-registers>

#tr((
en: [
  Embedded systems can only get so far by executing normal Rust code and
  moving data around in RAM. If we want to get any information into or out
  of our system (be that blinking an LED, detecting a button press or
  communicating with an off-chip peripheral on some sort of bus) we're
  going to have to dip into the world of Peripherals and their 'memory
  mapped registers'.
],
de: [
  Bei eingebetteten Systemen stößt man mit der reinen Ausführung von
  Standard-Rust-Code und dem Verschieben von Daten im Arbeitsspeicher
  (RAM) irgendwann an Grenzen. Wenn wir Informationen in das System
  einspeisen oder daraus ausgeben wollen -- sei es das Blinken einer LED,
  das Erkennen eines Tastendrucks oder die Kommunikation mit einer
  externen Peripheriekomponente über einen Bus --, müssen wir uns mit der
  Welt der Peripherieeinheiten und deren „im Speicher abgebildeten
  Registern" (memory-mapped registers) befassen.
],
ja: [
  組込みシステムでは、通常のRustコードを実行し、データをRAM内で移動させるだけではたいしたことはできません。
  LEDの点滅やボタンの押下検出、もしくは、バス上のオフチップペリフェラルとの通信など、
  システムが情報を入出力するには、ペリフェラルとその「メモリマップドレジスタ」の世界に足を踏み入れる必要があります。
],
zh: [
  嵌入式系统想要继续执行下去，只有通过执行常规的Rust代码并在RAM间移动数据才行。如果我们想要获取或者发出信息(点亮一个LED，发现一个按钮按下或者在总线上与芯片外设通信)，我们不得不深入了解外设和它们的"存储映射的寄存器"。
]))

#let ln_cortex = link("https://crates.io/crates/cortex-m")[cortex-m]
#let ln_tm4c123x = link("https://crates.io/crates/tm4c123x")[tm4c123x]
#let ln_f30x = link("https://crates.io/crates/stm32f30x")[stm32f30x]
#let ln_hal = link("https://crates.io/crates/embedded-hal")[embedded-hal]
#let ln_f3 = link("https://crates.io/crates/stm32f3-discovery")[stm32f3-discovery]
#tr((
en: [
  You may well find that the code you need to access the peripherals in
  your micro-controller has already been written, at one of the following
  levels:
  - Micro-architecture Crate - This sort of crate handles any useful
    routines common to the processor core your microcontroller is using,
    as well as any peripherals that are common to all micro-controllers
    that use that particular type of processor core. For example the
    #ln_cortex crate gives you
    functions to enable and disable interrupts, which are the same for all
    Cortex-M based micro-controllers. It also gives you access to the
    'SysTick' peripheral included with all Cortex-M based
    micro-controllers.
  - Peripheral Access Crate (PAC) - This sort of crate is a thin wrapper
    over the various memory-wrapper registers defined for your particular
    part-number of micro-controller you are using. For example,
    #ln_tm4c123x for the Texas Instruments Tiva-C TM4C123 series, or
    #ln_f30x for the ST-Micro STM32F30x series.
    Here, you'll be interacting with the
    registers directly, following each peripheral's operating instructions
    given in your micro-controller's Technical Reference Manual.
  - HAL Crate - These crates offer a more user-friendly API for your
    particular processor, often by implementing some common traits defined
    in #ln_hal. For
    example, this crate might offer a `Serial` struct, with a constructor
    that takes an appropriate set of GPIO pins and a baud rate, and offers
    some sort of `write_byte` function for sending data. See the chapter
    on #link(<portability>)[Portability] for more information
    on #ln_hal.
  - Board Crate - These crates go one step further than a HAL Crate by
    pre-configuring various peripherals and GPIO pins to suit the specific
    developer kit or board you are using, such as #ln_f3
    for the STM32F3DISCOVERY board.
],
ja: [
  マイクロコントローラのペリフェラルにアクセスするためのコードが、次のいずれかのレベルで、既に書かれています。
  - マイクロアーキテクチャクレート。この種のクレートは、マイクロコントローラに搭載されているプロセッサコアで共通となる便利なルーチンを扱っています。
    また、特定のプロセッサコアを使用する全てのマイクロコントローラに共通のペリフェラルも取り扱います。
    例えば、#ln_cortex;クレートは、割り込みの有効化と無効化を行う関数を提供しています。これは全てのCortex-Mベースマイクロコントローラで同じものです。
    #ln_cortex;クレートは、「SysTick」ペリフェラルへのアクセスも提供しています。このペリフェラルは、全てのCortex-Mベースマイクロコントローラに搭載されています。
  - ペリフェラルアクセスクレート（PAC）。この種のクレートは、薄いラッパーです。特定の型番のマイクロコントローラに対して定義されている、
    様々なメモリマップドレジスタのラッパーを提供します。例えば、テキサスインスツルメンツのTiva-C
    TM4C123シリーズ向けの#ln_tm4c123x;クレートや、
    STマイクロのSTM32F30xシリーズ向けの#ln_f30x;クレートです。マイクロコントローラのテクニカルリファレンスマニュアルに記載されている各ペリフェラルの操作手順に従って、
    レジスタと直接やり取りします。
  - HALクレート。これらのクレートは、特定のプロセッサに対して、よりユーザフレンドリなAPIを提供しています。#ln_hal;で定義されている共通のトレイトを使って実装されていることが多いです。
    例えば、このクレートは、`Serial`構造体を提供しているでしょう。そのコンストラクタは、適切なGPIOピンの一式とボーレートを引数に取ります。そして、データを送信するための`write_byte`関数一式を提供します。
    #ln_hal;に関する詳細は、#link(<portability>)[移植性]の章を参照して下さい。
  - ボードクレート。これらのクレートは、HALクレートのさらに一歩先を進んでいます。これらは、STM32F3DISCOVERYボード向けの#ln_f3;のように、
    特定の開発キットやボード向けに、様々なペリフェラルとGPIOピンを事前に設定してあります。
],
de: [
  Möglicherweise stellen Sie fest, dass der für den Zugriff auf die
  Peripherie Ihres Mikrocontrollers erforderliche Code bereits auf einer
  der folgenden Ebenen implementiert wurde:
  - Mikroarchitektur-Crate -- Diese Art von Crate verwaltet alle
    nützlichen Routinen, die dem Prozessorkern gemeinsam sind, den Ihr
    Mikrocontroller verwendet, sowie alle Peripheriegeräte, die allen
    Mikrocontrollern gemeinsam sind, die diesen bestimmten
    Prozessorkerntyp verwenden. Das #ln_cortex - Crate bietet
    Ihnen beispielsweise Funktionen zum Aktivieren und Deaktivieren von
    Interrupts, die für alle Cortex-M-basierten Mikrocontroller gleich
    sind. Außerdem erhalten Sie Zugriff auf die „SysTick"-Peripherie, die
    in allen Cortex-M-basierten Mikrocontrollern enthalten ist.
  - Peripheral Access Crate (PAC) -- Bei dieser Art von Crate handelt es
    sich um einen schlanken Adapter (Wrapper) für die verschiedenen
    Register, die für das spezifische Mikrocontroller-Modell definiert
    sind, das Sie verwenden. Zum Beispiel, #ln_tm4c123x für die
    Tiva-C-TM4C123-Serie von Texas Instruments oder #ln_f30x für die
    STM32F30x-Serie von STMicroelectronics. Hierbei greifen Sie direkt auf
    die Register zu und befolgen dabei die Betriebshinweise für die
    jeweilige Peripherieeinheit, wie sie im technischen Referenzhandbuch
    Ihres Mikrocontrollers beschrieben sind.
  - HAL-Crate -- Diese Crates bieten eine benutzerfreundlichere API für
    einen bestimmten Prozessor, häufig durch die Implementierung gängiger
    Traits, die in #ln_hal definiert
    sind. So könnte ein solches Crate beispielsweise eine
    `Serial`-Struktur bereitstellen, deren Konstruktor eine geeignete
    Kombination aus GPIO-Pins sowie eine Baudrate entgegennimmt und eine
    Funktion wie `write_byte` zum Senden von Daten anbietet. Weitere
    Informationen zu #ln_hal finden
    Sie im Kapitel über #link(<portability>)[Portabilität].
  - Board-Crate -- Diese Crates gehen noch einen Schritt weiter als
    HAL-Crates, indem sie verschiedene Peripheriekomponenten und GPIO-Pins
    passend für das jeweils verwendete Entwickler-Kit oder Board
    vorkonfigurieren -- wie zum Beispiel
    #ln_f3 für das STM32F3DISCOVERY-Board.
],
zh: [
  你可能会发现，访问你的微控制器外设所需要的代码，已经存在于下面的某个抽象层中了。
  - Micro-architecture Crate(微架构库) -
    这个库拥有任何对于微控制器的处理器内核来说经常会用到的程序，也包括在这些微控制器中的通用外设。比如
    #ln_cortex
    crate提供给你可以使能和关闭中断的函数，其对于所有的Cortex-M微控制器都是一样的。它也提供你访问'SysTick'外设的能力，在所有的Cortex-M微控制器中都包括了这个外设功能。
  - Peripheral Access Crate(PAC)(外设访问库) -
    这个库是对各种存储器封装的寄存器再进行的一次浅陋封装，特定于所使用的微控制器的产品号。比如，#ln_tm4c123x;针对TI的Tiva-C
    TM4C123系列，#ln_f30x;针对ST的STM32F30x系列。这块，根据微控制器的技术手册写的每个外设操作指令，直接和寄存器交互。
  - HAL Crate -
    这些crates为你的处理器提供了一个更友好的API，通常是通过实现在#ln_hal;中定义的一些常用的traits来实现的。比如，这个crate可能提供一个`Serial`结构体，它的构造函数需要一组合适的GPIO端口和一个波特率，它为发送数据提供了
    `write_byte` 函数。查看 #link(<portability>)[可移植性]
    可以看到更多关于
    #ln_hal 的信息。
  - Board Crate(开发板库) -
    这些Crate通过预配置不同的外设和GPIO管脚再进行了一层抽象以适配你正在使用的特定的开发者工具或者开发板，比如对于STM32F3DISCOVERY开发板来说，是#ln_f3
]))

= #tr((
  en: [Board Crate],
  de: [Board Crate],
  zh: [开发板Crate (Board Crate)],
))

#tr((
en: [
  A board crate is the perfect starting point, if you're new to embedded
  Rust. They nicely abstract the HW details that might be overwhelming
  when starting studying this subject, and makes standard tasks easy, like
  turning a LED on or off. The functionality it exposes varies a lot
  between boards. Since this book aims at staying hardware agnostic, the
  board crates won't be covered by this book.
],
de: [
  Eine Board-Crate ist der ideale Ausgangspunkt für den Einstieg in
  Embedded Rust. Sie abstrahiert auf angenehme Weise die Hardware-Details,
  die Anfänger in diesem Bereich oft überfordern können, und erleichtert
  Standardaufgaben wie das Ein- oder Ausschalten einer LED. Der
  bereitgestellte Funktionsumfang variiert jedoch stark von Board zu
  Board. Da dieses Buch hardwareunabhängig bleiben soll, werden
  Board-Crates hier nicht behandelt.
],
zh: [
  如果你是嵌入式Rust新手，board
  crate是一个完美的开始。它们很好地抽象出了，在开始学习这个项目时，需要耗费心力了解的硬件细节，使得标准工作，像是打开或者关闭LED，变得简单。不同的板子间，它们提供的功能变化很大。因为这本书是不假设我们使用的是何种板子，所以这本书不会提到board
  crate。
]))

#let url_disco = "https://rust-embedded.github.io/discovery/"
#tr((
en: [
  If you want to experiment with the STM32F3DISCOVERY board, it is highly
  recommended to take a look at the #ln_f3
  board crate, which provides functionality to blink the board LEDs,
  access its compass, bluetooth and more. The
  #link(url_disco)[Discovery] book
  offers a great introduction to the use of a board crate.
],
de: [
  Wenn Sie mit dem STM32F3DISCOVERY-Board experimentieren möchten, ist es
  sehr empfehlenswert, sich das #ln_f3;-Board-Crate
  anzusehen; dieses bietet Funktionen, um die LEDs des Boards blinken zu
  lassen sowie auf den Kompass, Bluetooth und mehr zuzugreifen. Das
  #link(url_disco)[Discovery]-Buch bietet eine hervorragende
  Einführung in die Verwendung eines Board-Crates.
],
zh: [
  如果你想要用STM32F3DISCOVERY开发板做实验，强烈建议看一下#ln_f3;开发板crate，它提供了闪烁LEDs，访问它的指南针，蓝牙和其它的功能。#link(url_disco)[Discovery]书对于一个board
  crate的用法提供一个很好的介绍。
]))

#tr((
en: [
  But if you're working on a system that doesn't yet have dedicated board
  crate, or you need functionality not provided by existing crates, read
  on as we start from the bottom, with the micro-architecture crates.
],
de: [
  Wenn Sie jedoch an einem System arbeiten, für das es noch kein
  dediziertes Board-Crate gibt, oder wenn Sie Funktionen benötigen, die
  von vorhandenen Crates nicht abgedeckt werden, lesen Sie weiter: Wir
  beginnen ganz unten, bei den Mikroarchitektur-Crates.
],
zh: [
  但是如果你正在使用一个还没有提供专用的board
  crate的系统，或者你需要的一些功能，现存的crates不提供，那我们需要从底层的微架构crates开始。
]))

= #tr((
  en: [Micro-architecture crate],
  de: [Mikroarchitektur-Crate],
  zh: [Micro-architecture crate],
))

#tr((
en: [
  Let's look at the SysTick peripheral that's common to all Cortex-M based
  micro-controllers. We can find a pretty low-level API in the
  #ln_cortex crate, and we can use it like this:
],
de: [
  Betrachten wir die SysTick-Peripherie, die allen Mikrocontrollern auf
  Cortex-M-Basis gemeinsam ist. Im #ln_cortex;-Crate finden wir
  eine recht hardwarenahe API, die sich folgendermaßen verwenden lässt:
],
ja: [
  全てのCortex-Mマイクロコントローラで共通のSysTickペリフェラルから見ていきましょう。
  #ln_cortex;クレートにはかなり低レベルなAPIがあり、次のように使うことができます。
],
zh: [
  让我们看一下SysTick外设，SysTick外设存在于所有的Cortex-M微控制器中。我们能在#ln_cortex
  crate中找到一个相当底层的API，我们能像这样使用它：
]))

#raw(block: true, lang: "rust",
"#![no_std]
#![no_main]
use cortex_m::peripheral::{syst, Peripherals};
use cortex_m_rt::entry;
use panic_halt as _;

#[entry]
fn main() -> ! {
    let peripherals = Peripherals::take().unwrap();
    let mut systick = peripherals.SYST;
    systick.set_clock_source(syst::SystClkSource::Core);
    systick.set_reload(1_000);
    systick.clear_current();
    systick.enable_counter();
    while !systick.has_wrapped() {
        // " + ts((
          en: "Loop",
          ja: "ループ",
        )) + "
    }

    loop {}
}
")

#tr((
en: [
  The functions on the `SYST` struct map pretty closely to the
  functionality defined by the ARM Technical Reference Manual for this
  peripheral. There's nothing in this API about 'delaying for X
  milliseconds' - we have to crudely implement that ourselves using a
  `while` loop. Note that we can't access our `SYST` struct until we have
  called `Peripherals::take()` - this is a special routine that guarantees
  that there is only one `SYST` structure in our entire program. For more
  on that, see the #link(<peripherals>)[Peripherals] section.
],
de: [
  Die Funktionen der `SYST`-Struktur entsprechen weitgehend der
  Funktionalität, die im ARM Technical Reference Manual für diese
  Peripherieeinheit definiert ist. Diese API bietet keine Möglichkeit,
  eine Verzögerung von „X Millisekunden" direkt umzusetzen; wir müssen
  dies stattdessen selbst auf einfache Weise mittels einer
  `while`-Schleife implementieren. Beachten Sie, dass wir erst auf die
  `SYST`-Struktur zugreifen können, nachdem wir `Peripherals::take()`
  aufgerufen haben. Dabei handelt es sich um eine spezielle Routine, die
  sicherstellt, dass im gesamten Programm nur eine einzige `SYST`-Instanz
  existiert. Weitere Informationen dazu finden Sie im Abschnitt
  "#link(<peripherals>)[Peripherien]".
],
ja: [
  `SYST`構造体の関数は、ARMテクニカルリファレンスマニュアルにおいて、このペリフェラルに定義されている機能と非常によく似ています。
  「Xミリ秒遅延」といった具合のAPIはありません。`while`ループを使って愚直に実装する必要があります。`Peripherals::take()`を呼び出すまでは、
  `SYST`構造体にアクセスできないことに注意して下さい。これは、プログラム全体で唯一の`SYST`構造体が存在することを保証する特別な手順です。
  詳しくは、#link(<peripherals>)[ペリフェラル]セクションをご覧下さい。
],
zh: [
  `SYST`结构体上的功能，相当接近ARM技术手册为这个外设定义的功能。在这个API中没有关于
  '延迟X毫秒' 的功能 - 我们不得不通过使用一个 `while`
  循环来粗略地实现它。注意，我们调用了`Peripherals::take()`才能访问我们的`SYST`结构体
  - 这是一个特别的程序，保障了在我们的整个程序中只存在一个`SYST`结构体实例，更多的信息可以看#link(<peripherals>)[外设]部分。
]))

= #tr((
  en: [Using a Peripheral Access Crate (PAC)],
  de: [Verwendung eines Peripheral Access Crate (PAC)],
  ja: [ペリフェラルアクセスクレート（PAC）の使用],
  zh: [使用一个外设访问Crate (PAC)],
))

#tr((
en: [
  We won't get very far with our embedded software development if we
  restrict ourselves to only the basic peripherals included with every
  Cortex-M. At some point, we're going to need to write some code that's
  specific to the particular micro-controller we're using. In this
  example, let's assume we have an Texas Instruments TM4C123 - a middling
  80MHz Cortex-M4 with 256 KiB of Flash. We're going to pull in the
  #ln_tm4c123x crate to make use of this chip.
],
de: [
  Bei der Entwicklung von Embedded-Software kommen wir nicht weit, wenn
  wir uns auf die grundlegenden Peripheriekomponenten beschränken, die in
  jedem Cortex-M enthalten sind. Irgendwann müssen wir Code schreiben, der
  speziell auf den verwendeten Mikrocontroller zugeschnitten ist. Gehen
  wir in diesem Beispiel davon aus, dass wir einen Texas Instruments
  TM4C123 verwenden -- einen soliden 80-MHz-Cortex-M4 mit 256 KiB
  Flash-Speicher. Um diesen Chip nutzen zu können, binden wir das
  #ln_tm4c123x;-Crate ein.
],
ja: [
  全てのCortex−Mに搭載されている基本的なペリフェラルのみに限定するのであれば、組込みソフトウェア開発はあまり進まないでしょう。
  どこかの時点で、使用している特定のマイクロコントローラ固有のコードを書く必要があります。今回の例では、テキサスインスツルメンツのTM4C123があるとしましょう。
  TM4C123はミドルレンジのマイクロコントローラで、80MHzのCortex-M4と256
  KiBのフラッシュメモリが搭載されています。
  このチップを利用するために、#ln_tm4c123x;クレートを取得します。
],
zh: [
  如果我们把自己只局限于每个Cortex-M拥有的基本外设，那我们的嵌入式软件开发将不会走得太远。我们准备需要写一些特定于我们正在使用的微控制器的代码。在这个例子里，让我们假设我们有一个TI的TM4C123
  - 一个有256KiB
  Flash的中等规模的80MHz的Cortex-M4。我们用#ln_tm4c123x
  crate去使用这个芯片。
]))

#raw(block: true, lang: "rust",
"#![no_std]
#![no_main]

use panic_halt as _; // " + ts((
                        en: "panic handler",
                        ja: "パニックハンドラ",
                      )) + "

use cortex_m_rt::entry;
use tm4c123x;

#[entry]
pub fn init() -> (Delay, Leds) {
    let cp = cortex_m::Peripherals::take().unwrap();
    let p = tm4c123x::Peripherals::take().unwrap();

    let pwm = p.PWM0;
    pwm.ctl.write(|w| w.globalsync0().clear_bit());
    // " + ts((
        en: "Mode = 1 => Count up/down mode",
        ja: "モード1は カウントアップ/ダウンモード",
      )) + "
    pwm._2_ctl.write(|w| w.enable().set_bit().mode().set_bit());
    pwm._2_gena.write(|w| w.actcmpau().zero().actcmpad().one());
    // " + ts((
        en: "528 cycles (264 up and down) = 4 loops per video line (2112 cycles)",
        ja: "528サイクル（264カウントアップとカウントダウン）は、ビデオラインごとに4ループ（2112サイクル）",
      )) + "
    pwm._2_load.write(|w| unsafe { w.load().bits(263) });
    pwm._2_cmpa.write(|w| unsafe { w.compa().bits(64) });
    pwm.enable.write(|w| w.pwm4en().set_bit());
}
")

#let ln_svd2rust = link("https://crates.io/crates/svd2rust")[svd2rust]
#tr((
en: [
  We've accessed the `PWM0` peripheral in exactly the same way as we
  accessed the `SYST` peripheral earlier, except we called
  `tm4c123x::Peripherals::take()`. As this crate was auto-generated using
  #ln_svd2rust, the access
  functions for our register fields take a closure, rather than a numeric
  argument. While this looks like a lot of code, the Rust compiler can use
  it to perform a bunch of checks for us, but then generate machine-code
  which is pretty close to hand-written assembler! Where the
  auto-generated code isn't able to determine that all possible arguments
  to a particular accessor function are valid (for example, if the SVD
  defines the register as 32-bit but doesn't say if some of those 32-bit
  values have a special meaning), then the function is marked as `unsafe`.
  We can see this in the example above when setting the `load` and `compa`
  sub-fields using the `bits()` function.
],
de: [
  Wir haben auf die `PWM0`-Peripherie auf genau dieselbe Weise zugegriffen
  wie zuvor auf die `SYST`-Peripherie, mit dem Unterschied, dass wir
  `tm4c123x::Peripherals::take()` aufgerufen haben. Da dieses Crate
  mithilfe von #ln_svd2rust
  automatisch generiert wurde, erwarten die Zugriffsfunktionen für unsere
  Registerfelder einen Closure anstelle eines numerischen Arguments. Auch
  wenn dies nach viel Code aussieht, kann der Rust-Compiler ihn nutzen, um
  eine Reihe von Prüfungen für uns durchzuführen und anschließend
  Maschinencode zu erzeugen, der handgeschriebenem Assemblercode sehr
  nahekommt! Wenn der automatisch generierte Code nicht feststellen kann,
  ob alle möglichen Argumente für eine bestimmte Zugriffsfunktion gültig
  sind (zum Beispiel, wenn die SVD das Register als 32-Bit-Register
  definiert, aber nicht angibt, ob bestimmte dieser 32-Bit-Werte eine
  besondere Bedeutung haben), wird die Funktion als `unsafe` markiert.
  Dies lässt sich im obigen Beispiel beim Setzen der Unterfelder `load`
  und `compa` mittels der Funktion `bits()` beobachten.
],
ja: [
  先ほど`SYST`にアクセスした時と全く同じ方法で、`PWM0`ペリフェラルにアクセスします。違う点は、`tm4c123x::Peripherals::take()`を呼ぶことです。
  このクレートは、#link("https://crates.io/crates/svd2rust")[svd2rust]を使って自動生成されたものです。レジスタフィールドのアクセス関数は、数値の引数ではなく、クロージャを取ります。
  このコードは量が多いように見えますが、Rustコンパイラは一連のチェックを実行し、手書きのアセンブラに近いマシンコードを生成します。
  自動生成されたコードが、特定のアクセサ関数への全引数が有効であることを判断できない場合、その関数は`unsafe`とマークされます。
  例えば、SVDがレジスタを32ビットと定義しているが、それらの32ビット値の一部が特別な意味を持つかどうか、記述していない場合です。
  上記の例では、`bits()`関数を使って`load`と`compa`サブフィールドを設定する時に、`unsafe`をマークしています。
],
zh: [
  我们访问 `PWM0` 外设的方法和我们之前访问 `SYST`
  的方法一样，除了我们调用的是 `tm4c123x::Peripherals::take()`
  之外。因为这个crate是使用#ln_svd2rust;自动生成的，访问我们寄存器位段的函数的参数是一个闭包，而不是一个数值参数。虽然这看起来像是有了更多的代码，但是Rust编译器能使用这个闭包为我们执行一系列检查，且产生的机器码十分接近手写的汇编码！如果自动生成的代码不能确保某个访问函数其所有可能的参数都能发挥作用(比如，如果寄存器被SVD定义为32位，但是没有说明某些32位值是否有特殊作用)，那么该函数需要被标记为
  `unsafe` 。我们能在上面看到这样的例子，我们使用 `bits()` 函数设置 `load` 和 `compa` 子域。
]))

== #tr((
  en: [Reading],
  de: [Lesen],
  ja: [読み込み],
  zh: [Reading],
))

#let url_struct_r = "https://docs.rs/tm4c123x/0.7.0/tm4c123x/pwm0/ctl/struct.R.html"
#tr((
en: [
  The `read()` function returns an object which gives read-only access to
  the various sub-fields within this register, as defined by the
  manufacturer's SVD file for this chip. You can find all the functions
  available on special `R` return type for this particular register, in
  this particular peripheral, on this particular chip, in the
  #link(url_struct_r)[tm4c123x documentation].
],
de: [
  Die Funktion `read()` gibt ein Objekt zurück, das schreibgeschützten
  Zugriff auf die verschiedenen Teilfelder dieses Registers gewährt --
  entsprechend der vom Hersteller für diesen Chip bereitgestellten
  SVD-Datei. Alle für den speziellen Rückgabetyp `R` dieses spezifischen
  Registers (innerhalb der jeweiligen Peripherieeinheit auf diesem Chip)
  verfügbaren Funktionen finden Sie in der
  #link(url_struct_r)[tm4c123x-Dokumentation].
],
ja: [
  `read()`関数は、メーカーのSVDファイルで定義されている通り、レジスタ内の様々なサブフィールドに対して、読み込み専用のアクセスオブジェクトを返します。
  特定チップ上にある、特定ペリフェラルの、特定レジスタに対して、固有の返り値`R`型があり、このR型で使える全ての関数は、#link(url_struct_r)[tm4c123xドキュメント]で見ることができます。
],
zh: [
  `read()`
  函数返回一个对象，这个对象提供了对这个寄存器中不同子域的只读访问，由厂商提供的这个芯片的SVD文件定义。在
  #link(url_struct_r)[tm4c123x documentation]
  中你能找到在这个特别的返回类型 `R`
  上所有可用的函数，其与特定芯片中的特定外设的特定寄存器有关。
]))

#raw(block: true, lang: "rust",
"if pwm.ctl.read().globalsync0().is_set() {
    // " + ts((
        en: "Do a thing",
        de: "Tu etwas",
        ja: "処理をする",
      )) + "
}
")

== #tr((
  en: [Writing],
  de: [Schreiben],
  ja: [書き込み],
  zh: [Writing],
))

#let url_struct_w = "https://docs.rs/tm4c123x/0.7.0/tm4c123x/pwm0/ctl/struct.W.html"
#tr((
en: [
  The `write()` function takes a closure with a single argument. Typically
  we call this `w`. This argument then gives read-write access to the
  various sub-fields within this register, as defined by the
  manufacturer's SVD file for this chip. Again, you can find all the
  functions available on the 'w' for this particular register, in this
  particular peripheral, on this particular chip, in the
  #link(url_struct_w)[tm4c123x documentation].
  Note that all of the sub-fields that we do not set will be set to a
  default value for us - any existing content in the register will be lost.
],
de: [
  Die Funktion `write()` erwartet einen Closure mit einem einzelnen
  Argument. Üblicherweise bezeichnen wir dieses als `w`. Dieses Argument
  gewährt Lese- und Schreibzugriff auf die verschiedenen Teilfelder
  innerhalb des Registers, wie sie in der SVD-Datei des Herstellers für
  diesen Chip definiert sind. Auch hier gilt: Alle für `w` verfügbaren
  Funktionen -- spezifisch für dieses Register, diese Peripherieeinheit
  und diesen Chip -- finden Sie in der
  #link(url_struct_w)[tm4c123x-Dokumentation].
  Beachten Sie, dass alle Teilfelder, die wir nicht explizit setzen,
  automatisch auf einen Standardwert gesetzt werden; bereits vorhandene
  Inhalte des Registers gehen dabei verloren.
],
ja: [
  `write()`関数は、単一引数のクロージャを取ります。通常は、この引数を`w`と呼びます。
  この引数は、チップメーカーがSVDファイルで定義している通り、様々なレジスタのサブフィールドへの読み書きアクセスを許可します。
  特定チップ上にある、特定ペリフェラルの、特定レジスタに対して、`w`型で使える全ての関数も、#link(url_struct_w)[tm4c123xドキュメント]で見ることができます。
  設定していない全てのサブフィールドは、デフォルト値に設定されます。レジスタの既存の内容は失われます。
],
zh: [
  `write()`函数使用一个只有一个参数的闭包。通常我们把这个参数叫做
  `w`。然后这个参数提供对这个寄存器中不同的子域的读写访问，由厂商关于这个芯片的SVD文件提供。再一次，在
  #link(url_struct_w)[tm4c123x documentation]
  中你能找到 `W`
  所有可用的函数，其与特定芯片中的特定外设的特定寄存器有关。注意,所有我们没有设置的子域将会被设置成一个默认值
  - 将会丢失任何在这个寄存器中的现存的内容。
]))

```rust
pwm.ctl.write(|w| w.globalsync0().clear_bit());
```

== #tr((
  en: [Modifying],
  de: [Ändern],
  ja: [修正],
  zh: [Modifying],
))

#tr((
en: [
  If we wish to change only one particular sub-field in this register and
  leave the other sub-fields unchanged, we can use the `modify` function.
  This function takes a closure with two arguments - one for reading and
  one for writing. Typically we call these `r` and `w` respectively. The
  `r` argument can be used to inspect the current contents of the
  register, and the `w` argument can be used to modify the register contents.
],
de: [
  Wenn wir in diesem Register nur ein bestimmtes Teilfeld ändern und die
  übrigen Teilfelder unverändert lassen möchten, können wir die Funktion
  `modify` verwenden. Diese Funktion nimmt eine Closure mit zwei
  Argumenten entgegen -- eines zum Lesen und eines zum Schreiben.
  Üblicherweise bezeichnen wir diese als `r` beziehungsweise `w`. Das
  Argument `r` dient dazu, den aktuellen Inhalt des Registers zu
  betrachten, während das Argument `w` genutzt werden kann, um den
  Registerinhalt zu ändern.
],
ja: [
  レジスタの特定のサブフィールドだけを変更して、残りのサブフィールドは変更したくない場合、`modify`関数を使えます。この関数は2引数のクロージャを取ります。
  1つは読み込み用で、もう1つは書き込み用です。通常、これらの引数をそれぞれ、`r`と`w`と呼びます。
  `r`引数は、レジスタの現在の内容を調べるために使用されます。そして、`w`引数は、レジスタの内容を修正するために使用されます。
],
zh: [
  如果我们希望只改变这个寄存器中某个特定的子域而让其它子域不变，我们能使用`modify`函数。这个函数使用一个具有两个参数的闭包
  - 一个用来读取，一个用来写入。通常我们分别称它们为 `r` 和 `w` 。 `r`
  参数能被用来查看这个寄存器现在的内容，`w` 参数能被用来修改寄存器的内容。
]))

```rust
pwm.ctl.modify(|r, w| w.globalsync0().clear_bit());
```

#tr((
en: [
  The `modify` function really shows the power of closures here. In C,
  we'd have to read into some temporary value, modify the correct bits and
  then write the value back. This means there's considerable scope for error:
],
de: [
  Die Funktion `modify` veranschaulicht hier eindrucksvoll die
  Leistungsfähigkeit von Closures. In C müssten wir den Wert zunächst in
  eine temporäre Variable einlesen, die entsprechenden Bits ändern und den
  Wert anschließend wieder zurückschreiben. Dies birgt ein erhebliches
  Fehlerpotenzial:
],
ja: [
  `modify`関数は、クロージャの本領を発揮します。C言語では、一時変数に読み込み、正しいビットを修正してから、その値を書き戻す必要があります。
  これは、エラーが発生するかなりの余地があることを示しています。
],
zh: [
  `modify`
  函数在这里真正展示了闭包的能量。在C中，我们经常需要读取一些临时值，修改成正确的比特，然后再把值写回。这意味着出现错误的范围非常大。
]))

#raw(block: true, lang: "c",
"uint32_t temp = pwm0.ctl.read();
temp |= PWM0_CTL_GLOBALSYNC0;
pwm0.ctl.write(temp);
uint32_t temp2 = pwm0.enable.read();
temp2 |= PWM0_ENABLE_PWM4EN;
pwm0.enable.write(temp); // " + ts((
                            en: "Uh oh! Wrong variable!",
                            ja: "ああ！間違った変数です！",
                            zh: "哦 不! 错误的变量!",
                          )) + "
")

= #tr((
  en: [Using a HAL crate],
  de: [Verwendung eines HAL-Crates],
  ja: [HALクレートの使用],
  zh: [使用一个HAL crate],
))

#tr((
en: [
  The HAL crate for a chip typically works by implementing a custom Trait
  for the raw structures exposed by the PAC. Often this trait will define
  a function called `constrain()` for single peripherals or `split()` for
  things like GPIO ports with multiple pins. This function will consume
  the underlying raw peripheral structure and return a new object with a
  higher-level API. This API may also do things like have the Serial port
  `new` function require a borrow on some `Clock` structure, which can
  only be generated by calling the function which configures the PLLs and
  sets up all the clock frequencies. In this way, it is statically
  impossible to create a Serial port object without first having
  configured the clock rates, or for the Serial port object to misconvert
  the baud rate into clock ticks. Some crates even define special traits
  for the states each GPIO pin can be in, requiring the user to put a pin
  into the correct state (say, by selecting the appropriate Alternate
  Function Mode) before passing the pin into Peripheral. All with no
  run-time cost!
],
de: [
  Ein HAL-Crate für einen Chip funktioniert typischerweise, indem es ein
  spezifisches Trait für die vom PAC bereitgestellten Rohstrukturen
  implementiert. Oft definiert dieses Trait eine Funktion namens
  `constrain()` für einzelne Peripherieeinheiten oder `split()` für
  Komponenten wie GPIO-Ports mit mehreren Pins. Diese Funktion übernimmt
  die zugrundeliegende Rohstruktur der Peripherie und gibt ein neues
  Objekt mit einer höherwertigen API zurück. Diese API kann zudem
  sicherstellen, dass beispielsweise die `new`-Funktion für die serielle
  Schnittstelle eine Referenz auf eine `Clock`-Struktur verlangt; eine
  solche Struktur lässt sich nur durch den Aufruf der Funktion erzeugen,
  welche die PLLs konfiguriert und sämtliche Taktfrequenzen einstellt. Auf
  diese Weise ist es zur Kompilierzeit ausgeschlossen, ein Objekt für die
  serielle Schnittstelle zu erzeugen, ohne zuvor die Taktraten
  konfiguriert zu haben, oder dass das Objekt die Baudrate fehlerhaft in
  Taktzyklen umrechnet. Manche Crates definieren sogar spezielle Traits
  für die Zustände, die ein GPIO-Pin einnehmen kann; der Nutzer muss den
  Pin dann in den korrekten Zustand versetzen (etwa durch Auswahl des
  passenden Modus für alternative Funktionen), bevor er ihn an die
  Peripherieeinheit übergibt. Und das alles ohne Laufzeitkosten!
],
ja: [
  あるチップ用のHALクレートは、典型的には、PACによって公開されている生の構造体に対して、カスタムトレイトを実装することで機能しています。
  大抵、このトレイトは、単独のペリフェラルには`constrain()`関数を定義し、複数ピンを利用するGPIOポートのようなものには`split()`関数を定義します。
  この関数は、下層の生のペリフェラル構造体オブジェクトを消費し、より高レベルなAPIを備える新しいオブジェクトを返します。
  このAPIは、シリアルポートの`new`関数が、`Clock`構造体オブジェクトの借用を必要とするようなことをするかもしれません。Clock構造体オブジェクトは、
  PLLと全てのクロック周波数とを設定する関数呼び出しによってのみ、生成することが可能です。この方法では、最初にクロックレートを設定しないでシリアルポートオブジェクトを作成したり、
  シリアルポートオブジェクトがボーレートをクロック数に誤って変換するようなことは、静的に起こり得ません。
  一部のクレートでは、各GPIOが取り得る状態のための特別なトレイトを定義することさえあります。このトレイトは、ペリフェラルにピンを渡す前に、
  ユーザがピンを正しい状態（例えば、適切なAlternate
  Functionモードを選択することによって）にすることを求めます。
  これらは全て、ランタイムのコストを必要としません。
],
zh: [
  一个芯片的HAL
  crate是通过为PAC暴露的基础结构体们实现一个自定义Trait来发挥作用的。经常这个trait将会为某个外设定义一个被称作
  `constrain()`
  的函数，或者为像是有多个管脚的GPIO端口这类东西定义一个`split()`函数。这个函数将会使用基础的外设结构体，然后返回一个具有更高抽象的API的新对象。这个API还可以做一些事，比如让Serial
  port的 `new`
  函数变成需要某个`Clock`结构体的函数，这个结构体只能通过调用配置PLLs并设置所有的时钟频率的函数来生成。在这时，生成一个Serial
  port对象而不先配置时钟速率是不可能的，对于Serial
  port对象来说错误地将波特率转换为时钟滴答数也是不会发生的。一些crates甚至为每个GPIO管脚的状态定义了特定的
  traits，在把管脚传递进外设前，要求用户去把一个管脚设置成正确的状态(通过选择Alternate
  Function模式) 。所有这些都没有运行时开销的！
]))

#tr((
en: [
  Let's see an example:
],
de: [
  Schauen wir uns ein Beispiel an:
],
ja: [
  例を見てみましょう。
],
zh: [
  让我们看一个例子:
]))

#raw(block: true, lang: "rust",
"#![no_std]
#![no_main]

use panic_halt as _; // panic handler

use cortex_m_rt::entry;
use tm4c123x_hal as hal;
use tm4c123x_hal::prelude::*;
use tm4c123x_hal::serial::{NewlineMode, Serial};
use tm4c123x_hal::sysctl;

#[entry]
fn main() -> ! {
    let p = hal::Peripherals::take().unwrap();
    let cp = hal::CorePeripherals::take().unwrap();

    // " + ts((
        en: "Wrap up the SYSCTL struct into an object with a higher-layer API",
        de: "Kapseln Sie die SYSCTL-Struktur in einem Objekt mit einer API auf 
    // hoeherer Ebene.",
        ja: "SYSCTL構造体をより高レイヤなAPIオブジェクトでラップします",
        zh: "将SYSCTL结构体封装成一个有更高抽象API的对象",
      )) + "
    let mut sc = p.SYSCTL.constrain();
    // " + ts((
        en: "Pick our oscillation settings",
        de: "Waehlen Sie unsere Oszillationseinstellungen aus.",
        ja: "オシレータの設定値を選択します",
        zh: "选择我们的晶振配置",
      )) + "
    sc.clock_setup.oscillator = sysctl::Oscillator::Main(
        sysctl::CrystalFrequency::_16mhz,
        sysctl::SystemClock::UsePll(sysctl::PllOutputFrequency::_80_00mhz),
    );
    // " + ts((
        en: "Configure the PLL with those settings",
        de: "Konfigurieren Sie die PLL mit diesen Einstellungen.",
        ja: "PLLをそれらの設定値で設定します",
        zh: "设置PLL",
      )) + "
    let clocks = sc.clock_setup.freeze();

    // " + ts((
        en: "Wrap up the GPIO_PORTA struct into an object with a higher-layer API.
    // Note it needs to borrow `sc.power_control` so it can power up the GPIO
    // peripheral automatically.",
        de: "Kapseln Sie die `GPIO_PORTA`-Struktur in einem Objekt mit einer API der 
    // hoeheren Ebene.
    // Beachten Sie, dass es `sc.power_control` nutzen muss, um die 
    // Stromversorgung der GPIO-Peripherie automatisch zu aktivieren.",
        ja: "GPIO_PORTA構造体をより高レイヤなAPIオブジェクトでラップします。
    // GPIOペリフェラルに自動的に電源を入れるために、
    // `sc.power_control`の借用が必要なことに留意して下さい。",
        zh: "把GPIO_PORTA结构体封装成一个有更高抽象API的对象
    // 注意它需要借用 `sc.power_control` 因此它能自动开启GPIO外设。",
      )) + "
    let mut porta = p.GPIO_PORTA.split(&sc.power_control);

    // " + ts((
        en: "Activate the UART.",
        de: "Aktivieren Sie den UART.",
        ja: "UARTを起動します。",
        zh: "激活UART",
      )) + "
    let uart = Serial::uart0(
        p.UART0,
        // " + ts((
            en: "The transmit pin",
            de: "Der Sende-Pin",
            ja: "送信ピン",
            zh: "激活UART",
          )) + "
        porta
            .pa1
            .into_af_push_pull::<hal::gpio::AF1>(&mut porta.control),
        // " + ts((
            en: "The receive pin",
            de: "Der Empfangs-Pin",
            ja: "受信ピン",
            zh: "接收管脚"
          )) + "
        porta
            .pa0
            .into_af_push_pull::<hal::gpio::AF1>(&mut porta.control),
        // " + ts((
            en: "No RTS or CTS required",
            de: "Kein RTS oder CTS erforderlich",
            ja: "RTSとCTSは必要としません",
            zh: "不需要RTS或者CTS"
          )) + "
        (),
        (),
        // " + ts((
            en: "The baud rate",
            de: "Die Baudrate",
            ja: "ボーレート",
            zh: "波特率",
          )) + "
        115200_u32.bps(),
        // " + ts((
            en: "Output handling",
            de: "Ausgabeverarbeitung",
            ja: "出力制御",
            zh: "输出处理",
          )) + "
        NewlineMode::SwapLFtoCRLF,
        // " + ts((
            en: "We need the clock rates to calculate the baud rate divisors",
            de: "Wir benoetigen die Taktfrequenzen, um die Baudraten-Teiler zu 
        // berechnen.",
            ja: "ボーレートの除数を計算するためにクロックレートが必要です",
            zh: "我们需要时钟频率去计算波特率除法器(divisors)",
          )) + "
        &clocks,
        // " + ts((
            en: "We need this to power up the UART peripheral",
            de: "Wir benoetigen dies, um die UART-Peripherie zu aktivieren.",
            ja: "UARTペリフェラルの電源を入れるために必要です",
            zh: "我们需要这个去启动UART外设",
          )) + "
        &sc.power_control,
    );

    loop {
        writeln!(uart, \"Hello, World!\\r\\n\").unwrap();
    }
}
")
