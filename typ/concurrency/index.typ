#import "../config.typ": *

#h1((en: [Concurrency],
  de: [Nebenläufigkeit],
  ja: [並行性],
  zh: [并发],
))
<concurrency>

#tr((
en: [
  Concurrency happens whenever different parts of your program might
  execute at different times or out of order. In an embedded context, this
  includes:
  - interrupt handlers, which run whenever the associated interrupt
    happens,
  - various forms of multithreading, where your microprocessor regularly
    swaps between parts of your program,
  - and in some systems, multiple-core microprocessors, where each core
    can be independently running a different part of your program at the
    same time.
],
de: [
  Nebenläufigkeit tritt immer dann auf, wenn verschiedene Teile Ihres
  Programms zu unterschiedlichen Zeiten oder in einer anderen als der
  vorgesehenen Reihenfolge ausgeführt werden können. Im Kontext
  eingebetteter Systeme umfasst dies:
  - Interrupt-Handler, die immer dann ausgeführt werden, wenn der
    zugehörige Interrupt auftritt,
  - verschiedene Formen des Multithreadings, bei denen Ihr Mikroprozessor
    regelmäßig zwischen Teilen Ihres Programms wechselt,
  - und in einigen Systemen Mehrkern-Mikroprozessoren, bei denen jeder
    Kern gleichzeitig und unabhängig voneinander einen anderen Teil Ihres
    Programms ausführen kann.
],
ja: [
  プログラムの異なる部分が様々なタイミングで実行されたり、アウトオブオーダに実行されると、並行性が発生します。
  組込みでは、次のものが該当します。
  - 割り込みが発生するたびに実行される割り込みハンドラ
  - マイクロプロセッサがプログラムの一部を定期的にスワップする様々な形式のマルチスレッド
  - システムによっては、各コアがプログラムの異なる部分を同時に独立して実行できるマルチコアマイクロプロセッサ
],
zh: [
  当程序的不同部分有可能会在不同的时刻被执行或者不按顺序地被执行时，那并发就出现了。在一个嵌入式环境中，这包括:
  - 中断处理函数，一旦相关的中断发生时，中断处理函数就会运行，
  - 不同的多线程形式，在这块，微处理器通常会在程序的不同部分间进行切换，
  - 在一些多核微处理器系统中，每个核可以同时独立地运行程序的不同部分。
]))

#tr((
en: [
  Since many embedded programs need to deal with interrupts, concurrency
  will usually come up sooner or later, and it's also where many subtle
  and difficult bugs can occur. Luckily, Rust provides a number of
  abstractions and safety guarantees to help us write correct code.
],
de: [
  Da viele eingebettete Programme mit Interrupts umgehen müssen, spielt
  Nebenläufigkeit früher oder später meist eine Rolle -- und genau hier
  können auch viele schwer zu findende und komplexe Fehler auftreten.
  Glücklicherweise bietet Rust eine Reihe von Abstraktionen und
  Sicherheitsgarantien, die uns dabei helfen, korrekten Code zu schreiben.
],
ja: [
  多くの組込みプログラムは割り込みを処理する必要があるため、早かれ遅かれ、並行性は発生します。
  割り込みは、捉えにくく、難しいバグが数多く発生し得る場所でもあります。
  幸運なことに、Rustは正しいコードを書く助けになる抽象化と安全性保証とを、いくつか提供しています。
],
zh: [
  因为许多嵌入式程序需要处理中断，因此并发迟早会出现，这也是许多微妙和困难的bugs会出现的地方。幸运地是，Rust提供了许多抽象和安全保障去帮助我们写正确的代码。
]))

== #tr((
  en: [No Concurrency],
  de: [Keine Nebenläufigkeit],
  ja: [並行性なし],
  zh: [没有并发],
))

#tr((
en: [
  The simplest concurrency for an embedded program is no concurrency: your
  software consists of a single main loop which just keeps running, and
  there are no interrupts at all. Sometimes this is perfectly suited to
  the problem at hand! Typically your loop will read some inputs, perform
  some processing, and write some outputs.
],
de: [
  Die einfachste Form der Nebenläufigkeit für ein Embedded-Programm ist
  der Verzicht darauf: Die Software besteht aus einer einzigen
  Hauptschleife, die kontinuierlich durchlaufen wird, und es kommen
  keinerlei Interrupts zum Einsatz. Manchmal ist genau dieser Ansatz für
  die vorliegende Aufgabenstellung ideal! Typischerweise liest die
  Schleife Eingabewerte ein, führt Berechnungen oder Verarbeitungen durch
  und gibt Ergebnisse aus.
],
ja: [
  組込みプログラムの最も簡単な並行性は、並行性がないことです。ソフトウェアは1つの動作し続けるメインループからなり、割り込みも発生しません。
  時には、これが手元の問題の最適解かもしれません。
  通常、ループは何か入力を受け付け、何らかの処理を行い、何かを出力します。
],
zh: [
  对于一个嵌入式程序来说最简单的并发是没有并发:
  软件由一个保持运行的main循环组成，一点中断也没有。有时候这非常适合手边的问题!
  通常你的循环将会读取一些输入，执行一些处理，且写入一些输出。
]))

```rust
#[entry]
fn main() {
    let peripherals = setup_peripherals();
    loop {
        let inputs = read_inputs(&peripherals);
        let outputs = process(inputs);
        write_outputs(&peripherals, outputs);
    }
}
```

#tr((
en: [
  Since there's no concurrency, there's no need to worry about sharing
  data between parts of your program or synchronising access to
  peripherals. If you can get away with such a simple approach this can be
  a great solution.
],
de: [
  Da keine Nebenläufigkeit vorliegt, müssen Sie sich keine Gedanken über
  die gemeinsame Datennutzung zwischen verschiedenen Programmteilen oder
  die Synchronisierung des Zugriffs auf Peripheriegeräte machen. Wenn ein
  solch einfacher Ansatz ausreicht, kann dies eine hervorragende Lösung sein.
],
ja: [
  並行性がないため、プログラム間でのデータ共有や、ペリフェラルへのアクセス同期に悩む必要はありません。
  このような単純なアプローチに逃れることができるのであれば、素晴らしい解決策かもしれません。
],
zh: [
  因为这里没有并发，因此不需要担心程序不同部分间的共享数据或者同步对外设的访问。如果可以使用一个简单的方法来解决问题，这种方法是个不错的选择。
]))

== #tr((
  en: [Global Mutable Data],
  de: [Globale veränderliche Daten],
  ja: [グローバルでミュータブルなデータ],
  zh: [全局可变数据],
))

#tr((
en: [
  Unlike non-embedded Rust, we will not usually have the luxury of
  creating heap allocations and passing references to that data into a
  newly-created thread. Instead, our interrupt handlers might be called at
  any time and must know how to access whatever shared memory we are
  using. At the lowest level, this means we must have _statically allocated_
  mutable memory, which both the interrupt handler and the main
  code can refer to.
],
de: [
  Im Gegensatz zu Rust-Anwendungen außerhalb des Embedded-Bereichs haben
  wir meist nicht den Luxus, Speicher auf dem Heap zu reservieren und
  Referenzen auf diese Daten an einen neu erstellten Thread zu übergeben.
  Stattdessen können unsere Interrupt-Handler jederzeit aufgerufen werden
  und müssen wissen, wie sie auf den jeweils genutzten gemeinsamen
  Speicher zugreifen können. Auf unterster Ebene bedeutet dies, dass wir
  über _statisch reservierten_, veränderbaren Speicher verfügen
  müssen, auf den sowohl der Interrupt-Handler als auch der
  Hauptprogrammcode zugreifen können.
],
ja: [
  組込みでないRustと異なり、通常、ヒープ領域を作成し、そのデータへの参照を新しく作成したスレッドに渡す、というような贅沢はできません。
  代わりに、割り込みハンドラはいつでも呼び出される可能性があり、使用する共有メモリにアクセスする方法を知っていなければなりません。
  最も低いレベルでは、 _静的に割り当てられた_
  ミュータブルなメモリを持つ必要があることを意味します。
  このメモリは、割り込みハンドラとメインコードの両方が参照できます。
],
zh: [
  不像非嵌入式Rust，我们通常不会奢侈地在堆上分配数据，并将对该数据的引用传递到新创建的线程中。相反，我们的中断处理函数随时可能被调用，且必须知道如何访问我们正在使用的共享内存。从最底层看来，这意味着我们必须有
  _静态分配的_ 可变的内存，中断处理函数和main代码都可以引用这块内存。
]))

#let ln_staticmut = link("https://doc.rust-lang.org/book/ch19-01-unsafe-rust.html#accessing-or-modifying-a-mutable-static-variable")[`static mut`]
#tr((
en: [
  In Rust, such #ln_staticmut
  variables are always unsafe to read or write, because without taking
  special care, you might trigger a race condition, where your access to
  the variable is interrupted halfway through by an interrupt which also
  accesses that variable.
],
de: [
  In Rust ist der Lese- oder Schreibzugriff auf solche
  #ln_staticmut;-Variablen
  stets als `unsafe` (unsicher) eingestuft. Ohne besondere
  Vorsichtsmaßnahmen könnte es nämlich zu einer sogenannten Race Condition
  (Wettlaufsituation) kommen: Der Zugriff auf die Variable wird mitten im
  Vorgang durch einen Interrupt unterbrochen, der seinerseits ebenfalls
  auf diese Variable zugreift.
],
ja: [
  Rustでは、このような#ln_staticmut;変数への読み書きは、常にアンセーフです。
  特別な注意を払わないと、レースコンディションを引き起こす可能性があります。
  つまり、その変数へのアクセスが、さらにその変数にアクセスする割り込みによって、中断されるということです。
],
zh: [
  在Rust中，#ln_staticmut;这样的变量读取或者写入总是unsafe的，因为不特别关注它们的话，可能会触发一个竞态条件，对变量的访问在中途就被一个也访问那个变量的中断打断了。
]))

#tr((
en: [
  For an example of how this behaviour can cause subtle errors in your
  code, consider an embedded program which counts rising edges of some
  input signal in each one-second period (a frequency counter):
],
de: [
  Um zu veranschaulichen, wie dieses Verhalten subtile Fehler in Ihrem
  Code verursachen kann, betrachten Sie ein eingebettetes Programm, das
  die steigenden Flanken eines Eingangssignals innerhalb jedes
  Ein-Sekunden-Intervalls zählt (einen Frequenzzähler):
],
ja: [
  この動作によって、コード内に分かりにくいエラーが発生する可能性があります。
  例えば、1秒毎に入力信号の立ち上がりエッジをカウントする組込みプログラム（周波数カウンタ）を考えてみましょう。
],
zh: [
  为了举例这种行为如何在代码中导致了微妙的错误，思考一个嵌入式程序，这个程序在每一秒的周期内计数一些输入信号的上升沿(一个频率计数器):
]))

#raw(block: true, lang: "rust",
"static mut COUNTER: u32 = 0;

#[entry]
fn main() -> ! {
    set_timer_1hz();
    let mut last_state = false;
    loop {
        let state = read_signal_level();
        if state && !last_state {
            // " + ts((
                en: "DANGER - Not actually safe! Could cause data races.",
                de: "GEFAHR – Nicht wirklich sicher! Koennte zu Datenwettlaeufen 
            //          fuehren.",
                ja: "危険。実際に安全ではありません。データ競合を引き起こす可能性があります。",
                zh: "危险 - 实际不安全! 可能导致数据竞争。",
              )) + "
            unsafe { COUNTER += 1 };
        }
        last_state = state;
    }
}

#[interrupt]
fn timer() {
    unsafe { COUNTER = 0; }
}
")

#tr((
en: [
  Each second, the timer interrupt sets the counter back to 0. Meanwhile,
  the main loop continually measures the signal, and incremements the
  counter when it sees a change from low to high. We've had to use
  `unsafe` to access `COUNTER`, as it's `static mut`, and that means we're
  promising the compiler we won't cause any undefined behaviour. Can you
  spot the race condition? The increment on `COUNTER` is _not_
  guaranteed to be atomic --- in fact, on most embedded platforms, it will
  be split into a load, then the increment, then a store. If the interrupt
  fired after the load but before the store, the reset back to 0 would be
  ignored after the interrupt returns --- and we would count twice as many
  transitions for that period.
],
de: [
  Sekündlich setzt der Timer-Interrupt den Zähler auf 0 zurück.
  Währenddessen misst die Hauptschleife kontinuierlich das Signal und
  erhöht den Zähler, sobald ein Wechsel von „Low" auf „High" erkannt wird.
  Wir mussten das Schlüsselwort `unsafe` verwenden, um auf `COUNTER`
  zuzugreifen, da es als `static mut` deklariert ist; damit versichern wir
  dem Compiler, dass wir kein undefiniertes Verhalten verursachen.
  Erkennst du die Race Condition? Die Inkrementierung von `COUNTER` ist
  _nicht_ garantiert atomar -- tatsächlich wird sie auf den meisten
  Embedded-Plattformen in die Schritte Laden, Inkrementieren und Speichern
  aufgeteilt. Würde der Interrupt nach dem Laden, aber vor dem Speichern
  ausgelöst, ginge das Zurücksetzen auf 0 nach der Rückkehr aus dem
  Interrupt verloren -- und wir würden für diesen Zeitraum doppelt so
  viele Signalwechsel zählen.
],
ja: [
  毎秒、タイマ割り込みはカウンタを0に戻します。同時に、メインループは信号を継続的に測定し、信号がローからハイに変わった時にカウンタをインクリメントします。
  `static mut`な`COUNTER`にアクセスするためには、`unsafe`を使う必要があります。
  これは、未定義動作を引き起こさないことを、コンパイラに約束するということです。
  レースコンディションがどこにあるかわかりますか？
  `COUNTER`のインクリメントは、アトミックであることが保証されて
  _いません_ 。
  実際、ほとんどの組込みプラットフォームにおいて、この操作は、ロードし、インクリメントし、ストアする、という動作に分割されます。
  割り込みがロードの後からストアの前に発生した場合、0に戻すリセットは、割り込みから復帰した後に無視されます。
  そして、その期間では、2倍の遷移をカウントすることになります。
],
zh: [
  每秒计时器中断会把计数器设置回0。这期间，main循环连续地测量信号，且当看到从低电平到高电平的变化时，增加计数器的值。因为它是`static mut`的，我们不得不使用`unsafe`去访问`COUNTER`，意思是我们向编译器保证我们的操作不会导致任何未定义的行为。你能发现竞态条件吗？`COUNTER`上的增加并不一定是原子的 -
  事实上，在大多数嵌入式平台上，它将被分开成一个读取操作，然后是增加，然后是写回。如果中断在计数器被读取之后但是在被写回之前被激活，在中断返回后，重置回0的操作会被忽略掉 - 那期间，我们会算出两倍的转换次数。
]))

== #tr((
  en: [Critical Sections],
  de: [Kritische Abschnitte],
  ja: [クリティカルセクション],
  zh: [临界区(Critical Sections)],
))

#tr((
en: [
  So, what can we do about data races? A simple approach is to use
  _critical sections_, a context where interrupts are disabled. By
  wrapping the access to `COUNTER` in `main` in a critical section, we can
  be sure the timer interrupt will not fire until we're finished
  incrementing `COUNTER`:
],
de: [
  Was können wir also gegen Data Races unternehmen? Ein einfacher Ansatz
  ist die Verwendung von _kritischen Abschnitten_ -- also Bereichen,
  in denen Interrupts deaktiviert sind. Indem wir den Zugriff auf
  `COUNTER` in der Funktion `main` in einen kritischen Abschnitt
  einbetten, stellen wir sicher, dass der Timer-Interrupt erst ausgelöst
  wird, nachdem wir das Inkrementieren von `COUNTER` abgeschlossen haben:
],
ja: [
  それでは、データ競合についてどうすれば良いのでしょうか。
  単純な方法は、割り込みが無効なコンテキストである
  _クリティカルセクション_ を使うことです。
  `main`中の`COUNTER`へのアクセスを、クリティカルセクションでラッピングします。
  そうすることで、`COUNTER`のインクリメントが完了するまで、タイマ割り込みが発生しないようにできます。
],
zh: [
  因此，关于数据竞争可以做些什么？一个简单的方法是使用
  _临界区(critical sections）_
  ，在临界区的上下文中中断被关闭了。通过把对`main`中的`COUNTER`访问封装进一个临界区，我们能确保计时器中断将不会激活，直到我们完成了增加`COUNTER`的操作:
]))

#raw(block: true, lang: "rust",
"static mut COUNTER: u32 = 0;

#[entry]
fn main() -> ! {
    set_timer_1hz();
    let mut last_state = false;
    loop {
        let state = read_signal_level();
        if state && !last_state {
            // " + ts((
                en: "New critical section ensures synchronised access to COUNTER",
                de: "Ein neuer kritischer Abschnitt gewaehrleistet den 
            // synchronisierten Zugriff auf COUNTER.",
                ja: "新しいクリティカルセクションは、COUNTERへの同期アクセスを保証します",
                zh: "新的临界区确保对COUNTER的同步访问",
              )) + "
            cortex_m::interrupt::free(|_| {
                unsafe { COUNTER += 1 };
            });
        }
        last_state = state;
    }
}

#[interrupt]
fn timer() {
    unsafe { COUNTER = 0; }
}
")

#tr((
en: [
  In this example, we use `cortex_m::interrupt::free`, but other platforms
  will have similar mechanisms for executing code in a critical section.
  This is also the same as disabling interrupts, running some code, and
  then re-enabling interrupts.
],
de: [
  In diesem Beispiel verwenden wir `cortex_m::interrupt::free`, doch auch
  andere Plattformen verfügen über ähnliche Mechanismen, um Code in einem
  kritischen Abschnitt auszuführen. Dies entspricht im Grunde dem
  Deaktivieren von Interrupts, der Ausführung von Code und dem
  anschließenden erneuten Aktivieren der Interrupts.
],
ja: [
  この例では`cortex_m::interrupt::free`を使いました。他のプラットフォームでもクリティカルセクションのコードを実行するための、類似の方法があります。
  これは、割り込みを無効にして、コードを実行し、再び割り込みを有効にすることと同じです。
],
zh: [
  在这个例子里，我们使用
  `cortex_m::interrupt::free`，但是其它平台将会有更简单的机制在一个临界区中执行代码。它们都有一样的逻辑，关闭中断，运行一些代码，然后重新使能中断。
]))

#tr((
en: [
  Note we didn't need to put a critical section inside the timer
  interrupt, for two reasons:
  - Writing 0 to `COUNTER` can't be affected by a race since we don't read it
  - It will never be interrupted by the `main` thread anyway
],
de: [
  Beachten Sie, dass wir innerhalb des Timer-Interrupts keinen kritischen
  Abschnitt benötigten; dies hat zwei Gründe:
  - Das Schreiben von 0 in `COUNTER` kann nicht von einer Race-Condition
    betroffen sein, da wir den Wert nicht lesen.
  - Es wird ohnehin niemals vom `main`-Thread unterbrochen werden.
],
ja: [
  タイマ割り込み内クリティカルセクションを置く必要がないことに注意して下さい。これは次の2つの理由からです。
  - 読み込みをしないため、`COUNTER`に0を書くことは、競合の影響を受けません
  - いずれにせよ、`main`スレッドによって割り込まれることはありえません
],
zh: [
  注意，有两个理由，不需要把一个临界区放进计时器中断中:
  - 向`COUNTER`写入0不会被一个竞争影响，因为我们不需要读取它
  - 无论如何，它永远不会被`main`线程中断
]))

#tr((
en: [
  If `COUNTER` was being shared by multiple interrupt handlers that might
  _preempt_ each other, then each one might require a critical
  section as well.
],
de: [
  Wenn `COUNTER` von mehreren Interrupt-Handlern gemeinsam genutzt würde,
  die sich gegenseitig _unterbrechen_ könnten, müsste jeder von ihnen
  ebenfalls einen kritischen Abschnitt verwenden.
],
ja: [
  `COUNTER`がお互いに _プリエンプション_
  する複数の割り込みハンドラから共有される場合、
  それぞれにクリティカルセクションが必要になるでしょう。
],
zh: [
  如果`COUNTER`被多个可能相互 _抢占_
  的中断处理函数共享，那么每一个也需要一个临界区。
]))

#tr((
en: [
  This solves our immediate problem, but we're still left writing a lot of
  unsafe code which we need to carefully reason about, and we might be
  using critical sections needlessly. Since each critical section
  temporarily pauses interrupt processing, there is an associated cost of
  some extra code size and higher interrupt latency and jitter (interrupts
  may take longer to be processed, and the time until they are processed
  will be more variable). Whether this is a problem depends on your
  system, but in general, we'd like to avoid it.
],
de: [
  Dies löst zwar unser unmittelbares Problem, doch wir müssen weiterhin
  viel unsicheren Code schreiben, dessen Verhalten wir sorgfältig
  analysieren müssen; zudem setzen wir möglicherweise unnötigerweise
  kritische Abschnitte ein. Da jeder kritische Abschnitt die
  Interrupt-Verarbeitung vorübergehend aussetzt, entstehen Kosten in Form
  von zusätzlichem Codeumfang sowie höherer Interrupt-Latenz und stärkerem
  Jitter (die Verarbeitung von Interrupts kann länger dauern, und die Zeit
  bis zur Verarbeitung schwankt stärker). Ob dies ein Problem darstellt,
  hängt vom jeweiligen System ab, doch im Allgemeinen sollten wir dies
  vermeiden.
],
ja: [
  クリティカルセクションは、当面の問題を解決しますが、慎重に検討しなければならない`unsafe`なコードをまだたくさん書いています。
  その結果、必要以上にクリティカルセクションを使用することになり、オーバーヘッドと割り込みレイテンシおよびジッタをもたらします。
],
zh: [
  这解决了我们眼前的问题，但是我们仍然要编写许多unsafe的代码，我们需要仔细推敲这些代码，有些我们可能不需要使用临界区。因为每个临界区暂时暂停了中断处理，就会带来一些相关的成本，一些额外的代码大小，更高的中断延迟和抖动(中断可能花费很长时间去处理，等待被处理的时间变化非常大)。这是否是个问题取决于你的系统，但是通常，我们想要避免它。
]))

#tr((
en: [
  It's worth noting that while a critical section guarantees no interrupts
  will fire, it does not provide an exclusivity guarantee on multi-core
  systems! The other core could be happily accessing the same memory as
  your core, even without interrupts. You will need stronger
  synchronisation primitives if you are using multiple cores.
],
de: [
  Es ist wichtig zu beachten: Auch wenn ein kritischer Abschnitt
  garantiert, dass keine Interrupts ausgelöst werden, bietet er auf
  Mehrkernsystemen keine Exklusivitätsgarantie! Der andere Rechenkern
  könnte -- selbst ohne Interrupts -- problemlos auf denselben Speicher
  zugreifen wie Ihr eigener Kern. Wenn Sie mehrere Rechenkerne nutzen,
  benötigen Sie daher leistungsfähigere Synchronisationsmechanismen.
],
ja: [
  注目すべき点は、クリティカルセクションでは、割り込みが発生しないことが保証されますが、
  マルチコアシステムでは、排他性の保証は提供されないことです。
  他のコアは、割り込みでなくても、とあるコアと同じメモリにアクセスできてしまいます。
  マルチコアを使う場合、より強力な同期プリミティブが必要になります。
],
zh: [
  值得注意的是，虽然一个临界区保障了不会发生中断，但是它在多核系统上不提供一个排他性保证(exclusivity
  guarantee)！其它核可能很开心地访问与你的核一样的内存区域，即使没有中断。如果你正在使用多核，你将需要更强的同步原语(synchronisation primitives)。
]))

== #tr((
  en: [Atomic Access],
  de: [Atomarer Zugriff],
  ja: [アトミックアクセス],
  zh: [原子访问],
))

#tr((
en: [
  On some platforms, special atomic instructions are available, which
  provide guarantees about read-modify-write operations. Specifically for
  Cortex-M: `thumbv6` (Cortex-M0, Cortex-M0+) only provide atomic load and
  store instructions, while `thumbv7` (Cortex-M3 and above) provide full
  Compare and Swap (CAS) instructions. These CAS instructions give an
  alternative to the heavy-handed disabling of all interrupts: we can
  attempt the increment, it will succeed most of the time, but if it was
  interrupted it will automatically retry the entire increment operation.
  These atomic operations are safe even across multiple cores.
],
de: [
  Auf einigen Plattformen stehen spezielle atomare Befehle zur Verfügung,
  die Garantien für Lese-Modifizier-Schreib-Operationen
  (Read-Modify-Write) bieten. Speziell für Cortex-M gilt: `thumbv6`
  (Cortex-M0, Cortex-M0+) bietet lediglich atomare Lade- und
  Speicherbefehle, während `thumbv7` (Cortex-M3 und höher) vollständige
  „Compare-and-Swap"-Befehle (CAS) bereitstellt. Diese CAS-Befehle bieten
  eine Alternative zur drastischen Maßnahme, sämtliche Interrupts zu
  deaktivieren: Man kann versuchen, den Inkrementierungsvorgang
  durchzuführen -- was meistens gelingt --, doch sollte eine Unterbrechung
  auftreten, wird der gesamte Vorgang automatisch erneut versucht. Diese
  atomaren Operationen sind auch in Mehrkernsystemen sicher.
],
ja: [
  プラットフォームによっては、アトミック命令が利用できます。アトミック命令は、リードモディファイライト操作の保証を提供します。
  特にCortex-Mの場合、`thumbv6`（Cortex-M0）はアトミック命令を提供しませんが、`thumbv7`（Cortex-M3以上）は提供します。
  これらの命令は、全ての割り込みを無効化する手荒な方法の代替手段を提供します。
  インクリメントを試みる時、ほとんどの場合は成功しますが、割り込まれた場合はインクリメント操作全体を自動的にやり直します。
  このようなアトミック操作は、複数のコアにまたがっても安全です。
],
zh: [
  在一些平台上，可以使用特定的原子指令，它保障了读取-修改-写回操作。针对Cortex-M:
  `thumbv6`\(Cortex-M0，Cortex-M0+)只提供原子读取和存取指令，而`thumv7`\(Cortex-M3及以上)提供完整的比较和交换(CAS)指令。这些CAS指令可以替代过重的禁用所有中断的方法:
  我们可以尝试执行加法操作，它在大多数情况下都会成功，但是如果它被中断了它将会自动重试完整的加法操作。这些原子操作甚至在多核间也是安全的。
]))

#raw(block: true, lang: "rust",
"use core::sync::atomic::{AtomicUsize, Ordering};

static COUNTER: AtomicUsize = AtomicUsize::new(0);

#[entry]
fn main() -> ! {
    set_timer_1hz();
    let mut last_state = false;
    loop {
        let state = read_signal_level();
        if state && !last_state {
            // " + ts((
                en: "Use `fetch_add` to atomically add 1 to COUNTER",
                de: "Verwenden Sie `fetch_add`, um 1 atomar zu COUNTER zu addieren.",
                ja: "自動的にCOUNTERに1を加えるために`fetch_add`を使います",
                zh: "使用 `fetch_add` 原子性地给 COUNTER 加一",
              )) + "
            COUNTER.fetch_add(1, Ordering::Relaxed);
        }
        last_state = state;
    }
}

#[interrupt]
fn timer() {
    // " + ts((
          en: "Use `store` to write 0 directly to COUNTER",
          de: "Verwenden Sie `store`, um 0 direkt in COUNTER zu schreiben.",
          ja: "COUNTERに直接0を書くために`store`を使います",
          zh: "使用 `store` 将 0 直接写入 COUNTER",
        )) + "
    COUNTER.store(0, Ordering::Relaxed)
}
")

#tr((
en: [
  This time `COUNTER` is a safe `static` variable. Thanks to the
  `AtomicUsize` type `COUNTER` can be safely modified from both the
  interrupt handler and the main thread without disabling interrupts. When
  possible, this is a better solution --- but it may not be supported on
  your platform.
],
de: [
  Diesmal ist `COUNTER` eine sichere `static`-Variable. Dank des Typs
  `AtomicUsize` kann `COUNTER` sowohl vom Interrupt-Handler als auch vom
  Hauptthread aus sicher geändert werden, ohne Interrupts zu deaktivieren.
  Wenn möglich, ist dies die bessere Lösung -- wird aber möglicherweise
  von Ihrer Plattform nicht unterstützt.
],
ja: [
  ここで、`COUNTER`は安全な`static`変数です。`AtomicUsize`のおかげで`COUNTER`の型は、割り込みを無効化することなく、
  割り込みハンドラとメインスレッドの両方から安全に修正できます。
  可能であれば、これはより良い解決方法です。しかし、あなたのプラットフォームではサポートされていないかもしれません。
],
zh: [
  这时，`COUNTER`是一个safe的`static`变量。多亏了`AtomicUsize`类型，不需要禁用中断，`COUNTER`能从中断处理函数和main线程被安全地修改。当可以这么做时，这是一个更好的解决方案 - 然而平台上可能不支持这么做。
]))

#let ln_ordering = link("https://doc.rust-lang.org/core/sync/atomic/enum.Ordering.html")[`Ordering`]
#tr((
en: [
  A note on #ln_ordering:
  this affects how the compiler and hardware may reorder instructions, and
  also has consequences on cache visibility. Assuming that the target is a
  single core platform `Relaxed` is sufficient and the most efficient
  choice in this particular case. Stricter ordering will cause the
  compiler to emit memory barriers around the atomic operations; depending
  on what you're using atomics for you may or may not need this! The
  precise details of the atomic model are complicated and best described
  elsewhere.
],
de: [
  Hinweis zur #ln_ordering:
  Diese beeinflusst, wie Compiler und Hardware Anweisungen neu anordnen,
  und hat auch Auswirkungen auf die Cache-Sichtbarkeit. Bei einer
  Einkernplattform ist die Option `Relaxed` ausreichend und in diesem Fall
  die effizienteste Wahl. Eine strengere Befehlsreihenfolge führt dazu,
  dass der Compiler Speicherbarrieren um die atomaren Operationen erzeugt.
  Je nachdem, wofür Sie atomare Operationen verwenden, benötigen Sie dies
  möglicherweise nicht. Die genauen Details des atomaren Modells sind
  komplex und werden am besten an anderer Stelle beschrieben.
],
ja: [
  #link("https://doc.rust-lang.org/core/sync/atomic/enum.Ordering.html")[`Ordering`]の注釈：これは、コンパイラとハードウェアがどのように命令の順番を入れ替えるか、に影響を与えます。
  また、キャッシュの可視性にも影響します。ターゲットがシングルコアプラットフォームだと仮定すると、`Relaxed`で十分であり、このケースでは最も効率の良い選択です。
  より厳密なオーダリングでは、コンパイラはアトミック操作の前後にメモリバリアを発行します。
  使用するアトミック操作によって、必要かもしれませんし、必要でないかもしれません！
  アトミックモデルの正確な詳細は複雑であり、他の文書内でしっかりと説明されています。
],
zh: [
  关于#ln_ordering;的提醒:
  它可能影响编译器和硬件如何重新排序指令，也会影响缓存可见性。假设目标是个单核平台，在这个案例里`Relaxed`是充足的和最有效的选择。更严格的排序将导致编译器在原子操作周围产生内存屏障(Memory
  Barriers)；取决于你做什么原子操作，你可能需要或者不需要这个排序！原子模型的精确细节是复杂的，最好写在其它地方。
]))

#let url_atomics = "https://doc.rust-lang.org/nomicon/atomics.html"
#tr((
en: [
  For more details on atomics and ordering, see the
  #link(url_atomics)[nomicon].
],
de: [
  Weitere Informationen zu atomaren Operationen und deren Reihenfolge
  finden Sie im #link(url_atomics)[nomicon].
],
ja: [
  詳細は、#link(url_atomics)[ノミコン]のアトミックとオーダリングを参照して下さい。
],
zh: [
  关于原子操作和排序的更多细节，可以看这里#link(url_atomics)[nomicon]。
]))

== #tr((
  en: [Abstractions, Send, and Sync],
  de: [Abstraktionen, Send und Sync],
  ja: [抽象化、SendとSync],
  zh: [抽象，Send和Sync],
))

#tr((
en: [
  None of the above solutions are especially satisfactory. They require
  `unsafe` blocks which must be very carefully checked and are not
  ergonomic. Surely we can do better in Rust!
],
de: [
  Keine der oben genannten Lösungen ist wirklich zufriedenstellend. Sie
  erfordern unsichere Blöcke, die sehr sorgfältig geprüft werden müssen
  und nicht ergonomisch sind. In Rust geht das doch bestimmt besser!
],
ja: [
  上記の解決方法のいずれも、これと言って満足いくものではありません。
  どの解決方法も`unsafe`ブロックを必要とし、非常に注意深くチェックしなければならず、人間工学的ではありません。
  Rustではもっとうまくやれるはずです！
],
zh: [
  上面的解决方案都不是特别令人满意。它们需要`unsafe`块，`unsafe`块必须要被十分小心地检查且不符合人体工程学。确实，我们在Rust中可以做得更好！
]))

#tr((
en: [
  We can abstract our counter into a safe interface which can be safely
  used anywhere else in our code. For this example, we'll use the
  critical-section counter, but you could do something very similar with
  atomics.
],
de: [
  Wir können unseren Zähler in eine sichere Schnittstelle abstrahieren,
  die überall im Code sicher verwendet werden kann. In diesem Beispiel
  verwenden wir den Zähler für kritische Abschnitte, aber mit atomaren
  Operationen ließe sich etwas sehr Ähnliches realisieren.
],
ja: [
  カウンタを、コード内のどこからでも安全に使えるインタフェースに抽象化することができます。
  次の例では、クリティカルセクションカウンタを使いますが、アトミックと非常に良く似たことが実現できます。
],
zh: [
  我们可以把我们的计数器抽象进一个安全的接口中，它可以在代码的其它地方被安全地使用。在这个例子里，我们将使用临界区的(cirtical-section)计数器，但是你可以用原子操作做一些非常类似的事情。
]))

#raw(block: true, lang: "rust",
"use core::cell::UnsafeCell;
use cortex_m::interrupt;

// " + ts((
    en: "Our counter is just a wrapper around UnsafeCell<u32>, which is the heart
// of interior mutability in Rust. By using interior mutability, we can have
// COUNTER be `static` instead of `static mut`, but still able to mutate
// its counter value.",
    de: "Unser Zaehler ist lediglich ein Wrapper um `UnsafeCell<u32>`, das Herzstueck 
// der „Interior Mutability“ in Rust. Dank dieses Konzepts können wir `COUNTER` 
// als `static` statt als `static mut` definieren und dennoch den Zaehlerwert 
// veraendern.",
    ja: "カウンタはUnsafeCell<u32>の単なるラッパです。UnsafeCellはRustの内部可変性の重要要素です。
// 内部可変性を使用することで、COUNTERを`static mut`の代わりに`static`として持つことができます。
// しかし、依然として、カウンタの値は変更することができます。",
    zh: "我们的计数器只是包围UnsafeCell<u32>的一个封装，它是Rust中内部可变性
// (interior mutability)的关键。通过使用内部可变性，我们能让COUNTER
// 变成`static`而不是`static mut`，但是仍能改变它的计数器值。"
  )) + "
struct CSCounter(UnsafeCell<u32>);

const CS_COUNTER_INIT: CSCounter = CSCounter(UnsafeCell::new(0));

impl CSCounter {
    pub fn reset(&self, _cs: &interrupt::CriticalSection) {
        // " + ts((
            en: "By requiring a CriticalSection be passed in, we know we must
        // be operating inside a CriticalSection, and so can confidently
        // use this unsafe block (required to call UnsafeCell::get).",
            de: "Indem wir die Uebergabe einer `CriticalSection` voraussetzen, wissen 
        // wir, dass wir uns innerhalb einer `CriticalSection` befinden; daher 
        // koennen wir bedenkenlos diesen `unsafe`-Block verwenden (der für den 
        // Aufruf von `UnsafeCell::get` erforderlich ist).",
            ja: "クリティカルセクションを引数として要求することで、クリティカルセクション内で
        // 実行されなければならないことがわかります。そのため、このアンセーフブロックを
        // 自信を持って使用できます（UnsafeCell::getの呼び出しに必要です）。",
            zh: "通过要求一个CriticalSection被传递进来，我们知道我们肯定正在一个
        // CriticalSection中操作，且因此可以自信地使用这个unsafe块(调用UnsafeCell::get的前提)。",
          )) + "
        unsafe { *self.0.get() = 0 };
    }

    pub fn increment(&self, _cs: &interrupt::CriticalSection) {
        unsafe { *self.0.get() += 1 };
    }
}

// " + ts((
    en: "Required to allow static CSCounter. See explanation below.",
    de: "Erforderlich, um ein statisches CSCounter zu ermoeglichen. Siehe Erlaeuterung 
// unten.",
    ja: "静的なCSCounterを許可するために必要です。以下の説明を参照して下さい。",
    zh: "允许静态CSCounter的前提。看下面的解释。"
  )) + "
unsafe impl Sync for CSCounter {}

// " + ts((
    en: "COUNTER is no longer `mut` as it uses interior mutability;
// therefore it also no longer requires unsafe blocks to access.",
    de: "COUNTER ist nicht mehr `mut`, da es „Interior Mutability“ verwendet; daher 
// sind fuer den Zugriff auch keine `unsafe`-Bloecke mehr erforderlich.",
    ja: "内部可変性を使用するため、COUNTERは、もはや`mut`ではありません。
// 従って、アクセスの際に、アンセーフなブロックも必要なくなりました。",
    zh: "COUNTER不再是`mut`的因为它使用内部可变性;
// 因此访问它也不再需要unsafe块。"
  )) + "
static COUNTER: CSCounter = CS_COUNTER_INIT;

#[entry]
fn main() -> ! {
    set_timer_1hz();
    let mut last_state = false;
    loop {
        let state = read_signal_level();
        if state && !last_state {
            // " + ts((
                en: "No unsafe here!",
                ja: "アンセーフはここでは必要ありません！",
                zh: "这里不用unsafe!",
              )) + "
            interrupt::free(|cs| COUNTER.increment(cs));
        }
        last_state = state;
    }
}

#[interrupt]
fn timer() {
    // " + ts((
        en: "We do need to enter a critical section here just to obtain a valid
    // cs token, even though we know no other interrupt could pre-empt
    // this one.",
        de: "Wir muessen hier tatsaechlich einen kritischen Abschnitt betreten, nur um 
    // ein gueltiges CS-Token zu erhalten, auch wenn wir wissen, dass kein 
    // anderer Interrupt diesen unterbrechen koennte.",
        ja: "有効なcsトークンを得るため、ここでクリティカルセクションに入る必要があります。
    // 他の割り込みがプリエンプションを起こさないと分かっていても必要です。",
        zh: "这里我们需要进入一个临界区，只是为了传递进一个有效的cs token，尽管我们知道
    // 没有其它中断可以抢占这个中断。"
      )) + "
    interrupt::free(|cs| COUNTER.reset(cs));

    // " + ts((
        en: "We could use unsafe code to generate a fake CriticalSection if we
    // really wanted to, avoiding the overhead:",
        de: "Wir koennten „unsicheren“ Code (unsafe code) verwenden, um eine 
    // gefaelschte CriticalSection zu erzeugen, falls wir das wirklich wollten, 
    // und so den Overhead vermeiden:",
        ja: "オーバーヘッドを避けるために、本当に必要であれば、偽のクリティカルセクションを生成する
    // アンセーフなコードを使うことができます。",
        zh: "如果我们真的需要，我们可以使用unsafe代码去生成一个假CriticalSection，
    // 避免开销:"
      )) + "
    // let cs = unsafe { interrupt::CriticalSection::new() };
}
")

#tr((
en: [
  We've moved our `unsafe` code to inside our carefully-planned
  abstraction, and now our application code does not contain any `unsafe`
  blocks.
],
de: [
  Wir haben unseren `unsafe`-Code in unsere sorgfältig entworfene
  Abstraktion verlagert; nun enthält unser Anwendungscode keine
  `unsafe`-Blöcke mehr.
],
ja: [
  `unsafe`コードを慎重に検討された抽象の内側に移動しました。
  そして、アプリケーションコードは、`unsafe`ブロックを含んでいません。
],
zh: [
  我们已经把我们的`unsafe`代码移进了精心安排的抽象中，现在我们的应用代码不包含任何`unsafe`块。
]))

#tr((
en: [
  This design requires that the application pass a `CriticalSection` token
  in: these tokens are only safely generated by `interrupt::free`, so by
  requiring one be passed in, we ensure we are operating inside a critical
  section, without having to actually do the lock ourselves. This
  guarantee is provided statically by the compiler: there won't be any
  runtime overhead associated with `cs`. If we had multiple counters, they
  could all be given the same `cs`, without requiring multiple nested
  critical sections.
],
de: [
  Dieser Entwurf setzt voraus, dass die Anwendung ein
  `CriticalSection`-Token übergibt: Da diese Tokens nur sicher durch
  `interrupt::free` erzeugt werden können, stellen wir durch die
  Anforderung eines solchen Tokens sicher, dass wir uns innerhalb eines
  kritischen Abschnitts befinden, ohne die Sperre selbst implementieren zu
  müssen. Diese Garantie wird statisch vom Compiler gewährleistet; es
  entsteht also kein Laufzeit-Overhead durch `cs`. Hätten wir mehrere
  Zähler, könnten diese alle dasselbe `cs` verwenden, ohne dass mehrere
  verschachtelte kritische Abschnitte erforderlich wären.
],
ja: [
  この設計は、アプリケーションが`CriticalSection`トークンを渡すことを要求します。
  トークンは、`interrupt::free`によってのみ、安全に生成することができます。
  そのため、このトークンが渡されることを要求することで、自分自身でロックを実際にかけることなしに、クリティカルセクション内で動作していることを保証します。
  この保証は、静的にコンパイラによって提供されます。`cs`による実行時のオーバーヘッドはありません。
  カウンタが複数ある場合、複数の入れ子になったクリティカルセクションなしに、同じ`cs`を与えることができます。
],
zh: [
  这个设计要求应用传递一个`CriticalSection` token进来:
  这些tokens仅由`interrupt::free`安全地产生，因此通过要求传递进一个`CriticalSection`
  token，我们确保我们正在一个临界区中操作，不用自己动手锁起来。这个保障由编译器静态地提供:
  这将不会带来任何与`cs`有关的运行时消耗。如果我们有多个计数器，它们都可以被指定同一个`cs`，而不用要求多个嵌套的临界区。
]))

#let url_sendsync = "https://doc.rust-lang.org/nomicon/send-and-sync.html"
#tr((
en: [
  This also brings up an important topic for concurrency in Rust: the
  #link(url_sendsync)[`Send` and `Sync`]
  traits. To summarise the Rust book, a type is Send when it can safely be
  moved to another thread, while it is Sync when it can be safely shared
  between multiple threads. In an embedded context, we consider interrupts
  to be executing in a separate thread to the application code, so
  variables accessed by both an interrupt and the main code must be Sync.
],
de: [
  Dies führt zu einem wichtigen Thema der Nebenläufigkeit in Rust: den
  Traits
  #link(url_sendsync)[`Send` und `Sync`].
  Um das „Rust Book" zusammenzufassen: Ein Typ ist `Send`, wenn er sicher
  in einen anderen Thread verschoben werden kann, während er `Sync` ist,
  wenn er sicher zwischen mehreren Threads geteilt werden kann. Im
  Embedded-Kontext betrachten wir Interrupts als Prozesse, die in einem
  vom Anwendungscode getrennten Thread ausgeführt werden; daher müssen
  Variablen, auf die sowohl ein Interrupt als auch der Hauptcode zugreift,
  `Sync` implementieren.
],
ja: [
  これは、Rustの並行性についても重要なトピックを提起します。#link(url_sendsync)[`Send`と`Sync`]トレイトです。
  the Rust
  bookを要約すると、安全に別のスレッドに移動できるとき、型はSendです。
  一方、複数のスレッド間で安全に共有できるとき、型はSyncです。
  組込みでは、割り込みがアプリケーションコードとは異なるスレッドで動作すると考えます。
  そのため、割り込みとメインコードとの両方からアクセスされる変数は、Syncでなければなりません。
],
zh: [
  这也带来了Rust中关于并发的一个重要主题:
  #link(url_sendsync)[`Send` and `Sync`]
  traits。总结一下Rust
  book，当一个类型能够安全地被移动到另一个线程，它是Send，当一个类型能被安全地在多个线程间共享的时候，它是Sync。在一个嵌入式上下文中，我们认为中断是在应用代码的一个独立线程中执行的，因此在一个中断和main代码中都能被访问的变量必须是Sync。
]))

#let ln_unsafecell = link("https://doc.rust-lang.org/core/cell/struct.UnsafeCell.html")[`UnsafeCell`]
#tr((
en: [
  For most types in Rust, both of these traits are automatically derived
  for you by the compiler. However, because `CSCounter` contains an #ln_unsafecell,
  it is not Sync, and therefore we could not make a `static CSCounter`:
  `static` variables _must_ be Sync, since they can be accessed by
  multiple threads.
],
de: [
  Für die meisten Typen in Rust werden diese beiden Traits automatisch vom
  Compiler für dich abgeleitet. Da `CSCounter` jedoch eine #ln_unsafecell
  enthält, ist der Typ nicht `Sync`\; folglich konnten wir keinen
  `static CSCounter` definieren, denn `static`-Variablen _müssen_
  `Sync` sein, da von mehreren Threads aus auf sie zugegriffen werden kann.
],
ja: [
  Rustのほとんどの型では、コンパイラによってSendとSyncの両方のトレイトが自動的に継承されます。
  しかし、`CSCounter`は#ln_unsafecell;を含んでいるため、Syncではありません。
  従って、`static CSCounter`を作ることはできません。`static`変数は、複数のスレッドからアクセスされるため、Syncでなければなりません。
],
zh: [
  在Rust中的大多数类型，这两个traits都会由你的编译器为你自动地产生。然而，因为`CSCounter`包含了一个#ln_unsafecell，它不是Sync，因此我们不能使用一个`static CSCounter`:
  `static` 变量 _必须_ 是Sync，因此它们能被多个线程访问。
]))

#tr((
en: [
  To tell the compiler we have taken care that the `CSCounter` is in fact
  safe to share between threads, we implement the Sync trait explicitly.
  As with the previous use of critical sections, this is only safe on
  single-core platforms: with multiple cores, you would need to go to
  greater lengths to ensure safety.
],
de: [
  Um dem Compiler mitzuteilen, dass wir sichergestellt haben, dass der
  `CSCounter` tatsächlich gefahrlos zwischen Threads geteilt werden kann,
  implementieren wir das `Sync`-Trait explizit. Wie schon bei der früheren
  Verwendung kritischer Abschnitte ist dies nur auf
  Single-Core-Plattformen sicher; bei mehreren Kernen wäre ein deutlich
  höherer Aufwand erforderlich, um die Sicherheit zu gewährleisten.
],
ja: [
  `CSCounter`が実はスレッド間で共有しても安全なように処理していることを、コンパイラに伝えるため、Syncトレイトを明示的に実装します。
  これまでのクリティカルセクションの使用と同様に、シングルコアのプラットフォームでのみ安全です。
  マルチコアのプラットフォームでは、安全性を確保するためにさらなる取り組みが必要です。
],
zh: [
  为了告诉编译器我们已经注意到`CSCounter`事实上在线程间共享是安全的，我们显式地实现了Sync
  trait。与之前使用的临界区一样，这只在单核平台上是安全的:
  对于多核，你需要做更多的事来确保安全。
]))

== #tr((
  en: [Mutexes],
  de: [Mutexe],
  ja: [ミューテックス],
  zh: [互斥量(Mutexs)],
))

#tr((
en: [
  We've created a useful abstraction specific to our counter problem, but
  there are many common abstractions used for concurrency.
],
de: [
  Wir haben eine nützliche, speziell auf unser Zählerproblem
  zugeschnittene Abstraktion entwickelt; es gibt jedoch viele gängige
  Abstraktionen für Nebenläufigkeit.
],
ja: [
  カウンタの問題に特有の便利な抽象化を行いましたが、並行性のために利用されるいくつかの抽象化が存在します。
],
zh: [
  我们已经为我们的计数器问题创造了一个有用的抽象，但是关于并发这里还存在许多通用的抽象。
]))

#let ln_drop = link("https://doc.rust-lang.org/core/ops/trait.Drop.html")[`Drop`]
#tr((
en: [
  One such _synchronisation primitive_ is a mutex, short for mutual
  exclusion. These constructs ensure exclusive access to a variable, such
  as our counter. A thread can attempt to _lock_ (or _acquire_)
  the mutex, and either succeeds immediately, or blocks waiting for the
  lock to be acquired, or returns an error that the mutex could not be
  locked. While that thread holds the lock, it is granted access to the
  protected data. When the thread is done, it _unlocks_ (or
  _releases_) the mutex, allowing another thread to lock it. In Rust,
  we would usually implement the unlock using the #ln_drop
  trait to ensure it is always released when the mutex goes out of scope.
],
de: [
  Ein solches _Synchronisationsprimitiv_ ist der Mutex (kurz für
  „mutual exclusion", also gegenseitiger Ausschluss). Diese Konstrukte
  gewährleisten den exklusiven Zugriff auf eine Variable, wie etwa unseren
  Zähler. Ein Thread kann versuchen, den Mutex zu _sperren_ (oder zu
  _erwerben_); dabei ist er entweder sofort erfolgreich, blockiert,
  bis die Sperre verfügbar ist, oder erhält eine Fehlermeldung, dass der
  Mutex nicht gesperrt werden konnte. Solange der Thread die Sperre hält,
  hat er Zugriff auf die geschützten Daten. Ist der Thread fertig,
  _entsperrt_ (oder _gibt_) er den Mutex _frei_, sodass ein
  anderer Thread ihn sperren kann. In Rust würden wir die Freigabe
  üblicherweise mithilfe des
  #ln_drop;-Traits
  implementieren; so ist sichergestellt, dass der Mutex immer freigegeben
  wird, sobald er den Gültigkeitsbereich (Scope) verlässt.
],
ja: [
  そのような _同期プリミティブ_
  の1つはミューテックス（mutex）です。mutexはmutual exclusionの略です。
  ミューテックスは、私達のカウンタのような変数への排他アクセスを保証します。
  あるスレッドは、ミューテックスの _ロック_（または
  _獲得_）を試みます。
  すると、すぐに成功するか、ロックが獲得されるのを待ってブロックするか、ミューテックスをロックできなかったエラーを返します。
  そのスレッドがロックを保持している間、保護されたデータへのアクセスが許可されます。
  そのスレッドが実行を完了すると、ミューテックスを
  _アンロック_（または
  _解放_）することで、他のスレッドがミューテックスをロックできるようにします。
  Rustでは、通常、アンロックを実装するために#ln_drop;トレイトを使用します。
  これは、ミューテックスがスコープの外に到達すると、常に解放されることを保証するためです。
],
zh: [
  一个互斥量(mutex)，互斥(mutual exclusion)的缩写，就是这样的一个
  _同步原语_
  。这些构造确保了对一个变量的排他访问，比如我们的计数器。一个线程会尝试
  _lock_ (或者 _acquire_)
  互斥量，或者当互斥量不能被锁住时返回一个错误。当线程持有锁时，它有权访问被保护的数据，当线程工作完成了，它
  _unlocks_ (或者 _releases_)
  互斥量，允许其它线程锁住它。在Rust中，我们通常使用#ln_drop
  trait实现unlock去确保当互斥量超出作用域时它总是被释放。
]))

#tr((
en: [
  Using a mutex with interrupt handlers can be tricky: it is not normally
  acceptable for the interrupt handler to block, and it would be
  especially disastrous for it to block waiting for the main thread to
  release a lock, since we would then _deadlock_ (the main thread
  will never release the lock because execution stays in the interrupt
  handler). Deadlocking is not considered unsafe: it is possible even in
  safe Rust.
],
de: [
  Die Verwendung eines Mutex in Interrupt-Handlern kann tückisch sein:
  Normalerweise darf ein Interrupt-Handler nicht blockieren. Besonders
  fatal wäre es, wenn er blockieren würde, während er darauf wartet, dass
  der Haupt-Thread eine Sperre (Lock) freigibt, da dies zu einem
  _Deadlock_ führen würde (der Haupt-Thread würde die Sperre niemals
  freigeben, da die Ausführung im Interrupt-Handler verbleibt). Ein
  Deadlock gilt nicht als „unsicher" (unsafe): Er ist selbst in sicherem
  Rust möglich.
],
ja: [
  割り込みハンドラでミューテックスを使用するのはトリッキーです。割り込みハンドラ内でブロックすることは、通常、好ましくありません。
  割り込みハンドラ内で、メインスレッドがロックを解放するのを待ってブロックすると、特に悲惨です。
  なぜならば。_デッドロック_
  になるからです。（割り込みハンドラ内に実行がとどまるため、メインスレッドがロックを解放することは決してありません）
  デッドロックはアンセーフとは考えられていません。安全なRustでも発生する可能性があります。
],
zh: [
  将中断处理函数与一个互斥量一起使用可能有点棘手:
  阻塞中断处理函数通常是不可接受的，如果它阻塞等待main线程去释放一个锁，那将是一场灾难。因为我们会
  _死锁_
  (因为执行停留在中断处理函数中，主线程将永远不会释放锁)。死锁被认为是不安全的:
  即使在安全的Rust中这也是可能发生的。
]))

#tr((
en: [
  To avoid this behaviour entirely, we could implement a mutex which
  requires a critical section to lock, just like our counter example. So
  long as the critical section must last as long as the lock, we can be
  sure we have exclusive access to the wrapped variable without even
  needing to track the lock/unlock state of the mutex.
],
de: [
  Um dieses Verhalten vollständig zu vermeiden, könnten wir einen Mutex
  implementieren, der für das Sperren eine kritische Sektion erfordert --
  genau wie in unserem Zähler-Beispiel. Solange die Dauer der kritischen
  Sektion der Dauer der Sperre entspricht, ist sichergestellt, dass wir
  exklusiven Zugriff auf die gekapselte Variable haben, ohne den
  Sperrstatus des Mutex explizit nachverfolgen zu müssen.
],
ja: [
  この動作を完全に避けるため、カウンタの例で示すように、ロックのためにクリティカルセクションを必要とするミューテックスを実装できます。
  クリティカルセクションがロックしている間続く限り、ミューテックスのロック/アンロックの状態を追跡することなしに、
  ラップされた変数に排他的にアクセスできます。
],
zh: [
  为了完全避免这个行为，我们可以实现一个要求临界区的互斥量去锁住，就像我们的计数器例子一样。临界区的存在时间必须和锁存在的时间一样长，我们能确保我们对被封装的变量有排他式访问，甚至不需要跟踪互斥量的
  lock/unlock 状态。
]))

#tr((
en: [
  This is in fact done for us in the `cortex_m` crate! We could have
  written our counter using it:
],
de: [
  Genau dies wird uns bereits durch die `cortex_m`-Crate abgenommen! Wir
  hätten unseren Zähler auch unter Verwendung dieser Crate implementieren können:
],
ja: [
  これは実際に`cortex_m`クレートで行われています！ それを使ってカウンタを書くことができます。
],
zh: [
  实际上我们在 `cortex_m` crate中就是这么做的！我们可以用它来写入我们的计数器:
]))

#raw(block: true, lang: "rust",
"use core::cell::Cell;
use cortex_m::interrupt::Mutex;

static COUNTER: Mutex<Cell<u32>> = Mutex::new(Cell::new(0));

#[entry]
fn main() -> ! {
    set_timer_1hz();
    let mut last_state = false;
    loop {
        let state = read_signal_level();
        if state && !last_state {
            interrupt::free(|cs|
                COUNTER.borrow(cs).set(COUNTER.borrow(cs).get() + 1));
        }
        last_state = state;
    }
}

#[interrupt]
fn timer() {
    // " + ts((
        en: "We still need to enter a critical section here to satisfy the Mutex.",
        de: "Wir muessen hier noch einen kritischen Abschnitt betreten, um die 
    // Mutex-Bedingung zu erfuellen.",
        ja: "ミューテックスを満たすために、ここでもクリティカルセクションに入る必要があります。",
        zh: "这里我们仍然需要进入一个临界区去满足互斥量。",
      )) + "
    interrupt::free(|cs| COUNTER.borrow(cs).set(0));
}
")

#let ln_cell = link("https://doc.rust-lang.org/core/cell/struct.Cell.html")[`Cell`]
#tr((
en: [
  We're now using #ln_cell,
  which along with its sibling `RefCell` is used to provide safe interior
  mutability. We've already seen `UnsafeCell` which is the bottom layer of
  interior mutability in Rust: it allows you to obtain multiple mutable
  references to its value, but only with unsafe code. A `Cell` is like an
  `UnsafeCell` but it provides a safe interface: it only permits taking a
  copy of the current value or replacing it, not taking a reference, and
  since it is not Sync, it cannot be shared between threads. These
  constraints mean it's safe to use, but we couldn't use it directly in a
  `static` variable as a `static` must be Sync.
],
de: [
  Wir verwenden nun #ln_cell;;
  dieses bietet -- ebenso wie sein Pendant `RefCell` -- eine sichere Form
  der „Interior Mutability" (internen Veränderbarkeit). Wir haben bereits
  `UnsafeCell` kennengelernt, die unterste Ebene der internen
  Veränderbarkeit in Rust: Sie ermöglicht es, mehrere veränderbare
  Referenzen auf den enthaltenen Wert zu erhalten, allerdings nur mittels
  `unsafe`-Code. Eine `Cell` ähnelt einer `UnsafeCell`, stellt jedoch eine
  sichere Schnittstelle bereit: Sie erlaubt lediglich das Kopieren des
  aktuellen Werts oder dessen Austausch, nicht jedoch den Zugriff über
  eine Referenz; zudem ist sie nicht `Sync` und kann daher nicht zwischen
  Threads geteilt werden. Aufgrund dieser Einschränkungen ist ihre
  Verwendung sicher, allerdings lässt sie sich nicht direkt in einer
  `static`-Variablen einsetzen, da `static`-Elemente die Eigenschaft
  `Sync` erfüllen müssen.
],
ja: [
  今回は#ln_cell;を使っています。これは、`RefCell`の同類で安全な内部可変性を提供するために使用されます。
  既に、`UnsafeCell`が、Rustの内部可変性の最下層であることを見てきました。
  UnsafeCellは、値への複数のミュータブル参照の取得を可能としますが、アンセーフなコードでのみ使用できます。
  `Cell`は`UnsafeCell`と似ていますが、安全なインタフェースを提供します。
  Cellは参照を取得せず、現在値のコピーを取得するか、置き換えることだけを許可します。
  CellはSyncでないため、スレッド間で共有できません。
  これらの制約は安全に使えることを意味しますが、`static`変数として直接使用できません。`static`はSyncである必要があるからです。
],
zh: [
  我们现在使用了#ln_cell，它与它的兄弟`RefCell`一起被用于提供safe的内部可变性。我们已经见过`UnsafeCell`了，在Rust中它是内部可变性的底层:
  它允许你去获得对某个值的多个可变引用，但是只能与不安全的代码一起工作。一个`Cell`像一个`UnsafeCell`一样但是它提供了一个安全的接口:
  它只允许拷贝现在的值或者替换它，不允许获取一个引用，因此它不是Sync，它不能被在线程间共享。这些限制意味着它用起来是safe的，但是我们不能直接将它用于`static`变量因为一个`static`必须是Sync。
]))

#tr((
en: [
  So why does the example above work? The `Mutex<T>` implements Sync for
  any `T` which is Send --- such as a `Cell`. It can do this safely
  because it only gives access to its contents during a critical section.
  We're therefore able to get a safe counter with no unsafe code at all!
],
de: [
  Warum funktioniert das obige Beispiel? Der `Mutex<T>` implementiert
  `Sync` für jedes `T`, das `Send` ist -- wie beispielsweise eine `Cell`.
  Dies ist sicher möglich, da der Zugriff auf den Inhalt nur während eines
  kritischen Abschnitts gewährt wird. Dadurch erhalten wir einen sicheren
  Zähler ohne jeglichen unsicheren Code!
],
ja: [
  では、なぜ上記の例はうまく動くのでしょうか？`Mutex<T>`は、`Cell`のようなSendな`T`に対してSyncを実装します。
  このことが、Cellをstaticで使うことを安全にします。なぜなら、クリティカルセクションの間だけ、その中身へのアクセスを提供するからです。
  従って、全くアンセーフなコードなしに、安全なカウンタを手に入れることができます。
],
zh: [
  因此为什么上面的例子可以工作?`Mutex<T>`对于任何是Send的`T`实现了Sync -
  比如一个`Cell`。因为它只能在临界区对它的内容进行访问，所以它这么做是safe的。因此我们可以即使没有一点unsafe的代码我们也能获取一个safe的计数器！
]))

#tr((
en: [
  This is great for simple types like the `u32` of our counter, but what
  about more complex types which are not Copy? An extremely common example
  in an embedded context is a peripheral struct, which generally is not
  Copy. For that, we can turn to `RefCell`.
],
de: [
  Das ist ideal für einfache Typen wie den `u32` unseres Zählers. Was aber
  ist mit komplexeren Typen, die nicht `Copy` sind? Ein sehr häufiges
  Beispiel in eingebetteten Systemen ist eine Peripheriestruktur, die in
  der Regel nicht `Copy` ist. Für diesen Fall können wir `RefCell` verwenden.
],
ja: [
  この方法は、カウンタの`u32`のような単純な型に適しています。しかし、もっと複雑なCopyでない型についてはどうでしょうか？
  組込みにおいて非常に一般的な例は、ペリフェラル構造体です。これは、通常Copyではありません。
  そのためには、`RefCell`に頼ることができます。
],
zh: [
  对于我们的简单类型，像是我们的计数器的`u32`来说是很棒的，但是对于更复杂的不能拷贝的类型呢？在一个嵌入式上下文中一个极度常见的例子是一个外设结构体，通常它们不是Copy。针对那种情况，我们可以使用`RefCell`。
]))

== #tr((
  en: [Sharing Peripherals],
  de: [Gemeinsame Nutzung von Peripheriegeräten],
  ja: [ペリフェラルの共有],
  zh: [共享外设],
))

#tr((
en: [
  Device crates generated using `svd2rust` and similar abstractions
  provide safe access to peripherals by enforcing that only one instance
  of the peripheral struct can exist at a time. This ensures safety, but
  makes it difficult to access a peripheral from both the main thread and
  an interrupt handler.
],
de: [
  Mit `svd2rust` und ähnlichen Abstraktionen erzeugte Device-Crates
  ermöglichen einen sicheren Zugriff auf Peripheriekomponenten, indem sie
  sicherstellen, dass zu jedem Zeitpunkt nur eine einzige Instanz der
  entsprechenden Peripherie-Struktur existiert. Dies gewährleistet zwar
  die Sicherheit, erschwert jedoch den gleichzeitigen Zugriff auf eine
  Peripheriekomponente sowohl aus dem Haupt-Thread als auch aus einem
  Interrupt-Handler heraus.
],
ja: [
  `svd2rust`および同様の抽象化を使って生成されるデバイスクレートは、ペリフェラルへの安全なアクセスを提供します。
  これは、同時に1つのペリフェラル構造体インスタンスしか存在できないように強制することによって、もたらされます。
  このことは、安全性を保証しますが、メインスレッドと割り込みハンドとの両方からペリフェラルにアクセスすることを難しくします。
],
zh: [
  使用`svd2rust`生成的设备crates和相似的抽象，通过强制要求同时只能存在一个外设结构体的实例，提供了对外设的安全的访问。这个确保了安全性，但是使得它很难从main线程和一个中断处理函数一起访问一个外设。
]))

#let ln_refcell = link("https://doc.rust-lang.org/core/cell/struct.RefCell.html")[`RefCell`]
#tr((
en: [
  To safely share peripheral access, we can use the `Mutex` we saw before.
  We'll also need to use #ln_refcell,
  which uses a runtime check to ensure only one reference to a peripheral
  is given out at a time. This has more overhead than the plain `Cell`,
  but since we are giving out references rather than copies, we must be
  sure only one exists at a time.
],
de: [
  Um den Zugriff auf Peripheriekomponenten sicher zu teilen, können wir
  den bereits bekannten `Mutex` verwenden. Zudem benötigen wir
  #ln_refcell;;
  dieses stellt mittels einer Laufzeitprüfung sicher, dass jeweils nur
  eine einzige Referenz auf eine Peripheriekomponente ausgegeben wird.
  Dies ist zwar mit einem höheren Overhead verbunden als bei einem
  einfachen `Cell`, doch da wir Referenzen anstatt Kopien weitergeben,
  müssen wir sicherstellen, dass zu jedem Zeitpunkt nur eine einzige
  Referenz existiert.
],
ja: [
  ペリフェラルアクセスを安全に共有するため、上で見たように`Mutex`を使うことができます。
  また、#ln_refcell;も必要です。RefCellは、実行時チェックを使って、同時に1つのペリフェラルへの参照だけが渡されるようにします。
  実行時チェックは、普通の`Cell`よりもオーバーヘッドが大きくなりますが、
  コピーではなく参照を受け渡しするため、同時に存在するのが1つだけであることを確認する必要があります。
],
zh: [
  为了安全地共享对外设的访问，我们能使用我们之前看到的`Mutex`。我们也将需要使用#ln_refcell，它使用一个运行时检查去确保对一个外设每次只有一个引用被给出。这个比纯`Cell`消耗更多，但是因为我们正给出引用而不是拷贝，我们必须确保每次只有一个引用存在。
]))

#tr((
en: [
  Finally, we'll also have to account for somehow moving the peripheral
  into the shared variable after it has been initialised in the main code.
  To do this we can use the `Option` type, initialised to `None` and later
  set to the instance of the peripheral.
],
de: [
  Schließlich müssen wir auch berücksichtigen, wie die
  Peripheriekomponente in die gemeinsam genutzte Variable übertragen
  werden kann, nachdem sie im Hauptcode initialisiert wurde. Hierfür
  können wir den Typ `Option` verwenden, der zunächst mit `None`
  initialisiert und später auf die Instanz der Peripheriekomponente gesetzt wird.
],
ja: [
  最後に、メインコード内でペリフェラルを初期化した後、なんとかしてペリフェラルを共有変数に移動する方法が必要です。
  これを実現するために、`Option`型を使います。`None`で初期化し、後でペリフェラルのインスタンスを設定します。
],
zh: [
  最终，我们也必须考虑在main代码中初始化外设后，如何将外设移到共享变量中。为了做这个，我们使用`Option`类型，初始成`None`，之后设置成外设的实例。
]))

#raw(block: true, lang: "rust",
"use core::cell::RefCell;
use cortex_m::interrupt::{self, Mutex};
use stm32f4::stm32f405;

static MY_GPIO: Mutex<RefCell<Option<stm32f405::GPIOA>>> =
    Mutex::new(RefCell::new(None));

#[entry]
fn main() -> ! {
    // " + ts((
        en: "Obtain the peripheral singletons and configure it.
    // This example is from an svd2rust-generated crate, but
    // most embedded device crates will be similar.",
        de: "Die Peripherie-Singletons abrufen und konfigurieren.
    // Dieses Beispiel stammt aus einer mit svd2rust erstellten Crate, die 
    // meisten Crates für eingebettete Geräte sind jedoch ähnlich.",
        ja: "ペリフェラルのシングルトンを取得し、設定します。
    // この例は、svd2rustで生成されたクレートから持ってきたものですが、
    // ほとんどの組込みデバイスクレートは同様になります。",
        zh: "获得外设的单例并配置它。这个例子来自一个svd2rust生成的crate，
    // 但是大多数的嵌入式设备crates都相似。",
      )) + "
    let dp = stm32f405::Peripherals::take().unwrap();
    let gpioa = &dp.GPIOA;

    // " + ts((
        en: "Some sort of configuration function.
    // Assume it sets PA0 to an input and PA1 to an output.",
        de: "Eine Art Konfigurationsfunktion.
    // Gehen wir davon aus, dass es PA0 als Eingang und PA1 als Ausgang 
    // konfiguriert.",
        ja: "一連の設定をする関数です。
    // PA0を入力、PA1を出力に設定すると仮定して下さい。",
        zh: "某个配置函数。假设它把PA0设置成一个输入和把PA1设置成一个输出。",
      )) + "
    configure_gpio(gpioa);

    // " + ts((
        en: "Store the GPIOA in the mutex, moving it.",
        de: "Speichere GPIOA im Mutex und verschiebe es dabei.",
        ja: "GPIOAをミューテックスに格納し、ムーブします。",
        zh: "把GPIOA存进互斥量中，移动它。",
      )) + "
    interrupt::free(|cs| MY_GPIO.borrow(cs).replace(Some(dp.GPIOA)));
    // " + ts((
        en: "We can no longer use `gpioa` or `dp.GPIOA`, and instead have to
    // access it via the mutex.

    // Be careful to enable the interrupt only after setting MY_GPIO:
    // otherwise the interrupt might fire while it still contains None,
    // and as-written (with `unwrap()`), it would panic.",
        de: "Wir koennen `gpioa` oder `dp.GPIOA` nicht mehr verwenden, sondern 
    // muessen stattdessen ueber den Mutex darauf zugreifen.

    // Achten Sie darauf, den Interrupt erst nach dem Setzen von MY_GPIO zu 
    // aktivieren:
    // Andernfalls koennte der Interrupt ausgeloest werden, solange MY_GPIO 
    // noch None enthaelt, was – wie implementiert (mit `unwrap()`) – zu einer 
    // Panic fuehren wuerde.",
        ja: "もはや`gpioa`や`dp.GPIOA`は使いません。
    // 代わりに、ミューテックス経由でアクセスする必要があります。

    // MY_GPIOを設定した後にのみ、割り込みを有効にするように注意して下さい。
    // そうしなければ、まだNoneが含まれている間に、割り込みが発生する可能性があります。
    // （`unwrap()`を使用して）書き込まれると、パニックになるでしょう。",
        zh: "我可以不再用`gpioa`或者`dp.GPIOA`，反而必须通过互斥量访问它。

    // 请注意，只有在设置MY_GPIO后才能使能中断: 要不然当MY_GPIO还是包含None的时候，
    // 中断可能会发生，然后像上面写的那样操作(使用`unwrap()`)，它将发生运行时恐慌。"
      )) + "
    set_timer_1hz();
    let mut last_state = false;
    loop {
        // " + ts((
            en: "We'll now read state as a digital input, via the mutex",
            de: "Wir lesen den Status nun als digitalen Eingang ueber den Mutex aus.",
            ja: "ミューテックス経由で、デジタル入力としての状態を読み込みます。",
            zh: "我们现在将通过互斥量，读取其作为数字输入时的状态。",
          )) + "
        let state = interrupt::free(|cs| {
            let gpioa = MY_GPIO.borrow(cs).borrow();
            gpioa.as_ref().unwrap().idr.read().idr0().bit_is_set()
        });

        if state && !last_state {
            // " + ts((
                en: "Set PA1 high if we've seen a rising edge on PA0.",
                de: "Setze PA1 auf High, wenn an PA0 eine steigende Flanke erkannt 
            // wurde.",
                ja: "PA0の立ち上がりエッジを検出した場合、PA1をハイに設定します。",
                zh: "如果我们在PA0上已经看到了一个上升沿，拉高PA1。"
              )) + "
            interrupt::free(|cs| {
                let gpioa = MY_GPIO.borrow(cs).borrow();
                gpioa.as_ref().unwrap().odr.modify(|_, w| w.odr1().set_bit());
            });
        }
        last_state = state;
    }
}

#[interrupt]
fn timer() {
    // " + ts((
        en: "This time in the interrupt we'll just clear PA0.",
        de: "Diesmal setzen wir im Interrupt lediglich PA0 zurueck.",
        ja: "今回は、割り込み内では単純にPA0をクリアするだけです。",
        zh: "这次在中断中，我们将清除PA0。",
      )) + "
    interrupt::free(|cs| {
        // " + ts((
            en: "We can use `unwrap()` because we know the interrupt wasn't enabled
        // until after MY_GPIO was set; otherwise we should handle the potential
        // for a None value.",
            de: "Wir koennen `unwrap()` verwenden, da wir wissen, dass der Interrupt 
        // erst aktiviert wurde, nachdem `MY_GPIO` gesetzt war; andernfalls 
        // muessten wir den moeglichen Fall eines `None`-Werts behandeln.",
            ja: "`unwrap()`を使うことができます。割り込みはMY_GPIOが設定されるまで有効化されないことを
        // 知っているためです。そうでなければ、Noneを処理しなければならないでしょう。",
            zh: "我们可以使用`unwrap()` 因为我们知道直到MY_GPIO被设置后，中断都是禁用的；
        // 否则我应该处理会出现一个None值的潜在可能"
          )) + "
        let gpioa = MY_GPIO.borrow(cs).borrow();
        gpioa.as_ref().unwrap().odr.modify(|_, w| w.odr1().clear_bit());
    });
}
")

#tr((
en: [
  That's quite a lot to take in, so let's break down the important lines.
],
de: [
  Das ist eine ganze Menge, die man erst einmal verarbeiten muss --
  schauen wir uns also die wichtigen Zeilen genauer an.
],
ja: [
  非常に多くのことを取り入れています。重要な部分を詳細に見ていきましょう。
],
zh: [
  这需要理解的内容很多，所以让我们把重要的内容分解一下。
]))

```rust
static MY_GPIO: Mutex<RefCell<Option<stm32f405::GPIOA>>> =
    Mutex::new(RefCell::new(None));
```

#tr((
en: [
  Our shared variable is now a `Mutex` around a `RefCell` which contains
  an `Option`. The `Mutex` ensures we only have access during a critical
  section, and therefore makes the variable Sync, even though a plain
  `RefCell` would not be Sync. The `RefCell` gives us interior mutability
  with references, which we'll need to use our `GPIOA`. The `Option` lets
  us initialise this variable to something empty, and only later actually
  move the variable in. We cannot access the peripheral singleton
  statically, only at runtime, so this is required.
],
de: [
  Unsere gemeinsam genutzte Variable ist nun ein `Mutex`, der einen
  `RefCell` umschließt, welcher wiederum ein `Option` enthält. Der `Mutex`
  stellt sicher, dass der Zugriff nur innerhalb eines kritischen
  Abschnitts erfolgt, und macht die Variable dadurch `Sync` -- auch wenn
  ein einfacher `RefCell` dies nicht wäre. Der `RefCell` ermöglicht uns
  „Interior Mutability" (interne Veränderbarkeit) bei Verwendung von
  Referenzen, was wir für unseren `GPIOA` benötigen. Das `Option` erlaubt
  es uns, die Variable zunächst leer zu initialisieren und den
  eigentlichen Wert erst später hineinzubewegen. Da wir nicht statisch,
  sondern nur zur Laufzeit auf das Peripherie-Singleton zugreifen können,
  ist dieses Vorgehen erforderlich.
],
ja: [
  ここでは、共有変数は`RefCell`を内部に含む`Mutex`です。さらに、RefCellは`Option`を含んでいます。
  `Mutex`はクリティカルセクションの間だけ、アクセスできるようにします。
  その結果、普通の`RefCell`はSyncでないにも関わらず、変数はSyncになります。
  `RefCell`は、`GPIOA`を使うのに必要となる参照によって内部可変性を提供します。
  `Option`を使用すると、この変数を空の値に初期化できます。後で実際に変数を移動します。
  ペリフェラルのシングルトンには静的にアクセスすることはできません。実行時のみアクセスできるため、Optionが必要とされます。
],
zh: [
  我们的共享变量现在是一个包围了一个`RefCell`的`Mutex`，`RefCell`包含一个`Option`。`Mutex`确保只在一个临界区中的时候可以访问，因此使变量变成了Sync，甚至即使一个纯`RefCell`不是Sync。`RefCell`赋予了我们引用的内部可变性，我们将需要使用我们的`GPIOA`。`Option`让我们可以初始化这个变量成空的东西，只在随后实际移动变量进来。只有在运行时，我们才能静态地访问外设单例，因此这是必须的。

]))

```rust
interrupt::free(|cs| MY_GPIO.borrow(cs).replace(Some(dp.GPIOA)));
```

#tr((
en: [
  Inside a critical section we can call `borrow()` on the mutex, which
  gives us a reference to the `RefCell`. We then call `replace()` to move
  our new value into the `RefCell`.
],
de: [
  Innerhalb eines kritischen Abschnitts können wir `borrow()` auf dem
  Mutex aufrufen, was uns eine Referenz auf die `RefCell` liefert.
  Anschließend rufen wir `replace()` auf, um unseren neuen Wert in die
  `RefCell` zu verschieben.
],
ja: [
  クリティカルセクションの内部で、ミューテックスの`borrow()`を呼んでいます。borrow()は`RefCell`の参照を提供します。
  その後、`replace()`を呼び出して、`RefCell`に新しい値をムーブします。
],
zh: [
  在一个临界区中，我们可以在互斥量上调用`borrow()`，其给了我们一个指向`RefCell`的引用。然后我们调用`replace()`去移动我们的新值进来`RefCell`。
]))

```rust
interrupt::free(|cs| {
    let gpioa = MY_GPIO.borrow(cs).borrow();
    gpioa.as_ref().unwrap().odr.modify(|_, w| w.odr1().set_bit());
});
```

#tr((
en: [
  Finally, we use `MY_GPIO` in a safe and concurrent fashion. The critical
  section prevents the interrupt firing as usual, and lets us borrow the
  mutex. The `RefCell` then gives us an `&Option<GPIOA>`, and tracks how
  long it remains borrowed - once that reference goes out of scope, the
  `RefCell` will be updated to indicate it is no longer borrowed.
],
de: [
  Schließlich verwenden wir `MY_GPIO` auf sichere und nebenläufige Weise.
  Der kritische Abschnitt verhindert wie üblich das Auslösen von
  Interrupts und ermöglicht es uns, den Mutex auszuleihen. Die `RefCell`
  liefert uns dann ein `&Option<GPIOA>` und überwacht die Dauer der
  Ausleihe; sobald die Referenz ihren Gültigkeitsbereich verlässt, wird
  der Status der `RefCell` aktualisiert, um anzuzeigen, dass sie nicht
  mehr ausgeliehen ist.
],
ja: [
  最後に、`MY_GPIO`を安全で並行なやり方で使います。
  クリティカルセクションは、通常通り割り込みの発生を防ぎ、ミューテックスを借用できます。
  `RefCell`は`&Option<GPIOA>`を提供し、その借用がいつまで続くかを追跡します。
  その参照がスコープ外になると、`RefCell`が借用されなくなったことを示すため、更新されます。
],
zh: [
  最终，我们用一种安全和并发的方式使用`MY_GPIO`。临界区禁止了中断像往常一样发生，让我们借用互斥量。`RefCell`然后给了我们一个`&Option<GPIOA>`并追踪它还要借用多久 - 一旦引用超出作用域，`RefCell`将会被更新去指出引用不再被借用。
]))

#tr((
en: [
  Since we can't move the `GPIOA` out of the `&Option`, we need to convert
  it to an `&Option<&GPIOA>` with `as_ref()`, which we can finally
  `unwrap()` to obtain the `&GPIOA` which lets us modify the peripheral.
],
de: [
  Da wir das `GPIOA`-Objekt nicht aus dem `&Option` herausverschieben
  können, müssen wir es mittels `as_ref()` in ein `&Option<&GPIOA>`
  umwandeln. Dieses können wir schließlich mit `unwrap()` auflösen, um das
  `&GPIOA` zu erhalten, das uns den Zugriff zur Modifikation der
  Peripherieeinheit ermöglicht.
],
ja: [
  `&Option`の外に`GPIOA`をムーブすることはできないので、`as_ref()`を使って`&Option<&GPIOA>`に変換します。
  そうすると、最終的に、`unwrap()`で`&GPIOA`を取得できます。
  &GPIOAにより、ペリフェラルを修正することができます。
],
zh: [
  因为我不能把`GPIOA`移出`&Option`，我们需要用`as_ref()`将它转换成一个`&Option<&GPIOA>`，最终我们能使用`unwrap()`获得`&GPIOA`，其让我们可以修改外设。
]))

#tr((
en: [
  If we need a mutable reference to a shared resource, then `borrow_mut`
  and `deref_mut` should be used instead. The following code shows an
  example using the TIM2 timer.
],
de: [
  Wenn wir eine veränderbare Referenz auf eine gemeinsam genutzte
  Ressource benötigen, sollten stattdessen `borrow_mut` und `deref_mut`
  verwendet werden. Der folgende Code zeigt ein Beispiel unter Verwendung
  des TIM2-Timers.
],
zh: [
  如果我们需要一个共享的资源的可变引用，那么`borrow_mut`和`deref_mut`应该被使用。下面的代码展示了一个使用TIM2计时器的例子。
]))

#raw(block: true, lang: "rust",
"use core::cell::RefCell;
use core::ops::DerefMut;
use cortex_m::interrupt::{self, Mutex};
use cortex_m::asm::wfi;
use stm32f4::stm32f405;

static G_TIM: Mutex<RefCell<Option<Timer<stm32::TIM2>>>> =
    Mutex::new(RefCell::new(None));

#[entry]
fn main() -> ! {
    let mut cp = cm::Peripherals::take().unwrap();
    let dp = stm32f405::Peripherals::take().unwrap();

    // " + ts((
        en: "Some sort of timer configuration function.
    // Assume it configures the TIM2 timer, its NVIC interrupt,
    // and finally starts the timer.",
        de: "Eine Art Timer-Konfigurationsfunktion. 
    // Angenommen, sie konfiguriert den TIM2-Timer sowie dessen NVIC-Interrupt 
    // und startet schließlich den Timer.",
        zh: "某个计时器配置函数。假设它配置了TIM2计时器和它的NVIC中断，
    // 最终启动计时器。"
      )) + "
    let tim = configure_timer_interrupt(&mut cp, dp);

    interrupt::free(|cs| {
        G_TIM.borrow(cs).replace(Some(tim));
    });

    loop {
        wfi();
    }
}

#[interrupt]
fn timer() {
    interrupt::free(|cs| {
        if let Some(ref mut tim)) =  G_TIM.borrow(cs).borrow_mut().deref_mut() {
            tim.start(1.hz());
        }
    });
}
")

#tr((
en: [
  Whew! This is safe, but it is also a little unwieldy. Is there anything
  else we can do?
],
de: [
  Puh! Das ist zwar sicher, aber auch etwas unhandlich. Können wir sonst
  noch etwas tun?
],
ja: [
  ヒューッ！これは安全ですが、少し大げさすぎて扱いにくいです。他に方法はないのでしょうか？
],
zh: [
  呼！这是安全的，但也有点笨拙。我们还能做些什么吗？
]))

== RTIC

#let url_rtic = "https://github.com/rtic-rs/cortex-m-rtic"
#tr((
en: [
  One alternative is the #link(url_rtic)[RTIC framework], short for Real Time
  Interrupt-driven Concurrency. It enforces static priorities and tracks
  accesses to `static mut` variables ("resources") to statically ensure
  that shared resources are always accessed safely, without requiring the
  overhead of always entering critical sections and using reference
  counting (as in `RefCell`). This has a number of advantages such as
  guaranteeing no deadlocks and giving extremely low time and memory
  overhead.
],
de: [
  Eine Alternative ist das
  #link(url_rtic)[RTIC-Framework] (kurz für _Real
  Time Interrupt-driven Concurrency_). Es erzwingt statische Prioritäten
  und überwacht Zugriffe auf `static mut`-Variablen („Ressourcen"), um
  statisch sicherzustellen, dass auf gemeinsam genutzte Ressourcen stets
  sicher zugegriffen wird -- ohne den Overhead, der durch das ständige
  Betreten kritischer Abschnitte oder die Verwendung von Referenzzählung
  (wie bei `RefCell`) entstünde. Dies bietet eine Reihe von Vorteilen, wie
  etwa die Garantie von Deadlock-Freiheit sowie einen extrem geringen
  Zeit- und Speicheraufwand.
],
ja: [
  代替手段の１つは、#link(url_rtic)[RTFMフレームワーク]です。RTFMは、Real
  Time For the Massesの略です。
  RTFMは、共有リソースが常に安全にアクセスされることを保証するために、静的な優先度を適用し、
  `static mut`変数（「リソース」）へのアクセスを追跡します。
  この方法は、（`RefCell`のように）常にクリティカルセクションに入り、参照カウントを使うというオーバーヘッドを必要としません。
  デッドロックがないことを保証したり、時間とメモリのオーバーヘッドを極めて小さくするといった、多くの利点があります。
],
zh: [
  另一个方法是使用#link(url_rtic)[RTIC框架]，Real
  Time Interrupt-driven
  Concurrency的缩写。它强制执行静态优先级并追踪对`static mut`变量("资源")的访问去确保共享资源总是能被安全地访问，而不需要总是进入临界区和使用引用计数带来的消耗(如`RefCell`中所示)。这有许多好处，比如保证没有死锁且时间和内存的消耗极度低。
]))

#tr((
en: [
  RTIC comes with as asynchronous executor, so your software tasks are
  `async` functions where you can use `async` APIs in addition to regular
  synchronous APIs.
],
de: [
  RTIC bietet einen asynchronen Executor, sodass Ihre Software-Tasks als
  `async`-Funktionen implementiert sind; darin können Sie neben
  herkömmlichen synchronen APIs auch `async`-APIs nutzen.
]))

#let url_rtic_doc = "https://rtic.rs"
#tr((
en: [
  The framework also includes other features like message passing, which
  reduces the need for explicit shared state, and the ability to schedule
  tasks to run at a given time, which can be used to implement periodic
  tasks. Check out #link(url_rtic_doc)[the documentation] for more
  information!
],
de: [
  Das Framework umfasst zudem Funktionen wie Message Passing -- was den
  Bedarf an explizit gemeinsam genutztem Zustand (Shared State) verringert
  -- sowie die Möglichkeit, Tasks für einen bestimmten Zeitpunkt zu
  planen, womit sich beispielsweise periodische Aufgaben realisieren
  lassen. Weitere Informationen finden Sie in
  #link(url_rtic_doc)[der Dokumentation]!
],
ja: [
  このフレームワークは他の機能も含んでいます。例えば、メッセージパッシングは明示的な共有状態の必要性を減らします。
  また、タスクを指定した時間に実行するスケジュールする機能もあります。これは、周期タスクの実装に使えます。
  詳しくは#link(url_rtic_doc)[ドキュメント]を参照して下さい。
],
zh: [
  这个框架也包括了其它的特性，像是消息传递(message
  passing)，消息传递减少了对显式共享状态的需要，还提供了在一个给定时间调度任务去运行的功能，这功能能被用来实现周期性的任务。看下#link(url_rtic_doc)[文档]可以知道更多的信息！
]))

== Embassy

#let url_executor = "https://docs.rs/embassy-executor/latest/embassy_executor/"
#tr((
en: [
  Embassy is an ecosystem of libraries which focus on using the `async` /
  `await` syntax included in Rust for concurrency. The core of embassy is
  its #link(url_executor)[asynchronous executor]
  which supports most common MCU architectures.
],
de: [
  Embassy ist ein Ökosystem von Bibliotheken, die sich auf die Nutzung der
  in Rust enthaltenen `async`/`await`-Syntax für Nebenläufigkeit
  konzentrieren. Das Herzstück von Embassy ist sein
  #link(url_executor)[asynchroner Executor],
  der die gängigsten MCU-Architekturen unterstützt.
]))

#let url_em_time = "https://docs.rs/embassy-time/latest/embassy_time/"
#let ln_en_sync = link("https://docs.embassy.dev/embassy-sync/git/default/index.html")[embassy-sync]
#tr((
en: [
  embassy also takes a battery-included approach and offers many other
  components, for example:
  - #link(url_em_time)[Time library]
  - Various HAL libraries which also provide the time library support.
  - #ln_en_sync for synchronization primitives
],
de: [
  Embassy verfolgt zudem einen „Batteries-included"-Ansatz und bietet
  viele weitere Komponenten an, zum Beispiel:
  - #link(url_em_time)[Zeit-Bibliothek]
  - Verschiedene HAL-Bibliotheken, die auch Unterstützung für die
    Zeitbibliothek bieten.
  - #ln_en_sync für Synchronisationsprimitive
]))

#let url_em_site = "https://embassy.dev/"
#let url_em_book = "https://embassy.dev/book/"
#tr((
en: [
  You can check the #link(url_em_site)[website] and the
  #link(url_em_book)[book] for more information.
],
de: [
  Weitere Informationen finden Sie auf der
  #link(url_em_site)[Website] und im #link(url_em_book)[Buch].
]))

== #tr((
  en: [Real Time Operating Systems],
  de: [Echtzeitbetriebssysteme],
  ja: [リアルタイムオペレーティングシステム],
  zh: [实时操作系统],
))

#let ln_freertos = link("https://freertos.org/")[FreeRTOS]
#let ln_chibi = link("http://chibios.org/")[ChibiOS]
#tr((
en: [
  Another common model for embedded concurrency is the real-time operating
  system (RTOS). While currently less well explored in Rust, they are
  widely used in traditional embedded development. Open source examples
  include #ln_freertos and #ln_chibi. These RTOSs provide support for
  running multiple application threads which the CPU swaps between, either
  when the threads yield control (called cooperative multitasking) or
  based on a regular timer or interrupts (preemptive multitasking). The
  RTOS typically provide mutexes and other synchronisation primitives, and
  often interoperate with hardware features such as DMA engines.
],
de: [
  Ein weiteres verbreitetes Modell für Nebenläufigkeit in eingebetteten
  Systemen ist das Echtzeitbetriebssystem (RTOS). Während diese in Rust
  bislang weniger stark erforscht sind, kommen sie in der klassischen
  Entwicklung eingebetteter Systeme häufig zum Einsatz. Zu den
  Open-Source-Beispielen zählen #ln_freertos und #ln_chibi.
  Solche Echtzeitbetriebssysteme unterstützen die Ausführung mehrerer
  Anwendungsthreads, zwischen denen die CPU wechselt -- entweder wenn die
  Threads die Kontrolle freiwillig abgeben (kooperatives Multitasking)
  oder gesteuert durch Timer bzw. Interrupts (präemptives Multitasking).
  Typischerweise stellen RTOS Mechanismen wie Mutexe und andere
  Synchronisationsprimitive bereit und interagieren häufig mit
  Hardwarefunktionen wie DMA-Controllern.
],
ja: [
  #todoupd("ja")
  組込み向け並行性の異なる一般的なモデルとして、リアルタイムオペレーティングシステム（RTOS）があります。
  現在、Rustではあまり検証されていませんが、従来の組込み開発では広く使用されています。
  オープンソースの例として、#ln_freertos;と#ln_chibi;があります。
  これらのRTOSは、複数のアプリケーションスレッドを動作させる機能を提供しています。
  スレッドが制御を明け渡す時（コオペレーティブマルチタスク）か、
  周期タイマまたは割り込みに基づく時（プリエンプティブマルチタスク）に、CPUで実行するスレッドを切り替えます。
  RTOSは、通常ミューテックスや他の同期プリミティブを提供します。また、DMAエンジンようなハードウェア機能を同時に使えることも多いです。
],
zh: [
  #todoupd("zh")
  与嵌入式并发有关的另一个模型是实时操作系统(RTOS)。虽然现在在Rust中的研究较少，但是它们被广泛用于传统的嵌入式开发。开源的例子包括#ln_freertos;和#ln_chibi。这些RTOSs提供对运行多个应用线程的支持，CPU在这些线程间进行切换，切换要么发生在当线程让出控制权的时候(被称为非抢占式多任务)，要么是基于一个常规计时器或者中断(抢占式多任务)。RTOS通常提供互斥量或者其它的同步原语，经常与硬件功能相互使用，比如DMA引擎。
]))

#tr((
en: [
  At the time of writing, there are not many Rust RTOS examples to point
  to, but it's an interesting area so watch this space!
],
de: [
  Zum jetzigen Zeitpunkt gibt es noch nicht viele Beispiele für Rust-RTOS,
  auf die man verweisen könnte; es handelt sich jedoch um ein
  interessantes Gebiet -- bleiben Sie also dran!
],
ja: [
  この本を書いている時点では、Rustで書かれたRTOSの例はそれほど多くありません。
  しかし、興味深い分野ですので、この分野にご注目下さい！
],
zh: [
  在撰写本文时，没有太多的Rust RTOS示例可供参考，但这是一个有趣的领域，所以请关注这块！
]))

== #tr((
  en: [Multiple Cores],
  de: [Mehrere Kerne],
  ja: [マルチコア],
  zh: [多个核心],
))

#tr((
en: [
  It is becoming more common to have two or more cores in embedded
  processors, which adds an extra layer of complexity to concurrency. All
  the examples using a critical section (including the
  `cortex_m::interrupt::Mutex`) assume the only other execution thread is
  the interrupt thread, but on a multi-core system that's no longer true.
  Instead, we'll need synchronisation primitives designed for multiple
  cores (also called SMP, for symmetric multi-processing).
],
de: [
  Es wird immer üblicher, eingebettete Prozessoren mit zwei oder mehr
  Kernen auszustatten, was die Parallelverarbeitung zusätzlich
  verkompliziert. Alle Beispiele mit kritischen Abschnitten
  (einschließlich `cortex_m::interrupt::Mutex`) gehen davon aus, dass der
  einzige weitere Ausführungsthread der Interrupt-Thread ist. Auf einem
  Mehrkernsystem trifft dies jedoch nicht mehr zu. Stattdessen benötigen
  wir Synchronisierungsprimitive, die speziell für Mehrkernsysteme (auch
  SMP, für symmetrisches Multiprocessing, genannt) entwickelt wurden.
],
ja: [
  組込みプロセッサにおいても、2個以上のコアを持つことがより一般的になってきています。
  このことは、並行性をさらに複雑にします。（`cortex_m::interrupt::Mutex`を含む）クリティカルセクションで使っている全ての例は、
  他の実行スレッドは、割り込みスレッドだけであることを前提にしています。
  しかし、マルチコアシステムにおいては、これは当てはまりません。
  代わりに、マルチコア（SMP; symmetric
  multi-proccesingとも呼ばれます）向けに設計した同期プリミティブが必要になります。
],
zh: [
  在嵌入式处理器中有两个或者多个核心很正常，其为并发添加了额外一层复杂性。所有使用临界区的例子(包括`cortex_m::interrupt::Mutex`)都假设了另一个执行的线程仅是中断线程，但是在一个多核系统中，这不再是正确的假设。反而，我们将需要为多核设计的同步原语(也被叫做SMP，symmetric
  multi-processing的缩写)。
]))

#tr((
en: [
  These typically use the atomic instructions we saw earlier, since the
  processing system will ensure that atomicity is maintained over all cores.
],
de: [
  Diese verwenden typischerweise die bereits erwähnten atomaren Befehle,
  da das Verarbeitungssystem die Atomarität über alle Kerne hinweg gewährleistet.
],
ja: [
  通常、これまでに見たアトミック命令を使用します。
  アトミック命令は、処理システムが全てのコア間でのアトミック性を維持してくれるためです。
],
zh: [
  我们之前看到的，这些通常使用原子指令，因为处理系统将确保原子性在所有的核中都保持着。
]))

#tr((
en: [
  Covering these topics in detail is currently beyond the scope of this
  book, but the general patterns are the same as for the single-core case.
],
de: [
  Eine detaillierte Behandlung dieser Themen würde den Rahmen dieses
  Buches sprengen, die allgemeinen Muster sind jedoch dieselben wie im Einzelkernfall.
],
ja: [
  これらのトピックを詳細に説明することは、この本のスコープ範囲外ですが、
  一般的なパターンはシングルコアの場合と同じです。
],
zh: [
  覆盖这些主题的细节已经超出了本书的范围，但是常规的模式与单核的相似。
]))
