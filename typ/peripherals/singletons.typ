#import "../config.typ": *

#h1((en: [Singletons],
  de: [Singletons],
  ja: [シングルトン],
  zh: [单例],
), offset: whole)

#quote(block: true)[
#tr((
en: [
  In software engineering, the singleton pattern is a software design
  pattern that restricts the instantiation of a class to one object.
],
de: [
	In der Softwaretechnik ist das Singleton-Muster ein Entwurfsmuster, das
	die Instanziierung einer Klasse auf ein einziges Objekt beschränkt.
],
ja: [
  ソフトウェア工学において、シングルトン・パターンはクラスのインスタンス化を１つのオブジェクトに制限するデザインパターンです。
],
zh: [
	在软件工程中，单例模式是一个软件设计模式，其限制了一个类到一个对象的实例化。
]))

#let url_singleton = "https://en.wikipedia.org/wiki/Singleton_pattern"
#tr((
en: [
  _Wikipedia: #link(url_singleton)[Singleton Pattern]_
],
de: [
	_Wikipedia: #link(url_singleton)[Singleton-Muster]_
],
ja: [
  _Wikipedia: #link(url_singleton)[Singleton Pattern]_
],
zh: [
	_Wikipedia: #link(url_singleton)[Singleton Pattern]_
]))
]

= #tr((
  en: [But why can't we just use global variable(s)?],
  de: [Aber warum können wir nicht einfach globale Variable(n) verwenden?],
  ja: [なぜグローバル変数は使えないのか？],
  zh: [为什么不可以使用全局变量？],
))

#tr((
en: [
  We could make everything a public static, like this
],
de: [
	Wir könnten alles als „public static" definieren, etwa so:
],
ja: [
  このように、全てをパブリックかつスタティックにすることができます。
],
zh: [
	可以像这样，我们可以使每个东西都变成公共静态的(public static):
]))

```rust
static mut THE_SERIAL_PORT: SerialPort = SerialPort;

fn main() {
    let _ = unsafe {
        THE_SERIAL_PORT.read_speed();
    };
}
```

#tr((
en: [
  But this has a few problems. It is a mutable global variable, and in
  Rust, these are always unsafe to interact with. These variables are also
  visible across your whole program, which means the borrow checker is
  unable to help you track references and ownership of these variables.
],
de: [
	Dies bringt jedoch einige Probleme mit sich. Es handelt sich um eine
	veränderbare globale Variable, und der Zugriff auf solche Variablen ist
	in Rust stets „unsafe". Zudem sind diese Variablen im gesamten Programm
	sichtbar, was bedeutet, dass der Borrow Checker nicht dabei helfen kann,
	die Referenzen und die Ownership dieser Variablen zu verfolgen.
],
ja: [
  しかし、これにはいくつか問題があります。
  これはミュータブルなグローバル変数であり、Rustにおいては、これらとやり取りするのは常にアンセーフです。
  これらの変数はプログラムの全体を通して見えることになり、つまりそれは借用チェッカがこれらの変数の参照や所有権を追跡するのに役立たなくなることを意味します。
],
zh: [
	但是这个带来了一些问题。它是一个可变的全局变量，在Rust，与这些变量交互总是unsafe的。这些变量在你所有的程序间也是可见的，意味着借用检查器不能帮你跟踪这些变量的引用和所有权。
]))

= #tr((
  en: [How do we do this in Rust?],
  de: [Wie machen wir das in Rust?],
  ja: [Rustではどうするか？],
  zh: [在Rust中要怎么做?],
))

#tr((
en: [
  Instead of just making our peripheral a global variable, we might
  instead decide to make a structure, in this case called `PERIPHERALS`,
  which contains an `Option<T>` for each of our peripherals.
],
de: [
	Anstatt unser Peripheriegerät einfach als globale Variable zu
	definieren, könnten wir uns stattdessen dazu entschließen, eine Struktur
	-- in diesem Fall mit dem Namen `PERIPHERALS` -- zu erstellen, die für
	jedes unserer Peripheriegeräte ein `Option<T>` enthält.
],
ja: [
  単にペリフェラルをグローバル変数にする代わりに、各ペリフェラル毎に`Option<T>`を含む`PERIPHERALS`と呼ばれるグローバル変数を作ることにします。
],
zh: [
	与其只是让我们的外设变成一个全局变量，我们不如创造一个结构体，在这个例子里其被叫做
	`PERIPHERALS`，这个全局变量对于我们的每个外设，它都有一个与之对应的
	`Option<T>` ．
]))

```rust
struct Peripherals {
    serial: Option<SerialPort>,
}
impl Peripherals {
    fn take_serial(&mut self) -> SerialPort {
        let p = replace(&mut self.serial, None);
        p.unwrap()
    }
}
static mut PERIPHERALS: Peripherals = Peripherals {
    serial: Some(SerialPort),
};
```

#tr((
en: [
  This structure allows us to obtain a single instance of our peripheral.
  If we try to call `take_serial()` more than once, our code will panic!
],
de: [
	Diese Struktur ermöglicht es uns, eine einzelne Instanz unserer
	Peripheriekomponente zu erhalten. Wenn wir versuchen, `take_serial()`
	mehr als einmal aufzurufen, wird unser Code eine Panic auslösen!
],
ja: [
  この構造体によって、ペリフェラルの唯一のインスタンスが取得できるようになります。
  もしも`take_serial()`を複数回呼び出そうとすれば、コードはパニックするでしょう。
],
zh: [
	这个结构体允许我们获得一个外设的实例。如果我们尝试调用`take_serial()`获得多个实例，我们的代码将会抛出运行时恐慌(panic)！
]))

#raw(block: true, lang: "rust",
"fn main() {
    let serial_1 = unsafe { PERIPHERALS.take_serial() };
    // " + ts((
        en: "This panics!",
        de: "Dies loest eine panic aus!",
        ja: "これはパニックします！",
        zh: "这里造成运行时恐慌！",
      )) + "
    // let serial_2 = unsafe { PERIPHERALS.take_serial() };
}
")

#tr((
en: [
  Although interacting with this structure is `unsafe`, once we have the
  `SerialPort` it contained, we no longer need to use `unsafe`, or the
  `PERIPHERALS` structure at all.
],
de: [
	Obwohl die Interaktion mit dieser Struktur als `unsafe` gilt, benötigen
	wir -- sobald wir über die darin enthaltene `SerialPort`-Instanz
	verfügen -- weder `unsafe`-Code noch die `PERIPHERALS`-Struktur selbst.
],
ja: [
  この構造体とのやり取りは`unsafe`にはなりますが、一度この構造体に含まれる`SerialPort`を取得してしまえばもう`unsafe`や`PERIPHERALS`構造体を使う必要は全くありません。
],
zh: [
	虽然与这个结构体交互是`unsafe`，然而一旦我们获得了它包含的
	`SerialPort`，我们将不再需要使用`unsafe`，或者`PERIPHERALS`结构体。
]))

#tr((
en: [
  This has a small runtime overhead because we must wrap the `SerialPort`
  structure in an option, and we'll need to call `take_serial()` once,
  however this small up-front cost allows us to leverage the borrow
  checker throughout the rest of our program.
],
de: [
	Dies bringt einen geringen Laufzeit-Overhead mit sich, da wir die
	`SerialPort`-Struktur in eine `Option` einbetten und einmalig
	`take_serial()` aufrufen müssen; dieser geringe anfängliche Aufwand
	ermöglicht es uns jedoch, den Borrow-Checker im weiteren Verlauf des
	Programms voll zu nutzen.
],
ja: [
  この方法では、オプション型の中に`SerialPort`構造体をラップし、`take_serial()`を一度コールする必要があるため、実行時に小さなオーバーヘッドとなります。
  しかし、この少々のコストを前払いすることで、残りのプログラムで借用チェッカを利用できるようになるのです。
],
zh: [
	这个带来了少量的运行时开销，因为我们必须打包 `SerialPort`
	结构体进一个option中，且我们将需要调用一次
	`take_serial()`，但是这种少量的前期成本，能使我们在接下来的程序中使用借用检查器(borrow
	checker) 。
]))

= #tr((
  en: [Existing library support],
  de: [Vorhandene Bibliotheksunterstützung],
  ja: [既存のライブラリによるサポート],
  zh: [已存在的库支持],
))

#tr((
en: [
  Although we created our own `Peripherals` structure above, it is not
  necessary to do this for your code. the `cortex_m` crate contains a
  macro called `singleton!()` that will perform this action for you.
],
de: [
	Obwohl wir oben unsere eigene `Peripherals`-Struktur erstellt haben, ist
	dies für Ihren Code nicht erforderlich; das `cortex_m`-Crate enthält ein
	Makro namens `singleton!()`, das diese Aufgabe für Sie übernimmt.
],
ja: [
  上記のコードでは`Peripherals`構造体を作りましたが、あなたのコードでも同じようにする必要はありません。
  `cortex_m`クレートはこれと同様のことをしてくれる`singleton!()`と呼ばれるマクロを含んでいます。
],
zh: [
	虽然我们在上面生成了我们自己的 `Peripherals`
	结构体，但这并不是必须的。`cortex_m` crate 包含一个被叫做 `singleton!()`
	的宏，它可以为你完成这个任务。
]))

#raw(block: true, lang: "rust",
"use cortex_m::singleton;

fn main() {
    // " + ts((
        en: "OK if `main` is executed only once",
        de: "In Ordnung, wenn `main` nur einmal ausgefuehrt wird.",
        ja: "`main`が一度だけしか実行されなければOKです",
        zh: "OK 如果 `main` 只被执行一次",
      )) + "
    let x: &'static mut bool =
        singleton!(: bool = false).unwrap();
}
")

#let url_sinmacro = "https://docs.rs/cortex-m/latest/cortex_m/macro.singleton.html"
#tr((
  en: link(url_sinmacro)[cortex_m docs],
  de: link(url_sinmacro)[cortex_m Dokumente],
))

#let ln_rtic = link("https://github.com/rtic-rs/cortex-m-rtic")[`cortex-m-rtic`]
#tr((
en: [
  Additionally, if you use #ln_rtic, the
  entire process of defining and obtaining these peripherals are
  abstracted for you, and you are instead handed a `Peripherals` structure
  that contains a non-`Option<T>` version of all of the items you define.
],
de: [
	Wenn Sie zudem #ln_rtic
	verwenden, wird der gesamte Prozess der Definition und Bereitstellung
	dieser Peripheriekomponenten für Sie abstrahiert; stattdessen erhalten
	Sie eine `Peripherals`-Struktur, die eine Version aller von Ihnen
	definierten Elemente enthält, die nicht als `Option<T>` vorliegen.
],
zh: [
	另外，如果你使用
	#ln_rtic，它将获取和定义这些外设的整个过程抽象了出来，你将获得一个`Peripherals`结构体，其包含了所有你定义了的项的一个非
	`Option<T>` 的版本。
]))


#raw(block: true, lang: "rust",
"// cortex-m-rtic v0.5.x
#[rtic::app(device = lm3s6965, peripherals = true)]
const APP: () = {
    #[init]
    fn init(cx: init::Context) {
        static mut X: u32 = 0;
         
        // " + ts((
            en: "Cortex-M peripherals",
            de: "Cortex-M-Peripherie",
            zh: "Cortex-M外设",
          )) + "
        let core: cortex_m::Peripherals = cx.core;
        
        // " + ts((
            en: "Device specific peripherals",
            de: "Geraetespezifische Peripheriegeraete",
            zh: "设备特定的外设",
          )) + "
        let device: lm3s6965::Peripherals = cx.device;
    }
}
")

= #tr((
  en: [But why?],
  de: [Aber warum?],
  ja: [しかしなぜ？],
  zh: [为什么？],
))

#tr((
en: [
  But how do these Singletons make a noticeable difference in how our Rust
  code works?
],
de: [
	Aber wie bewirken diese Singletons einen spürbaren Unterschied in der
	Funktionsweise unseres Rust-Codes?
],
ja: [
  しかし、これらのシングルトンがRustのコードの動作にどのような顕著な違いをもたらすのでしょうか？
],
zh: [
	但是这些单例模式是如何使我们的Rust代码在工作方式上产生很大不同的?
]))

#raw(block: true, lang: "rust",
"impl SerialPort {
    const SER_PORT_SPEED_REG: *mut u32 = 0x4000_1000 as _;

    fn read_speed(
        &self // " + ts((
                  en: "<------ This is really, really important",
                  de: "<------ Das ist wirklich, wirklich wichtig.",
                  ja: "<------ これは本当に、本当に重要です。",
                  zh: "<------ 这个真的真的很重要",
                )) + "
    ) -> u32 {
        unsafe {
            ptr::read_volatile(Self::SER_PORT_SPEED_REG)
        }
    }
}
")

#tr((
en: [
  There are two important factors in play here:
  - Because we are using a singleton, there is only one way or place to
    obtain a `SerialPort` structure
  - To call the `read_speed()` method, we must have ownership or a
    reference to a `SerialPort` structure
],
de: [
	Hier spielen zwei wichtige Faktoren eine Rolle:
	- Da wir ein Singleton verwenden, gibt es nur eine Möglichkeit bzw.
	einen Ort, um eine `SerialPort`-Struktur zu erhalten.
	- Um die Methode `read_speed()` aufzurufen, benötigen wir den Besitz
	einer `SerialPort`-Struktur oder eine Referenz darauf.
],
ja: [
  ここには２つの重要な要素があります。
  - シングルトンを使用しているため、`SerialPort`構造体の取得手段や場所は１つだけになります。
  - `read_speed()`メソッドを呼ぶためには、`SerialPort`構造体の所有権もしくは参照を持つ必要があります。
],
zh: [
	这里有两个重要因素:
	- 因为我们正在使用一个单例模式，所以我们只有一种方法或者地方去获得一个
		`SerialPort` 结构体。
	- 为了调用 `read_speed()` 方法，我们必须拥有一个 `SerialPort`
		结构体的所有权或者一个引用。
]))

#tr((
en: [
  These two factors put together means that it is only possible to access
  the hardware if we have appropriately satisfied the borrow checker,
  meaning that at no point do we have multiple mutable references to the
  same hardware!
],
de: [
	Zusammengenommen bedeuten diese beiden Faktoren, dass ein Zugriff auf
	die Hardware nur möglich ist, wenn wir die Anforderungen des
	Borrow-Checkers ordnungsgemäß erfüllt haben -- das heißt, dass zu keinem
	Zeitpunkt mehrere veränderbare Referenzen auf dieselbe Hardware
	existieren!
],
ja: [
  これらの２つの要素をまとめると、借用チェッカを適切に満たしている場合のみハードウェアにアクセスできることを意味します。つまり、同じハードウェアに対して複数のミュータブルな参照を持つことはありません。
],
zh: [
	这两个因素放在一起意味着，只有当我们满足了借用检查器的条件时，我们才有可能访问硬件，也意味着在任何时候不可能存在多个对同一个硬件的可变引用(&mut)！
]))

#raw(block: true, lang: "rust",
"fn main() {
    // " + ts((
        en: "missing reference to `self`! Won't work.",
        de: "Verweis auf `self` fehlt! Das wird nicht funktionieren.",
        ja: "`self`への参照が見つかりません。これはうまく動きません。",
        zh: "缺少对`self`的引用！将不会工作。",
      )) + "
    // SerialPort::read_speed();

    let serial_1 = unsafe { PERIPHERALS.take_serial() };

    // " + ts((
        en: "you can only read what you have access to",
        de: "Sie koennen nur lesen, worauf Sie Zugriff haben",
        ja: "アクセスできるものだけ読み出すことができます。",
        zh: "你只能读取你有权访问的内容",
      )) + "
    let _ = serial_1.read_speed();
}
")

= #tr((
  en: [Treat your hardware like data],
  de: [Behandle deine Hardware wie Daten],
  ja: [ハードウェアをデータのように扱う],
  zh: [像对待数据一样对待硬件],
))

#tr((
en: [
  Additionally, because some references are mutable, and some are
  immutable, it becomes possible to see whether a function or method could
  potentially modify the state of the hardware. For example,
],
de: [
	Da es zudem sowohl veränderbare als auch unveränderbare Referenzen gibt,
	lässt sich erkennen, ob eine Funktion oder Methode potenziell den
	Zustand der Hardware ändern könnte. Zum Beispiel:
],
ja: [
  加えて、いくつかの参照はミュータブルで、またいくつかはイミュータブルなため、関数またはメソッドがハードウェアの状態を変更できるかどうかを確認することが可能になります。
],
zh: [
	另外，因为一些引用是可变的，一些是不可变的，就可以知道一个函数或者方法是否有能力修改硬件的状态。比如，
]))

#tr((
en: [
  This is allowed to change hardware settings:
],
de: [
	Dies darf Hardware-Einstellungen ändern:
],
ja: [
  この関数はハードウェアの設定を変更できます。
],
zh: [
	这个函数可以改变硬件的配置:
]))

```rust
fn setup_spi_port(
    spi: &mut SpiPort,
    cs_pin: &mut GpioPin
) -> Result<()> {
    // ...
}
```

#tr((
en: [
  This isn't:
],
de: [
	Das nicht:
],
ja: [
  このメソッドは変更できません。
],
zh: [
  这个不行:
]))

```rust
fn read_button(gpio: &GpioPin) -> bool {
    // ...
}
```

#tr((
en: [
  This allows us to enforce whether code should or should not make changes
  to hardware at *compile time*, rather than at runtime. As a note,
  this generally only works across one application, but for bare metal
  systems, our software will be compiled into a single application, so
  this is not usually a restriction.
],
de: [
	Dies ermöglicht es uns, bereits zur *Kompilierzeit* -- und nicht
	erst zur Laufzeit -- festzulegen, ob Code Änderungen an der Hardware
	vornehmen darf oder nicht. Zu beachten ist, dass dies im Allgemeinen nur
	innerhalb einer einzelnen Anwendung funktioniert; da unsere Software für
	Bare-Metal-Systeme jedoch als eine einzige Anwendung kompiliert wird,
	stellt dies üblicherweise keine Einschränkung dar.
],
ja: [

  これにより、実行時ではなく*コンパイル時に*コードがハードウェアを変更するかどうかを強制できます。
  注意点としては、通常この強制はひとつのアプリケーション内でのみ機能します。ベアメタルシステムにおいては、ソフトウェアはひとつのアプリケーションにコンパイルされるため、これは一般的には制約にはなりません。

],
zh: [
	这允许我们在*编译时*而不是运行时强制代码是否应该或者不应该对硬件进行修改。要注意，这通常在只有一个应用的情况下起作用，但是对于裸机系统来说，我们的软件将被编译进一个单一应用中，因此这通常不是一个限制。
]))
