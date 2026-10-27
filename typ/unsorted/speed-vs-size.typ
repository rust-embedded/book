#import "../config.typ": *

#h1((en: [Optimizations: the speed size tradeoff],
  de: [Optimierungen: Der Kompromiss zwischen Geschwindigkeit und Größe],
  ja: [最適化：速度とサイズのトレードオフ],
  zh: [优化: 速度与大小之间的博弈],
), offset: whole)

#tr((
en: [
  Everyone wants their program to be super fast and super small but it's
  usually not possible to have both characteristics. This section
  discusses the different optimization levels that `rustc` provides and
  how they affect the execution time and binary size of a program.
],
de: [
  Jeder möchte, dass sein Programm extrem schnell und extrem klein ist,
  doch meist lassen sich nicht beide Eigenschaften zugleich verwirklichen.
  Dieser Abschnitt behandelt die verschiedenen Optimierungsstufen von
  `rustc` und deren Auswirkungen auf die Ausführungszeit sowie die Größe
  der Binärdatei eines Programms.
],
ja: [
  誰もがプログラムを超高速で超小さくしたいと願いますが、両方の特性を最大化することはできません。
  このセクションは、`rustc`が提供する異なる最適化レベルについて、どのようにプログラムの実行時間とバイナリサイズに影響するかを説明します。
],
zh: [
  每个人都想要程序变得即快又小，但是同时满足这两个条件是不可能的。这部分讨论`rustc`提供的不同的优化等级，和它们是如何影响执行时间和一个程序的二进制项的大小。
]))

= #tr((
  en: [No optimizations],
  de: [Keine Optimierungen],
  ja: [最適化なし],
  zh: [无优化],
))

#tr((
en: [
  This is the default. When you call `cargo build` you use the development
  (AKA `dev`) profile. This profile is optimized for debugging so it
  enables debug information and does _not_ enable any optimizations,
  i.e.~it uses `-C opt-level = 0`.
],
de: [
  Dies ist die Standardeinstellung. Wenn Sie `cargo build` aufrufen, wird
  das Entwicklungs-Profil (auch bekannt als `dev`-Profil) verwendet. Da
  dieses Profil für das Debugging optimiert ist, werden
  Debug-Informationen aktiviert, jedoch _keinerlei_ Optimierungen
  vorgenommen; es wird also `-C opt-level=0` verwendet.
],
ja: [
  これはデフォルトです。`cargo build`を実行する場合、開発（別名`dev`）プロファイルを使います。
  このプロファイルはデバッグに最適化されています。そのため、デバッグ情報が有効化されており、最適化は一切有効化されて_いません_。
  つまり、`-C opt-level = 0`を使用します。
],
zh: [
  这是默认的。当你调用`cargo build`时，你使用的是development(又叫`dev`)配置。这个配置优化的目的是为了调试，因此它使能了调试信息且_关闭_了所有优化，i.e.~它使用
  `-C opt-level = 0` 。
]))

#tr((
en: [
  At least for bare metal development, debuginfo is zero cost in the sense
  that it won't occupy space in Flash / ROM so we actually recommend that
  you enable debuginfo in the release profile -- it is disabled by
  default. That will let you use breakpoints when debugging release builds.
],
de: [
  Zumindest bei der Bare-Metal-Entwicklung verursachen Debug-Informationen
  keine Kosten im Sinne von Speicherplatzbedarf im Flash- oder
  ROM-Speicher. Daher empfehlen wir, Debug-Informationen auch im
  Release-Profil zu aktivieren -- standardmäßig sind sie dort deaktiviert.
  Dies ermöglicht Ihnen die Verwendung von Breakpoints beim Debuggen von
  Release-Builds.
],
ja: [
  少なくともベアメタルの開発では、デバッグ情報はある意味ゼロコストです。
  デバッグ情報は、Flash/ROMの容量を使いません。そのため、リリースプロファイルで、デフォルトで無効化されているデバッグ情報を有効化することをお勧めします。
  これにより、リリースビルドをデバッグする時、ブレイクポイントを使うことができます。
],
zh: [
  至少对于裸机开发来说，调试信息不会占用Flash/ROM中的空间，意味着在这种情况下，调试信息是零开销的，因此实际上我们推荐你在release配置中使能调试信息
  -- 默认它被关闭了。那会让你调试release版本的固件时可以使用断点。
]))

#raw(block: true, lang: "toml",
"[profile.release]
# " + ts((
    en: "symbols are nice and they don't increase the size on Flash",
    de: "Symbole sind praktisch und vergroessern die Dateigroesse im Flash nicht",
    ja: "シンボルは素晴らしく、Flashのサイズを増やしません",
    zh: "调试符号很好且它们不会增加Flash上的大小",
  )) + "
debug = true
")

#tr((
en: [
  No optimizations is great for debugging because stepping through the
  code feels like you are executing the program statement by statement,
  plus you can `print` stack variables and function arguments in GDB. When
  the code is optimized, trying to print variables results in
  `$0 = <value optimized out>` being printed.
],
de: [
  Der Verzicht auf Optimierungen ist ideal für das Debugging, da sich das
  schrittweise Durchlaufen des Codes anfühlt, als würde man das Programm
  Anweisung für Anweisung ausführen; zudem lassen sich Stack-Variablen und
  Funktionsargumente in GDB per `print` ausgeben. Bei optimiertem Code
  führt der Versuch, Variablen auszugeben, hingegen zur Meldung
  `$0 = <value optimized out>`.
],
ja: [
  最適化しないことはデバッグでは重要です。コードをステップ実行する時、プログラムをステートメントごとに実行しているように感じられるからです。
  さらに、スタックの変数や関数の引数をGDBで`print`することができます。
  コードが最適化されると、変数を表示しようとしても、`$0 = <value optimized out>`と表示されます。
],
zh: [
  无优化对于调试来说是最好的选择，因为单步调试代码感觉像是你正在逐条语句地执行程序，且你能在GDB中`print`栈变量和函数参数。当代码被优化了，尝试打印变量会导致`$0 = <value optimized out>`被打印出来。
]))

#tr((
en: [
  The biggest downside of the `dev` profile is that the resulting binary
  will be huge and slow. The size is usually more of a problem because
  unoptimized binaries can occupy dozens of KiB of Flash, which your
  target device may not have -- the result: your unoptimized binary
  doesn't fit in your device!
],
de: [
  Der größte Nachteil des `dev`-Profils besteht darin, dass die
  resultierende Binärdatei sehr groß und langsam ist. Meist wiegt vor
  allem die Größe schwer, da nicht optimierte Binärdateien Dutzende KiB an
  Flash-Speicher belegen können -- Speicherplatz, über den das Zielgerät
  womöglich gar nicht verfügt. Die Folge: Die nicht optimierte Binärdatei
  passt nicht auf das Gerät!
],
ja: [
  `dev`プロファイルの最大の欠点は、バイナリが大きく、遅いことです。
  バイナリサイズは通常、より問題となります。最適化されていないバイナリは数十KiBもFlashを専有するからです。
  ターゲットデバイスは、数十KiBものFlashを持っていないかもしれず、最適化されていないバイナリは、デバイス内に納まりません。
],
zh: [
  `dev`配置最大的缺点就是最终的二进制项将会变得巨大且缓慢。大小通常是一个更大的问题，因为未优化的二进制项会占据大量KiB的Flash，你的目标设备可能没这么多Flash
  -- 结果: 你未优化的二进制项无法烧录进你的设备中！
]))

#tr((
en: [
  Can we have smaller, debugger friendly binaries? Yes, there's a trick.
],
de: [
  Gibt es eine Möglichkeit, kleinere und dennoch für das Debugging
  geeignete Binärdateien zu erhalten? Ja, es gibt einen Trick.
],
ja: [
  デバッガで扱いやすい、小さなバイナリを作ることができるのでしょうか？できます。良いやり方があります。
],
zh: [
  我们可以有更小的，调试友好的二进制项吗?是的，这里有一个技巧。
]))

== #tr((
  en: [Optimizing dependencies],
  de: [Optimierung der Abhängigkeiten],
  ja: [依存関係の最適化],
  zh: [优化依赖],
))

#let url_overrides = "https://doc.rust-lang.org/cargo/reference/profiles.html#overrides"
#tr((
en: [
  There's a Cargo feature named #link(url_overrides)[`profile-overrides`]
  that lets you override the optimization level of dependencies. You can
  use that feature to optimize all dependencies for size while keeping the
  top crate unoptimized and debugger friendly.
],
de: [
  Cargo bietet mit #link(url_overrides)[`Profil-Überschreibung`]
  eine Funktion, mit der Sie den Optimierungsgrad von Abhängigkeiten
  überschreiben können. So lassen sich alle Abhängigkeiten hinsichtlich
  ihrer Größe optimieren, während die oberste Crate unoptimiert und
  debuggfreundlich bleibt.
],
ja: [
  nightlyでは、#link(url_overrides)[`profile-overrides`]と呼ばれるCargoフィーチャがあります。これは、依存関係の最適化レベルをオーバーライドします。
  このフィーチャを使って、全ての依存クレートのサイズを最適化しながら、トップクレートを最適化しないでデバッガで扱いやすくすることができます。。
],
zh: [
  这里有个名为#link(url_overrides)[`profile-overrides`]的Cargo
  feature，其可以让你覆盖依赖项的优化等级。你能使用这个feature去优化所有依赖的大小，而保持顶层的crate没有被优化以致调试起来友好。
]))

#tr((
en: [
  Beware that generic code can sometimes be optimized alongside the crate
  where it is instantiated, rather than the crate where it is defined. If
  you create an instance of a generic struct in your application and find
  that it pulls in code with a large footprint, it may be that increasing
  the optimisation level of the relevant dependencies has no effect.
],
de: [
  Beachten Sie, dass generischer Code manchmal zusammen mit der Crate
  optimiert werden kann, in der er instanziiert wird, anstatt mit der
  Crate, in der er definiert ist. Wenn Sie in Ihrer Anwendung eine Instanz
  einer generischen Struktur erstellen und feststellen, dass diese Code
  mit großem Speicherbedarf einbindet, kann es sein, dass eine Erhöhung
  des Optimierungsgrads der relevanten Abhängigkeiten keine Wirkung zeigt.
],
zh: [
  需要知道，泛型代码有时是在它被实例化的库中被优化的，而不是它被定义的地方．如果你在你的应用中生成了一个泛型结构体的实例，
  并且发现它让代码体积变得更大，那可能是因为相关的依赖的优化等级的增加没有造成影响．
]))

#tr((
en: [
  Here's an example:
],
de: [
  Hier ist ein Beispiel:
],
ja: [
  例を示します。
],
zh: [
  这是一个示例:
]))

```toml
# Cargo.toml
[package]
name = "app"
# ..

[profile.dev.package."*"] # +
opt-level = "z" # +
```

#tr((
en: [
  Without the override:
],
de: [
  Ohne die Überschreibung:
],
ja: [
  オーバーライドなしでは、次の通りです。
],
zh: [
  没有覆盖:
]))

```text
$ cargo size --bin app -- -A
app  :
section               size        addr
.vector_table         1024   0x8000000
.text                 9060   0x8000400
.rodata               1708   0x8002780
.data                    0  0x20000000
.bss                     4  0x20000000
```

#tr((
en: [
  With the override:
],
de: [
  Mit der Überschreibung
],
ja: [
  オーバーライドをすると、以下のようになります。
],
zh: [
  有覆盖:
]))

```text
$ cargo size --bin app -- -A
app  :
section               size        addr
.vector_table         1024   0x8000000
.text                 3490   0x8000400
.rodata               1100   0x80011c0
.data                    0  0x20000000
.bss                     4  0x20000000
```

#tr((
en: [
  That's a 6 KiB reduction in Flash usage without any loss in the
  debuggability of the top crate. If you step into a dependency then
  you'll start seeing those `<value optimized out>` messages again but
  it's usually the case that you want to debug the top crate and not the
  dependencies. And if you _do_ need to debug a dependency then you
  can use the `profile-overrides` feature to exclude a particular
  dependency from being optimized. See example below:
],
de: [
  Das bedeutet eine Verringerung des Flash-Speicherverbrauchs um 6 KiB,
  ohne die Debug-Fähigkeit des Haupt-Crates zu beeinträchtigen. Wenn man
  in eine Abhängigkeit hineinspringt, erscheinen zwar wieder die Meldungen
  `<value optimized out>`, doch in der Regel möchte man das Haupt-Crate
  debuggen und nicht die Abhängigkeiten. Sollte es dennoch erforderlich
  sein, eine Abhängigkeit zu debuggen, lässt sich die Funktion
  `profile-overrides` nutzen, um diese spezifische Abhängigkeit von der
  Optimierung auszunehmen. Siehe dazu das folgende Beispiel:
],
ja: [
  トップクレートのデバッグ性を失うことなしに、Flash使用量を6KiB減らしています。
  依存クレートの中に足を踏み入れると、`<value optimized out>`のメッセージを目にするでしょう。
  しかし、依存クレートではなく、トップクレートをデバッグしたい場合がほとんどでしょう。
  依存クレートをデバッグする必要が_ある_場合、特定の依存クレートを最適化から除外するために、`profile-overrides`フィーチャを使えます。
  例えば、以下のようになります。
],
zh: [
  在Flash的使用上减少了6KiB，而不会损害顶层crate的可调试性。如果你步进一个依赖项，然后你将开始再次看到那些`<value optimized out>`信息，但是通常的情况下你只想调试顶层的crate而不是依赖项。如果你
  _需要_ 调试一个依赖项，那么你可以使用`profile-overrides`
  feature去防止一个特定的依赖项被优化。看下面的例子:
]))

#raw(block: true, lang: "toml",
"# ..

# " + ts((
    en: "don't optimize the `cortex-m-rt` crate",
    de: "Optimiere das `cortex-m-rt`-Crate nicht",
    ja: "`cortex-m-rt`クレートは最適化しません",
    zh: "不要优化`cortex-m-rt` crate",
  )) + "
[profile.dev.package.cortex-m-rt] # +
opt-level = 0 # +

# " + ts((
    en: "but do optimize all the other dependencies",
    de: "optimieren Sie jedoch alle anderen Abhaengigkeiten",
    ja: "しかし、他の依存クレートは最適化します",
    zh: "但是优化所有其它依赖项",
  )) + "
[profile.dev.package.\"*\"]
codegen-units = 1 # " + ts((
                        en: "better optimizations",
                      )) + "
opt-level = \"z\"
")

#tr((
en: [
  Now the top crate and `cortex-m-rt` are debugger friendly!
],
de: [
  Jetzt sind das Top-Level-Crate und `cortex-m-rt` debuggerfreundlich!
],
ja: [
  これで、トップクレートと`cortex-m-rt`クレートはデバッガで扱いやすくなります！
],
zh: [
  现在顶层的crate和`cortex-m-rt`对调试器很友好！
]))

= #tr((
  en: [Optimize for speed],
  de: [Auf Geschwindigkeit optimieren],
  ja: [速度の最適化],
  zh: [优化速度],
))

#tr((
en: [
  As of 2018-09-18 `rustc` supports three "optimize for speed" levels:
  `opt-level = 1`, `2` and `3`. When you run `cargo build --release` you
  are using the release profile which defaults to `opt-level = 3`.
],
de: [
  Seit dem 18.09.2018 unterstützt `rustc` drei Stufen der
  Geschwindigkeitsoptimierung: `opt-level = 1`, `2` und `3`. Beim
  Ausführen von `cargo build --release` wird das Release-Profil verwendet,
  das standardmäßig auf `opt-level = 3` eingestellt ist.
],
ja: [
  2018-09-18の`rustc`は、3つの「速度最適化」を提供しています。`opt-level = 1`、`2`と`3`です。
  `cargo build --release`を実行した時、デフォルトでは`opt-level = 3`のリリースプロファイルを使います。
],
zh: [
  自2018-09-18开始 `rustc` 支持三个 "优化速度" 的等级: `opt-level = 1`,
  `2` 和 `3` 。当你运行 `cargo build --release`
  时，你正在使用的是release配置，其默认是 `opt-level = 3` 。
]))

#tr((
en: [
  Both `opt-level = 2` and `3` optimize for speed at the expense of binary
  size, but level `3` does more vectorization and inlining than level `2`.
  In particular, you'll see that at `opt-level` equal to or greater than
  `2` LLVM will unroll loops. Loop unrolling has a rather high cost in
  terms of Flash / ROM (e.g.~from 26 bytes to 194 for a zero this array
  loop) but can also halve the execution time given the right conditions
  (e.g.~number of iterations is big enough).
],
de: [
  Sowohl `opt-level = 2` als auch `3` optimieren auf Geschwindigkeit
  zulasten der Binärgröße; allerdings führt Stufe `3` mehr Vektorisierung
  und Inlining durch als Stufe `2`. Insbesondere ist zu beobachten, dass
  LLVM bei einem `opt-level` von 2 oder höher Schleifen entrollt („Loop
  Unrolling"). Das Entrollen von Schleifen ist recht kostspielig im
  Hinblick auf den Flash-/ROM-Speicherbedarf (z. B. Anstieg von 26 auf 194
  Bytes für eine Schleife zum Nullsetzen eines Arrays), kann aber unter
  geeigneten Bedingungen (etwa bei einer ausreichend hohen Anzahl von
  Iterationen) die Ausführungszeit halbieren.
],
ja: [
  `opt-level = 2`と`3`は、バイナリサイズを犠牲にして、速度を最適化します。レベル`3`はレベル`2`より、ベクトル化とインライン化を行います。
  特に、`opt-level`が`2`以上の場合、LLVMがループを展開するのがわかるでしょう。
  ループ展開は、Flash/ROMの観点からはよりコストが高いです（例えば、配列のループをゼロにする場合、26バイトから194バイトまで増加します）。
  しかし、適切な条件では、実行時間が半分になります（例えば、イテレーションの回数が十分大きい場合）。
],
zh: [
  `opt-level = 2` 和 `3`
  都以二进制项大小为代价优化速度，但是等级`3`比等级`2`做了更多的向量化和内联。特别是，你将看到在`opt-level`等于或者大于`2`时LLVM将展开循环。循环展开在
  Flash / ROM 方面的成本相当高(e.g.~from 26 bytes to 194 for a zero this
  array loop)但是如果条件合适(迭代次数足够大)，也可以将执行时间减半。
]))

#tr((
en: [
  Currently there's no way to disable loop unrolling in `opt-level = 2`
  and `3` so if you can't afford its cost you should optimize your program
  for size.
],
de: [
  Derzeit gibt es keine Möglichkeit, das Entrollen von Schleifen bei
  `opt-level = 2` und `3` zu deaktivieren; wenn Sie sich diesen
  Speicheraufwand also nicht leisten können, sollten Sie Ihr Programm
  stattdessen auf eine geringe Größe hin optimieren.
],
ja: [
  現在、`opt-level = 2`と`3`でループ展開を無効化する方法はありません。
  ループ展開のコストを払うことができない場合、プログラムサイズの最適化をするべきです。
],
zh: [
  现在还没有办法在`opt-level = 2`和`3`的情况下关闭循环展开，因此如果你不能接受它的开销，你应该选择优化你的程序的大小。
]))

= #tr((
  en: [Optimize for size],
  de: [Nach Größe optimieren],
  ja: [サイズの最適化],
  zh: [优化大小],
))

#tr((
en: [
  As of 2018-09-18 `rustc` supports two "optimize for size" levels:
  `opt-level = "s"` and `"z"`. These names were inherited from clang /
  LLVM and are not too descriptive but `"z"` is meant to give the idea
  that it produces smaller binaries than `"s"`.
],
de: [
  Seit dem 18.09.2018 unterstützt `rustc` zwei Stufen zur
  Größenoptimierung: `opt-level = "s"` und `"z"`. Diese Bezeichnungen
  wurden von Clang/LLVM übernommen und sind nicht besonders
  aussagekräftig; allerdings soll das `"z"` signalisieren, dass damit
  kleinere Binärdateien erzeugt werden als mit `"s"`.
],
ja: [
  2018-09-18の`rustc`は、2つの`サイズ最適化`を提供しています。`opt-level = "s"`と`"z"`です。
  これらの名前は、clang / LLVMから受け継いでおり、意味がわかりにくいです。
  `"z"`は、`"s"`より小さなバイナリを作る意図を意味します。
],
zh: [
  自2018-09-18开始`rustc`支持两个"优化大小"的等级: `opt-level = "s"` 和
  `"z"` 。这些名字传承自 clang / LLVM
  且不具有描述性，但是`"z"`意味着它产生的二进制文件比`"s"`更小。
]))

#tr((
en: [
  If you want your release binaries to be optimized for size then change
  the `profile.release.opt-level` setting in `Cargo.toml` as shown below.
],
de: [
  Wenn Ihre Release-Binärdateien hinsichtlich der Größe optimiert werden
  sollen, ändern Sie die Einstellung `profile.release.opt-level` in der
  Datei `Cargo.toml` wie unten dargestellt.
],
ja: [
  リリースバイナリのサイズを最適化したい場合、`Cargo.toml`の`profile.release.opt-level`設定を下記の通り変更します。
],
zh: [
  如果你想要发布一个优化了大小的二进制项，那么改变下面展示的`Cargo.toml`中的`profile.release.opt-level`配置。
]))

#raw(block: true, lang: "toml",
"[profile.release]
# " + ts((
    en: "or \"z\"",
    de: "oder \"z\"",
    ja: "または\"z\"",
  )) + "
opt-level = \"s\"
")

#tr((
en: [
  These two optimization levels greatly reduce LLVM's inline threshold, a
  metric used to decide whether to inline a function or not. One of Rust
  principles are zero cost abstractions; these abstractions tend to use a
  lot of newtypes and small functions to hold invariants (e.g.~functions
  that borrow an inner value like `deref`, `as_ref`) so a low inline
  threshold can make LLVM miss optimization opportunities (e.g.~eliminate
  dead branches, inline calls to closures).
],
de: [
  Diese beiden Optimierungsstufen senken den Inline-Schwellenwert von LLVM
  erheblich -- einen Kennwert, der darüber entscheidet, ob eine Funktion
  „geinlined" (direkt an der Aufrufstelle eingebettet) wird oder nicht.
  Eines der Prinzipien von Rust sind „Zero-Cost-Abstractions"
  (Abstraktionen ohne Laufzeitkosten); diese nutzen häufig sogenannte
  „Newtypes" und kleine Funktionen zur Wahrung von Invarianten (z. B.
  Funktionen wie `deref` oder `as_ref`, die einen inneren Wert ausleihen).
  Ein niedriger Inline-Schwellenwert kann daher dazu führen, dass LLVM
  Optimierungsmöglichkeiten verpasst (etwa das Entfernen von nicht
  erreichbaren Programmzweigen oder das Inlinen von Closure-Aufrufen).
],
ja: [
  これらの2つの最適化レベルは、LLVMのインラインしきい値を大幅に減らします。
  インラインしきい値は、関数をインライン化するか否かを決めるために使われる基準値です。
  Rustの原則の1つは、ゼロコスト抽象化です。
  これらの抽象化は、不変条件を保持するため、多くの新しい型と小さな関数を使う傾向にあります
  （例えば、`deref`や`as_ref`のような内部の値を借用するための関数）。
  そのため、インラインしきい値を低くすると、LLVMが最適化の機会を失います
  （例えば、不要な分岐を削除したり、クロージャをインライン呼び出しにする、など）。
],
zh: [
  这两个优化等级极大地减小了LLVM的内联阈值，一个用来决定是否内联或者不内联一个函数的度量。Rust其中一个概念是零成本抽象；这些抽象趋向于去使用许多新类型和小函数去保持不变量(e.g.~像是`deref`，`as_ref`这样借用内部值的函数)因此一个低内联阈值会使LLVM失去优化的机会(e.g.~去掉死分支(dead
  branches)，内联对闭包的调用)。
]))

#tr((
en: [
When optimizing for size you may want to try increasing the inline
threshold to see if that has any effect on the binary size. The
recommended way to change the inline threshold is to append the
`-C inline-threshold` flag to the other rustflags in
`.cargo/config.toml`.
],
de: [
  Bei der Optimierung auf eine geringe Binärgröße kann es sinnvoll sein,
  den Inline-Schwellenwert zu erhöhen und zu prüfen, ob sich dies auf die
  Größe der Binärdatei auswirkt. Die empfohlene Methode zur Änderung
  dieses Schwellenwerts besteht darin, das Flag `-C inline-threshold` zu
  den übrigen `rustflags` in der Datei `.cargo/config.toml` hinzuzufügen.
],
ja: [
  サイズの最適化を行っている時、バイナリサイズに影響があるかどうかを見るために、インラインしきい値を増やしたいかもしれません。
  インラインしきい値を変更するお勧めの方法は、`.cargo/config`内のrustflagsに`-C inline-threshold`フラグを追加することです。
],
zh: [
  当优化大小时，你可能想要尝试增加内联阈值去观察是否会对你的二进制项的大小有影响。推荐的改变内联阈值的方法是在`.cargo/config.toml`中往其它rustflags后插入`-C inline-threshold`
]))

#raw(block: true, lang: "toml",
"# .cargo/config.toml
# " + ts((
    en: "this assumes that you are using the cortex-m-quickstart template",
    de: "Dies setzt voraus, dass Sie die cortex-m-quickstart-Vorlage verwenden",
    ja: "cortex-m-quickstartテンプレートを使っていることを想定しています",
    zh: "这里假设你正在使用cortex-m-quickstart模板",
  )) + "
[target.'cfg(all(target_arch = \"arm\", target_os = \"none\"))']
rustflags = [
  # ..
  \"-C\", \"inline-threshold=123\", # +
]
")

#let url_opt_lvls = "https://github.com/rust-lang/rust/blob/1.29.0/src/librustc_codegen_llvm/back/write.rs#L2105-L2122"
#tr((
en: [
  What value to use?
  #link(url_opt_lvls)[As of 1.29.0 these are the inline thresholds that the different optimization levels use]:
  - `opt-level = 3` uses 275
  - `opt-level = 2` uses 225
  - `opt-level = "s"` uses 75
  - `opt-level = "z"` uses 25
],
de: [
  Welchen Wert verwenden?
  #link(url_opt_lvls)[Ab Version 1.29.0 gelten für die verschiedenen Optimierungsstufen folgende Inline-Schwellenwerte]:
  - `opt-level = 3` verwendet 275
  - `opt-level = 2` verwendet 225
  - `opt-level = "s"` verwendet 75
  - `opt-level = "z"` verwendet 25
],
ja: [
  この値は何に使われるのでしょうか？
  #link(url_opt_lvls)[1.29.0では、下記の値は、異なる最適化レベルで使われるインラインしきい値です]
  - `opt-level = 3`は275を使います
  - `opt-level = 2`は225を使います
  - `opt-level = "s"`は75を使います
  - `opt-level = "z"`は25を使います
],
zh: [
  用什么值?#link(url_opt_lvls)[从1.29.0开始，这些是不同优化级别使用的内联阈值]:
  - `opt-level = 3` 使用 275
  - `opt-level = 2` 使用 225
  - `opt-level = "s"` 使用 75
  - `opt-level = "z"` 使用 25
]))

#tr((
en: [
  You should try `225` and `275` when optimizing for size.
],
de: [
  Du solltest `225` und `275` ausprobieren, wenn du auf die Größe
  optimierst.
],
ja: [
  サイズの最適化をするときは、`225`と`275`を試してみるべきです。
],
zh: [
  当优化大小时，你应该尝试`225`和`275` 。
]))
