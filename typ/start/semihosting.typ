#import "../config.typ": *

#h1((en: [Semihosting],
  de: [Semihosting],
  ja: [セミホスティング],
  zh: [半主机模式],
), offset: whole)

#tr((
en: [
  Semihosting is a mechanism that lets embedded devices do I/O on the host
  and is mainly used to log messages to the host console. Semihosting
  requires a debug session and pretty much nothing else (no extra wires!)
  so it's super convenient to use. The downside is that it's super slow:
  each write operation can take several milliseconds depending on the
  hardware debugger (e.g.~ST-Link) you use.
],
de: [
  Semihosting ist ein Mechanismus, der es eingebetteten Systemen
  ermöglicht, Ein-/Ausgabeoperationen über den eigenen Rechner (Host)
  durchzuführen; er wird hauptsächlich dazu genutzt, Meldungen auf der
  Host-Konsole zu protokollieren. Da Semihosting lediglich eine
  Debug-Sitzung und sonst so gut wie nichts (keine zusätzlichen Kabel!)
  erfordert, ist es äußerst komfortabel in der Anwendung. Der Nachteil ist
  jedoch die sehr geringe Geschwindigkeit: Je nach verwendetem
  Hardware-Debugger (z. B. ST-Link) kann jeder Schreibvorgang mehrere
  Millisekunden in Anspruch nehmen.
],
ja: [
  セミホスティングは、組込みデバイスがホスト上でI/Oを行う仕組みです。主に、ホストのコンソールにログ出力するために使われます。
  セミホスティングには、デバッグセッションが必要ですが、他には何も必要としません（追加の配線は不要です）。そのため、非常に便利です。
  欠点は、非常に低速であることです。ハードウェアデバッガ（例えば、ST-Link）によっては、書き込み操作が数ミリ秒かかります。
],
zh: [
  半主机模式是一种可以让嵌入式设备在主机上进行I/O操作的的机制，主要被用来记录信息到主机控制台上。半主机模式需要一个debug会话，除此之外几乎没有其它要求了，因此它非常易于使用。缺点是它非常慢：每个写操作需要几毫秒的时间，其取决于你的硬件调试器(e.g.~ST-LINK)。
]))

#let ln_sh = link("https://crates.io/crates/cortex-m-semihosting")[`cortex-m-semihosting`]
#tr((
en: [
  The #ln_sh crate provides an API to do semihosting
  operations on Cortex-M devices.
  The program below is the semihosting version of "Hello, world!":
],
de: [
  Das #ln_sh;-Crate
  stellt eine API für Semihosting-Operationen auf Cortex-M-Geräten bereit.
  Das folgende Programm ist die Semihosting-Version von „Hello, world!":
],
ja: [
  #ln_sh;クレートは、Cortex-Mデバイス上でセミホスティング操作をするためのAPIを提供します。
  下のプログラムは、セミホスティングバージョンの「Hello, world!」です。
],
zh: [
  #ln_sh crate 提供了一个API去在Cortex-M设备上执行半主机操作。下面的程序是"Hello,
  world!"的半主机版本。
]))

```rust
#![no_main]
#![no_std]

use panic_halt as _;

use cortex_m_rt::entry;
use cortex_m_semihosting::hprintln;

#[entry]
fn main() -> ! {
    hprintln!("Hello, world!").unwrap();

    loop {}
}
```

#tr((
en: [
  If you run this program on hardware you'll see the "Hello, world!"
  message within the OpenOCD logs.
],
de: [
  Wenn Sie dieses Programm auf der Hardware ausführen, sehen Sie die
  Meldung „Hello, world!" in den OpenOCD-Protokollen.
],
ja: [
  このプログラムをハードウェア上で実行すると、OpenOCDのログに、「Hello
  world!」のメッセージが表示されます。
],
zh: [
  如果你在硬件上运行这个程序，你将会在OpenOCD的logs中看到"Hello,
  world!"信息。
]))

```text
$ openocd
(..)
Hello, world!
(..)
```

#tr((
en: [
  You do need to enable semihosting in OpenOCD from GDB first:
],
de: [
  Sie müssen zunächst Semihosting in OpenOCD über GDB aktivieren:
],
ja: [
  最初に、GDBからOpenOCDのセミホスティングを有効化する必要があります。
],
zh: [
  你首先需要从GDB使能OpenOCD中的半主机模式。
]))

```console
(gdb) monitor arm semihosting enable
semihosting is enabled
```

#tr((
en: [
  QEMU understands semihosting operations so the above program will also
  work with `qemu-system-arm` without having to start a debug session.
  Note that you'll need to pass the `-semihosting-config` flag to QEMU to
  enable semihosting support; these flags are already included in the
  `.cargo/config.toml` file of the template.
],
de: [
  QEMU unterstützt Semihosting-Operationen, sodass das obige Programm auch
  mit `qemu-system-arm` funktioniert, ohne dass eine Debug-Sitzung
  gestartet werden muss. Beachten Sie, dass Sie QEMU die Option
  `-semihosting-config` übergeben müssen, um die Semihosting-Unterstützung
  zu aktivieren; diese Optionen sind bereits in der Datei
  `.cargo/config.toml` der Vorlage enthalten.
],
ja: [
  QEMUはセミホスティング操作を理解しているため、上のプログラムは、デバッグセッションを開始していない`qemu-system-arm`でも動作します。
  セミホスティングサポートを有効化するため、QEMUに`-semihosting-config`フラグを渡す必要があることに注意して下さい。
  これらのフラグは、テンプレートの`.cargo/config`ファイルに既に含まれています。
],
zh: [
  QEMU理解半主机操作，因此上面的程序不需要启动一个debug会话，也能在`qemu-system-arm`中工作。注意你需要传递`-semihosting-config`标志给QEMU去使能支持半主机模式；这些标识已经被包括在模板的`.cargo/config.toml`文件中了。
]))

#raw(block: true, lang: "text",
"$ # " + ts((
    en: "this program will block the terminal",
    de: "Dieses Programm wird das Terminal blockieren.",
    ja: "このプログラムは端末をブロックします",
  )) + "
$ cargo run
     Running `qemu-system-arm (..)
Hello, world!
")

#tr((
en: [
  There's also an `exit` semihosting operation that can be used to
  terminate the QEMU process. Important: do *not* use `debug::exit`
  on hardware; this function can corrupt your OpenOCD session and you will
  not be able to debug more programs until you restart it.
],
de: [
  Es gibt auch eine `exit`-Semihosting-Operation, mit der sich der
  QEMU-Prozess beenden lässt. Wichtig: Verwenden Sie `debug::exit`
  *nicht* auf echter Hardware; diese Funktion kann Ihre
  OpenOCD-Sitzung beschädigen, sodass Sie keine weiteren Programme mehr
  debuggen können, bis Sie die Sitzung neu starten.
],
ja: [
  `exit`セミホスティング操作もあり、QEMUプロセスを終了するために使われます。
  重要：ハードウェア上で`debug::exit`を*使用しない*で下さい。この関数は、OpenOCDセッションを破壊する可能性があり、
  OpenOCDを再起動しない限り、それ以上のプログラムのデバッグができなくなります。
],
zh: [
  `exit`半主机操作也能被用于终止QEMU进程。重要：*不要*在硬件上使用`debug::exit`；这个函数会关闭你的OpenOCD对话，这样你就不能执行其它的程序调试操作了，除了重启它。
]))

```rust
#![no_main]
#![no_std]

use panic_halt as _;

use cortex_m_rt::entry;
use cortex_m_semihosting::debug;

#[entry]
fn main() -> ! {
    let roses = "blue";

    if roses == "red" {
        debug::exit(debug::EXIT_SUCCESS);
    } else {
        debug::exit(debug::EXIT_FAILURE);
    }

    loop {}
}
```

```text
$ cargo run
     Running `qemu-system-arm (..)

$ echo $?
1
```

#tr((
en: [
  One last tip: you can set the panicking behavior to
  `exit(EXIT_FAILURE)`. This will let you write `no_std` run-pass tests
  that you can run on QEMU.
],
de: [
  Ein letzter Tipp: Du kannst das Verhalten bei einem Panic auf
  `exit(EXIT_FAILURE)` einstellen. Dadurch lassen sich `no_std`-Tests
  schreiben, die erfolgreich durchlaufen und unter QEMU ausgeführt werden
  können.
],
ja: [
  最後のヒント：パニック時の挙動を、`exit(EXIT_FAILURE)`に設定することができます。
  これで、QEMU上で実行できる`no_std`ランパステストを書くことができます。

],
zh: [
  最后一个提示：你可以将运行时恐慌(panicking)的行为设置成
  `exit(EXIT_FAILURE)`。这会允许你编写可以在QEMU上运行通过的 `no_std`
  测试。
]))

#tr((
en: [
  For convenience, the `panic-semihosting` crate has an "exit" feature
  that when enabled invokes `exit(EXIT_FAILURE)` after logging the panic
  message to the host stderr.
],
de: [
  Praktischerweise bietet der `panic-semihosting`-Crate ein „exit"-Feature
  an; ist dieses aktiviert, wird `exit(EXIT_FAILURE)` aufgerufen, nachdem
  die Panic-Meldung auf dem `stderr` des Hosts ausgegeben wurde.
],
ja: [
  利便性のために、`panic-semihosting`クレートは、「exit」フィーチャを持っています。
  このフィーチャが有効化されていると、ホストの標準エラーにパニックメッセージをログ出力した後、`exit(EXIT_FAILURE)`を呼び出します。
],
zh: [
  为了方便，`panic-semihosting` crate有一个 "exit"
  特性。当它使能的时候，在主机stderr上打印恐慌(painc)信息后会调用
  `exit(EXIT_FAILURE)` 。
]))

```rust
#![no_main]
#![no_std]

use panic_semihosting as _; // features = ["exit"]

use cortex_m_rt::entry;
use cortex_m_semihosting::debug;

#[entry]
fn main() -> ! {
    let roses = "blue";

    assert_eq!(roses, "red");

    loop {}
}
```

```text
$ cargo run
     Running `qemu-system-arm (..)
panicked at 'assertion failed: `(left == right)`
  left: `"blue"`,
 right: `"red"`', examples/hello.rs:15:5

$ echo $?
1
```

#tr((
en: [
  *NOTE*: To enable this feature on `panic-semihosting`, edit your
  `Cargo.toml` dependencies section where `panic-semihosting` is specified
  with:
],
de: [
  *HINWEIS*: Um diese Funktion für `panic-semihosting` zu
  aktivieren, bearbeiten Sie den Abschnitt „dependencies" in Ihrer
  `Cargo.toml`, in dem `panic-semihosting` wie folgt angegeben ist:
],
zh: [
  *注意*:
  为了在`panic-semihosting`上使能这个特性，编辑你的`Cargo.toml`依赖，`panic-semihosting`改写成:
]))

```toml
panic-semihosting = { version = "VERSION", features = ["exit"] }
```

#let ln_spec_defs = link("https://doc.rust-lang.org/cargo/reference/specifying-dependencies.html")[`specifying dependencies`]
#tr((
en: [
  where `VERSION` is the version desired. For more information on
  dependencies features check the
  #ln_spec_defs
  section of the Cargo book.
],
de: [
  wobei `VERSION` für die gewünschte Version steht. Weitere Informationen
  zu Abhängigkeiten und Funktionen finden Sie im Abschnitt
  "#ln_spec_defs"
  des Cargo-Buchs.
],
zh: [
  `VERSION`是想要的版本。关于依赖features的更多信息查看Cargo
  book的#ln_spec_defs;部分。
]))
