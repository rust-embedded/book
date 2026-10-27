#import "../config.typ": *

#h1([QEMU],
  offset: whole)
<getting-started-qemu>

// TODO: check
#if lang == "de" [
  QEMU (von englisch „Quick Emulator") ist eine freie
  Virtualisierungssoftware, die die gesamte Hardware eines Computers
  emuliert und durch die dynamische Übersetzung der Prozessorinstruktionen
  des Gastprozessors (englisch guest) in Instruktionen für den
  Wirtprozessor (englisch host) eine sehr gute Ausführungsgeschwindigkeit
  erreicht.

  URL: #link("https://www.qemu.org/")

  QEMU emuliert Systeme mit den folgenden Prozessorarchitekturen:
  - 68K,
  - Alpha,
  - ARM (32- und 64-Bit),
  - CHRIS,
  - HPPA,
  - LatticeMico32,
  - m68K bzw. Coldfire,
  - MicroBlaze,
  - MIPS,
  - Moxie,
  - Nios2,
  - OpenRISC,
  - PC
  - Power
  - PowerNV
  - PowerPC (32- und 64-Bit),
  - RISC-V,
  - S/390,
  - SH-4,
  - Sparc32/64,
  - TILE-Gx,
  - TriCore,
  - Unicore,
  - x86 (x86-32 und x86-64),
  - Xtensa

  (Stand 2026).
]

#let ln_lm3s6965 = link("http://www.ti.com/product/LM3S6965")[LM3S6965]
#let url_qemu = "https://wiki.qemu.org/Documentation/Platforms/ARM#Supported_in_qemu-system-arm"
#tr((
en: [
  We'll start writing a program for the #ln_lm3s6965, a Cortex-M3
  microcontroller. We have chosen this as our initial target because it
  #link(url_qemu)[can be emulated]
  using QEMU so you don't need to fiddle with hardware in this section and
  we can focus on the tooling and the development process.
],
de: [
  Wir beginnen mit der Entwicklung eines Programms für den
  #ln_lm3s6965, einen ARM
  Cortex-M3-Mikrocontroller. Wir haben diesen als unser erstes Ziel
  ausgewählt, da er mit QEMU
  #link(url_qemu)[emuliert werden kann],
  sodass Sie sich in diesem Abschnitt nicht mit der Hardware beschäftigen
  müssen und wir uns auf die Werkzeuge und den Entwicklungsprozess
  konzentrieren können.
],
ja: [
  Cortex-M3マイクロコントローラの#ln_lm3s6965;用にプログラムを書くところから始めましょう。
  このLM3S6965を最初のターゲットとして選んだ理由は、QEMUを使ってエミュレーションできるからです。
  このセクションでは、ハードウェアをいじる必要がなく、ツールと開発プロセスに集中できます。
],
zh: [
  我们将开始为#ln_lm3s6965;编写程序，一个Cortex-M3微控制器。因为它能使用#link("https://wiki.qemu.org/Documentation/Platforms/ARM#Supported_in_qemu-system-arm")[QEMU仿真]，所以我们选择它作为我们的第一个目标，本节中，不需要使用硬件，我们注意力可以集中在工具和开发过程上。
]))

#tr((
en: [
  *IMPORTANT* We'll use the name "app" for the project name in this
  tutorial. Whenever you see the word "app" you should replace it with the
  name you selected for your project. Or, you could also name your project
  "app" and avoid the substitutions.
],
de: [
  *WICHTIG* In dieser Anleitung verwenden wir den Namen „app" als
  Projektnamen. Wann immer Sie das Wort „app" sehen, sollten Sie es durch
  den Namen ersetzen, den Sie für Ihr Projekt gewählt haben. Alternativ
  können Sie Ihr Projekt auch „app" nennen und so die Ersetzungen
  vermeiden.
],
zh: [
  *重要*
  在这个引导里，我们将使用"app"这个名字来代指项目名。无论何时你看到单词"app"，你应该用你选择的项目名来替代"app"。或者你也可以选择把你的项目命名为"app"，避免要替换掉。
]))

= #tr((
  en: [Creating a non standard Rust program],
  de: [Erstellen eines nicht standardmäßigen Rust-Programms],
  ja: [標準ライブラリを使わないRustプログラム],
  zh: [生成一个非标准的 Rust program],
))

#let ln_quick = link("https://github.com/rust-embedded/cortex-m-quickstart")[`cortex-m-quickstart`]
#tr((
en: [
  We'll use the #ln_quick
  project template to generate a new project from it. The created project
  will contain a barebone application: a good starting point for a new
  embedded rust application. In addition, the project will contain an
  `examples` directory, with several separate applications, highlighting
  some of the key embedded rust functionality.
],
de: [
  Wir werden die Projektvorlage #ln_quick
  verwenden, um daraus ein neues Projekt zu erstellen. Das erstellte
  Projekt enthält eine Minimalanwendung: einen guten Ausgangspunkt für
  eine neue Embedded-Rust-Anwendung. Darüber hinaus enthält das Projekt
  ein Verzeichnis `examples` mit mehreren separaten Anwendungen, die
  einige der wichtigsten Funktionen von Embedded Rust veranschaulichen.
],
zh: [
  我们将使用#ln_quick;项目模板来生成一个新项目。生成的项目将包含一个最基本的应用:对于一个新的嵌入式rust应用来说，是一个很好的开始。另外，项目将包含一个`example`文件夹，文件夹中有许多独立的应用，突出了一些关键的嵌入式rust的功能。
]))

== #tr((
  en: [Using `cargo-generate`],
  de: [Verwendung von `cargo-generate`],
  zh: [使用 `cargo-generate`],
))

#tr((
en: [
  First install cargo-generate
],
de: [
  Installieren Sie zunächst cargo-generate
],
zh: [
  首先安装 cargo-generate
]))

```console
cargo install cargo-generate
```

#tr((
en: [
  Then generate a new project
],
de: [
  Erstellen Sie anschließend ein neues Projekt
],
zh: [
  然后生成一个新项目
]))

```console
cargo generate --git https://github.com/knurling-rs/app-template
```

```text
 Project Name: app
 Creating project called `app`...
 Done! New project created /tmp/app
```

```console
cd app
```

== #tr((
  en: [Using `git`],
  de: [Verwendung von `git`],
  zh: [使用 `git`],
))

#tr((
en: [
  Clone the repository
],
de: [
  Das Repository klonen
],
zh: [
  克隆仓库
]))

```console
git clone https://github.com/rust-embedded/cortex-m-quickstart app
cd app
```

#tr((
en: [
  And then fill in the placeholders in the `Cargo.toml` file
],
de: [
  Und fülle dann die Platzhalter in der Datei `Cargo.toml` aus
],
zh: [
  然后补充`Cargo.toml`文件中的占位符
]))

```toml
[package]
authors = ["{{authors}}"] # "{{authors}}" -> "John Smith"
edition = "2018"
name = "{{project-name}}" # "{{project-name}}" -> "app"
version = "0.1.0"

# ..

[[bin]]
name = "{{project-name}}" # "{{project-name}}" -> "app"
test = false
bench = false
```

== #tr((
  en: [Using neither],
  de: [Keines von beiden verwenden],
  zh: [要么使用],
))

#tr((
en: [
  Grab the latest snapshot of the `cortex-m-quickstart` template and
  extract it.
],
de: [
  Laden Sie den neuesten Snapshot der Vorlage `cortex-m-quickstart`
  herunter und entpacken Sie ihn.
],
zh: [
  抓取最新的 `cortex-m-quickstart` 模板，解压它。
]))

```console
curl -LO https://github.com/rust-embedded/cortex-m-quickstart/archive/master.zip
unzip master.zip
mv cortex-m-quickstart-master app
cd app
```

#tr((
en: [
  Or you can browse to #ln_quick, click the green "Clone or download" button and then click "Download ZIP".
],
de: [
  Oder Sie navigieren zu #ln_quick,
  klicken auf die grüne Schaltfläche „Clone or download" und anschließend auf „Download ZIP".
],
zh: [
  或者你可以浏览#ln_quick，点击绿色的
  "Clone or download" 按钮，然后点击 "Download ZIP" 。
]))

#tr((
en: [
  Then fill in the placeholders in the `Cargo.toml` file as done in the
  second part of the "Using `git`" version.
],
de: [
  Füllen Sie anschließend die Platzhalter in der Datei `Cargo.toml` aus,
  wie im zweiten Teil der Version „Verwendung von `git` beschrieben.
],
zh: [
  然后像在 "使用 `git`" 那里的第二部分写的那样填充 `Cargo.toml` 。
]))

= #tr((
  en: [Program Overview],
  de: [Programmübersicht],
  zh: [项目概览],
))

#tr((
en: [
  For convenience here are the most important parts of the source code in `src/main.rs`:
],
de: [
  Der Einfachheit halber sind hier die wichtigsten Teile des Quellcodes in
  `src/main.rs` aufgeführt:
],
zh: [
  这是`src/main.rs`中源码最重要的部分。
]))

#raw(block: true, lang: "rust",
"#![no_std]
#![no_main]

use panic_halt as _;

use cortex_m_rt::entry;

#[entry]
fn main() -> ! {
    loop {
        // " + ts((
            en: "your code goes here",
            de: "Hier kommt Ihr Code hin.",
            ja: "あなたのコードはここに書きます",
          )) + "
    }
}
")

#tr((
en: [
  This program is a bit different from a standard Rust program so let's
  take a closer look.
],
de: [
  Dieses Programm unterscheidet sich ein wenig von einem typischen
  Rust-Programm, schauen wir es uns also einmal genauer an.
],
zh: [
  这个程序与标准Rust程序有一点不同，让我们走近点看看。
]))

#tr((
en: [
  `#![no_std]` indicates that this program will _not_ link to the
  standard crate, `std`. Instead it will link to its subset: the `core` crate.
],
de: [
  `#![no_std]` gibt an, dass dieses Programm _nicht_ mit der
  Standard-Crate `std` verknüpft wird. Stattdessen wird es mit deren
  Teilmenge verknüpft: der Crate `core`.
],
zh: [
  `#![no_std]`指出这个程序将 _不会_
  链接标准crate`std`。反而它将会链接到它的子集: `core` crate。
]))

#tr((
en: [
  `#![no_main]` indicates that this program won't use the standard `main`
  interface that most Rust programs use. The main (no pun intended) reason
  to go with `no_main` is that using the `main` interface in `no_std`
  context requires nightly.
],
de: [
  `#![no_main]` gibt an, dass dieses Programm nicht die Standard-`main`-
  Schnittstelle verwendet, die die meisten Rust-Programme nutzen. Der
  Hauptgrund (kein Wortspiel beabsichtigt) für die Verwendung von
  `no_main` ist, dass die Nutzung der `main`-Schnittstelle im
  `no_std`-Kontext „Nightly" erfordert.
],
zh: [
  `#![no_main]`指出这个程序将不会使用标准的且被大多数Rust程序使用的`main`接口。使用`no_main`的主要理由是，在`no_std`上下文中使用`main`接口需要
  nightly 版的 Rust。
]))

#tr((
en: [
  `use panic_halt as _;`. This crate provides a `panic_handler` that
  defines the panicking behavior of the program. We will cover this in
  more detail in the #link(<getting-started-panicking>)[Panicking] chapter of the book.
],
de: [
  `use panic_halt as _;`. Diese Crate stellt einen `panic_handler` bereit,
  der das Verhalten des Programms im Panikfall definiert. Wir werden
  darauf im Kapitel #link(<getting-started-panicking>)[In Panik geraten] des Buches
  näher eingehen.
],
zh: [
  `use panic_halt as _;`。这个crate提供了一个`panic_handler`，它定义了程序陷入`panic`时的行为。我们将会在这本书的#link(<getting-started-panicking>)[运行时恐慌(Panicking)]章节中覆盖更多的细节。
]))

#let ln_entry = link("https://docs.rs/cortex-m-rt-macros/latest/cortex_m_rt_macros/attr.entry.html")[`#[entry]`]
#let ln_rt = link("https://crates.io/crates/cortex-m-rt")[`cortex-m-rt`]
#tr((
en: [
  #ln_entry is an attribute provided by the #ln_rt crate
  that's used to mark the entry point of the program. As we are not using
  the standard `main` interface we need another way to indicate the entry
  point of the program and that'd be `#[entry]`.
],
de: [
  #ln_entry ist ein Attribut des
  #ln_rt;-Crate, das dazu dient, den Einstiegspunkt des Programms zu kennzeichnen. Da wir
  nicht die Standard-Schnittstelle `main` verwenden, benötigen wir eine
  andere Möglichkeit, den Einstiegspunkt des Programms anzugeben, und das
  wäre `#[entry]`.
],
zh: [
  #ln_entry 是一个由#ln_rt;提供的属性，它用来标记程序的入口。当我们不使用标准的`main`接口时，我们需要其它方法来指示程序的入口，那就是`#[entry]`。
]))

#let url_div = "https://doc.rust-lang.org/rust-by-example/fn/diverging.html"
#tr((
en: [
  `fn main() -> !`. Our program will be the _only_ process running on
  the target hardware so we don't want it to end! We use a
  #link(url_div)[divergent function]
  (the `-> !` bit in the function signature) to ensure at compile time
  that'll be the case.
],
de: [
  `fn main() -> !`. Unser Programm wird der _einzige_ Prozess sein,
  der auf der Zielhardware läuft, deshalb soll es nicht beendet werden!
  Wir verwenden eine #link(url_div)[divergent function]
  (das `-> !` in der Funktionssignatur), um bereits zur Kompilierungszeit
  sicherzustellen, dass dies auch der Fall ist.
],
zh: [
  `fn main() -> !`。我们的程序将会是运行在目标板子上的 _唯一_
  的进程，因此我们不想要它结束！我们使用一个#link(url_div)[发散函数]
  (函数签名中的 `-> !` )来确保在编译时就是这么回事儿。
]))

= #tr((
  en: [Cross compiling],
  de: [Cross-Kompilierung],
  zh: [交叉编译],
))

#tr((
en: [
  First of all we will need the memory layout for the target
  microcontroller, the LM3S6965 in our case. Otherwise the build will fail
  to link the image. Create a file named `memory.x` at the root of the
  project and paste the following content:
],
de: [
  Zunächst benötigen wir das Speicherlayout für den Ziel-Mikrocontroller,
  in unserem Fall den LM3S6965. Andernfalls schlägt die Verknüpfung des
  Images beim Build fehl. Erstellen Sie eine Datei mit dem Namen
  `memory.x` im Stammverzeichnis des Projekts und fügen Sie den folgenden
  Inhalt ein:
]))

#raw(block: true, lang: "text",
"MEMORY
{
  /* " + ts((
    en: "NOTE 1 K = 1 KiBi = 1024 bytes */
  /* TODO Adjust these memory regions to match your device memory layout */
  /* These values correspond to the LM3S6965, one of the few devices
  /* QEMU can emulate */",
    de: "Hinweis: 1 K = 1 KiBi = 1024 bytes */
  /* TODO Passen Sie diese Speicherbereiche an das Speicherlayout Ihres Geräts an. */
  /* Diese Werte entsprechen dem LM3S6965, einem der wenigen Bausteine, die 
  QEMU emulieren kann */",
  )) + "
  FLASH : ORIGIN = 0x00000000, LENGTH = 256K
  RAM : ORIGIN = 0x20000000, LENGTH = 64K
}

/* " + ts((
    en: "This is where the call stack will be allocated. */
/* The stack is of the full descending type. */
/* You may want to use this variable to locate the call stack and static
   variables in different memory regions. Below is shown the default value */",
    de: "Hier wird der Aufrufstapel zugewiesen. */
/* Der Stapel ist vom Typ „vollständig absteigend“. */
/* Möglicherweise möchten Sie diese Variable verwenden, um den Aufrufstapel und 
  statische Variablen in verschiedenen Speicherbereichen zu lokalisieren. 
  Nachstehend ist der Standardwert aufgeführt */"
  )) + "
/* _stack_start = ORIGIN(RAM) + LENGTH(RAM); */

/* " + ts((
    en: "You can use this symbol to customize the location of the .text section */
/* If omitted the .text section will be placed right after the .vector_table
   section */
/* This is required only on microcontrollers that store some configuration right
   after the vector table */",
    de: "Mit diesem Symbol können Sie den Speicherort des .text-Abschnitts anpassen. */
/* Wird dies weggelassen, wird der .text-Abschnitt direkt nach dem .vector_table-
  Abschnitt platziert */
/* Dies ist nur bei Mikrocontrollern erforderlich, die bestimmte 
  Konfigurationsdaten direkthinter der Vektortabelle speichern */"
  )) + "
/* _stext = ORIGIN(FLASH) + 0x400; */

/* " + ts((
    en: "Example of putting non-initialized variables into custom RAM locations. */
/* This assumes you have defined a region RAM2 above, and in the Rust
  sources added the attribute `#[link_section = \".ram2bss\"]` to the data
  you want to place there. */
/* Note that the section will not be zero-initialized by the runtime! */",
    de: "Beispiel für die Zuweisung nicht initialisierter Variablen zu 
benutzerdefinierten RAM-Speicherplätzen. */
/* Dies setzt voraus, dass Sie oben einen Bereich namens „RAM2“ definiert und 
in den Rust-Quelldateien das Attribut `#[link_section = „.ram2bss“]` zu den 
Daten hinzugefügt haben, die Sie dort platzieren möchten. */
/* Beachten Sie, dass der Bereich von der Laufzeitumgebung nicht auf Null 
initialisiert wird! */"
  )) + "
/* SECTIONS {
     .ram2bss (NOLOAD) : ALIGN(4) {
       *(.ram2bss);
       . = ALIGN(4);
     } > RAM2
   } INSERT AFTER .bss;
*/
")

#tr((
en: [
  The next step is to _cross_ compile the program for the Cortex-M3
  architecture. That's as simple as running `cargo build --target $TRIPLE`
  if you know what the compilation target (`$TRIPLE`) should be. Luckily,
  the `.cargo/config.toml` in the template has the answer:
],
de: [
  Der nächste Schritt besteht darin, das Programm für die
  Cortex-M3-Architektur _cross_ zu kompilieren. Das geht ganz einfach
  mit dem Befehl `cargo build --target $TRIPLE`, sofern Sie wissen, wie
  das Kompilierungsziel (`$TRIPLE`) lauten soll. Glücklicherweise finden
  Sie die Antwort in der Datei `.cargo/config.toml` in der Vorlage:
],
zh: [
  下一步是为Cortex-M3架构_交叉_编译程序。如果你知道编译目标(`$TRIPLE`)应该是什么，运行`cargo build --target $TRIPLE`就可以了。幸运地，模板中的`.cargo/config.toml`有这个答案:
]))

```console
tail -n6 .cargo/config.toml
```

#let _and_ = tr((
  en: " and ",
), default: " and ")

#raw(block: true, lang: "toml",
"[build]
# " + ts((
    en: "Pick ONE of these compilation targets",
    de: "Waehlen Sie EINES dieser Kompilierungsziele aus",
  )) + "
# target = \"thumbv6m-none-eabi\"    # Cortex-M0"+_and_+"Cortex-M0+
target = \"thumbv7m-none-eabi\"    # Cortex-M3
# target = \"thumbv7em-none-eabi\"   # Cortex-M4"+_and_+"Cortex-M7 (no FPU)
# target = \"thumbv7em-none-eabihf\" # Cortex-M4F"+_and_+"Cortex-M7F (with FPU)
")

#tr((
en: [
  To cross compile for the Cortex-M3 architecture we have to use
  `thumbv7m-none-eabi`. That target is not automatically installed when
  installing the Rust toolchain, it would now be a good time to add that
  target to the toolchain, if you haven't done it yet:
],
de: [
  Für die Cross-Kompilierung für die Cortex-M3-Architektur müssen wir
  `thumbv7m-none-eabi` verwenden. Dieses Ziel wird bei der Installation
  der Rust-Werkzeuge nicht automatisch installiert. Jetzt wäre ein guter
  Zeitpunkt, dieses Ziel zu den Werkzeugen hinzuzufügen, falls Sie dies
  noch nicht getan haben:
],
zh: [
  为了交叉编译Cortex-M3架构我们不得不使用`thumbv7m-none-eabi`。当安装Rust工具时，target不会自动被安装，如果还没有添加，现在可以去添加那个target到工具链上。
]))

```console
rustup target add thumbv7m-none-eabi
```

#tr((
en: [
  Since the `thumbv7m-none-eabi` compilation target has been set as the
  default in your `.cargo/config.toml` file, the two commands below do the same:
],
de: [
  Da das Kompilierungsziel `thumbv7m-none-eabi` in Ihrer Datei
  `.cargo/config.toml` als Standard festgelegt wurde, haben die beiden
  folgenden Befehle dieselbe Wirkung:
],
zh: [
  因为`thumbv7m-none-eabi`编译目标在你的`.cargo/config.toml`中被设置成默认值，下面的两个命令是一样的效果:
]))

```console
cargo build --target thumbv7m-none-eabi
cargo build
```

= #tr((
  en: [Inspecting],
  de: [Überprüfen],
  zh: [检查],
))

#tr((
en: [
  Now we have a non-native ELF binary in
  `target/thumbv7m-none-eabi/debug/app`. We can inspect it using
  `cargo-binutils`.
],
de: [
  Nun haben wir eine nicht-native ELF-Binärdatei in
  `target/thumbv7m-none-eabi/debug/app`. Wir können sie mit
  `cargo-binutils` untersuchen.
],
zh: [
  现在在`target/thumbv7m-none-eabi/debug/app`中有一个非主机环境的ELF二进制文件。我们能使用`cargo-binutils`检查它。
]))

#tr((
en: [
  With `cargo-readobj` we can print the ELF headers to confirm that this
  is an ARM binary.
],
de: [
  Mit `cargo-readobj` können wir die ELF-Header ausgeben, um zu
  überprüfen, ob es sich um eine ARM- Binärdatei handelt.
],
zh: [
  使用`cargo-readobj`我们能打印ELF头，确认这是一个ARM二进制。
]))

```console
cargo readobj --bin app -- --file-headers
```

#tr((
en: [
  Note that:
  - `--bin app` is sugar for inspect the binary at `target/$TRIPLE/debug/app`
  - `--bin app` will also (re)compile the binary, if necessary
],
de: [
  Bitte beachten Sie:
  - `--bin app` ist eine vereinfachte Schreibweise
    für die Überprüfung der Binärdatei unter `target/$TRIPLE/debug/app`
  - `--bin app` kompiliert die Binärdatei bei Bedarf auch (neu)
],
zh: [
  注意:
  - `--bin app` 是一个用来查看二进制项`target/$TRIPLE/debug/app`的语法糖
  - `--bin app` 需要时也会重新编译二进制项。
]))

```text
ELF Header:
  Magic:   7f 45 4c 46 01 01 01 00 00 00 00 00 00 00 00 00
  Class:                             ELF32
  Data:                              2's complement, little endian
  Version:                           1 (current)
  OS/ABI:                            UNIX - System V
  ABI Version:                       0x0
  Type:                              EXEC (Executable file)
  Machine:                           ARM
  Version:                           0x1
  Entry point address:               0x405
  Start of program headers:          52 (bytes into file)
  Start of section headers:          153204 (bytes into file)
  Flags:                             0x5000200
  Size of this header:               52 (bytes)
  Size of program headers:           32 (bytes)
  Number of program headers:         2
  Size of section headers:           40 (bytes)
  Number of section headers:         19
  Section header string table index: 18
```

#tr((
en: [
  `cargo-size` can print the size of the linker sections of the binary.
],
de: [
  Mit `cargo-size` lässt sich die Größe der Linker-Abschnitte der
  Binärdatei anzeigen.
],
zh: [
  `cargo-size` 能打印二进制项的linker section的大小。
]))

```console
cargo size --bin app --release -- -A
```

#tr((
en: [
  we use `--release` to inspect the optimized version
],
de: [
  Wir verwenden `--release`, um die optimierte Version zu überprüfen.
],
zh: [
  我们使用`--release`查看优化后的版本
]))

```text
app  :
section             size        addr
.vector_table       1024         0x0
.text                 92       0x400
.rodata                0       0x45c
.data                  0  0x20000000
.bss                   0  0x20000000
.debug_str          2958         0x0
.debug_loc            19         0x0
.debug_abbrev        567         0x0
.debug_info         4929         0x0
.debug_ranges         40         0x0
.debug_macinfo         1         0x0
.debug_pubnames     2035         0x0
.debug_pubtypes     1892         0x0
.ARM.attributes       46         0x0
.debug_frame         100         0x0
.debug_line          867         0x0
Total              14570
```

#quote(block: true)[
#tr((
en: [
  A refresher on ELF linker sections
  - `.text` contains the program instructions
  - `.rodata` contains constant values like strings
  - `.data` contains statically allocated variables whose initial values
    are _not_ zero
  - `.bss` also contains statically allocated variables whose initial
    values _are_ zero
  - `.vector_table` is a _non_-standard section that we use to store
    the vector (interrupt) table
  - `.ARM.attributes` and the `.debug_*` sections contain metadata and
    will _not_ be loaded onto the target when flashing the binary.
],
de: [
  Eine Auffrischung zum Thema ELF-Linker-Abschnitte
  - `.text` enthält die Programmbefehle
  - `.rodata` enthält konstante Werte wie Zeichenfolgen
  - `.data` enthält statisch zugewiesene Variablen, deren Anfangswerte
    _nicht_ Null
  - Die Datei `.bss` enthält außerdem statisch zugewiesene Variablen,
    deren Anfangswerte _sind_ Null
  - `.vector_table` ist ein _nicht_ standardmäßiger Abschnitt, in dem
    wir den Vektor speichern (interrupt) table
  - Die Abschnitte `.ARM.attributes` und `.debug_*` enthalten Metadaten
    und werden _nicht_ beim Flashen der Binärdatei auf das Zielgerät
    geladen werden.
],
zh: [
  ELF linker sections的复习
  - `.text` 包含程序指令
  - `.rodata` 包含像是字符串这样的常量
  - `.data` 包含静态分配的初始值_非_零的变量
  - `.bss` 也包含静态分配的初始值_是_零的变量
  - `.vector_table` 是一个我们用来存储向量(中断)表的_非_标准的section
  - `.ARM.attributes` 和 `.debug_*`
    sections包含元数据，当烧录二进制文件时，它们不会被加载到目标上。
]))
]

#tr((
en: [
  *IMPORTANT*: ELF files contain metadata like debug information so
  their _size on disk_ does _not_ accurately reflect the space
  the program will occupy when flashed on a device. _Always_ use
  `cargo-size` to check how big a binary really is.
],
de: [
  *WICHTIG*: ELF-Dateien enthalten Metadaten wie
  Debug-Informationen, sodass ihre _Größe auf der Festplatte_
  _nicht_ genau den Speicherplatz widerspiegelt, den das Programm
  beanspruchen wird, wenn es auf ein Gerät geflasht wird. Verwenden Sie
  _immer_ `cargo-size`, um zu überprüfen, wie groß eine Binärdatei
  tatsächlich ist.
],
zh: [
  *重要*:
  ELF文件包含像是调试信息这样的元数据，因此它们在_硬盘上的尺寸_没有正确地反应处程序被烧录到设备上时将占据的空间的大小。要_一直_使用`cargo-size`检查一个二进制项的大小。
]))

#tr((
en: [
`cargo-objdump` can be used to disassemble the binary.
],
de: [
  Mit `cargo-objdump` lässt sich die Binärdatei disassemblieren.
],
zh: [
`cargo-objdump` 能用来反编译二进制项。
]))

```console
cargo objdump --bin app --release -- --disassemble --no-show-raw-insn --print-imm-hex
```

#quote(block: true)[
#let ln_issue269 = link("https://github.com/rust-embedded/book/issues/269")
#tr((
en: [
  *NOTE* if the above command complains about
  `Unknown command line argument` see the following bug report: #ln_issue269
],
de: [
  *HINWEIS*: Falls der obige Befehl die Fehlermeldung „Unbekanntes
  Befehlszeilenargument" ausgibt, siehe den folgenden Fehlerbericht: #ln_issue269
],
zh: [
  *注意* 如果上面的命令抱怨 `Unknown command line argument`
  看下面的bug报告:#ln_issue269
]))
]

#quote(block: true)[
#tr((
en: [
  *NOTE* this output can differ on your system. New versions of
  rustc, LLVM and libraries can generate different assembly. We truncated
  some of the instructions to keep the snippet small.
],
de: [
  *HINWEIS* Diese Ausgabe kann auf Ihrem System abweichen. Neuere
  Versionen von rustc, LLVM und Bibliotheken können unterschiedlichen
  Assemblercode erzeugen. Wir haben einige der Befehle gekürzt, um den
  Ausschnitt kurz zu halten.
],
zh: [
  *注意* 在你的系统上这个输出可能不一样。rustc, LLVM
  和库的新版本能产出不同的汇编。我们截取了一些指令
]))
]

```text
app:  file format ELF32-arm-little

Disassembly of section .text:
main:
     400: bl  #0x256
     404: b #-0x4 <main+0x4>

Reset:
     406: bl  #0x24e
     40a: movw  r0, #0x0
     < .. truncated any more instructions .. >

DefaultHandler_:
     656: b #-0x4 <DefaultHandler_>

UsageFault:
     657: strb  r7, [r4, #0x3]

DefaultPreInit:
     658: bx  lr

__pre_init:
     659: strb  r7, [r0, #0x1]

__nop:
     65a: bx  lr

HardFaultTrampoline:
     65c: mrs r0, msp
     660: b #-0x2 <HardFault_>

HardFault_:
     662: b #-0x4 <HardFault_>

HardFault:
     663: <unknown>
```

= #tr((
  en: [Running],
  de: [Ausführen],
  zh: [运行],
))

#tr((
en: [
  Next, let's see how to run an embedded program on QEMU! This time we'll
  use the `hello` example which actually does something. By default, this
  example uses `[defmt]` and RTT to print text.
],
de: [
  Als Nächstes schauen wir uns an, wie man ein eingebettetes Programm auf
  QEMU ausführt! Diesmal verwenden wir das `hello`-Beispiel, das
  tatsächlich etwas tut. Standardmäßig nutzt dieses Beispiel `[defmt]` und
  RTT, um Text auszugeben.
],
zh: [
  #todoupd("zh")
  接下来，让我们看一个嵌入式程序是如何在QEMU上运行的！此刻我们将使用
  `hello` 示例，来做些真正的事。
]))

#quote(block: true)[
#tr((
en: [
  *NOTE* `defmt` is a third-party dependency (i.e.~non-core) widely
  used in the Embedded Rust ecosystem.
],
de: [
  *HINWEIS* `defmt` ist eine Abhängigkeit eines Drittanbieters
  (d. h. keine Kernkomponente), die im Embedded-Rust-Ökosystem weit
  verbreitet ist.
]))
]

#tr((
en: [
  In order to read and decode the messages produced by `defmt` in the
  host, we need to switch the RTT transport output to semihosting. When
  using real hardware this requires a debug session but when using QEMU
  this Just Works.
],
de: [
  Um die von `defmt` im Host erzeugten Nachrichten lesen und entschlüsseln
  zu können, müssen wir die RTT-Transportausgabe auf „Semihosting"
  umstellen. Bei Verwendung von echter Hardware erfordert dies eine
  Debug-Sitzung, bei Verwendung von QEMU funktioniert dies jedoch einfach
  so.
]))

#tr((
en: [
  Let's switch the dependencies:
],
de: [
  Stellen wir die Abhängigkeiten um:
]))

```console
cargo remove defmt-rtt
cargo add defmt-semihosting
```

#tr((
en: [
  Open `src/lib.rs` and replace `use defmt_rtt as _;` by `use defmt_semihosting as _;`
],
de: [
  Öffnen Sie `src/lib.rs` und ersetzen Sie `use defmt_rtt as _;` durch
  `use defmt_semihosting as _;`.
]))

#tr((
en: [
  Now we can build the example:
],
de: [
  Nun können wir das Beispiel kompilieren:
]))

```console
cargo build --bin hello
```

#tr((
en: [
  The output binary will be located at `target/thumbv7m-none-eabi/debug/hello`.
],
de: [
  Die ausgegebene Binärdatei befindet sich unter
  `target/thumbv7m-none-eabi/debug/hello`.
]))

#tr((
en: [
  To run this binary on QEMU, the following command would be usually enough:
],
de: [
  Um diese Binärdatei unter QEMU auszuführen, reicht in der Regel der
  folgende Befehl aus:
],
zh: [
  为了在QEMU上运行这个二进制项，执行下列的命令:
]))

```console
qemu-system-arm \
  -cpu cortex-m3 \
  -machine lm3s6965evb \
  -nographic \
  -semihosting-config enable=on,target=native \
  -kernel target/thumbv7m-none-eabi/debug/hello
```

#let ln_run = link("https://github.com/knurling-rs/defmt/tree/main/qemu-run/")[`qemu-run`]
#tr((
en: [
  In our case, since we use `defmt`, the host will not be able to decode
  the output. Instead, we will need a tool by Ferrous Systems named #ln_run:
],
de: [
  Da wir in unserem Fall `defmt` verwenden, kann der Host die Ausgabe
  nicht dekodieren. Stattdessen benötigen wir ein Werkzeug von Ferrous
  Systems namens #ln_run:
]))

```console
git clone git@github.com:knurling-rs/defmt.git
cd defmt/qemu-run/
cargo run -- --machine lm3s6965evb ../qemu-rs/target/thumbv7m-none-eabi/debug/hello
```

```text
Hello, world!
```

#tr((
en: [
  The command should successfully exit (exit code = 0) after printing the
  text. On \*nix you can check that with the following command:
],
de: [
  Der Befehl sollte nach der Ausgabe des Textes erfolgreich beendet werden
  (Exit-Code = 0). Unter \*nix können Sie dies mit dem folgenden Befehl überprüfen:
]))

```console
echo $?
```

```text
0
```

#tr((
en: [
  Let's break down that QEMU command:
  - `qemu-system-arm`. This is the QEMU emulator. There are a few variants
    of these QEMU binaries; this one does full _system_ emulation of
    _ARM_ machines hence the name.
  - `-cpu cortex-m3`. This tells QEMU to emulate a Cortex-M3 CPU.
    Specifying the CPU model lets us catch some miscompilation errors: for
    example, running a program compiled for the Cortex-M4F, which has a
    hardware FPU, will make QEMU error during its execution.
  - `-machine lm3s6965evb`. This tells QEMU to emulate the LM3S6965EVB, an
    evaluation board that contains a LM3S6965 microcontroller.
  - `-nographic`. This tells QEMU to not launch its GUI.
  - `-semihosting-config (..)`. This tells QEMU to enable semihosting.
    Semihosting lets the emulated device, among other things, use the host
    stdout, stderr and stdin and create files on the host.
  - `-kernel $file`. This tells QEMU which binary to load and run on the
    emulated machine.
],
de: [
  Schauen wir uns diesen QEMU-Befehl einmal genauer an:
  - `qemu-system-arm`. Dies ist der QEMU-Emulator. Es gibt einige
    Varianten dieser QEMU-Binärdateien; diese hier führt eine vollständige
    _System_-Emulation von _ARM_-Rechnern durch, daher der Name.
  - `-cpu cortex-m3`. Damit wird QEMU angewiesen, eine Cortex-M3-CPU zu
    emulieren. Durch die Angabe des CPU-Modells lassen sich einige
    Kompilierungsfehler erkennen: Wenn man beispielsweise ein Programm
    ausführt, das für den Cortex-M4F kompiliert wurde, der über eine
    Hardware-FPU verfügt, löst dies bei QEMU während der Ausführung einen Fehler aus.
  - `-machine lm3s6965evb`. Damit wird QEMU angewiesen, das LM3S6965EVB zu
    emulieren, ein Evaluierungsboard, das einen LM3S6965-Mikrocontroller enthält.
  - `-nographic`. Damit wird QEMU angewiesen, seine grafische
    Benutzeroberfläche nicht zu starten.
  - `-semihosting-config (..)`. Damit wird QEMU angewiesen, Semihosting zu
    aktivieren. Semihosting ermöglicht es dem emulierten Gerät unter
    anderem, die Host-Ausgabe (stdout), die Host-Fehlerausgabe (stderr)
    und die Host-Eingabe (stdin) zu nutzen sowie Dateien auf dem Host zu erstellen.
  - `-kernel $file`. Damit wird QEMU mitgeteilt, welche Binärdatei auf der
    emulierten Maschine geladen und ausgeführt werden soll.
],
zh: [
  #todoupd("zh")
  让我们看看QEMU命令:
  - `qemu-system-arm`。这是QEMU仿真器。这些QEMU二进制项有一些变体，这个仿真器能做ARM机器的全系统仿真。
  - `-cpu cortex-m3`。这告诉QEMU去仿真一个Cortex-M3
    CPU。指定CPU模型会让我们捕捉到一些误编译错误:比如，运行一个为Cortex-M4F编译的程序，它具有一个硬件FPU，在执行时将会使QEMU报错。
  - `-machine lm3s6965evb`。这告诉QEMU去仿真
    LM3S6965EVB，一个包含LM3S6965微控制器的评估板。
  - `-nographic`。这告诉QEMU不要启动它的GUI。
  - `-semihosting-config (..)`。这告诉QEMU使能半主机模式。半主机模式允许被仿真的设备，使用主机的stdout，stderr，和stdin，并在主机上创建文件。
  - `-kernel $file`。这告诉QEMU在仿真机器上加载和运行哪个二进制项。

  输入这么长的QEMU命令太费功夫了！我们可以设置一个自定义运行器(runner)简化步骤。`.cargo/config.toml`
  有一个被注释掉的，可以调用QEMU的运行器。让我们去掉注释。
]))

#tr((
en: [
  Typing out that long QEMU command is too much work! We can set a custom
  runner to simplify the process. `.cargo/config.toml` has a commented out
  runner that invokes QEMU; let's uncomment it:
],
de: [
  Das Eintippen dieses langen QEMU-Befehls ist viel zu mühsam! Wir können
  einen benutzerdefinierten Runner einrichten, um den Vorgang zu
  vereinfachen. In der Datei `.cargo/config.toml` gibt es einen
  auskommentierten Runner, der QEMU aufruft; entfernen wir die
  Auskommentierung:
]))

```console
head -n3 .cargo/config.toml
```

#raw(block: true, lang: "toml",
"[target.thumbv7m-none-eabi]
# " + ts((
    en: "uncomment this to make `cargo run` execute programs on QEMU",
    de: "Entferne den Kommentar hier, damit `cargo run` Programme auf QEMU ausfuehrt",
    ja: "`cargo run`で、プログラムをQEMUで実行するため、コメントアウトを外して下さい。",
  )) + "
runner = \"qemu-system-arm -cpu cortex-m3 -machine lm3s6965evb -nographic -semihosting-config enable=on,target=native -kernel\"
")

#tr((
en: [
  This runner only applies to the `thumbv7m-none-eabi` target, which is
  our default compilation target. Now `cargo run` will compile the program
  and run it on QEMU:
],
de: [
  Dieser Runner gilt nur für das Ziel `thumbv7m-none-eabi`, das unser
  Standard-Kompilierungsziel ist. Nun kompiliert `cargo run` das Programm
  und führt es auf QEMU aus:
],
ja: [
  このランナーは、デフォルトのコンパイルターゲットである`thumbv7m-none-eabi`のみに適用されます。
  これで、`cargo run`はプログラムをコンパイルしてQEMUで実行します。
],
zh: [
  这个运行器只会应用于 `thumbv7m-none-eabi`
  目标，它是我们的默认编译目标。现在 `cargo run`
  将会编译程序且在QEMU上运行它。
]))

```console
cargo ru(
  level: 2 + whole
)--release
```

```text
   Compiling app v0.1.0 (file:///tmp/app)
    Finished release [optimized + debuginfo] target(s) in 0.26s
     Running `qemu-system-arm -cpu cortex-m3 -machine lm3s6965evb -nographic -semihosting-config enable=on,target=native -kernel target/thumbv7m-none-eabi/release/examples/hello`
Hello, world!
```

= #tr((
  en: [Debugging],
  de: [Fehlerbehebung (Debugging)],
  ja: [デバッグ],
  zh: [调试],
))

#tr((
en: [
  Debugging is critical to embedded development. Let's see how it's done.
],
de: [
  Das Debuggen ist für die Embedded-Entwicklung von entscheidender
  Bedeutung. Schauen wir uns einmal an, wie es funktioniert.
],
ja: [
  デバッグは組込み開発にとって非常に重要です。どのように行うのか、見てみましょう。
],
zh: [
  对于嵌入式开发来说，调试非常重要。让我们来看下如何调试它。
]))

#tr((
en: [
  Debugging an embedded device involves _remote_ debugging as the
  program that we want to debug won't be running on the machine that's
  running the debugger program (GDB or LLDB).
],
de: [
  Das Debuggen eines Embedded-Geräts erfolgt _remote_, da das
  Programm, das wir debuggen möchten, nicht auf dem Rechner läuft, auf dem
  das Debugger-Programm (GDB oder LLDB) ausgeführt wird.
],
ja: [
  組込みデバイスのデバッグは、_リモート_デバッグを伴います。デバッグしたいプログラムは、
  デバッガプログラム（GDBまたはLLDB）を実行しているマシン上で実行されないためです。
],
zh: [
  因为我们想要调试的程序所运行的机器上并没有运行一个调试器程序(GDB或者LLDB)，所以调试一个嵌入式设备就涉及到了
  _远程_ 调试
]))

#tr((
en: [
  Remote debugging involves a client and a server. In a QEMU setup, the
  client will be a GDB (or LLDB) process and the server will be the QEMU
  process that's also running the embedded program.
],
de: [
  Beim Remote-Debugging sind ein Client und ein Server beteiligt. In einer
  QEMU-Umgebung ist der Client ein GDB- (oder LLDB-)Prozess und der Server
  der QEMU-Prozess, auf dem auch das eingebettete Programm läuft.
],
ja: [
  リモートデバッグは、クライアントとサーバからなります。QEMUのセットアップで、
  クライアントはGDB（またはLLDB）プロセスとなり、サーバは組込みプログラムを実行しているQEMUプロセスとなります。
],
zh: [
  远程调试涉及一个客户端和一个服务器。在QEMU的情况中，客户端将是一个GDB(或者LLDM)进程且服务器将会是运行着嵌入式程序的QEMU进程。

]))

#tr((
en: [
  In this section we'll use the `hello` example we already compiled.
],
de: [
  In diesem Abschnitt verwenden wir das bereits kompilierte Beispiel `hello`.
],
ja: [
  このセクションでは、コンパイル済みの`hello`の例を使用します。
],
zh: [
  在这部分，我们要使用我们已经编译的 `hello` 示例。
]))

#tr((
en: [
  The first debugging step is to launch QEMU in debugging mode:
],
de: [
  Der erste Schritt beim Debuggen besteht darin, QEMU im Debugging-Modus zu starten:
],
ja: [
  最初のデバッグステップは、QEMUをデバッグモードで起動することです。
],
zh: [
  调试的第一步是在调试模式中启动QEMU：
]))

```console
qemu-system-arm \
  -cpu cortex-m3 \
  -machine lm3s6965evb \
  -nographic \
  -semihosting-config enable=on,target=native \
  -gdb tcp::3333 \
  -S \
  -kernel target/thumbv7m-none-eabi/debug/examples/hello
```

#tr((
en: [
  This command won't print anything to the console and will block the
  terminal. We have passed two extra flags this time:
  - `-gdb tcp::3333`. This tells QEMU to wait for a GDB connection on TCP
    port 3333.
  - `-S`. This tells QEMU to freeze the machine at startup. Without this
    the program would have reached the end of main before we had a chance
    to launch the debugger!
],
de: [
  Dieser Befehl gibt nichts auf der Konsole aus und blockiert das
  Terminal. Wir haben diesmal zwei zusätzliche Flags übergeben:
  - `-gdb tcp::3333`. Damit wird QEMU angewiesen, auf eine GDB-Verbindung
    über den TCP-Port 3333 zu warten.
  - `-S`. Damit wird QEMU angewiesen, die Maschine beim Start
    einzufrieren. Ohne diese Option hätte das Programm das Ende der
    Funktion `main` erreicht, bevor wir die Gelegenheit gehabt hätten, den
    Debugger zu starten!
],
ja: [
  このコマンドは、コンソールに何も表示せず、端末をブロックします。
  ここでは2つの追加フラグを渡しています。
  - `-gdb tcp::3333`。QEMUがTCPポート3333番で、GDBコネクションを待つようにします。
  - `-S`。QEMUが、起動時に、マシンをフリーズします。このフラグがないと、
    デバッガを起動する前に、プログラムがmain関数の終わりに到達してしまいます。
],
zh: [
  这个命令将不打印任何东西到调试台上，且将会阻塞住终端。此刻我们还传递了两个额外的标志。
  - `-gdb tcp::3333`。这告诉QEMU在3333的TCP端口上等待一个GDB连接。
  - `-S`。这告诉QEMU在启动时，冻结机器。没有这个，在我们有机会启动调试器之前，程序有可能已经到达了主程序的底部了!
]))

#tr((
en: [
  Next we launch GDB in another terminal and tell it to load the debug
  symbols of the example:
],
de: [
  Als Nächstes starten wir GDB in einem anderen Terminal und weisen es an,
  die Debug-Symbole des Beispiels zu laden:
],
ja: [
  次に別の端末でGDBを起動し、`hello`の例のデバッグシンボルをロードします。
],
zh: [
  接下来我们在另一个终端启动GDB，且告诉它去加载示例的调试符号。
]))

```console
gdb-multiarch -q target/thumbv7m-none-eabi/debug/examples/hello
```

#tr((
en: [
  *NOTE*: you might need another version of gdb instead of
  `gdb-multiarch` depending on which one you installed in the installation
  chapter. This could also be `arm-none-eabi-gdb` or just `gdb`.
],
de: [
  *HINWEIS*: Möglicherweise benötigen Sie anstelle von
  `gdb-multiarch` eine andere Version von gdb, je nachdem, welche Sie im
  Kapitel zur Installation installiert haben. Dies könnte auch
  `arm-none-eabi-gdb` oder einfach nur `gdb` sein.
],
zh: [
  *注意*: 你可能需要另一个gdb版本而不是
  `gdb-multiarch`，取决于你在安装章节中安装了哪个。这个可能是
  `arm-none-eabi-gdb` 或者只是 `gdb`。
]))

#tr((
en: [
  Then within the GDB shell we connect to QEMU, which is waiting for a
  connection on TCP port 3333.
],
de: [
  Anschließend stellen wir innerhalb der GDB-Shell eine Verbindung zu QEMU
  her, das auf dem TCP-Port 3333 auf eine Verbindung wartet.
],
zh: [
  然后在GDB shell中，我们连接QEMU，QEMU正在等待一个在3333
  TCP端口上的连接。
]))

```console
target remote :3333
```

```text
Remote debugging using :3333
Reset () at $REGISTRY/cortex-m-rt-0.6.1/src/lib.rs:473
473     pub unsafe extern "C" fn Reset() -> ! {
```

#tr((
en: [
  You'll see that the process is halted and that the program counter is
  pointing to a function named `Reset`. That is the reset handler: what
  Cortex-M cores execute upon booting.
],
de: [
  Sie werden feststellen, dass der Prozess angehalten wurde und der
  Programmzähler auf eine Funktion namens `Reset` zeigt. Das ist der
  Reset-Handler: das, was Cortex-M-Kerne beim Booten ausführen.
],
zh: [
  你将看到，进程被挂起了，程序计数器正指向一个名为 `Reset` 的函数。那是
  reset 句柄：Cortex-M 内核在启动时执行的中断函数。
]))

#quote(block: true)[
#tr((
en: [
  Note that on some setup, instead of displaying the line
  `Reset () at $REGISTRY/cortex-m-rt-0.6.1/src/lib.rs:473` as shown above,
  gdb may print some warnings like:
],
de: [
  Beachten Sie, dass gdb in manchen Konfigurationen anstelle der oben
  gezeigten Zeile `Reset () at $REGISTRY/cortex-m-rt-0.6.1/src/lib.rs:473`
  möglicherweise Warnungen wie die folgenden ausgibt:
],
zh: [
  注意在一些配置中，可能不会像上面一样，显示`Reset() at $REGISTRY/cortex-m-rt-0.6.1/src/lib.rs:473`，gdb可能打印一些警告，比如:
]))

`core::num::bignum::Big32x40::mul_small () at src/libcore/num/bignum.rs:254`
`src/libcore/num/bignum.rs: No such file or directory.`

#tr((
en: [
  That's a known glitch. You can safely ignore those warnings, you're most
  likely at Reset().
],
de: [
  Das ist ein bekannter Fehler. Sie können diese Warnungen getrost
  ignorieren, da Sie sich höchstwahrscheinlich bei `Reset()` befinden.
],
zh: [
  那是一个已知的小bug，你可以安全地忽略这些警告，你非常大可能已经进入Reset()了。
]))
]

#tr((
en: [
  This reset handler will eventually call our main function. Let's skip
  all the way there using a breakpoint and the `continue` command. To set
  the breakpoint, let's first take a look where we would like to break in
  our code, with the `list` command.
],
de: [
  Dieser Reset-Handler ruft schließlich unsere Hauptfunktion auf. Lassen
  Sie uns den gesamten Weg dorthin mithilfe eines Haltepunkts und des
  Befehls `continue` überspringen. Um den Haltepunkt zu setzen, schauen
  wir uns zunächst mit dem Befehl `list` an, an welcher Stelle in unserem
  Code wir anhalten möchten.
],
zh: [
  这个reset句柄最终将调用我们的主函数，让我们使用一个断点和`continue`命令跳过所有的步骤。为了设置断点，让我们首先看下我们想要在我们代码哪里打断点，使用`list`指令
]))

```console
list main
```

#tr((
en: [
  This will show the source code, from the file examples/hello.rs.
],
de: [
  Dadurch wird der Quellcode aus der Datei „examples/hello.rs" angezeigt.
],
zh: [
  这将显示从examples/hello.rs文件来的源代码。
]))

```text
6       use panic_halt as _;
7
8       use cortex_m_rt::entry;
9       use cortex_m_semihosting::{debug, hprintln};
10
11      #[entry]
12      fn main() -> ! {
13          hprintln!("Hello, world!").unwrap();
14
15          // exit QEMU
```

#tr((
en: [
  We would like to add a breakpoint just before the "Hello, world!", which
  is on line 13. We do that with the `break` command:
],
de: [
  Wir möchten einen Haltepunkt direkt vor „Hello, world!" setzen, das sich
  in Zeile 13 befindet. Dazu verwenden wir den Befehl `break`:
],
zh: [
  我们想要在"Hello,
  world!"之前添加一个断点，在13行那里。我们可以使用`break`命令
]))

```console
break 13
```

#tr((
en: [
  We can now instruct gdb to run up to our main function, with the
  `continue` command:
],
de: [
  Wir können gdb nun mit dem Befehl `continue` anweisen, bis zu unserer
  Hauptfunktion weiterzulaufen:
],
zh: [
  我们现在能使用`continue`命令指示gdb运行到我们的主函数。
]))

```console
continue
```

```text
Continuing.

Breakpoint 1, hello::__cortex_m_rt_main () at examples\hello.rs:13
13          hprintln!("Hello, world!").unwrap();
```

#tr((
en: [
  We are now close to the code that prints "Hello, world!". Let's move
  forward using the `next` command.
],
de: [
  Wir sind nun fast bei dem Code angelangt, der „Hello, world!" ausgibt.
  Machen wir weiter mit dem Befehl `next`.
],
ja: [
  「Hello, world!」を表示するコードに近づいてきました。
  `next`コマンドを使って、先へ進みましょう。
],
zh: [
  我们现在靠近打印"Hello, world!"的代码。让我们使用`next`命令继续前进。
]))

```console
next
```

```text
16          debug::exit(debug::EXIT_SUCCESS);
```

#tr((
en: [
  At this point you should see "Hello, world!" printed on the terminal
  that's running `qemu-system-arm`.
],
de: [
  An dieser Stelle sollte auf dem Terminal, auf dem `qemu-system-arm`
  läuft, „Hello, world!" angezeigt werden.
],
ja: [
  この時点で、`qemu-system-arm`を実行している端末に「Hello,
  world」が表示されるはずです。
],
zh: [
  在这里，你应该看到 "Hello, world!" 被打印到正在运行 `qemu-system-arm` 的终端上。
]))

```text
$ qemu-system-arm (..)
Hello, world!
```

#tr((
en: [
  Calling `next` again will terminate the QEMU process.
],
de: [
  Ein erneuter Aufruf von `next` beendet den QEMU-Prozess.
],
ja: [
  もう1度`next`を実行すると、QEMUプロセスが終了します。
],
zh: [
  再次调用`next`将会终止QEMU进程。
]))

```console
next
```

```text
[Inferior 1 (Remote target) exited normally]
```

#tr((
en: [
  You can now exit the GDB session.
],
de: [
  Sie können die GDB-Sitzung nun beenden.
],
ja: [
  これでGDBセッションを終了できます。
],
zh: [
  你现在能退出GDB的会话了。
]))

```console
quit
```
