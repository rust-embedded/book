#import "../config.typ": *

#h1((en: [A little Rust with your C],
  de: [Ein bisschen Rust zu Ihrem C],
  ja: [Cと少しのRust],
  zh: [使用Rust的C],
), offset: whole)
<rust-with-c>

#tr((
en: [
  Using Rust code inside a C or C++ project mostly consists of two parts.
  - Creating a C-friendly API in Rust
  - Embedding your Rust project into an external build system
],
de: [
  Die Verwendung von Rust-Code in einem C- oder C++-Projekt besteht
  größtenteils aus zwei Teilen.
  - Erstellung einer C-kompatiblen API in Rust
  - Einbindung Ihres Rust-Projekts in ein externes Build-System
],
ja: [
  CまたはC++のプロジェクト内でRustのコードを使うためには、主に次の2つの対応をします。
  - Cが扱いやすいAPIをRustに作ります
  - 外部ビルドシステムにRustプロジェクトを組み込みます
],
zh: [
  在C或者C++中使用Rust代码通常由两部分组成。
  - 用Rust生成一个C友好的API
  - 将你的Rust项目嵌入一个外部的编译系统
]))

#tr((
en: [
  Apart from `cargo` and `meson`, most build systems don't have native
  Rust support. So you're most likely best off just using `cargo` for
  compiling your crate and any dependencies.
],
de: [
  Abgesehen von `cargo` und `meson` bieten die meisten Build-Systeme keine
  native Rust-Unterstützung. Daher fährst du höchstwahrscheinlich am
  besten damit, einfach `cargo` für die Kompilierung deines Crates und
  aller Abhängigkeiten zu verwenden.
],
ja: [
  `cargo`と`meson`は別として、ほとんどのビルドシステムはRustをサポートしていません。
  そのため、自分のクレートとその依存関係をコンパイルするには、`cargo`を使うのが一番です。
],
zh: [
  除了`cargo`和`meson`，大多数编译系统没有原生Rust支持。因此你最好只用`cargo`编译你的crate和依赖。
]))

= #tr((
  en: [Setting up a project],
  de: [Ein Projekt einrichten],
  ja: [プロジェクトの準備],
  zh: [设置一个项目],
))

#tr((
en: [
  Create a new `cargo` project as usual.
],
de: [
  Erstellen Sie wie gewohnt ein neues `cargo`-Projekt.
],
ja: [
  いつもどおり、新しい`cargo`プロジェクトを作成します。
]))

#tr((
en: [
  There are flags to tell `cargo` to emit a systems library, instead of
  its regular rust target. This also allows you to set a different output
  name for your library, if you want it to differ from the rest of your crate.
],
de: [
  Es gibt Flags, mit denen man `cargo` anweisen kann, eine
  Systembibliothek anstelle des üblichen Rust-Ziels zu erstellen. Auf
  diese Weise können Sie auch einen abweichenden Namen für die Bibliothek
  festlegen, falls dieser sich von dem des restlichen Crates unterscheiden soll.
],
ja: [
  通常のRustのターゲットではなく、システムライブラリを出力するように、`cargo`に指示するフラグがあります。
  クレートの残り部分と異なる名前を付けたい場合、ライブラリに対して、別の名前を設定することもできます。
],
zh: [
  像往常一样创建一个新的`cargo`项目。有一些标志可以告诉`cargo`去生成一个系统库，而不是常规的rust目标文件。如果你想要它与crate的其它部分不一样，你也可以为你的库设置一个不同的输出名。
]))
 
#raw(block: true, lang: "toml",
"[lib]
name = \"your_crate\"
crate-type = [\"cdylib\"]      # " + ts((
                                  en: "Creates dynamic lib",
                                  de: "Erstellt eine dynamische Bibliothek",
                                  ja: "動的ライブラリを作ります",
                                  zh: "生成动态链接库",
                                )) + "
# crate-type = [\"staticlib\"] # " + ts((
                                  en: "Creates static lib",
                                  de: "Erstellt eine statische Bibliothek",
                                  ja: "静的ライブラリを作ります",
                                  zh: "生成静态链接库",
                                )) + "
")

= #tr((
  en: [Building a `C` API],
  de: [Erstellung einer C-API],
  ja: [`C` APIの作成],
  zh: [构建一个`C` API],
))

#tr((
en: [
  Because C++ has no stable ABI for the Rust compiler to target, we use
  `C` for any interoperability between different languages. This is no
  exception when using Rust inside of C and C++ code.
],
de: [
  Da C++ über keine stabile ABI verfügt, auf die der Rust-Compiler
  abzielen könnte, nutzen wir C für die Interoperabilität zwischen
  verschiedenen Sprachen. Dies gilt auch für die Verwendung von Rust
  innerhalb von C- und C++-Code.
],
ja: [
  C++は、Rustコンパイラがターゲットにできる安定したABIを持っていないため、別言語との相互運用には、CのABIを使用します。
  CとC++のコード内でRustを使うとき、このことに例外はありません。
],
zh: [
  因为对于Rust编译器来说，C++没有稳定的ABI，因此对于不同语言间的互操性我们使用`C`。在C和C++代码的内部使用Rust时也不例外。
]))

== `#[no_mangle]`

#tr((
en: [
  The Rust compiler mangles symbol names differently than native code
  linkers expect. As such, any function that Rust exports to be used
  outside of Rust needs to be told not to be mangled by the compiler.
],
de: [
  Der Rust-Compiler verarbeitet Symbolnamen anders als Linker für nativen
  Code erwarten. Daher muss jeder Funktion, die Rust zur Verwendung
  außerhalb von Rust exportiert, mitgeteilt werden, dass der Compiler sie
  nicht verändern soll.
],
ja: [
  Rustコンパイラは、シンボル名をネイティブコードリンカが期待するものとは異なるものにマングルします。
  そのため、Rustの外にエクスポートするRustの関数は、マングルしないようにコンパイラに指示する必要があります。
],
zh: [
  Rust对符号名的修饰与主机的代码链接器所期望的不同。因此，需要告知任何被Rust导出到Rust外部去使用的函数不要被编译器修饰。
]))

== `extern "C"`

#tr((
en: [
  By default, any function you write in Rust will use the Rust ABI (which
  is also not stabilized). Instead, when building outwards facing FFI APIs
  we need to tell the compiler to use the system ABI.
],
de: [
  Standardmäßig verwendet jede in Rust geschriebene Funktion die Rust-ABI
  (die ebenfalls nicht stabilisiert ist). Beim Erstellen von nach außen
  gerichteten FFI-APIs muss der Compiler daher angewiesen werden, die
  System-ABI zu verwenden.
],
ja: [
  デフォルトでは、Rustに書いたいずれの関数もRustのABI（これも安定化されていません）を使います。
  代わりに、外に公開するFFI
  APIはシステムABIを使うように、コンパイラに指示する必要があります。
],
zh: [
  默认，任何用Rust写的函数将使用Rust ABI(这也不稳定)。当编译面向外部的FFI
  APIs时，我们需要告诉编译器去使用系统ABI 。
]))

#let url_external = "https://doc.rust-lang.org/reference/items/external-blocks.html"
#tr((
en: [
  Depending on your platform, you might want to target a specific ABI
  version, which are documented #link(url_external)[here].
],
de: [
  Je nach Plattform möchten Sie möglicherweise eine bestimmte ABI-Version
  anvisieren; diese sind #link(url_external)[hier] dokumentiert.
],
ja: [
  プラットフォームによっては、特定のABIバージョンをターゲットにしたい場合があります。
  ABIについては、#link(url_external)[ここ]にドキュメントがあります。
],
zh: [
  取决于你的平台，你可能想要针对一个特定的ABI版本，其记录在#link(url_external)[这里]。
]))

#divider()

#tr((
en: [
  Putting these parts together, you get a function that looks roughly like this.
],
de: [
  Wenn man diese Teile zusammensetzt, erhält man eine Funktion, die
  ungefähr so ​​aussieht.
],
ja: [
  これらの部品をまとめると、おおよそ次のような関数になります。
],
zh: [
  把这些部分放在一起，你得到一个函数，其粗略看起来像是这个。
]))

```rust
#[no_mangle]
pub extern "C" fn rust_function() {

}
```

#tr((
en: [
  Just as when using `C` code in your Rust project you now need to
  transform data from and to a form that the rest of the application will
  understand.
],
de: [
  Genau wie bei der Verwendung von C-Code in Ihrem Rust-Projekt müssen Sie
  nun Daten in eine Form umwandeln -- und aus dieser zurück --, die der
  Rest der Anwendung versteht.
],
ja: [
  Rustプロジェクトで`C`コードを使った時と同様に、異なる言語間で理解できるデータ型に変換する必要があります。
],
zh: [
  就像在Rust项目中使用`C`代码时那样，现在需要把数据转换为应用中其它部分可以理解的形式。
]))

= #tr((
  en: [Linking and greater project context],
  de: [Verknüpfung und übergeordneter Projektkontext],
  ja: [リンクとより大きなプロジェクトの状況],
  zh: [链接和更大的项目上下文],
))

#tr((
en: [
  So then, that's one half of the problem solved. How do you use this now?
],
de: [
  Damit ist die eine Hälfte des Problems gelöst. Wie verwendet man das nun?
],
ja: [
  ここまでで、問題の半分は解決しました。 これをどうやって使うのでしょうか？
],
zh: [
  问题只解决了一半。

  你现在要如何使用它?
]))

#tr((
en: [
  *This very much depends on your project and/or build system*
],
de: [
  *Das hängt stark von Ihrem Projekt bzw. Ihrem Build-System ab.*
],
ja: [
  *それは、プロジェクトやビルドシステムに強く依存します。*
],
zh: [
  *这很大程度上取决于你的项目或者编译系统*
]))

#tr((
en: [
  `cargo` will create a `my_lib.so`/`my_lib.dll` or `my_lib.a` file,
  depending on your platform and settings. This library can simply be
  linked by your build system.
],
de: [
  `cargo` erstellt -- je nach Plattform und Einstellungen -- eine Datei
  namens `my_lib.so`, `my_lib.dll` oder `my_lib.a`. Diese Bibliothek kann
  einfach von Ihrem Build-System eingebunden (gelinkt) werden.
],
ja: [
  `cargo`は、プラットフォームと設定に依存して、`my_lib.so`、`my_lib.dll`または`my_lib.a`ファイルを作成します。
  このライブラリは、そのプラットフォームのビルドシステムによって簡単にリンクすることができます。
],
zh: [
  `cargo`将生成一个`my_lib.so`/`my_lib.dll`或者`my_lib.a`文件，取决于你的平台和配置。可以通过编译系统简单地链接这个库。
]))

#tr((
en: [
  However, calling a Rust function from C requires a header file to
  declare the function signatures.
],
de: [
  Um jedoch eine Rust-Funktion aus C heraus aufzurufen, ist eine
  Header-Datei erforderlich, in der die Funktionssignaturen deklariert werden.
],
ja: [
  しかし、CからRustを呼ぶためには、関数シグネチャを宣言するためのヘッダファイルが必要です。
],
zh: [
  然而，从C调用一个Rust函数要求一个头文件去声明函数的签名。
]))

#tr((
en: [
  Every function in your Rust-ffi API needs to have a corresponding header function.
],
de: [
  Für jede Funktion in Ihrer Rust-FFI-API muss eine entsprechende
  Deklaration im Header vorhanden sein.
],
ja: [
  Rust-ffi APIの関数全てが、対応する関数ヘッダを持つ必要があります。
],
zh: [
  在Rust-ffi API中的每个函数需要有一个相关的头文件函数。
]))

```rust
#[no_mangle]
pub extern "C" fn rust_function() {}
```

#tr((
en: [
  would then become
],
de: [
  würde dann werden
],
ja: [
  上記は、次のようになるでしょう。
],
zh: [
  将会变成
]))

```c
void rust_function();
```

#tr((
en: [
  etc.
],
de: [
  usw.
],
ja: [
  などなど。
],
zh: [
  等等。
]))

#let ln_cbindgen = link("https://github.com/eqrion/cbindgen")[cbindgen]
#tr((
en: [
  There is a tool to automate this process, called
  #ln_cbindgen which analyses
  your Rust code and then generates headers for your C and C++ projects
  from it.
],
de: [
  Es gibt ein Werkzeug zur Automatisierung dieses Prozesses namens
  #ln_cbindgen, das Ihren
  Rust-Code analysiert und daraus Header-Dateien für Ihre C- und
  C++-Projekte generiert.
],
ja: [
  このプロセスを自動化する#ln_cbindgen;というツールがあります。
  このツールは、Rustのコードを解析して、CとC++プロジェクトのためのヘッダを生成します。
],
zh: [
  这里有个工具可以自动化这个过程，叫做#ln_cbindgen，其会分析你的Rust代码然后为C和C++项目生成头文件。
]))

#tr((
en: [
  At this point, using the Rust functions from C is as simple as including
  the header and calling them!
],
de: [
  An diesem Punkt ist die Verwendung der Rust-Funktionen aus C heraus so
  einfach, wie den Header einzubinden und die Funktionen aufzurufen!
],
ja: [
  この時点で、CからRustの関数を使うには、単にヘッダをインクルードして、それを呼び出すだけです！
],
zh: [
  此时从C中使用Rust函数非常简单，只需包含头文件和调用它们！
]))

```c
#include "my-rust-project.h"
rust_function();
```
