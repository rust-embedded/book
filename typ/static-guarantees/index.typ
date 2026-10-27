#import "../config.typ": *

#h1((en: [Static Guarantees],
  de: [Statische Garantien],
  ja: [静的な保証],
  zh: [静态保障],
))

#let ln_send = link("https://doc.rust-lang.org/core/marker/trait.Send.html")[`Send`]
#let ln_sync = link("https://doc.rust-lang.org/core/marker/trait.Sync.html")[`Sync`]
#tr((
en: [
  Rust's type system prevents data races at compile time
  (see #ln_send and #ln_sync traits).
  The type system can also be used to check other properties at
  compile time; reducing the need for runtime checks in some cases.
],
de: [
  Das Typsystem von Rust verhindert Data Races zur Kompilierzeit
  (siehe die Traits #ln_send und #ln_sync).
  Zudem lässt sich das Typsystem nutzen, um weitere Eigenschaften bereits
  zur Kompilierzeit zu überprüfen, wodurch in einigen Fällen
  Laufzeitprüfungen überflüssig werden.
],
ja: [
  コンパイル時にデータ競合を防ぐのは、Rustの型システムです（#ln_send;と#ln_sync;トレイトを参照）。
  この型システムは、コンパイル時に他のプロパティをチェックするためにも使用できます。
  その結果、実行時チェックの必要性を減らせる場合があります。
],
zh: [
  Rust的类型系统可以在编译时防止数据竞争(看#ln_send;和#ln_sync;特性(traits))。也可以在编译时使用类型系统来完成一些检查工作；减少某些例子中对运行时检查的需要。
]))

#tr((
en: [
  When applied to embedded programs these _static checks_ can be
  used, for example, to enforce that configuration of I/O interfaces is
  done properly. For instance, one can design an API where it is only
  possible to initialize a serial interface by first configuring the pins
  that will be used by the interface.
],
de: [
  Bei Embedded-Programmen lassen sich diese _statischen Prüfungen_
  beispielsweise nutzen, um sicherzustellen, dass die Konfiguration von
  E/A-Schnittstellen korrekt erfolgt. So lässt sich etwa eine API
  entwerfen, bei der die Initialisierung einer seriellen Schnittstelle nur
  möglich ist, wenn zuvor die für diese Schnittstelle vorgesehenen Pins
  konfiguriert wurden.
],
ja: [
  組込みプログラムに適用する場合、これらの_静的なチェック_は、例えば、入出力インタフェースが正しく設定されていることを強制することができます。
  例えば、使用されるピンを最初に設定することによってのみ、シリアルインタフェースを初期化できるようなAPI設計が可能です。
],
zh: [
  当应用到嵌入式程序时，这些_静态检查_能被用来，比如，强制按需配置I/O接口。例如，可以设计一个初始化串行接口的API，这个API只有在配置好接口需要的管脚后才可以被正确地使用。
]))

#tr((
en: [
  One can also statically check that operations, like setting a pin low,
  can only be performed on correctly configured peripherals. For example,
  trying to change the output state of a pin configured in floating input
  mode would raise a compile error.
],
de: [
  Zudem lässt sich statisch überprüfen, ob Operationen -- wie etwa das
  Setzen eines Pins auf den Pegel „Low" -- nur an korrekt konfigurierten
  Peripheriekomponenten ausgeführt werden. Der Versuch, den
  Ausgangszustand eines Pins zu ändern, der als „Floating Input" (Eingang
  mit undefiniertem Pegel) konfiguriert ist, würde beispielsweise zu einem
  Kompilierfehler führen.
],
ja: [
  正しく設定されたペリフェラルでのみ、ピンをローレベルにするというような操作ができることを、
  静的にチェックすることも可能です。例えば、フローティング入力モードに設定されたピンの出力状態を変更しようとすると、
  コンパイルエラーが発生します。
],
zh: [
  也可以静态检查,是否是在正确配置了的外设上执行的操作，像是拉低一个管脚这种操作。比如尝试修改一个被配置成浮空输入模式的管脚的输出状态时，会触发一个编译时错误。
]))

#tr((
en: [
  And, as seen in the previous chapter, the concept of ownership can be
  applied to peripherals to ensure that only certain parts of a program
  can modify a peripheral. This _access control_ makes software
  easier to reason about compared to the alternative of treating
  peripherals as global mutable state.
],
de: [
  Wie bereits im vorherigen Kapitel erläutert, lässt sich auch das Konzept
  des „Ownership" (Besitzverhältnis) auf Peripheriekomponenten anwenden,
  um sicherzustellen, dass nur bestimmte Programmteile diese modifizieren
  können. Diese _Zugriffskontrolle_ erleichtert das Verständnis und
  die Analyse der Software im Vergleich zu dem alternativen Ansatz,
  Peripheriekomponenten als globalen, veränderbaren Zustand zu behandeln.
],
ja: [
  以前の章で見た通り、所有権の概念はペリフェラルにも適用できます。所有権は、プログラムの特定部分のみがペリフェラルを変更することを保証します。
  この_アクセスコントロール_は、ペリフェラルをグローバルでミュータブルな状態として扱う代替案と比較して、
  ソフトウェアの解析をより簡単にします。
],
zh: [
  并且，像是在前面章节看到的，所有权的概念能被应用到外设上确保一个程序只有某些部分可以修改一个外设。与将这个外设当做全局可变的状态相比，_访问控制_(assess control)使得软件更容易推理。
]))
