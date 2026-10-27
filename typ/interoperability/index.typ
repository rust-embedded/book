#import "../config.typ": *

#h1((en: [Interoperability],
  de: [Interoperabilität],
  ja: [相互運用性],
  zh: [互操性],
))

#let ln_ffi = link("https://doc.rust-lang.org/std/ffi/index.html")[`std::ffi`]
#tr((
en: [
  Interoperability between Rust and C code is always dependent on
  transforming data between the two languages. For this purpose, there is
  a dedicated module in the `stdlib` called #ln_ffi.
],
de: [
  Die Interoperabilität zwischen Rust- und C-Code hängt stets von der
  Umwandlung von Daten zwischen den beiden Sprachen ab. Hierfür gibt es in
  der Standardbibliothek (`stdlib`) ein spezielles Modul namens #ln_ffi.
],
ja: [
  #todoupd("ja")
  RustとCとの相互運用性は、常に2つの言語間のデータ変換に依存しています。
  そこで、2つの専用モジュールが`stdlib`内にあります。
  #ln_ffi;と呼ばれるものです。
],
zh: [
  Rust和C代码之间的互操性始终依赖于数据在两个语言间的转换．为了互操性，在`stdlib`中有一个专用的模块，叫作 #ln_ffi.
]))

#tr((
en: [
  `std::ffi` provides type definitions for C primitive types, such as
  `char`, `int`, and `long`. It also provides some utility for converting
  more complex types such as strings, mapping both `&str` and `String` to
  C types that are easier and safer to handle.
],
de: [
  `std::ffi` stellt Typdefinitionen für primitive C-Datentypen bereit, wie
  etwa `char`, `int` und `long`. Zudem bietet es Hilfsmittel zur
  Konvertierung komplexerer Typen wie Strings, indem es sowohl `&str` als
  auch `String` auf C-Typen abbildet, die sich einfacher und sicherer
  handhaben lassen.
],
zh: [
  `std::ffi`提供了与C基础类型对应的类型定义，比如`char`，
  `int`，和`long`．
  它也提供了一些工具用于更复杂的类型之间的转换，比如字符串，可以把`&str`和`String`映射成更容易和安全处理的C类型．
]))

#let ln_cty = link("https://crates.io/crates/cty")[`cty`]
#let ln_cstr = link("https://crates.io/crates/cstr_core")[`cstr_core`]
#tr((
en: [
  As of Rust 1.30, functionalities of `std::ffi` are available in either
  `core::ffi` or `alloc::ffi` depending on whether or not memory
  allocation is involved. The #ln_cty crate and the #ln_cstr
  crate also offer similar functionalities.
],
de: [
  Seit Rust 1.30 stehen die Funktionalitäten von `std::ffi` wahlweise in
  `core::ffi` oder `alloc::ffi` zur Verfügung, je nachdem, ob
  Speicherreservierungen erforderlich sind oder nicht.
  Auch die Crates #ln_cty und #ln_cstr bieten vergleichbare Funktionalitäten an.
],
zh: [
  从Rust
  1.30以来，`std::ffi`的功能也出现在`core::ffi`或者`alloc::ffi`中，取决于是否涉及到内存分配．
  #ln_cty;库和#ln_cstr;库也提供了相同的功能．
]))

#figure(
  kind: table,
  table(
    columns: 3,
    align: (auto,auto,auto,),
    table.header(
      tr((
        en: [Rust type],
        de: [Rusttyp],
        ja: [Rustの型],
        zh: [Rust类型],
      )),
      tr((
        en: [Intermediate],
        de: [Dazwischenliegend],
        ja: [中間表現],
        zh: [间接],
      )),
      tr((
        en: [C type],
        de: [C-Typ],
        ja: [Cの型],
        zh: [C类型],
      )),
    ),
    `String`, `CString`, `char *`,
    `&str`, `CStr`, `const char *`,
    `()`, `c_void`, `void`,
    tr((
      en: [`u32` or `u64`],
      de: [`u32` or `u64`],
      ja: [`u32` or `u64`],
    )),
    )),
    `c_uint`, `unsigned int`,
    tr((
      en: [etc],
      de: [usw.],
      ja: [他],
    )),
    […], […],
  )
)

#tr((
en: [
  A value of a C primitive type can be used as one of the corresponding
  Rust type and vice versa, since the former is simply a type alias of the
  latter. For example, the following code compiles on platforms where
  `unsigned int` is 32-bit long.
],
de: [
  Ein Wert eines primitiven C-Datentyps kann als Wert des entsprechenden
  Rust-Datentyps verwendet werden und umgekehrt, da der erstere lediglich
  ein Typalias des letzteren ist. Beispielsweise lässt sich der folgende
  Code auf Plattformen kompilieren, auf denen `unsigned int` 32 Bit lang
  ist.
],
zh: [
  一个C基本类型的值可以被用来作为相关的Rust类型的值，反之亦然，因此前者仅仅是后者的一个类型伪名．
  比如，下列的代码可以在`unsigned int`是32位宽的平台上编译．
]))

```rust
fn foo(num: u32) {
    let c_num: c_uint = num;
    let r_num: u32 = c_num;
}
```

== #tr((
  en: [Interoperability with other build systems],
  de: [Interoperabilität mit anderen Build-Systemen],
  ja: [他のビルドシステムとの相互運用性],
  zh: [与其它编译系统的互用性],
))

#tr((
en: [
  A common requirement for including Rust in your embedded project is
  combining Cargo with your existing build system, such as make or cmake.
],
de: [
  Eine häufige Voraussetzung für die Einbindung von Rust in
  Embedded-Projekte ist die Kombination von Cargo mit Ihrem bestehenden
  Build-System, beispielsweise Make oder CMake.
],
ja: [
  組込みプロジェクトにRustを組み込むための共通の要件は、Cargoとmakeやcmakeのような既存のビルドシステムとを組み合わせることです。
],
zh: [
  在嵌入式项目中引入Rust的一个常见需求是，把Cargo结合进你现存的编译系统中，比如make或者cmake。
]))

#let url_issue61 = "https://github.com/rust-embedded/book/issues/61"
#tr((
en: [
  We are collecting examples and use cases for this on our issue tracker
  in #link(url_issue61)[issue \#61].
],
de: [
  Wir sammeln Beispiele und Anwendungsfälle hierzu in unserem
  Problem-Verfolgungswerkzeug unter #link(url_issue61)[Issue \#61].
],
ja: [
  #link(url_issue61)[issue \#61]でこれに関する事例とユースケースを集めています。
],
zh: [
  在#link(url_issue61)[issue \#61]的issue
  tracker上，我们正在为这个需求收集例子和用例。
]))

== #tr((
  en: [Interoperability with RTOSs],
  de: [Interoperabilität mit RTOS],
  ja: [RTOSとの相互運用性],
  zh: [与RTOSs的互操性],
))

#tr((
en: [
  Integrating Rust with an RTOS such as FreeRTOS or ChibiOS is still a
  work in progress; especially calling RTOS functions from Rust can be
  tricky.
],
de: [
  Die Integration von Rust in ein RTOS wie FreeRTOS oder ChibiOS befindet
  sich noch in der Entwicklung; insbesondere der Aufruf von
  RTOS-Funktionen aus Rust heraus kann sich als schwierig erweisen.
],
ja: [
  RustをFreeRTOSやChibiOSといったRTOSに統合することは、まだ作業を進めている状態です。
  特に、RTOSの関数をRustから呼び出すことはトリッキーです。
],
zh: [
  将Rust和一个RTOS集成在一起，比如FreeRTOS或者ChibiOS仍然在进行中;
  尤其是从Rust调用RTOS函数可能很棘手。
]))

#let url_zephyr = "https://docs.zephyrproject.org/latest/develop/languages/rust/index.html"
#tr((
en: [
  Currently, the following projects publicly support Rust\<-\>RTOS
  interoperability:
  - #link(url_zephyr)[Zephyr Project]
],
de: [
  Derzeit unterstützen die folgenden Projekte öffentlich die
  Interoperabilität zwischen Rust und RTOS:
  - #link(url_zephyr)[Zephyr-Projekt]
]))

#let url_issue62 = "https://github.com/rust-embedded/book/issues/62"
#tr((
en: [
  We are collecting examples and use cases for this on our issue tracker
  in #link(url_issue62)[issue \#62].
],
de: [
  Wir sammeln hierfür Beispiele und Anwendungsfälle in unserem
  Problem-Verfolgungswerkzeug unter
  #link(url_issue62)[Issue \#62].
],
ja: [
  #link(url_issue62)[issue \#62]でこれに関する事例とユースケースを集めています。
],
zh: [
  在#link(url_issue62)[issue \#62]的issue
  tracker上，我们正为这件事收集例子和用例。
]))
