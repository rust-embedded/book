#import "../config.typ": *

#h1((en: [A little C with your Rust],
  de: [Ein bisschen C zu Ihrem Rust],
  ja: [Rustと少しのC],
  zh: [使用C的Rust],
), offset: whole)
<c-with-rust>

#tr((
en: [
  Using C or C++ inside of a Rust project consists of two major parts:
  - Wrapping the exposed C API for use with Rust
  - Building your C or C++ code to be integrated with the Rust code
],
de: [
  Die Verwendung von C oder C++ innerhalb eines Rust-Projekts umfasst zwei
  wesentliche Aspekte:
  - Einkapselung der bereitgestellten C-API für die Verwendung mit Rust
  - Erstellen Ihres C- oder C++-Codes zur Integration mit dem Rust-Code
],
ja: [
  CまたはC++をRustプロジェクトの内部で使うには、主に2つの対応をします。
  - 公開されているCのAPIを、Rustで使えるようにラッピングする
  - CまたはC++のコードを、Rustのコードと一緒にビルドする
],
zh: [
  要在一个Rust项目中使用C或者C++，主要有两个步骤:
  - 用Rust封装要暴露出来使用的C API
  - 编译要和Rust代码集成在一起的C或者C++代码
]))

#tr((
en: [
  As C++ does not have a stable ABI for the Rust compiler to target, it is
  recommended to use the `C` ABI when combining Rust with C or C++.
],
de: [
  Da C++ über keine stabile ABI verfügt, auf die der Rust-Compiler
  abzielen könnte, wird empfohlen, bei der Kombination von Rust mit C oder
  C++ die `C`-ABI zu verwenden.
],
ja: [
  C++は、Rustコンパイラがターゲットにできる安定したABIを持っていないため、CまたはC++とRustとを組み合わせるときは、`C`のABIを使うのがお勧めです。
],
zh: [
  因为对于Rust编译器来说，C++没有一个稳定的ABI，当要将Rust和C或者C++结合时，建议优先选择`C`。
]))

= #tr((
  en: [Defining the interface],
  de: [Definition der Schnittstelle],
  ja: [インタフェースの定義],
  zh: [定义接口],
))

#tr((
en: [
  Before consuming C or C++ code from Rust, it is necessary to define (in
  Rust) what data types and function signatures exist in the linked code.
  In C or C++, you would include a header (`.h` or `.hpp`) file which
  defines this data. In Rust, it is necessary to either manually translate
  these definitions to Rust, or use a tool to generate these definitions.
],
de: [
  Bevor C- oder C++-Code aus Rust heraus verwendet werden kann, muss (in
  Rust) definiert werden, welche Datentypen und Funktionssignaturen im
  verlinkten Code vorhanden sind. In C oder C++ würde man eine
  Header-Datei (`.h` oder `.hpp`) einbinden, die diese Daten definiert. In
  Rust ist es erforderlich, diese Definitionen entweder manuell nach Rust
  zu übertragen oder ein Werkzeug zu ihrer Generierung zu verwenden.
],
ja: [
  RustからCまたはC++のコードを使う前に、リンクされるコードにどのようなデータ型や関数シグネチャが存在するかを、（Rustに）定義する必要があります。
  CまたはC++では、このデータを定義したヘッダファイル（`.h`または`.hpp`）をインクルードします。
  Rustでは、これらの定義を手動で変換するか、定義を自動生成するツールを使うか、のいずれかが必要です。
],
zh: [
  在Rust消费C或者C++代码之前，必须定义(在Rust中定义)，在要被链接的代码中存在什么数据类型和函数签名。在C或者C++中，你要包含一个头文件(`.h`或者`.hpp`)，其定义了这个数据。而在Rust中，必须手动地将这些定义翻译成Rust，或者使用一个工具去生成这些定义。
]))

#tr((
en: [
  First, we will cover manually translating these definitions from C/C++
  to Rust.
],
de: [
  Zunächst behandeln wir die manuelle Übertragung dieser Definitionen von
  C/C++ nach Rust.
],
ja: [
  まずは、C/C++からRustに、定義を手動で変換する方法を説明します。
],
zh: [
  首先，我们将介绍如何将这些定义从C/C++手动地转换为Rust。
]))

== #tr((
  en: [Wrapping C functions and Datatypes],
  de: [Einbinden von C-Funktionen und -Datentypen],
  ja: [Cの関数とデータ型のラッピング],
  zh: [封装C函数和数据类型],
))

#tr((
en: [
  Typically, libraries written in C or C++ will provide a header file
  defining all types and functions used in public interfaces. An example
  file may look like this:
],
de: [
  Typischerweise stellen in C oder C++ geschriebene Bibliotheken eine
  Header-Datei bereit, die alle in öffentlichen Schnittstellen verwendeten
  Typen und Funktionen definiert. Eine Beispieldatei könnte wie folgt aussehen:
],
ja: [
  通常、CまたはC++で書かれたライブラリは、公開インタフェースで使用する全ての型と関数を定義するヘッダファイルを提供します。
  ヘッダファイルの例は次の通りです。
],
zh: [
  通常，用C或者C++写的库会提供一个头文件，头文件定义了所有的类型和用于公共接口的函数。如下是一个示例文件:
]))

```c
/* File: cool.h */
typedef struct CoolStruct {
    int x;
    int y;
} CoolStruct;

void cool_function(int i, char c, CoolStruct* cs);
```

#tr((
en: [
  When translated to Rust, this interface would look as such:
],
de: [
  Nach Rust übertragen, sähe diese Schnittstelle folgendermaßen aus:
],
ja: [
  Rustに変換すると、このインタフェースは次のようになります。
],
zh: [
  当翻译成Rust时，这个接口将看起来像是:
]))

```rust
/* File: cool_bindings.rs */
#[repr(C)]
pub struct CoolStruct {
    pub x: cty::c_int,
    pub y: cty::c_int,
}

extern "C" {
    pub fn cool_function(
        i: cty::c_int,
        c: cty::c_char,
        cs: *mut CoolStruct
    );
}
```

#tr((
en: [
  Let's take a look at this definition one piece at a time, to explain
  each of the parts.
],
de: [
  Schauen wir uns diese Definition Schritt für Schritt an, um die
  einzelnen Bestandteile zu erläutern.
],
ja: [
  各部分の説明をするため、この定義を1つずつ見ていきましょう。
],
zh: [
  让我们一次看一个语句，来解释每个部分。
]))

```rust
#[repr(C)]
pub struct CoolStruct { ... }
```

#tr((
en: [
  By default, Rust does not guarantee order, padding, or the size of data
  included in a `struct`. In order to guarantee compatibility with C code,
  we include the `#[repr(C)]` attribute, which instructs the Rust compiler
  to always use the same rules C does for organizing data within a struct.
],
de: [
  Standardmäßig garantiert Rust weder die Reihenfolge noch das Padding
  oder die Größe der in einer `struct` enthaltenen Daten. Um die
  Kompatibilität mit C-Code zu gewährleisten, verwenden wir das Attribut
  `#[repr(C)]`; dieses weist den Rust-Compiler an, für die Anordnung der
  Daten innerhalb der Struktur stets dieselben Regeln wie C anzuwenden.
],
ja: [
  デフォルトでは、Rustは`struct`に含まれるデータの順序やパディング、サイズを保証しません。
  Cのコードとの互換性を保証するために、`#[repr(C)]`アトリビュートを使います。
  このアトリビュートにより、Rustコンパイラは、構造体のデータをCと同じルールで構成します。
],
zh: [
  默认，Rust不会保证包含在`struct`中的数据的大小，填充，或者顺序。为了保证与C代码兼容，我们使用`#[repr(C)]`属性，它指示Rust编译器总是使用和C一样的规则去组织一个结构体中的数据。
]))


```rust
pub x: cty::c_int,
pub y: cty::c_int,
```

#tr((
en: [
  Due to the flexibility of how C or C++ defines an `int` or `char`, it is
  recommended to use primitive data types defined in `cty`, which will map
  types from C to types in Rust.
],
de: [
  Aufgrund der Flexibilität, wie C oder C++ ein „int" oder „char"
  definiert, wird empfohlen, in „cty" definierte primitive Datentypen zu
  verwenden, die Typen von C auf Typen in Rust abbilden.
],
ja: [
  CまたはC++が`int`や`char`を定義する方法は柔軟であるため、`cty`で定義されているプリミティブデータ型の使用をお勧めします。
  ctyは、Cの型をRustの型にマップします。
],
zh: [
  由于C或者C++定义一个`int`或者`char`的方式很灵活，所以建议使用在`cty`中定义的基础类型，它将类型从C映射到Rust中的类型。
]))

```rust
extern "C" { pub fn cool_function( ... ); }
```

#tr((
en: [
  This statement defines the signature of a function that uses the C ABI,
  called `cool_function`. By defining the signature without defining the
  body of the function, the definition of this function will need to be
  provided elsewhere, or linked into the final library or binary from a
  static library.
],
de: [
  Diese Anweisung definiert die Signatur einer Funktion namens
  `cool_function`, die die C-ABI verwendet. Da die Signatur ohne den
  Funktionsrumpf definiert wird, muss die eigentliche Funktionsdefinition
  an anderer Stelle bereitgestellt oder aus einer statischen Bibliothek in
  die endgültige Bibliothek bzw. das fertige Binärprogramm eingebunden werden.
],
ja: [
  このステートメントは、`cool_function`という名前の、CのABIを使った関数シグネチャを定義します。
  関数本体の定義なしにシグネチャを定義することで、この関数の定義は別の場所で与えられるか、静的ライブラリから最終的なライブラリまたはバイナリにリンクされる必要があります。
],
zh: [
  这个语句定义了一个使用C
  ABI的函数的签名，叫做`cool_function`。因为只定义了签名而没有定义函数的主体，所以这个函数的定义将需要在其它地方定义，或者从一个静态库链接进最终的库或者一个二进制文件中。
]))

```rust
    i: cty::c_int,
    c: cty::c_char,
    cs: *mut CoolStruct
```

#tr((
en: [
  Similar to our datatype above, we define the datatypes of the function
  arguments using C-compatible definitions. We also retain the same
  argument names, for clarity.
],
de: [
  Ähnlich wie bei unserem obigen Datentyp definieren wir die Datentypen
  der Funktionsargumente mithilfe von C-kompatiblen Definitionen. Der
  Übersichtlichkeit halber behalten wir zudem die ursprünglichen Argumentnamen bei.
],
ja: [
  上記のデータ型と同様に、Cと互換の定義を使って、関数の引数のデータ型を定義します。
  わかりやすくするために、引数の名前は同じままにしてあります。
],
zh: [
  与我们上面的数据类型一样，我们使用C兼容的定义去定义函数参数的数据类型。为了清晰可见，我们还保留了相同的参数名。
]))

#tr((
en: [
  We have one new type here, `*mut CoolStruct`. As C does not have a
  concept of Rust's references, which would look like this:
  `&mut CoolStruct`, we instead have a raw pointer. As dereferencing this
  pointer is `unsafe`, and the pointer may in fact be a `null` pointer,
  care must be taken to ensure the guarantees typical of Rust when
  interacting with C or C++ code.
],
de: [
  Hier begegnet uns ein neuer Typ: `*mut CoolStruct`. Da C das Konzept der
  Rust-Referenzen (die etwa so aussehen: `&mut CoolStruct`) nicht kennt,
  verwenden wir stattdessen einen sogenannten „Raw Pointer" (Rohzeiger).
  Da das Dereferenzieren dieses Zeigers als `unsafe` gilt und es sich
  tatsächlich um einen `null`-Zeiger handeln kann, ist bei der Interaktion
  mit C- oder C++-Code besondere Sorgfalt geboten, um die für Rust
  typischen Garantien zu wahren.
],
ja: [
  `*mut CoolStruct`という新しい型があります。Cは、`&mut CoolStruct`のようなRustの参照という概念を持っていません。
  代わりに、生ポインタを使います。
  このポインタの参照外しは、`unsafe`です。また、このポインタは実際に`null`ポインタになる可能性があります。
  CまたはC++のコードとやり取りする時には、Rustが通常行う保証を確実にするように気をつける必要があります。
],
zh: [
  这里我们有了一个新类型，`*mut CoolStruct` 。因为C没有Rust中像
  `&mut CoolStruct`
  这样的引用，替代的是一个裸指针。所以解引用这个指针是`unsafe`的，因为这个指针实际上可能是一个`null`指针，因此当与C或者C++代码交互时必须要小心对待那些Rust做出的安全保证。
]))

== #tr((
  en: [Automatically generating the interface],
  de: [Automatische Generierung der Schnittstelle],
  ja: [インタフェースの自動生成],
  zh: [自动产生接口],
))

#let url_bindgen = "https://github.com/rust-lang/rust-bindgen"
#let url_bindgen_manual = "https://rust-lang.github.io/rust-bindgen/"
#let ln_cty = link("https://crates.io/crates/cty")[`cty`]
#tr((
en: [
  Rather than manually generating these interfaces, which may be tedious
  and error prone, there is a tool called
  #link(url_bindgen)[bindgen] which will
  perform these conversions automatically. For instructions of the usage
  of #link(url_bindgen)[bindgen], please
  refer to the #link(url_bindgen_manual)[bindgen user's manual],
  however the typical process consists of the following:
  + Gather all C or C++ headers defining interfaces or datatypes you would
    like to use with Rust.
  + Write a `bindings.h` file, which `#include "..."`'s each of the files
    you gathered in step one.
  + Feed this `bindings.h` file, along with any compilation flags used to
    compile your code into `bindgen`. Tip: use
    `Builder.ctypes_prefix("cty")` / `--ctypes-prefix=cty` and
    `Builder.use_core()` / `--use-core` to make the generated code
    `#![no_std]` compatible.
  + `bindgen` will produce the generated Rust code to the output of the
    terminal window. This output may be piped to a file in your project,
    such as `bindings.rs`. You may use this file in your Rust project to
    interact with C/C++ code compiled and linked as an external library.
    Tip: don't forget to use the #ln_cty crate if your types in
    the generated bindings are prefixed with `cty`.
],
de: [
  Anstatt diese Schnittstellen manuell zu erstellen -- was mühsam und
  fehleranfällig sein kann --, gibt es ein Werkzeug namens
  #link(url_bindgen)[bindgen], das diese
  Konvertierungen automatisch durchführt. Hinweise zur Verwendung von
  #link(url_bindgen)[bindgen] finden Sie im
  #link(url_bindgen_manual)[bindgen-Benutzerhandbuch]\;
  der typische Ablauf sieht jedoch folgendermaßen aus:
  + Sammeln Sie alle C- oder C++-Header, die Schnittstellen oder
    Datentypen definieren, die Sie mit Rust verwenden möchten.
  + Erstelle eine Datei namens `bindings.h`, die mittels `#include "..."`
    jede der Dateien einbindet, die du in Schritt eins zusammengetragen
    hast.
  + Übergeben Sie diese `bindings.h`-Datei zusammen mit den für die
    Kompilierung Ihres Codes verwendeten Flags an `bindgen`. Tipp:
    Verwenden Sie `Builder.ctypes_prefix("cty")` / `--ctypes-prefix=cty`
    und `Builder.use_core()` / `--use-core`, um den generierten Code
    `#![no_std]`-kompatibel zu machen.
  + `bindgen` gibt den generierten Rust-Code direkt im Terminal aus. Diese
    Ausgabe lässt sich in eine Datei Ihres Projekts umleiten,
    beispielsweise `bindings.rs`. Sie können diese Datei in Ihrem
    Rust-Projekt verwenden, um mit C/C++-Code zu interagieren, der als
    externe Bibliothek kompiliert und gelinkt wurde. Tipp: Vergessen Sie
    nicht, das #ln_cty;-Crate zu
    verwenden, falls die Typen in den generierten Bindings das Präfix
    `cty` aufweisen.
],
ja: [
  面倒であり間違いの元である手動のインタフェース生成ではなく、#link(url_bindgen)[bindgen]と呼ばれるインタフェース変換を自動で行ってくれるツールがあります。
  #link(url_bindgen)[bindgen]の使用手順は、#link(url_bindgen_manual)[bindgenユーザマニュアル]を参照して下さい。
  #link(url_bindgen)[bindgen]を使用するための一般的なプロセスは、次の通りです。
  + Rustで使いたいインタフェースやデータ型を定義している全てのCまたはC++ヘッダを集めます。
  + ステップ1で集めたヘッダファイルを`#include "..."`する`bindings.h`ファイルを書きます。
  + `bindgen`にコンパイルフラグとコードと共に、`bindings.h`を与えます。
    ヒント：`#![no_std]`互換なコードを生成するために、`Builder.ctypes_prefix("cty")`と`--ctypes-prefix=cty`を使って下さい。
  + `bindgen`は、端末のウィンドウに生成したRustコードを出力します。これは、`bindings.rs`のようなプロジェクトのファイルにパイプすることができます。
    外部ライブラリとしてコンパイル、リンクされたC/C++コードとやり取りするために、このファイルをRustプロジェクトで使用できます。
    #todoupd("ja")
],
zh: [
  有一个叫做#link(url_bindgen)[bindgen]的工具，它可以自动执行这些转换，而不用手动生成这些接口，手动进行这样的操作非常繁琐且容易出错。关于#link(url_bindgen)[bindgen]的使用指令，可以参考#link(url_bindgen_manual)[bindgen user's manual]，常用的步骤大致如下:
  + 收集所有定义了你可能在Rust中会用到的数据类型或者接口的C或者C++头文件。
  + 写一个`bindings.h`文件，其`#include "..."`每一个你在步骤一中收集的文件。
  + 将这个`bindings.h`文件和任何用来编译你代码的编译标识发给`bindgen`。贴士:
    使用`Builder.ctypes_prefix("cty")` / `--ctypes-prefix=cty` 和
    `Builder.use_core()` / `--use-core` 去使生成的代码兼容`#![no_std]`
  + `bindgen`将会在终端窗口输出生成的Rust代码。这个文件可能会被通过管道发送给你项目中的一个文件，比如`bindings.rs`
    。你可能要在你的Rust项目中使用这个文件来与被编译和链接成一个外部库的C/C++代码交互。贴士:
    如果你的类型在生成的绑定中被前缀了`cty`，不要忘记使用#ln_cty crate 。
]))

= #tr((
  en: [Building your C/C++ code],
  de: [Erstellen Ihres C/C++-Codes],
  ja: [C/C++コードのビルド],
  zh: [编译你的 C/C++ 代码],
))

#tr((
en: [
  As the Rust compiler does not directly know how to compile C or C++ code
  (or code from any other language, which presents a C interface), it is
  necessary to compile your non-Rust code ahead of time.
],
de: [
  Da der Rust-Compiler nicht direkt weiß, wie man C- oder C++-Code (oder
  Code einer anderen Sprache mit C-Schnittstelle) kompiliert, muss der
  Nicht-Rust-Code vorab kompiliert werden.
],
ja: [
  Rustコンパイラは、CまたはC++のコード（または、Cのインタフェースを提供する他の言語のコード）をコンパイルする方法を直接は知らないため、Rustでないコードは事前にコンパイルする必要があります。
],
zh: [
  因为Rust编译器并不直接知道如何编译C或者C++代码(或者从其它语言来的代码，其提供了一个C接口)，所以必须要静态编译你的非Rust代码。
]))

#tr((
en: [
  For embedded projects, this most commonly means compiling the C/C++ code
  to a static archive (such as `cool-library.a`), which can then be
  combined with your Rust code at the final linking step.
],
de: [
  Bei Embedded-Projekten bedeutet dies meist, dass der C/C++-Code zu einem
  statischen Archiv (z. B. `cool-library.a`) kompiliert wird, welches dann
  im abschließenden Link-Schritt mit dem Rust-Code zusammengeführt werden kann.
],
ja: [
  組込みプロジェクトでは、C/C++のコードを（`cool-library.a`のような）静的なアーカイブにコンパイルすることを意味します。
  このアーカイブは、最終リンク時に、Rustのコードに組み込むことができます。
],
zh: [
  对于嵌入式项目，这通常意味着把C/C++代码编译成一个静态库文档(比如
  `cool-library.a`)，然后其能在最后链接阶段与你的Rust代码组合起来。
]))

#tr((
en: [
  If the library you would like to use is already distributed as a static
  archive, it is not necessary to rebuild your code. Just convert the
  provided interface header file as described above, and include the
  static archive at compile/link time.
],
de: [
  Wenn die gewünschte Bibliothek bereits als statisches Archiv vorliegt,
  ist eine erneute Kompilierung des Codes nicht erforderlich. Es genügt,
  die bereitgestellte Header-Datei für die Schnittstelle wie oben
  beschrieben umzuwandeln und das statische Archiv beim Kompilieren bzw.
  Linken einzubinden.
],
ja: [
  使おうとしているライブラリが、既に静的なアーカイブとして配布されている場合、そのコードを再度ビルドする必要はありません。
  提供されているインタフェースのヘッダファイルを、上述の方法で、単に変換するだけです。
  そして、その静的なアーカイブをコンパイル/リンク時に組み込みます。
],
zh: [
  如果你要使用的库已经作为一个静态库文档被发布，那就没必要重新编译你的代码。只需按照上面所述转换提供的接口头文件，且在编译/链接时包含静态库文档。
]))

#tr((
en: [
  If your code exists as a source project, it will be necessary to compile
  your C/C++ code to a static library, either by triggering your existing
  build system (such as `make`, `CMake`, etc.), or by porting the
  necessary compilation steps to use a tool called the `cc` crate. For
  both of these steps, it is necessary to use a `build.rs` script.
],
de: [
  Liegt der Code als Quellcode-Projekt vor, muss der C/C++-Code in eine
  statische Bibliothek kompiliert werden. Dies kann entweder durch Aufruf
  des vorhandenen Build-Systems (z. B. `make`, `CMake` usw.) oder durch
  Portierung der erforderlichen Kompilierungsschritte auf das sogenannte
  `cc`-Crate erfolgen. Für beide Vorgehensweisen ist die Verwendung eines
  `build.rs`-Skripts erforderlich.
],
ja: [
  もしコードがソースファイルとして存在するのであれば、C/C++のコードを静的ライブラリとしてコンパイルする必要があります。
  （`make`や`CMake`のような）ビルドシステムを使うか、必要なコンパイルステップを`cc`クレートを使って移植するか、いずれかの方法を取れます。
  どちらの方法でも、`build.rs`スクリプトを使う必要があります。
],
zh: [
  如果你的代码作为一个源项目(source
  project)存在，将你的C/C++代码编译成一个静态库将是必须的，要么通过使用你现存的编译系统(比如
  `make`，`CMake`，等等)，要么通过使用一个被叫做`cc`
  crate的工具移植必要的编译步骤。关于这两个，都必须使用一个`build.rs`脚本。
]))

== #tr((
  en: [Rust `build.rs` build scripts],
  de: [Rust-`build.rs`-Build-Skripte],
  ja: [Rustの`build.rs`ビルドスクリプト],
  zh: [Rust的 `build.rs` 编译脚本],
))

#tr((
en: [
  A `build.rs` script is a file written in Rust syntax, that is executed
  on your compilation machine, AFTER dependencies of your project have
  been built, but BEFORE your project is built.
],
de: [
  Ein `build.rs`-Skript ist eine in Rust-Syntax verfasste Datei, die auf
  dem Kompilierrechner ausgeführt wird -- und zwar _nachdem_ die
  Abhängigkeiten Ihres Projekts erstellt wurden, aber _bevor_ Ihr
  Projekt selbst kompiliert wird.
],
ja: [
  `build.rs`スクリプトは、Rustの構文で書かれたファイルです。
  このスクリプトは、プロジェクトの依存をビルドした後、プロジェクトをビルドする前に、コンパイルを行っているコンピュータ上で実行されます。
],
zh: [
  一个 `build.rs`
  脚本是一个用Rust语法编写的文件，它被运行在你的编译机器上，发生在你项目的依赖项被编译*之后*，但是在你的项目被编译*之前* 。
]))

#let url_build_scripts = "https://doc.rust-lang.org/cargo/reference/build-scripts.html"
#tr((
en: [
  The full reference may be found #link(url_build_scripts)[here].
  `build.rs` scripts are useful for generating code
  (such as via #link(url_bindgen)[bindgen]), calling
  out to external build systems such as `Make`, or directly compiling
  C/C++ through use of the `cc` crate.
],
de: [
  Die vollständige Referenz finden Sie #link(url_build_scripts)[hier].
  `build.rs`-Skripte eignen sich beispielsweise zur Code-Generierung (etwa
  mittels #link(url_bindgen)[bindgen]),
  zum Aufruf externer Build-Systeme wie `Make` oder zur direkten
  Kompilierung von C/C++-Code unter Verwendung des `cc`-Crates.
],
ja: [
  完全なリファレンスは#link(url_build_scripts)[ここ]にあります。
  `build.rs`スクリプトは、（#link(url_bindgen)[bindgen]のようなツールを用いて）コードを生成したり、
  `Make`のような外部ビルドシステムを呼び出したり、`cc`クレートを使ってC/C++を直接ビルドしたりするのに便利です。
],
zh: [
  可能能在#link(url_build_scripts)[这里]发现完整的参考。`build.rs`
  脚本能用来生成代码(比如通过#link(url_bindgen)[bindgen])，调用外部编译系统，比如`Make`，或者直接通过使用`cc`
  crate来直接编译C/C++ 。
]))

== #tr((
  en: [Triggering external build systems],
  de: [Auslösen externer Build-Systeme],
  ja: [外部ビルドシステムの使用],
  zh: [使用外部编译系统],
))

#let ln_command = link("https://doc.rust-lang.org/std/process/struct.Command.html")[`std::process::Command`]
#tr((
en: [
  For projects with complex external projects or build systems,
  it may be easiest to use #ln_command
  to "shell out" to your other build systems by traversing relative paths,
  calling a fixed command (such as `make library`), and then copying the
  resulting static library to the proper location in the `target` build
  directory.
],
de: [
  Bei Projekten, die komplexe externe Projekte oder Build-Systeme
  einbinden, ist es oft am einfachsten, #ln_command
  zu verwenden, um andere Build-Systeme aufzurufen (sogenanntes
  „Shelling-out"). Dabei navigieren Sie über relative Pfade, führen einen
  festen Befehl aus (wie etwa `make library`) und kopieren anschließend
  die erzeugte statische Bibliothek an den entsprechenden Ort im
  `target`-Build-Verzeichnis.
],
ja: [
  複雑な外部プロジェクトや外部ビルドシステムを使うプロジェクトに関しては、#ln_command;を使って、他のビルドシステムに対して「シェルを呼び出す」のが最も簡単でしょう。
  これにより、相対パスを渡り歩いたり、（`make library`のような）固定のコマンドを呼び出したり、その後、`target`ビルドディレクトリにある静的ライブラリをコピーしたりすることができます。
],
zh: [
  对于有复杂的外部项或者编译系统的项目，使用#ln_command;通过遍历相对路径来向其它编译系统"输出"，调用一个固定的命令(比如
  `make library`)，然后拷贝最终的静态库到`target`编译文件夹中恰当的位置，可能是最简单的方法。
]))

#tr((
en: [
  While your crate may be targeting a `no_std` embedded platform, your
  `build.rs` executes only on machines compiling your crate. This means
  you may use any Rust crates which will run on your compilation host.
],
de: [
  Auch wenn Ihre Crate für eine eingebettete Plattform ohne
  Standardbibliothek (`no_std`) gedacht ist, wird die `build.rs`
  ausschließlich auf dem Rechner ausgeführt, der die Crate kompiliert. Das
  bedeutet, dass Sie beliebige Rust-Crates verwenden können, die auf Ihrem
  Kompilier-Host lauffähig sind.
],
ja: [
  作っているクレートが`no_std`な組込みプラットフォームをターゲットにしていたとしても、`build.rs`はクレートをコンパイルしているコンピュータ上でのみ動作します。
  そのため、コンパイルしているホスト上で動作する、あらゆるRustのクレートを使うことができます。
],
zh: [
  虽然你的crate目标可能是一个`no_std`嵌入式平台，但你的`build.rs`只运行在负责编译你的crate的机器上。这意味着你能使用任何Rust
  crates，其将运行在你的编译主机上。
]))

== #tr((
  en: [Building C/C++ code with the `cc` crate],
  de: [Kompilieren von C/C++-Code mit dem `cc`-Crate],
  ja: [C/C++コードを`cc`クレートでビルド],
  zh: [使用`cc` crate构建C/C++代码],
))

#let url_cc = "https://github.com/alexcrichton/cc-rs"
#tr((
en: [
  For projects with limited dependencies or complexity, or for projects
  where it is difficult to modify the build system to produce a static
  library (rather than a final binary or executable), it may be easier to
  instead utilize the #link(url_cc)[`cc` crate], which
  provides an idiomatic Rust interface to the compiler provided by the
  host.
],
de: [
  Bei Projekten mit geringen Abhängigkeiten oder überschaubarer
  Komplexität -- oder wenn es schwierig ist, das Build-System so
  anzupassen, dass eine statische Bibliothek (statt einer fertigen
  Binärdatei oder eines ausführbaren Programms) erzeugt wird -- kann es
  einfacher sein, stattdessen das
  #link(url_cc)[`cc`-Crate] zu verwenden;
  dieses bietet eine idiomatische Rust-Schnittstelle zu dem vom Host
  bereitgestellten Compiler.
],
ja: [
  依存や複雑さが少ないプロジェクトや、（最終バイナリや実行ファイルではなく）静的ライブラリを作成するためにビルドシステムを修正するのが難しいプロジェクトであれば、
  代わりに#link(url_cc)[`cc`クレート]を使う方が簡単でしょう。
  ccクレートは、ホスト上のコンパイラへの、扱いやすいRustインタフェースを提供します。
],
zh: [
  对于具有有限的依赖项或者复杂度的项目，或者对于那些难以修改编译系统去生成一个静态库(而不是一个二进制文件或者可执行文件)的项目，使用#url_cc;可能更容易，它提供了一个符合Rust语法的接口，这个接口是关于主机提供的编译器的。
]))

#tr((
en: [
  In the simplest case of compiling a single C file as a dependency to a
  static library, an example `build.rs` script using the
  #link(url_cc)[`cc` crate] would look like this:
],
de: [
  Im einfachsten Fall, bei dem eine einzelne C-Datei als Abhängigkeit für
  eine statische Bibliothek kompiliert wird, sähe ein Beispiel für ein
  `build.rs`-Skript, das das #link(url_cc)[`cc`-Crate] verwendet, folgendermaßen aus:
],
ja: [
  単一のCファイルを静的ライブラリにコンパイルする最も単純な例では、#link(url_cc)[`cc`クレート]を使った`build.rs`スクリプトは次のようになります。
],
zh: [
  在把一个C文件编译成一个静态库的依赖项的最简单的场景下，可以使用#link(url_cc)[`cc` crate]，示例`build.rs`脚本看起来像这样:
]))

```rust
fn main() {
    cc::Build::new()
        .file("src/foo.c")
        .compile("foo");
}
```

#tr((
en: [
  The `build.rs` is placed at the root of the package. Then `cargo build`
  will compile and execute it before the build of the package. A static
  archive named `libfoo.a` is generated and placed in the `target` directory.
],
de: [
  Die Datei `build.rs` befindet sich im Wurzelverzeichnis des Pakets.
  `cargo build` kompiliert und führt sie dann vor dem eigentlichen
  Build-Vorgang des Pakets aus. Dabei wird ein statisches Archiv namens
  `libfoo.a` erstellt und im Verzeichnis `target` abgelegt.
],
zh: [
  要把`build.rs`放在包的根目录下．然后`cargo build`会在构建包之前编译和执行它．一个静态的名为`libfoo.a`的归档文件会生成并被放在`target`文件夹中．
]))
