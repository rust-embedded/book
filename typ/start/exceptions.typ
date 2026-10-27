#import "../config.typ": *

#h1((en: [Exceptions],
  de: [Ausnahmen (Exceptions)],
  ja: [例外],
  zh: [异常],
), offset: whole)
<getting-started-exceptions>

#tr((
en: [
  Exceptions, and interrupts, are a hardware mechanism by which the
  processor handles asynchronous events and fatal errors (e.g.~executing
  an invalid instruction). Exceptions imply preemption and involve
  exception handlers, subroutines executed in response to the signal that
  triggered the event.
],
de: [
  Ausnahmen und Interrupts sind ein Hardwaremechanismus, mit dem der
  Prozessor asynchrone Ereignisse und schwerwiegende Fehler (z. B. die
  Ausführung einer ungültigen Anweisung) behandelt. Ausnahmen implizieren
  Präemption und erfordern Ausnahmebehandlungsroutinen, die als Reaktion
  auf das auslösende Signal ausgeführt werden.
],
ja: [
  例外と割り込みは、プロセッサが非同期イベントと致命的なエラー（例えば、不正な命令の実行）を扱うためのハードウェアの仕組みです。
  例外はプリエンプションを意味し、例外ハンドラを呼び出します。例外ハンドラは、イベントを引き起こした信号に応答して実行されるサブルーチンです。
],
zh: [
  异常和中断，是处理器用来处理异步事件和致命错误(e.g.~执行一个无效的指令)的一种硬件机制。异常意味着抢占并涉及到异常处理程序，即响应触发事件的信号的子程序。
]))

#let ln_ex = link("https://docs.rs/cortex-m-rt-macros/latest/cortex_m_rt_macros/attr.exception.html")[`exception`]
#tr((
en: [
  The `cortex-m-rt` crate provides an #ln_ex attribute to declare exception handlers.
],
de: [
  Die `cortex-m-rt`-Crate bietet das Attribut #ln_ex zur Deklaration von Ausnahmebehandlungsroutinen.
],
ja: [
  `cortex-m-rt`クレートは、例外ハンドラを宣言するために、#ln_ex;アトリビュートを提供しています。
],
zh: [
  `cortex-m-rt` crate提供了一个 #ln_ex 属性去声明异常处理程序。
]))

#raw(block: true, lang: "rust",
"// " + ts((
    en: "Exception handler for the SysTick (System Timer) exception",
    de: "Ausnahmebehandlungsroutine fuer die SysTick-Ausnahme (System-Timer)",
    ja: "SysTick（システムタイマ）例外のための例外ハンドラ",
    zh: "SysTick (System计时器)异常的异常处理函数",
  )) + "
#[exception]
fn SysTick() {
    // ..
}
")

#tr((
en: [
  Other than the `exception` attribute exception handlers look like plain
  functions but there's one more difference: `exception` handlers can
  _not_ be called by software. Following the previous example, the
  statement `SysTick();` would result in a compilation error.
],
de: [
  Abgesehen vom `exception`-Attribut sehen Exception-Handler wie
  gewöhnliche Funktionen aus, doch es gibt noch einen weiteren
  Unterschied: `exception`-Handler können _nicht_ per Software
  aufgerufen werden. Bezogen auf das vorherige Beispiel würde die
  Anweisung `SysTick();` zu einem Kompilierfehler führen.
],
ja: [
  `exception`属性の他は、例外ハンドラは普通の関数のように見えます。しかし、もう1つ違いがあります。
  `exception`ハンドラはソフトウェアから呼び出すことが_できません_。前述の例では、`SysTick();`というステートメントは、
  コンパイルエラーになります。
],
zh: [
  除了 `exception`
  属性，异常处理函数看起来和普通函数一样，但是有一个很大的不同:
  `exception` 处理函数 _不能_ 被软件调用。在先前的例子中，语句
  `SysTick();` 将会导致一个编译错误。
]))

#tr((
en: [
  This behavior is pretty much intended and it's required to provide a
  feature: `static mut` variables declared _inside_ `exception`
  handlers are _safe_ to use.
],
de: [
  Dieses Verhalten ist durchaus beabsichtigt und notwendig, um eine
  bestimmte Eigenschaft zu gewährleisten: `static mut`-Variablen, die
  _innerhalb_ von `exception`-Handlern deklariert werden, sind
  _sicher_ in der Verwendung.
],
ja: [
  この動作は、非常に意図的なものです。
  これは`exception`ハンドラ_内_で宣言された`static mut`変数の利用を_安全_にする、という機能を提供するためのものです。
],
zh: [
  这么做是有目的的，因为异常处理函数必须具有一个特性:
  在异常处理函数中被声明为`static mut`的变量能被安全(safe)地使用。
]))

#raw(block: true, lang: "rust",
"#[exception]
fn SysTick() {
    static mut COUNT: u32 = 0;
    // " + ts((
        en: "`COUNT` has transformed to type `&mut u32` and it's safe to use",
        de: "`COUNT` wurde in den Typ `&mut u32` umgewandelt und ist sicher in der 
    // Verwendung.",
        ja: "`COUNT`は`&mut u32`の型をもっており、その利用は安全です",
        zh: "`COUNT` 被转换到了 `&mut u32` 类型且它用起来是安全的",
      )) + "
    *COUNT += 1;
")

#let url_re = "https://en.wikipedia.org/wiki/Reentrancy_(computing)"
#tr((
en: [
  As you may know, using `static mut` variables in a function makes it
  #link(url_re)[_non-reentrant_].
  It's undefined behavior to call a non-reentrant function, directly or
  indirectly, from more than one exception / interrupt handler or from
  `main` and one or more exception / interrupt handlers.
],
de: [
  Wie Ihnen vielleicht bekannt ist, führt die Verwendung von
  `static mut`-Variablen in einer Funktion dazu, dass diese
  #link(url_re)[_nicht wiedereintrittsfähig_]
  ist. Es stellt undefiniertes Verhalten dar, eine nicht
  wiedereintrittsfähige Funktion direkt oder indirekt aus mehr als einem
  Ausnahme- oder Interrupt-Handler oder aus `main` und einem oder mehreren
  Ausnahme- oder Interrupt-Handlern heraus aufzurufen.
],
ja: [
  ご存知かもしれませんが、`static mut`変数を関数内で使うことは、その関数を_再入不可能_にします。
  直接的または間接的に、複数の例外・割り込みハンドラから、もしくは、`main`と1つ以上の例外・割り込みハンドラから、
  再進入不可能な関数を呼び出すことは、未定義動作です。
],
zh: [
  就像你可能已经知道的那样，在一个函数里使用`static mut`变量，会让函数变成#link(url_re)[_非可重入函数(non-reentrancy)_]。从多个异常/中断处理函数，或者从`main`函数和多个异常/中断处理函数中，直接或者间接地调用一个非可重入(non-reentrancy)函数是未定义的行为。
]))

#tr((
en: [
  Safe Rust must never result in undefined behavior so non-reentrant
  functions must be marked as `unsafe`. Yet I just told that `exception`
  handlers can safely use `static mut` variables. How is this possible?
  This is possible because `exception` handlers can _not_ be called
  by software thus reentrancy is not possible. These handlers are called
  by the hardware itself which is assumed to be physically non-concurrent.
],
de: [
  Safe Rust darf niemals zu undefiniertem Verhalten führen; daher müssen
  nicht-wiedereintrittsfähige Funktionen als `unsafe` gekennzeichnet
  werden. Dennoch habe ich gerade erwähnt, dass Ausnahme-Handler
  (`exception handlers`) sicher `static mut`-Variablen verwenden können.
  Wie ist das möglich? Dies ist möglich, da Ausnahme-Handler _nicht_
  per Software aufgerufen werden können und somit kein Wiedereintritt
  (Reentrancy) stattfinden kann. Diese Handler werden von der Hardware
  selbst aufgerufen, bei der davon ausgegangen wird, dass sie physisch
  keine Nebenläufigkeit aufweist.
],
ja: [
  #todoupd("ja")
  安全なRustは、決して未定義動作になりません。そのため、再入不可能な関数は、`unsafe`とマークされなければなりません。
  それでも、`exception`ハンドラは`static mut`な変数を安全に使える、と述べました。これが可能なのは、どうしてでしょうか。
  `exception`ハンドラはソフトウェアから呼び出すことが_できない_ため、再入する可能性はありません。だから、安全に使えるのです。
],
zh: [
  #todoupd("zh")
  安全的Rust不能导致未定义的行为出现，所以非可重入函数必须被标记为
  `unsafe`。然而，我刚说了`exception`处理函数能安全地使用`static mut`变量。这怎么可能？因为`exception`处理函数
  _不_ 能被软件调用因此重入(reentrancy)不会发生，所以这才变得可能。
]))

#tr((
en: [
  As a result, in the context of exception handlers in embedded systems,
  the absence of concurrent invocations of the same handler ensures that
  there are no reentrancy issues, even if the handler uses static mutable
  variables.
],
de: [
  Im Kontext von Ausnahme-Handlern in eingebetteten Systemen stellt das
  Ausbleiben gleichzeitiger Aufrufe desselben Handlers folglich sicher,
  dass keine Probleme mit der Wiedereintrittsfähigkeit auftreten -- selbst
  dann nicht, wenn der Handler veränderbare statische Variablen verwendet
]))

#tr((
en: [
  In a multicore system, where multiple processor cores are executing code
  concurrently, the potential for reentrancy issues becomes relevant
  again, even within exception handlers. While each core may have its own
  set of exception handlers, there can still be scenarios where multiple
  cores attempt to execute the same exception handler simultaneously. \
  To address this concern in a multicore environment, proper synchronization
  mechanisms need to be employed within the exception handlers to ensure
  that access to shared resources is properly coordinated among the cores.
  This typically involves the use of techniques such as locks, semaphores,
  or atomic operations to prevent data races and maintain data integrity
],
de: [
  In einem Multicore-System, in dem mehrere Prozessorkerne gleichzeitig
  Code ausführen, gewinnt die Problematik der Wiedereintrittsfähigkeit
  (Reentrancy) erneut an Bedeutung -- selbst innerhalb von
  Exception-Handlern. Auch wenn jeder Kern über eigene Exception-Handler
  verfügen mag, kann es dennoch zu Situationen kommen, in denen mehrere
  Kerne versuchen, denselben Exception-Handler simultan auszuführen. Um
  dieser Herausforderung in einer Multicore-Umgebung zu begegnen, müssen
  innerhalb der Exception-Handler geeignete Synchronisationsmechanismen
  eingesetzt werden; so wird sichergestellt, dass der Zugriff auf
  gemeinsam genutzte Ressourcen zwischen den Kernen korrekt koordiniert
  wird. Dies geschieht typischerweise durch den Einsatz von Techniken wie
  Locks, Semaphoren oder atomaren Operationen, um Race Conditions zu
  vermeiden und die Datenintegrität zu wahren.
]))

#quote(block: true)[
#tr((
en: [
  Note that the `exception` attribute transforms definitions of static
  variables inside the function by wrapping them into `unsafe` blocks and
  providing us with new appropriate variables of type `&mut` of the same
  name. Thus we can dereference the reference via `*` to access the values
  of the variables without needing to wrap them in an `unsafe` block.
],
de: [
  Beachten Sie, dass das Attribut `exception` Definitionen statischer
  Variablen innerhalb der Funktion umwandelt, indem es sie in
  `unsafe`-Blöcke einschließt und uns neue, passende Variablen des Typs
  `&mut` mit demselben Namen zur Verfügung stellt. Auf diese Weise können
  wir die Referenz mittels `*` dereferenzieren, um auf die Werte der
  Variablen zuzugreifen, ohne sie selbst in einen `unsafe`-Block
  einschließen zu müssen.
],
zh: [
  注意，`exception`属性，通过将静态变量封装进`unsafe`块中并为我们提供了名字相同的，类型为
  `&mut` 的，合适的新变量，转换了函数中静态变量的定义。因此我们可以通过
  `*` 解引用访问变量的值而不需要将它们打包进一个 `unsafe` 块中。
]))
]

= #tr((
  en: [A complete example],
  de: [Ein vollständiges Beispiel],
  ja: [完全な例],
  zh: [一个完整的例子],
))

#tr((
en: [
  Here's an example that uses the system timer to raise a `SysTick`
  exception roughly every second. The `SysTick` exception handler keeps
  track of how many times it has been called in the `COUNT` variable and
  then prints the value of `COUNT` to the host console using semihosting.
  of the variables without needing to wrap them in an `unsafe` block.
],
de: [
  Hier ist ein Beispiel, das den System-Timer verwendet, um etwa jede
  Sekunde eine `SysTick`-Exception auszulösen. Der
  `SysTick`-Exception-Handler protokolliert in der Variablen `COUNT`, wie
  oft er aufgerufen wurde, und gibt anschließend den Wert von `COUNT`
  mittels Semihosting auf der Host-Konsole aus.
],
ja: [
  `SysTick`例外を大体1秒毎に発生させるシステムタイマの例を使います。
  `SysTick`例外ハンドラは、呼び出された回数を`COUNT`変数に記録し、
  セミホスティングを使ってホストコンソールに`COUNT`の値を出力します。
],
zh: [
  这里有个例子，使用系统计时器大概每秒抛出一个 `SysTick`
  异常。异常处理函数使用 `COUNT`
  变量追踪它自己被调用了多少次，然后使用半主机模式(semihosting)打印
  `COUNT` 的值到主机控制台上。
]))

#quote(block: true)[
#tr((
en: [
  *NOTE*: You can run this example on any Cortex-M device; you can
  also run it on QEMU
],
de: [
  *HINWEIS*: Sie können dieses Beispiel auf jedem Cortex-M-Gerät
  ausführen; es lässt sich auch unter QEMU ausführen.
],
ja: [
  *注記*：この例は、どのCortex-Mデバイスでも実行できます。QEMU上でも実行可能です。
],
zh: [
  *注意*: 你能在任何Cortex-M设备上运行这个例子;你也能在QEMU运行它。
]))
]

#raw(block: true, lang: "rust",
"#![deny(unsafe_code)]
#![no_main]
#![no_std]

use panic_halt as _;

use core::fmt::Write;

use cortex_m::peripheral::syst::SystClkSource;
use cortex_m_rt::{entry, exception};
use cortex_m_semihosting::{
    debug,
    hio::{self, HostStream},
};

#[entry]
fn main() -> ! {
    let p = cortex_m::Peripherals::take().unwrap();
    let mut syst = p.SYST;

    // " + ts((
        en: "configures the system timer to trigger a SysTick exception every second",
        de: "konfiguriert den System-Timer so, dass er jede Sekunde eine SysTick-
    // Exception ausloest",
        ja: "毎秒SysTick例外を起こすためのシステムタイマを設定します",
        zh: "配置系统的计时器每秒去触发一个SysTick异常",
      )) + "
    syst.set_clock_source(SystClkSource::Core);
    // " + ts((
        en: "this is configured for the LM3S6965 which has a default CPU clock of 12 MHz",
        de: "Dies ist für den LM3S6965 konfiguriert, der einen Standard-CPU-Takt von 
    // 12 MHz hat",
        ja: "デフォルトのCPUクロックが12MHzのLM3S6965向けの設定です",
        zh: "这是关于LM3S6965的配置，其有一个12MHz的默认CPU时钟",
      )) + "
    syst.set_reload(12_000_000);
    syst.clear_current();
    syst.enable_counter();
    syst.enable_interrupt();

    loop {}
}

#[exception]
fn SysTick() {
    static mut COUNT: u32 = 0;
    static mut STDOUT: Option<HostStream> = None;

    *COUNT += 1;

    // " + ts((
        en: "Lazy initialization",
        de: "Verzoegerte Initialisierung",
        ja: "遅延初期化",
        zh: "惰性初始化(Lazy initialization)",
      )) + "
    if STDOUT.is_none() {
        *STDOUT = hio::hstdout().ok();
    }

    if let Some(hstdout) = STDOUT.as_mut() {
        write!(hstdout, \"{}\", *COUNT).ok();
    }

    // " + ts((
        en: "IMPORTANT omit this `if` block if running on real hardware or your
    // debugger will end in an inconsistent state",
        de: "WICHTIG: Lassen Sie diesen `if`-Block weg, wenn Sie das Programm auf 
    //          echter Hardware ausfuehren, da sich Ihr Debugger sonst in 
    //          einem inkonsistenten Zustand befinden wird.",
        ja: "重要。実際のハードウェアで実行するときは`if`ブロックを削除して下さい。そうでなければ、
    // デバッガが不整合な状態に陥るでしょう。",
        zh: "重要信息 如果运行在真正的硬件上，去掉这个 `if` 块，
    // 否则你的调试器将会以一种不一致的状态结束"
      )) + "
    if *COUNT == 9 {
        // " + ts((
            en: "This will terminate the QEMU process",
            de: "Dies beendet den QEMU-Prozess.",
            ja: "QEMUプロセスを終了します",
            zh: "这将终结QEMU进程",
          )) + "
        debug::exit(debug::EXIT_SUCCESS);
    }
}
")

```console
tail -n5 Cargo.toml
```

```toml
[dependencies]
cortex-m = "0.5.7"
cortex-m-rt = "0.6.3"
panic-halt = "0.2.0"
cortex-m-semihosting = "0.3.1"
```

```text
$ cargo run --release
     Running `qemu-system-arm -cpu cortex-m3 -machine lm3s6965evb (..)
123456789
```

#tr((
en: [
  If you run this on the Discovery board you'll see the output on the
  OpenOCD console. Also, the program will _not_ stop when the count
  reaches 9.
],
de: [
  Wenn Sie dies auf dem Discovery-Board ausführen, sehen Sie die Ausgabe
  in der OpenOCD-Konsole. Außerdem hält das Programm _nicht_ an, wenn
  der Zählerstand 9 erreicht.
],
ja: [
  Discoveryボードでこのコードを実行すると、OpenOCDコンソールに出力を確認できるでしょう。
  プログラムは、カウントが9に到達しても停止_しません_。
],
zh: [
  如果你在Discovery开发板上运行这个例子，你将会在OpenOCD控制台上看到输出。还有，当计数到达9的时候，程序将 _会_ 停止。
]))

= #tr((
  en: [The default exception handler],
  de: [Der Standard-Exception-Handler],
  ja: [デフォルト例外ハンドラ],
  zh: [默认异常处理函数],
))

#tr((
en: [
  What the `exception` attribute actually does is _override_ the
  default exception handler for a specific exception. If you don't
  override the handler for a particular exception it will be handled by
  the `DefaultHandler` function, which defaults to:
],
de: [
  Das `exception`-Attribut bewirkt eigentlich, dass der
  Standard-Exception-Handler für eine bestimmte Exception
  _überschrieben_ wird. Wenn Sie den Handler für eine bestimmte
  Exception nicht überschreiben, wird sie von der Funktion
  `DefaultHandler` behandelt, die standardmäßig Folgendes tut:
],
ja: [
  `exception`アトリビュートが実際に行っていることは、特定の例外を処理するデフォルト例外ハンドラの_オーバーライド_です。
  特定の例外について、ハンドラをオーバーライドしない場合、`DefaultHandler`関数がその例外を処理します。
  DefaultHandler関数は下記の通りです。
],
zh: [
  `exception` 属性真正做的是，_覆盖_
  了一个特定异常的默认异常处理函数。如果你不覆盖一个特定异常的处理函数，它将会被
  `DefaultHandler` 函数处理，其默认的是:
]))

```rust
fn DefaultHandler() {
    loop {}
}
```

#tr((
en: [
  This function is provided by the `cortex-m-rt` crate and marked as
  `#[no_mangle]` so you can put a breakpoint on "DefaultHandler" and catch
  _unhandled_ exceptions.
],
de: [
  Diese Funktion wird vom `cortex-m-rt`-Crate bereitgestellt und ist mit
  `#[no_mangle]` markiert, sodass Sie einen Breakpoint auf
  „DefaultHandler" setzen und _unbehandelte_ Exceptions abfangen
  können.
],
ja: [
  この関数は、`cortex-m-rt`クレートによって提供されており、`#[no_mangle]`とマークされています。
  そのため、「DefaultHandler」にブレイクポイントを設定することができ、_未処理の_例外を捕捉することができます。
],
zh: [
  这个函数是 `cortex-m-rt` crate提供的，且被标记为 `#[no_mangle]`
  因此你能在 "DefaultHandler" 上放置一个断点并捕获 _unhandled_ 异常。
]))

#tr((
en: [
  It's possible to override this `DefaultHandler` using the `exception`
  attribute:
],
de: [
  Es ist möglich, diesen `DefaultHandler` mithilfe des
  `exception`-Attributs zu überschreiben:
],
ja: [
  `exception`アトリビュートを使うことで、`DefaultHandler`をオーバーライドできます。
],
zh: [
  可以使用 `exception` 属性覆盖这个 `DefaultHandler`:
]))

#raw(block: true, lang: "rust",
"#[exception]
fn DefaultHandler(irqn: i16) {
    // " + ts((
        en: "custom default handler",
        de: "benutzerdefinierter Standard-Handler",
        ja: "カスタムデフォルトハンドラ",
        zh: "自定义默认处理函数",
      )) +  "
}
")

#tr((
en: [
  The `irqn` argument indicates which exception is being serviced. A
  negative value indicates that a Cortex-M exception is being serviced;
  and zero or a positive value indicate that a device specific exception,
  AKA interrupt, is being serviced.
],
de: [
  Das Argument `irqn` gibt an, welche Exception gerade bearbeitet wird.
  Ein negativer Wert zeigt an, dass eine Cortex-M-Exception bearbeitet
  wird, während ein Wert von null oder ein positiver Wert darauf hinweist,
  dass eine gerätespezifische Exception -- auch als Interrupt bezeichnet
  -- bearbeitet wird.
],
ja: [
  `irqn`引数は、どの例外が処理されているかを示します。負の値は、Cortex-Mの例外が処理されていることを意味します。
  ゼロまたは正の値は、デバイス固有の例外、すなわち、割り込みが処理されていること、を示しています。
],
zh: [
  `irqn` 参数指出了被服务的是哪个异常。一个负数值指出了被服务的是一个Cortex-M异常;0或者一个正数值指出了被服务的是一个设备特定的异常，也就是中断。
]))

= #tr((
  en: [The hard fault handler],
  de: [Der "Schwere Fehler"-Handler],
  ja: [ハードフォールトハンドラ],
  zh: [硬错误(Hard Fault)处理函数],
))

#tr((
en: [
  The `HardFault` exception is a bit special. This exception is fired when
  the program enters an invalid state so its handler can _not_ return
  as that could result in undefined behavior. Also, the runtime crate does
  a bit of work before the user defined `HardFault` handler is invoked to
  improve debuggability.
],
de: [
  Die `HardFault`-Exception nimmt eine Sonderstellung ein. Sie wird
  ausgelöst, wenn das Programm in einen ungültigen Zustand gerät; daher
  darf ihr Handler nicht zurückkehren, da dies zu undefiniertem Verhalten
  führen könnte. Zudem führt die Runtime-Crate einige Vorarbeiten durch,
  bevor der benutzerdefinierte `HardFault`-Handler aufgerufen wird, um die
  Fehlersuche (Debugging) zu erleichtern.
],
ja: [
  `HardFault`例外は、少し特別です。この例外は、プログラムが不正な状態になった場合に発生します。
  そのため、このハンドラはリターンすることができず、未定義動作を引き起こす可能性があります。
  ランタイムクレートは、デバッグ性を向上するために、ユーザ定義の`HardFault`ハンドラが呼び出される前に、少し仕事をします。
],
zh: [
  `HardFault`异常有点特别。当程序进入一个无法工作的状态时，这个异常被触发，因此它的处理函数
  _不能_ 返回，因为这么做可能导致一个未定义的行为。在用户定义的
  `HardFault`
  处理函数被调用之前，运行时crate还做了一些工作以改进调试功能。
]))

#tr((
en: [
  The result is that the `HardFault` handler must have the following
  signature: `fn(&ExceptionFrame) -> !`. The argument of the handler is a
  pointer to registers that were pushed into the stack by the exception.
  These registers are a snapshot of the processor state at the moment the
  exception was triggered and are useful to diagnose a hard fault.
],
de: [
  Daraus ergibt sich, dass der `HardFault`-Handler folgende Signatur
  aufweisen muss: `fn(&ExceptionFrame) -> !`. Das Argument des Handlers
  ist ein Zeiger auf Register, die beim Auftreten der Exception auf den
  Stack gesichert wurden. Diese Register stellen eine Momentaufnahme des
  Prozessorzustands zum Zeitpunkt der Auslösung der Exception dar und sind
  für die Diagnose eines Hard Faults hilfreich.
],
ja: [
  その結果、`HardFault`ハンドラは、`fn(&ExceptionFrame) -> !`のシグネチャを持つ必要があります。
  ハンドラの引数は、例外によってスタックにプッシュされたレジスタへのポインタです。
  これらのレジスタは、例外が発生した瞬間のプロセッサステートのスナップショットで、ハードフォールトの原因を突き止めるのに便利です。
],
zh: [
  结果是，`HardFault`处理函数必须有下列的签名: `fn(&ExceptionFrame) -> !`
  。处理函数的参数是一个指针，它指向被异常推入栈中的寄存器。这些寄存器是异常被触发那刻，处理器状态的一个记录，能被用来分析一个硬错误。
]))

#tr((
en: [
  Here's an example that performs an illegal operation: a read to a
  nonexistent memory location.
],
de: [
  Hier ist ein Beispiel für eine unzulässige Operation: der Lesezugriff
  auf eine nicht existierende Speicheradresse.
],
ja: [
  不正な操作を行う例を示します。存在しないメモリ位置への読み込みです。
],
zh: [
  这里有个执行不合法操作的案例: 读取一个不存在的存储位置。
]))

#quote(block: true)[
#tr((
en: [
  *NOTE*: This program won't work, i.e.~it won't crash, on QEMU
  because `qemu-system-arm -machine lm3s6965evb` doesn't check memory
  loads and will happily return `0`on reads to invalid memory.
],
de: [
  *HINWEIS*: Dieses Programm wird unter QEMU nicht fehlschlagen
  (d.~h. es stürzt nicht ab), da `qemu-system-arm -machine lm3s6965evb`
  keine Überprüfung von Speicherzugriffen durchführt und beim Lesen von
  ungültigem Speicher problemlos den Wert `0` zurückgibt.
],
ja: [
  *注記*：このプログラムは、QEMU上ではうまく動きません。つまり、クラッシュしません。
  `qemu-system-arm -machine lm3s6965evb`はメモリの読み込みをチェックしないため、
  無効なメモリを読み込むと、幸いにも、`0`を返します。
],
zh: [
  *注意*: 这个程序在QEMU上不能起作用，i.e.~它不会崩溃，因为
  `qemu-system-arm -machine lm3s6965evb`
  不对读取存储的操作进行检查，且读取无效存储时将会开心地返回 `0`。
]))
]


#raw(block: true, lang: "rust",
"#![no_main]
#![no_std]

use panic_halt as _;

use core::fmt::Write;
use core::ptr;

use cortex_m_rt::{entry, exception, ExceptionFrame};
use cortex_m_semihosting::hio;

#[entry]
fn main() -> ! {
    // " + ts((
        en: "read a nonexistent memory location",
        de: "liest einen nicht existierenden Speicherbereich",
        ja: "存在しないメモリ位置を読み込みます",
        zh: "读取一个无效的存储位置",
      )) + "
    unsafe {
        ptr::read_volatile(0x3FFF_0000 as *const u32);
    }

    loop {}
}

#[exception]
fn HardFault(ef: &ExceptionFrame) -> ! {
    if let Ok(mut hstdout) = hio::hstdout() {
        writeln!(hstdout, \"{:#?}\", ef).ok();
    }

    loop {}
}
")

#tr((
en: [
  The `HardFault` handler prints the `ExceptionFrame` value. If you run
  this you'll see something like this on the OpenOCD console.
],
de: [
  Der `HardFault`-Handler gibt den Wert des `ExceptionFrame` aus. Wenn Sie
  dies ausführen, sehen Sie auf der OpenOCD-Konsole eine Ausgabe wie diese.
],
ja: [
  `HardFault`ハンドラは、`ExceptionFrame`の値を表示します。実行すると、
  OpenOCDコンソールに次のような表示が見えるでしょう。
],
zh: [
  `HardFault`处理函数打印了`ExceptionFrame`值。如果你运行这个，你将会看到下面的东西打印到OpenOCD控制台上。
]))

```text
$ openocd
(..)
ExceptionFrame {
    r0: 0x3fff0000,
    r1: 0x00000003,
    r2: 0x080032e8,
    r3: 0x00000000,
    r12: 0x00000000,
    lr: 0x080016df,
    pc: 0x080016e2,
    xpsr: 0x61000000,
}
```

#tr((
en: [
  The `pc` value is the value of the Program Counter at the time of the
  exception and it points to the instruction that triggered the exception.
],
de: [
  Der Wert `pc` ist der Wert des Programmzählers zum Zeitpunkt der
  Ausnahme und verweist auf die Anweisung, die die Ausnahme ausgelöst hat.
],
ja: [
  `pc`の値は、例外発生時のプログラムカウンタの値で、例外を引き起こした命令を指しています。
],
zh: [
  `pc`值是异常时程序计数器(Program Counter)的值，它指向触发了异常的指令。
]))

#tr((
en: [
  If you look at the disassembly of the program:
],
de: [
  Wenn Sie sich den Disassembler des Programms ansehen:
],
ja: [
  プログラムのディスアセンブル結果を見ます。
],
zh: [
  如果你看向程序的反汇编:
]))

```text
$ cargo objdump --bin app --release -- -d --no-show-raw-insn --print-imm-hex
(..)
ResetTrampoline:
 8000942:       movw    r0, #0xfffe
 8000946:       movt    r0, #0x3fff
 800094a:       ldr     r0, [r0]
 800094c:       b       #-0x4 <ResetTrampoline+0xa>
```

#tr((
en: [
  You can lookup the value of the program counter `0x0800094a` in the
  disassembly. You'll see that a load operation (`ldr r0, [r0]` ) caused
  the exception. The `r0` field of `ExceptionFrame` will tell you the
  value of register `r0` was `0x3fff_fffe` at that time.
],
de: [
  Den Wert des Programmzählers `0x0800094a` können Sie in der
  Disassemblierung nachschlagen.

  Sie werden sehen, dass eine Ladeoperation (`ldr r0, [r0]`) die Ausnahme
  verursacht hat.

  Das Feld `r0` von `ExceptionFrame` gibt an, dass der Wert des Registers
  `r0` zu diesem Zeitpunkt `0x3fff_fffe` war.
],
ja: [
  #todoupd("ja")
  ロード命令（`ldr r0, [r0]`）が例外を発生させたことがわかります。そして、この時の`r0`レジスタの値は、
  `0x3fff_fffe`です。この値は、`ExceptionFrame`の`r0`フィールドと一致します。
],
zh: [
  你可以在反汇编中搜索程序计数器`0x0800094a`的值。你将会看到一个读取操作(`ldr r0, [r0]`)导致了异常。`ExceptionFrame`的`r0`字段将告诉你，那时寄存器`r0`的值是`0x3fff_fffe`
  。
]))
