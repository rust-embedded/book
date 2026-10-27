#import "../config.typ": *

#h1((en: [A First Attempt],
  de: [Ein erster Versuch in Rust],
  ja: [最初の試み],
  zh: [Rust尝鲜],
), offset: whole)

= #tr((
  en: [The Registers],
  de: [Die Register],
  ja: [レジスタ],
  zh: [寄存器],
))

#let url_arm = "http://infocenter.arm.com/help/topic/com.arm.doc.dui0553a/Babieigh.html"
#tr((
en: [
  Let's look at the 'SysTick' peripheral - a simple timer which comes with
  every Cortex-M processor core. Typically you'll be looking these up in
  the chip manufacturer's data sheet or _Technical Reference Manual_,
  but this example is common to all ARM Cortex-M cores, let's look in the
  #link(url_arm)[ARM reference manual].
  We see there are four registers:
],
de: [
  Betrachten wir die „SysTick"-Peripherie -- einen einfachen Timer, der in
  jedem Cortex-M-Prozessorkern enthalten ist. Normalerweise würde man
  hierfür im Datenblatt des Chip-Herstellers oder im _Technical
  Reference Manual_ nachschlagen; da dieses Beispiel jedoch für alle
  ARM-Cortex-M-Kerne gilt, werfen wir einen Blick in das
  #link(url_arm)[ARM-Referenzhandbuch].
  Wir sehen, dass es vier Register gibt:
],
ja: [
  `SysTick` ペリフェラルを見ていきましょう。 `SysTick`
  はCortex-Mプロセッサ・コアに搭載されているシンプルなタイマーです。
  通常は、チップメーカーのデータシートや_テクニカルリファレンスマニュアル_でこれらのペリフェラルの情報を調べることができるのですが、この例においては全てのARM
  Cortex-Mコアで共通のものですので、今回は#link("http://infocenter.arm.com/help/topic/com.arm.doc.dui0553a/Babieigh.html")[ARMリファレンスマニュアル]を見てみましょう。
  そこには4つのレジスタが載っています。
],
zh: [
  让我们看下 'SysTick' 外设 -
  一个简单的计时器，它存在于每个Cortex-M处理器内核中。通常你能在芯片厂商的数据手册或者_技术参考手册_中看到它们，但是下面的例子对所有ARM
  Cortex-M核心都是通用的，让我们看下#link(url_arm)[ARM参考手册]。我们能看到这里有四个寄存器:
]))

#let _32bits = tr((
  en: [32 bits],
  ja: [32ビット],
), default: [32 bits])

#figure(
  kind: table,
  table(
    columns: 4,
    align: (auto,auto,auto,auto,),
    table.header(
      tr((
        en: [Offset],
        de: [Offset],
        ja: [オフセット],
        zh: [Offset],
      )),
      tr((
        en: [Name],
        de: [Name],
        ja: [名前],
        zh: [Name],
      )),
      tr((
        en: [Description],
        de: [Beschreibung],
        ja: [説明],
        zh: [Description],
      )),
      tr((
        en: [Width],
        de: [Breite],
        ja: [幅],
        zh: [Width],
      )),
    ),
    [0x00], [SYST_CSR],
    tr((
      en: [Control and Status Register],
      de: [Steuerung und Status Register],
      ja: [制御およびステータスレジスタ],
      zh: [控制和状态寄存器],
    )),
    _32bits,
    [0x04], [SYST_RVR],
    tr((
      en: [Reload Value Register],
      de: [Wert-Register neu laden],
      ja: [リロード値レジスタ],
      zh: [重装载值寄存器],
    )),
    _32bits,
    [0x08], [SYST_CVR],
    tr((
      en: [Current Value Register],
      de: [Register für den aktuellen Wert],
      ja: [現在値レジスタ],
      zh: [当前值寄存器],
    )),
    _32bits,
    [0x0C], [SYST_CALIB],
    tr((
      en: [Calibration Value Register],
      de: [Kalibrierwert-Register],
      ja: [キャリブレーション値レジスタ],
      zh: [校准值寄存器],
    )),
    _32bits,
  )
)

= #tr((
  en: [The C Approach],
  de: [Der C-Ansatz],
  ja: [Cアプローチ],
  zh: [C语言风格的方法(The C Approach)],
))

#tr((
en: [
  In Rust, we can represent a collection of registers in exactly the same
  way as we do in C - with a `struct`.
],
de: [
  In Rust können wir eine Sammlung von Registern auf genau dieselbe Weise
  darstellen wie in C -- mit einem `struct`.
],
ja: [
  Rustでも、`struct`を使ってCと同じ方法でレジスタの集合を正確に表現することができます。
],
zh: [
  在Rust中，我们可以像C语言一样，用一个 `struct` 表示一组寄存器。
]))

```rust
#[repr(C)]
struct SysTick {
    pub csr: u32,
    pub rvr: u32,
    pub cvr: u32,
    pub calib: u32,
}
```

#tr((
en: [
  The qualifier `#[repr(C)]` tells the Rust compiler to lay this structure
  out like a C compiler would. That's very important, as Rust allows
  structure fields to be re-ordered, while C does not. You can imagine the
  debugging we'd have to do if these fields were silently re-arranged by
  the compiler! With this qualifier in place, we have our four 32-bit
  fields which correspond to the table above. But of course, this `struct`
  is of no use by itself - we need a variable.
],
de: [
  Der Qualifizierer `#[repr(C)]` weist den Rust-Compiler an, diese
  Struktur wie ein C-Compiler anzulegen. Das ist sehr wichtig, da Rust die
  Neuordnung von Strukturfeldern zulässt, C jedoch nicht. Sie können sich
  vorstellen, wie viel Debugging wir durchführen müssten, wenn diese
  Felder vom Compiler stillschweigend neu angeordnet würden! Mit diesem
  Qualifizierer verfügen wir über unsere vier 32-Bit-Felder, die der
  obigen Tabelle entsprechen. Aber diese „Struktur" allein nützt natürlich
  nichts -- wir brauchen eine Variable.
],
ja: [
  `#[repr(C)]`修飾子はRustコンパイラ対して、この構造体をCコンパイラと同じようにメモリにレイアウトするように指示します。
  これはとても重要なことです。なぜならRustでは、Cにおいては行われない構造体のフィールドの並び替えが許されているためです。
  コンパイラによって暗黙のうちに構造体のフィールドが並び替えられることにより、デバッグをするはめになることは想像できるでしょう！
  この修飾子を置くことで、4つの32ビットの各フィールドは上記のテーブルに対応付けられます。
  ただしもちろん、この`struct`はそれ自体では何の役にも立ちません。次のように変数として使う必要があります。
],
zh: [
  告诉Rust编译器像C编译器一样去布局这个结构体。这非常重要，因为Rust允许结构体字段被重新排序，而C语言不允许。你可以想象下如果这些字段被编译器悄悄地重新排了序，在调试时会给我们带来多大的麻烦！有了这个限定符，我们就有了与上表对应的四个32位的字段。但当然，这个
  `struct` 本身没什么用处 - 我们需要一个变量。
]))

```rust
let systick = 0xE000_E010 as *mut SysTick;
let time = unsafe { (*systick).cvr };
```

= #tr((
  en: [Volatile Accesses],
  de: [Volatile-Zugriffe],
  ja: [volatileアクセス],
  zh: [volatile访问(Volatile Accesses)],
))

#tr((
en: [
  Now, there are a couple of problems with the approach above.
  + We have to use unsafe every time we want to access our Peripheral.
  + We've got no way of specifying which registers are read-only or
    read-write.
  + Any piece of code anywhere in your program could access the hardware
    through this structure.
  + Most importantly, it doesn't actually work…
],
de: [
  Nun gibt es bei dem oben genannten Ansatz einige Probleme.
  + Wir müssen `unsafe` verwenden, wann immer wir auf unsere Peripherie
    zugreifen wollen.
  + Wir haben keine Möglichkeit festzulegen, welche Register nur lesbar
    oder sowohl les- als auch schreibbar sind.
  + Jeder Code-Abschnitt an beliebiger Stelle Ihres Programms könnte über
    diese Struktur auf die Hardware zugreifen.
  + Vor allem aber funktioniert es eigentlich nicht …
],
ja: [
  上記のやり方には、いくつか問題があります。
  + ペリフェラルにアクセスするためには毎回アンセーフを使わなくてはなりません。
  + どのレジスタが読み取り専用でどのレジスタが読み書き可能かを指定する方法がありません。
  + プログラム内のどのコードからでもこの構造体を通してハードウェアにアクセスできてしまいます。
  + 最も大事なことは、このコードは実際には動作しないということです…
],
zh: [
  现在，上面的方法有一堆问题。
  + 每次想要访问外设，不得不使用unsafe 。
  + 无法指定哪个寄存器是只读的或者读写的。
  + 程序中任何地方的任何一段代码都可以通过这个结构体访问硬件。
  + 最重要的是，实际上它并不能工作。
]))

#tr((
en: [
  Now, the problem is that compilers are clever. If you make two writes to
  the same piece of RAM, one after the other, the compiler can notice this
  and just skip the first write entirely. In C, we can mark variables as
  `volatile` to ensure that every read or write occurs as intended. In
  Rust, we instead mark the _accesses_ as volatile, not the variable.
],
de: [
  Das Problem ist nun, dass Compiler clever sind. Wenn man zwei
  Schreibzugriffe nacheinander auf denselben Speicherbereich durchführt,
  kann der Compiler dies erkennen und den ersten Schreibvorgang einfach
  komplett überspringen. In C können wir Variablen als `volatile`
  kennzeichnen, um sicherzustellen, dass jeder Lese- oder Schreibvorgang
  wie vorgesehen ausgeführt wird. In Rust hingegen kennzeichnen wir die
  _Zugriffe_ als volatile, nicht die Variable.
],
ja: [
  ここで問題となるのは、コンパイラが賢いということです。
  同じRAMに相次いで２回書き込むと、コンパイラはこれに気づき、最初の書き込みを完全にスキップします。
  Cでは、全ての読み書きが意図した通りに行われることを保証するために、`volatile`型修飾子を変数につけることができます。
  Rustでは、変数ではなく_アクセス_に対してvolatileをつけます。
],
zh: [
  现在的问题是编译器很聪明。如果你往RAM同个地方写两次，一个接着一个，编译器会注意到这个行为，且完全跳过第一个写入操作。在C语言中，我们能标记变量为`volatile`去确保每个读或写操作按所想的那样发生。在Rust中，我们将_访问_操作标记为易变的(volatile)，而不是将变量标记为volatile。
]))

```rust
let systick = unsafe { &mut *(0xE000_E010 as *mut SysTick) };
let time = unsafe { core::ptr::read_volatile(&mut systick.cvr) };
```

#let ln_volatile = link("https://crates.io/crates/volatile_register")[`volatile_register`]
#tr((
en: [
  So, we've fixed one of our four problems, but now we have even more
  `unsafe` code! Fortunately, there's a third party crate which can help - #ln_volatile.
],
de: [
  Wir haben also eines unserer vier Probleme gelöst, aber jetzt haben wir
  noch mehr `unsafe`-Code! Glücklicherweise gibt es ein Crate eines
  Drittanbieters, das hierbei helfen kann -- #ln_volatile.
],
ja: [
  これで4つの問題のうち1つを直せました。しかし、さらに`unsafe`なコードがあります！
  幸いなことに、これに対処できるサードパーティ製のクレート#ln_volatile;があります。
],
zh: [
  这样，我们已经修复了一个问题，但是现在我们有了更多的 `unsafe`
  代码!幸运的是，有个第三方的crate可以帮助到我们 -
  #ln_volatile
]))

```rust
use volatile_register::{RW, RO};

#[repr(C)]
struct SysTick {
    pub csr: RW<u32>,
    pub rvr: RW<u32>,
    pub cvr: RW<u32>,
    pub calib: RO<u32>,
}

fn get_systick() -> &'static mut SysTick {
    unsafe { &mut *(0xE000_E010 as *mut SysTick) }
}

fn get_time() -> u32 {
    let systick = get_systick();
    systick.cvr.read()
}
```

#tr((
en: [
  Now, the volatile accesses are performed automatically through the
  `read` and `write` methods. It's still `unsafe` to perform writes, but
  to be fair, hardware is a bunch of mutable state and there's no way for
  the compiler to know whether these writes are actually safe, so this is
  a good default position.
],
de: [
  Die volatilen Zugriffe erfolgen nun automatisch über die Methoden `read`
  und `write`. Schreibzugriffe sind zwar weiterhin als `unsafe`
  eingestuft, doch fairerweise muss man sagen, dass Hardware im Grunde aus
  veränderlichem Zustand besteht und der Compiler nicht wissen kann, ob
  diese Schreibvorgänge tatsächlich sicher sind; daher ist dies eine
  sinnvolle Standardeinstellung.
],
ja: [
  これで`read`と`write`メソッドを通してvolatileアクセスが自動的に行われるようになりました。
  書き込みを実行するのはまだ`unsafe`です。しかし、公平を期するために言うと、ハードウェアは変更可能な状態の集まりであるため、それらへの書き込みが実際に安全なのかどうか、をコンパイラが知る方法はないのです。そのため、これは基本姿勢としては悪くないでしょう。
],
zh: [
  现在通过`read`和`write`方法，volatile
  accesses可以被自动执行。执行写操作仍然是 `unsafe`
  的，但是公平地讲，硬件有一堆可变的状态，对于编译器来说没有办法知道是否这些写操作是真正安全的，因此默认就这样是个不错的选择。
]))

= #tr((
  en: [The Rusty Wrapper],
  de: [Der Rusty Wrapper],
  ja: [Rustのラッパ],
  zh: [Rust风格的封装],
))

#tr((
en: [
  We need to wrap this `struct` up into a higher-layer API that is safe
  for our users to call. As the driver author, we manually verify the
  unsafe code is correct, and then present a safe API for our users so
  they don't have to worry about it (provided they trust us to get it
  right!).
],
de: [
  Wir müssen diese `struct` in eine API der höheren Ebene verpacken, deren
  Aufruf für unsere Nutzer sicher ist. Als Treiberentwickler überprüfen
  wir manuell die Korrektheit des `unsafe`-Codes und stellen unseren
  Nutzern dann eine sichere API zur Verfügung, sodass sie sich darum nicht
  kümmern müssen (vorausgesetzt, sie vertrauen darauf, dass wir alles
  richtig gemacht haben!).
],
ja: [
  ユーザが安全に呼び出せるように、この`struct`を高レイヤーのAPIでラップする必要があります。
  ドライバの作者として、アンセーフなコードが正しいことを手動で検証し、ユーザがそのドライバを使用する上で心配することがないように安全なAPIとして提供します。（ユーザは提供されたものが正しいと信頼しています！）
],
zh: [
  我们需要把这个`struct`封装进一个更高抽象的API中，这个API对于用户来说，可以安全地调用。作为驱动的作者，我们亲手验证不安全的代码是否正确，然后为我们的用户提供一个safe的API，因此用户们不必担心它(让他们相信我们不会出错!)。
]))

#tr((
en: [
  One example might be:
],
de: [
  Ein Beispiel hierfür wäre:
],
ja: [
  一例を挙げます。
],
zh: [
  有可能可以这样写:
]))

```rust
use volatile_register::{RW, RO};

pub struct SystemTimer {
    p: &'static mut RegisterBlock
}

#[repr(C)]
struct RegisterBlock {
    pub csr: RW<u32>,
    pub rvr: RW<u32>,
    pub cvr: RW<u32>,
    pub calib: RO<u32>,
}

impl SystemTimer {
    pub fn new() -> SystemTimer {
        SystemTimer {
            p: unsafe { &mut *(0xE000_E010 as *mut RegisterBlock) }
        }
    }

    pub fn get_time(&self) -> u32 {
        self.p.cvr.read()
    }

    pub fn set_reload(&mut self, reload_value: u32) {
        unsafe { self.p.rvr.write(reload_value) }
    }
}

pub fn example_usage() -> String {
    let mut st = SystemTimer::new();
    st.set_reload(0x00FF_FFFF);
    format!("Time is now 0x{:08x}", st.get_time())
}
```

#tr((
en: [
  Now, the problem with this approach is that the following code is
  perfectly acceptable to the compiler:
],
de: [
  Das Problem bei diesem Ansatz ist nun, dass der folgende Code für den
  Compiler völlig zulässig ist:
],
ja: [
  このやり方の問題は、次のコードがコンパイラに完全に受け入れられることです。
],
zh: [
  现在，这种方法带来的问题是，下列的代码完全可以被编译器接受:
]))

```rust
fn thread1() {
    let mut st = SystemTimer::new();
    st.set_reload(2000);
}

fn thread2() {
    let mut st = SystemTimer::new();
    st.set_reload(1000);
}
```

#tr((
en: [
  Our `&mut self` argument to the `set_reload` function checks that there
  are no other references to _that_ particular `SystemTimer` struct,
  but they don't stop the user creating a second `SystemTimer` which
  points to the exact same peripheral! Code written in this fashion will
  work if the author is diligent enough to spot all of these 'duplicate'
  driver instances, but once the code is spread out over multiple modules,
  drivers, developers, and days, it gets easier and easier to make these
  kinds of mistakes.
],
de: [
  Das `&mut self`-Argument der Funktion `set_reload` stellt zwar sicher,
  dass keine weiteren Referenzen auf _genau diese_
  `SystemTimer`-Struktur existieren, verhindert jedoch nicht, dass der
  Benutzer einen zweiten `SystemTimer` erstellt, der auf dieselbe
  Peripherieeinheit verweist. Auf diese Weise geschriebener Code
  funktioniert zwar, sofern der Autor sorgfältig genug ist, all diese
  „doppelten" Treiberinstanzen zu erkennen; sobald sich der Code jedoch
  über mehrere Module, Treiber, Entwickler und Zeiträume hinweg erstreckt,
  schleichen sich derartige Fehler immer leichter ein.
],
ja: [
  `set_reload`関数に`&mut self`引数を渡すことで、_その_インスタンスの`SystemTimer`構造体に対する他の参照がないことを確認しますが、全く同じペリフェラルを指す２つ目の`SystemTimer`構造体をユーザが作ることは止められません！
  このように書かれたコードは、作者がこれらの「重複した」ドライバのインスタンスを全て見つけるのに十分に熱心であれば動作するでしょうが、一度コードが複数のモジュール、ドライバ、開発者、そして日に渡って分散すると、この種の間違いがどんどん入り込みやすくなっていきます。
],
zh: [
  虽然 `set_reload` 函数的 `&mut self`
  参数保证了没有引用到其它的`SystemTimer`结构体，但是不能阻止用户去创造第二个`SystemTimer`，其指向同个外设！如果作者足够努力的话，他能发现所有这些'重复的'驱动实例，那么按这种方式写的代码就可以工作，但是一旦代码被散播一段时间，散播给多个模块，驱动，开发者，它会越来越容易触发此类错误。
]))
