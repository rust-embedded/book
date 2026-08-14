#import "../config.typ": *

#h1((en: [Panicking],
  de: [In Panik geraten],
  ja: [パニック],
  zh: [运行时恐慌(Panicking)],
), offset: whole)
<getting-started-panicking>

#tr((
en: [
  Panicking is a core part of the Rust language. Built-in operations like
  indexing are runtime checked for memory safety. When out of bounds
  indexing is attempted this results in a panic.
],
de: [
  Das Auslösen einer Panik ist ein wesentlicher Bestandteil der Sprache
  Rust. Eingebaute Operationen wie der Zugriff per Index werden zur
  Laufzeit auf Speichersicherheit überprüft. Erfolgt ein Zugriff außerhalb
  der zulässigen Grenzen, führt dies zu einer Panik.
],
ja: [
  パニックはRustのコア部分です。インデックス操作のような言語組込みの操作は、メモリ安全性をランタイム時に検査されます。
  範囲外のインデックスにアクセスしようとすると、パニックが発生します。
],
zh: [
  运行时恐慌是Rust语言的一个核心部分。像是索引这样的内建的操作为了存储安全性是运行时检查的。当尝试越界索引时，这会导致运行时恐慌(panic)。
]))

#tr((
en: [
  In the standard library panicking has a defined behavior: it unwinds the
  stack of the panicking thread, unless the user opted for aborting the
  program on panics.
],
de: [
  In der Standardbibliothek ist das Verhalten bei einer Panik definiert:
  Der Stack des betroffenen Threads wird abgewickelt (Stack Unwinding), es
  sei denn, der Benutzer hat sich für einen Programmabbruch im Falle einer
  Panik entschieden.
],
ja: [
  標準ライブラリでは、パニックは定義された動作です。ユーザがパニック発生時にプログラムをアボートする選択をしない限り、
  パニックを起こしたスレッドのスタックを巻き戻します。
],
zh: [
  在标准库中，运行时恐慌的行为被定义成：展开(unwinds)恐慌的线程的栈，除非用户自己选择在恐慌时终止程序。
]))

#let ln_info = link("https://doc.rust-lang.org/core/panic/struct.PanicInfo.html")[`PanicInfo`]
#tr((
en: [
  In programs without standard library, however, the panicking behavior is
  left undefined. A behavior can be chosen by declaring a
  `#[panic_handler]` function. This function must appear exactly
  _once_ in the dependency graph of a program, and must have the
  following signature: `fn(&PanicInfo) -> !`, where #ln_info
  is a struct containing information about the location of the panic.
],
de: [
  In Programmen ohne Standardbibliothek ist das Verhalten bei einer Panik
  hingegen nicht definiert. Ein Verhalten lässt sich durch die Deklaration
  einer `#[panic_handler]`-Funktion festlegen. Diese Funktion muss im
  Abhängigkeitsgraphen des Programms genau _einmal_ vorkommen und
  folgende Signatur aufweisen: `fn(&PanicInfo) -> !`, wobei #ln_info
  eine Struktur ist, die Informationen über den Ort des Panic enthält.
],
ja: [
  しかし、非標準のプログラムでは、パニック時の挙動は、未定義のままです。`#[panic_handler]`関数を宣言することにより、
  挙動を選択することができます。この関数は、プログラムの依存関係グラフに、*1回だけ*現れる必要があります。
  そして、 `fn(&PanicInfo) -> !`のシグネチャを持つ必要があります。
  ここで、#ln_info;は、パニックした位置情報を含む構造体です。
],
zh: [
  然而在没有标准库的程序中，运行时恐慌的行为是未被定义了的。通过声明一个
  `#[panic_handler]` 函数可以选择一个运行时恐慌的行为。

  这个函数在一个程序的依赖图中必须只出现一次，且必须有这样的签名:
  `fn(&PanicInfo) -> !`，`PanicInfo`是一个包含关于发生运行时恐慌的位置信息的结构体。
]))

#let ln_abort = link("https://crates.io/crates/panic-abort")[`panic-abort`]
#let ln_halt = link("https://crates.io/crates/panic-halt")[`panic-halt`]
#let ln_itm = link("https://crates.io/crates/panic-itm")[`panic-itm`]
#let ln_sh = link("https://crates.io/crates/panic-semihosting")[`panic-semihosting`]
#tr((
en: [
  Given that embedded systems range from user facing to safety critical
  (cannot crash) there's no one size fits all panicking behavior but there
  are plenty of commonly used behaviors. These common behaviors have been
  packaged into crates that define the `#[panic_handler]` function. Some
  examples include:
  - #ln_abort. A panic causes the abort instruction to be executed.
  - #ln_halt. A panic causes the program, or the current thread, to halt by entering an infinite loop.
  - #ln_itm. The panicking message is logged using the ITM, an ARM Cortex-M specific peripheral.
  - #ln_sh. The panicking message is logged to the host using the semihosting technique.
],
de: [
  Da das Spektrum eingebetteter Systeme von anwenderorientierten bis hin
  zu sicherheitskritischen Anwendungen (bei denen ein Absturz
  ausgeschlossen sein muss) reicht, gibt es kein universelles Verhalten im
  Fehlerfall („Panic"); es existieren jedoch zahlreiche gängige Ansätze.
  Diese verbreiteten Verhaltensweisen wurden in Crates zusammengefasst,
  die die Funktion `#[panic_handler]` definieren. Zu den Beispielen
  gehören:
  - #ln_abort. Eine Panic bewirkt die Ausführung der Abbruchanweisung.
  - #ln_halt. Ein Panic bewirkt, dass das Programm oder der aktuelle
    Thread anhält, indem es bzw. er in eine Endlosschleife eintritt.
  - #ln_itm. Die Panik-Meldung wird mithilfe des ITM protokolliert -- einer für ARM
    Cortex-M spezifischen Peripheriekomponente.
  - #ln_sh. Die Panik-Meldung wird mithilfe der Semihosting-Technik
    auf dem Host protokolliert.
],
ja: [
  組込みシステムは、ユーザとやり取りするものから、安全性が重要な（クラッシュできない）ものまであります。
  そのため、全てのパニック時動作に対応できる唯一のものはありませんが、よく利用される挙動がたくさんあります。
  これらの一般的な挙動が、`#[panic_handler]`関数を定義するクレートにまとめられています。
  いくつか、例を挙げます。
  - #ln_abort。パニックが発生すると、アボート命令を実行します。
  - #ln_halt。パニックが発生すると、プログラム、または、現在のスレッドは、無限ループに入ることで停止します。
  - #ln_itm。パニック発生時のメッセージは、ARM
    Cortex-M固有のペリフェラルであるITMを使ってログ出力されます。
  - #ln_sh。パニック発生時のメッセージは、セミホスティングを使ってログ出力されます。
],
zh: [
  鉴于嵌入式系统的范围从面向用户的系统到安全关键系统，没有一个运行时恐慌行为能满足所有场景，但是有许多常用的行为。这些常用的行为已经被打包进了一些crates中，这些crates中定义了
  `#[panic_handler]`函数。比如:
  - #ln_abort.
    这个运行时恐慌会导致终止指令被执行。
  - #ln_halt.
    这个运行时恐慌会导致程序，或者现在的线程，通过进入一个无限循环中而挂起。
  - #ln_itm.
    运行时恐慌的信息会被ITM记录，ITM是一个ARM Cortex-M的特殊的外设。
  - #ln_sh.
    使用半主机技术，运行时恐慌的信息被记录到主机上。

]))

#let ln_handler = link("https://crates.io/keywords/panic-handler")[`panic-handler`]
#tr((
en: [
  You may be able to find even more crates searching for the
  #ln_handler keyword on crates.io.
],
de: [
  Möglicherweise findest du noch mehr Crates, wenn du auf crates.io nach
  dem Schlüsselwort #ln_handler suchst.
],
ja: [
  crates.ioで#ln_handler;をキーワードに検索することで、さらにクレートを見つけることができます。
],
zh: [
  在crates.io上搜索
  #ln_handler，你甚至可以找到更多的crates。
]))

#tr((
en: [
  A program can pick one of these behaviors simply by linking to the
  corresponding crate. The fact that the panicking behavior is expressed
  in the source of an application as a single line of code is not only
  useful as documentation but can also be used to change the panicking
  behavior according to the compilation profile. For example:
],
de: [
  Ein Programm kann eines dieser Verhalten einfach dadurch auswählen, dass
  es das entsprechende Crate einbindet. Dass das Verhalten im Fehlerfall
  (Panic-Verhalten) im Quellcode einer Anwendung als einzelne Codezeile
  ausgedrückt wird, ist nicht nur als Dokumentation nützlich, sondern
  ermöglicht es auch, dieses Verhalten je nach Kompilierungsprofil
  anzupassen. Zum Beispiel:
],
ja: [
  プログラムは、対応するクレートとリンクすることで、これらの挙動の中から1つを選びます。
  パニック時の挙動がアプリケーションソースコードの中で単一行で表現されていることは、ドキュメントとして有用なだけでなく、
  パニック時の挙動をコンパイル時のプロファイルで変更にする時にも利用できます。
  例えば
],
zh: [
  仅仅通过链接到相关的crate中，一个程序就可以简单地从这些行为中选择一个运行时恐慌行为。将运行时恐慌的行为作为一行代码放进一个应用的源码中，不仅仅是因为可以作为文档使用，而且能根据编译配置改变运行时恐慌的行为。比如:
]))

#raw(block: true, lang: "rust",
"#![no_main]
#![no_std]

// " + ts((
    en: "dev profile: easier to debug panics; can put a breakpoint on `rust_begin_unwind`",
    de: "dev-Profil: einfacheres Debuggen von Panics; man kann einen Breakpoint bei 
// `rust_begin_unwind` setzen.",
    ja: "開発プロファイル：パニックのデバッグを容易にします。`rust_begin_unwind`にブレイクポイントを置くことを可能にします。",
    zh: "dev配置: 更容易调试运行时恐慌; 可以在 `rust_begin_unwind` 上放一个断点"
  )) + "
#[cfg(debug_assertions)]
use panic_halt as _;

// " + ts((
    en: "release profile: minimize the binary size of the application",
    de: "Release-Profil: Minimierung der Binaergroesse der Anwendung",
    ja: "リリースプロファイル：アプリケーションのバイナリサイズを最小化します。",
    zh: "release配置: 最小化应用的二进制文件的大小",
  )) + "
#[cfg(not(debug_assertions))]
use panic_abort as _;

// ..
")

#tr((
en: [
  In this example the crate links to the `panic-halt` crate when built
  with the dev profile (`cargo build`), but links to the `panic-abort`
  crate when built with the release profile (`cargo build --release`).
],
de: [
  In diesem Beispiel verlinkt der Crate beim Bauen mit dem Dev-Profil
  (`cargo build`) auf den `panic-halt`-Crate, beim Bauen mit dem
  Release-Profil (`cargo build --release`) hingegen auf den
  `panic-abort`-Crate.
],
ja: [
  #todoupd("ja")
  この例では、開発プロファイルでビルド（`cargo build`）した時は、`panic-halt`クレートとリンクします。
  しかし、リリースプロファイルでビルド（`cargo build --release`）した時は、`panic-abort`クレートとリンクします。
],
zh: [
  在这个例子里，当使用dev配置编译的时候(`cargo build`)，crate链接到
  `panic-halt`
  crate上，但是当使用release配置编译时(`cargo build --release`)，crate链接到`panic-abort`
  crate上。
]))

#quote(block: true)[
#tr((
en: [
  The `use panic_abort as _;` form of the `use` statement is used to
  ensure the `panic_abort` panic handler is included in our final
  executable while making it clear to the compiler that we won't
  explicitly use anything from the crate. Without the `as _` rename, the
  compiler would warn that we have an unused import. Sometimes you might
  see `extern crate panic_abort` instead, which is an older style used
  before the 2018 edition of Rust, and should now only be used for
  "sysroot" crates (those distributed with Rust itself) such as
  `proc_macro`, `alloc`, `std`, and `test`.
],
de: [
  Die `use panic_abort as _;`-Variante der `use`-Anweisung wird verwendet,
  um sicherzustellen, dass der `panic_abort`-Panic-Handler in die fertige
  ausführbare Datei aufgenommen wird, während dem Compiler gleichzeitig
  signalisiert wird, dass wir nichts aus diesem Crate explizit verwenden
  werden. Ohne die Umbenennung mittels `as _` würde der Compiler eine
  Warnung wegen eines ungenutzten Imports ausgeben. Gelegentlich stößt man
  stattdessen auf `extern crate panic_abort`\; dabei handelt es sich um
  einen älteren Stil, der vor der Rust-Edition 2018 üblich war und heute
  nur noch für sogenannte „sysroot"-Crates (die gemeinsam mit Rust selbst
  ausgeliefert werden) -- wie etwa `proc_macro`, `alloc`, `std` und `test`
  -- verwendet werden sollte.
],
zh: [
  `use panic_abort as _` 形式的 `use` 语句，被用来确保 `panic_abort`
  运行时恐慌函数被包含进我们最终的可执行程序里，同时让编译器清楚地知道我们不会从这个crate显式地使用任何东西。没有
  `_` 重命名，编译器将会警告我们有一个未使用的导入。有时候你可能会看到
  `extern crate panic_abort`，这是Rust
  2018之前的版本使用的更旧的写法，现在应该只被用于 "sysroot" crates
  (与Rust一起发布的crates)，比如 `proc_macro`，`alloc`，`std` 和 `test` 。
]))
]

= #tr((
  en: [An example],
  de: [Ein Beispiel],
  ja: [例],
  zh: [一个例子],
))

#tr((
en: [
  Here's an example that tries to index an array beyond its length. The
  operation results in a panic.
],
de: [
  Hier ist ein Beispiel, das versucht, auf ein Array an einer Position
  zuzugreifen, die über dessen Länge hinausgeht. Der Vorgang führt zu einer Panic.
],
ja: [
  配列の長さを超えてアクセスしようとする例を示します。この操作はパニックを引き起こします。
],
zh: [
  这里有一个尝试越界访问数组的例子。操作的结果导致了一个运行时恐慌(panic)。
]))

#raw(block: true, lang: "rust",
"#![no_main]
#![no_std]

use panic_semihosting as _;

use cortex_m_rt::entry;

#[entry]
fn main() -> ! {
    let xs = [0, 1, 2];
    let i = xs.len();
    let _y = xs[i]; // " + ts((
                        en: "out of bounds access",
                        de: "Zugriff ausserhalb der zulaessigen Grenzen",
                        ja: "範囲外アクセス",
                        zh: "out of bounds access"
                      )) + "

    loop {}
}
")

#tr((
en: [
  This example chose the `panic-semihosting` behavior which prints the
  panic message to the host console using semihosting.
],
de: [
  Für dieses Beispiel wurde das Verhalten `panic-semihosting` gewählt, das
  die Panic-Meldung mittels Semihosting auf der Host-Konsole ausgibt.
],
ja: [
  この例では、`panic-semihosting`の挙動を選択しており、パニックメッセージは、
  セミホスティングを使ってホストコンソールに出力されます。
],
zh: [
  这个例子选择了`panic-semihosting`行为，运行时恐慌的信息会被打印至使用了半主机模式的主机控制台上。
]))

```text
$ cargo run
     Running `qemu-system-arm -cpu cortex-m3 -machine lm3s6965evb (..)
panicked at 'index out of bounds: the len is 3 but the index is 4', src/main.rs:12:13
```

#tr((
en: [
  You can try changing the behavior to `panic-halt` and confirm that no
  message is printed in that case.
],
de: [
  Sie können versuchen, das Verhalten auf `panic-halt` zu ändern, und
  bestätigen, dass in diesem Fall keine Meldung ausgegeben wird.
],
ja: [
  挙動を`panic-halt`に変更し、その場合にメッセージが出力されないことを確認することができます。
],
zh: [
  你可以尝试将行为改成`panic-halt`，确保在这个案例里没有信息被打印。
]))
