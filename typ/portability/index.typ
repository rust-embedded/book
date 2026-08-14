#import "../config.typ": *

#h1((en: [Portability],
  de: [Portabilität],
  ja: [移植性],
  zh: [可移植性],
))
<portability>

#tr((
en: [
  In embedded environments portability is a very important topic: Every
  vendor and even each family from a single manufacturer offers different
  peripherals and capabilities and similarly the ways to interact with the
  peripherals will vary.
],
de: [
  In eingebetteten Systemen ist Portabilität ein sehr wichtiges Thema:
  Jeder Hersteller und sogar jede Produktfamilie eines einzelnen
  Herstellers bietet unterschiedliche Peripheriegeräte und Funktionen an,
  und dementsprechend variieren auch die Interaktionsmöglichkeiten mit den
  Peripheriegeräten.
],
ja: [
  組込み環境においては、移植性は非常に重要なトピックです。1つのメーカから、それぞれのベンダや各プロダクトファミリが、異なるペリフェラルや機能を提供します、
  異なるペリフェラルでは、ペリフェラルとやり取りする方法も異なります。
],
zh: [
  在嵌入式环境中，可移植性是一个非常重要的主题:
  每个供应商甚至同个制造商的不同系列间，都提供了不同的外设和功能。同样地，与外设交互的方式也将会不一样。
]))

#tr((
en: [
  A common way to equalize such differences is via a layer called Hardware
  Abstraction layer or *HAL*.
],
de: [
  Eine gängige Methode, diese Unterschiede auszugleichen, ist die
  sogenannte Hardware-Abstraktionsschicht (HAL).
],
ja: [
  このような違いを吸収する一般的な方法は、ハードウェア抽象化レイヤまたは*HAL*と呼ばれるレイヤを導入することです。
],
zh: [
  通过一个被叫做硬件抽象层或者*HAL*的层去均等化这种差异是一种常见的方法。
]))

#quote(block: true)[
#tr((
en: [
  Hardware abstractions are sets of routines in software that emulate some
  platform-specific details, giving programs direct access to the hardware
  resources.
],
de: [
  Hardware-Abstraktionen sind Sammlungen von Software-Routinen, die
  bestimmte plattformspezifische Details emulieren und Programmen so
  direkten Zugriff auf die Hardwareressourcen ermöglichen.
],
ja: [
  ハードウェア抽象化は、プラットフォーム固有の細部をエミュレーションして、プログラムにハードウェアリソースへ直接アクセスする方法を提供する、ソフトウェアの一連のルーチンです。
],
zh: [
  在软件中硬件抽象是一组函数，其模仿了一些平台特定的细节，让程序可以直接访问硬件资源。
]))

#tr((
en: [
  They often allow programmers to write device-independent, high
  performance applications by providing standard operating system (OS)
  calls to hardware.
],
de: [
  Sie ermöglichen es Programmierern häufig, geräteunabhängige
  Hochleistungsanwendungen zu schreiben, indem sie standardisierte
  Betriebssystemaufrufe für den Hardwarezugriff bereitstellen.
],
ja: [
  それらのルーチンがハードウェアへのオペレーティングシステム（OS）コールを提供することで、プログラマは、デイバスに依存せず、高性能なアプリケーションを書くことができます。
],
zh: [
  通过向硬件提供标准的操作系统(OS)调用，它可以让程序员编写独立于设备的高性能应用。
]))

#let url_hal = "https://en.wikipedia.org/wiki/Hardware_abstraction"
#tr((
  en: [_Wikipedia: #link(url_hal)[Hardware Abstraction Layer]_],
  de: [_Wikipedia: #link(url_hal)[Hardware Abstraction Layer]_],
  ja: [_Wikipedia: #link(url_hal)[ハードウェア抽象化レイヤ]_],
  zh: [_Wikipedia: #link(url_hal)[Hardware Abstraction Layer]_],
))
]

#tr((
en: [
  Embedded systems are a bit special in this regard since we typically do
  not have operating systems and user installable software but firmware
  images which are compiled as a whole as well as a number of other
  constraints. So while the traditional approach as defined by Wikipedia
  could potentially work it is likely not the most productive approach to
  ensure portability.
],
de: [
  Eingebettete Systeme nehmen hier eine Sonderstellung ein, da wir es
  typischerweise nicht mit Betriebssystemen und vom Benutzer
  installierbarer Software zu tun haben, sondern mit Firmware-Images, die
  als Ganzes kompiliert werden -- und zudem mit einer Reihe weiterer
  Einschränkungen konfrontiert sind. Der klassische, auf Wikipedia
  beschriebene Ansatz könnte zwar theoretisch funktionieren, ist aber
  wahrscheinlich nicht der effizienteste Weg, um Portabilität zu
  gewährleisten.
],
ja: [
  組込みシステムは、通常オペレーティングシステムを使わず、ユーザがインストールできるソフトウェアもありません。
  全体として1つにコンパイルされたファームウェアイメージであり、様々な制約を持つ、という点が特殊です。
  そのため、Wikipediaで定義されている従来のアプローチでもうまく機能する可能性はありますが、移植性を確保するための最も有効なアプローチではない可能性があります。
],
zh: [
  在这方面，嵌入式系统有点特别，因为通常没有操作系统和用户可安装的软件，而只有固件镜像，其作为一个整体被编译且伴着许多约束。因此虽然维基百科定义的传统方法可能有用，但是它不是确保可移植性最有效的方法。
]))

#let ln_hal = link("https://crates.io/crates/embedded-hal")[embedded-hal]
#tr((
en: [
  How do we do this in Rust? Enter *#ln_hal*…
],
de: [
  Wie gehen wir dabei in Rust vor? Hier kommt *#ln_hal* ins Spiel…
],
ja: [
  Rustではどうするのでしょうか？*embedded-hal*を見ていきましょう。
],
zh: [
  在Rust中我们要怎么实现这个目标呢?让我们进入*embedded-hal*…
]))

== #tr((
  en: [What is #ln_hal?],
  de: [Was ist #ln_hal?],
  ja: [embedded-halとは？],
  zh: [什么是embedded-hal？],
))

#tr((
en: [
  In a nutshell it is a set of traits which define implementation
  contracts between *HAL implementations*, *drivers* and
  *applications (or firmwares)*. Those contracts include both
  capabilities (i.e.~if a trait is implemented for a certain type, the
  *HAL implementation* provides a certain capability) and methods
  (i.e.~if you can construct a type implementing a trait it is guaranteed
  that you have the methods specified in the trait available).
],
de: [
  Kurz gesagt handelt es sich um eine Reihe von Merkmalen, die
  Implementierungsverträge zwischen *HAL-Implementierungen*,
  *Treibern* und *Anwendungen (oder Firmware)* definieren.
  Diese Verträge umfassen sowohl Fähigkeiten (d.~h., wenn ein Merkmal für
  einen bestimmten Typ implementiert ist, stellt die
  *HAL-Implementierung* eine bestimmte Fähigkeit bereit) als auch
  Methoden (d.~h., wenn ein Typ, der ein Merkmal implementiert, erstellt
  werden kann, ist garantiert, dass die im Merkmal spezifizierten Methoden
  verfügbar sind).
],
ja: [
  一言で言えば、*HAL実装*、*ドライバ*、*アプリケーションまたはファームウェア*間の実装規約を定義するトレイトの集まりのことです。
  それらの規約は、機能（ある型にトレイトが実装されていれば、*HAL実装*はそのトレイトの機能を提供します）とメソッド（あるトレイトを実装している型のオブジェクトを作成できれば、そのトレイトに含まれるメソッドが利用可能であることが保証されます）を含んでいます。
],
zh: [
  简而言之，它是一组traits，其定义了*HAL
  implementations*，*驱动*，*应用(或者固件)*
  之间的实现约定(implementation
  contracts)。这些约定包括功能(即约定，如果为某个类型实现了某个trait，*HAL
  implementation*就提供了某个功能)和方法(即，如果构造一个实现了某个trait的类型，约定保障类型肯定有在trait中指定的方法)。
]))

#tr((
en: [
  A typical layering might look like this:
],
de: [
  Ein typischer Schichtaufbau könnte wie folgt aussehen:
],
ja: [
  典型的なレイヤ構造は、次のようになります。
],
zh: [
  典型的分层可能如下所示:
]))

#box(image("../assets/rust_layers.svg"))

#tr((
en: [
  Some of the defined traits in *#ln_hal* are:
  - GPIO (input and output pins)
  - Serial communication
  - I2C
  - SPI
  - Timers/Countdowns
  - Analog Digital Conversion
],
de: [
  Einige der in *#ln_hal* definierten Traits sind:
  - GPIO (Eingangs- und Ausgangspins)
  - Serielle Kommunikation
  - I2C
  - SPI
  - Timers/Countdowns
  - Analog-Digital-Umsetzung
],
ja: [
  *embedded-hal*で定義されているいくつかのトレイトを示します。
  - GPIO（入出力ピン）
  - シリアル通信
  - I2C
  - SPI
  - タイマ/カウントダウン
  - アナログデジタル変換
],
zh: [
  一些在*embedded-hal*中被定义的traits:
  - GPIO (input and output pins)
  - Serial communication
  - I2C
  - SPI
  - Timers/Countdowns
  - Analog Digital Conversion
]))

#tr((
en: [
  The main reason for having the *embedded-hal* traits and crates
  implementing and using them is to keep complexity in check. If you
  consider that an application might have to implement the use of the
  peripheral in the hardware as well as the application and potentially
  drivers for additional hardware components, then it should be easy to
  see that the re-usability is very limited. Expressed mathematically, if
  *M* is the number of peripheral HAL implementations and
  *N* the number of drivers then if we were to reinvent the wheel
  for every application then we would end up with *M\*N*
  implementations while by using the _API_ provided by the *#ln_hal*
  traits will make the implementation complexity approach *M+N*. Of
  course there're additional benefits to be had, such as less
  trial-and-error due to a well-defined and ready-to-use APIs.
],
de: [
  Der Hauptgrund für die Existenz der *embedded-hal*-Traits und der
  sie implementierenden sowie nutzenden Crates liegt darin, die
  Komplexität beherrschbar zu halten. Bedenkt man, dass eine Anwendung
  sowohl die Nutzung der Hardware-Peripherie als auch die eigentliche
  Anwendungslogik sowie möglicherweise Treiber für zusätzliche
  Hardwarekomponenten implementieren muss, wird schnell klar, dass die
  Wiederverwendbarkeit stark eingeschränkt ist. Mathematisch ausgedrückt:
  Wenn *M* die Anzahl der HAL-Implementierungen für
  Peripheriegeräte und *N* die Anzahl der Treiber ist, würde man --
  müsste man für jede Anwendung das Rad neu erfinden -- bei *M × N*
  Implementierungen landen; durch die Verwendung der von den *#ln_hal*-Traits
  bereitgestellten API nähert sich die Implementierungskomplexität
  hingegen *M + N* an. Natürlich ergeben sich daraus weitere
  Vorteile, wie etwa ein geringerer Aufwand durch „Trial-and-Error" dank
  wohldefinierter und sofort einsatzbereiter APIs.
],
ja: [
  *embedded-hal*トレイトと、それらを実装して使用するクレートを持つ主な理由は、複雑さを抑えることです。
  アプリケーションがハードウェアのペリフェラルを使うコードだけでなく、追加するハードウェアコンポーネントのドライバを実装しなければならない場合を考えると、再利用性は非常に制限されます。
  数学的に表現すると、*M*がペリフェラルHAL実装の数で、*N*がドライバの数とするならば、全てのアプリケーションで車輪の再発明を行うことになります。
  その結果、*M\*N*の実装が必要になります。
  一方、*embedded-hal*トレイトで提供されるAPIを使うことで、実装の複雑さは*M+N*になるでしょう。
  もちろん、明確に定義されたすぐに利用可能なAPIによって試行錯誤を減らすなど、他にも利点があります。
],
zh: [
  使用*embedded-hal*
  traits和依赖*embedded-hal*的crates的主要原因是为了控制复杂性。如果发现一个应用可能必须要实现对硬件外设的使用，以及需要实现应用程序和其它硬件组件间潜在的驱动，那么其应该很容易被看作是可复用性有限的。用数学语言来说就是，如果*M*是外设HAL
  implementations的数量，*N*是驱动的数量，那么如果我们要为每个应用重新发明轮子我们最终会有*M\*N*个实现，然而通过使用*embedded-hal*的traits提供的
  _API_ 将会使实现复杂性变成*M+N*
  。当然还有其它好处，比如由于API定义良好，开箱即用，导致试错减少。
]))

== #tr((
  en: [Users of the #ln_hal],
  de: [Nutzer von #ln_hal],
  ja: [embedded-halのユーザ],
  zh: [embedded-hal的用户],
))

#tr((
en: [
  As said above there are three main users of the HAL:
],
de: [
  Wie bereits erwähnt, gibt es drei Hauptnutzer einer HAL:
],
ja: [
  上記のように、HALには主に3つのユーザがいます。
],
zh: [
  像上面所说的，HAL有三个主要用户:
]))

=== #tr((
  en: [HAL implementation],
  de: [HAL-Implementierung],
  ja: [HAL実装],
  zh: [HAL implementation],
))

#tr((
en: [
  A HAL implementation provides the interfacing between the hardware and
  the users of the HAL traits. Typical implementations consist of three
  parts:
  - One or more hardware specific types
  - Functions to create and initialize such a type,
    often providing various configuration options
    (speed, operation mode, use pins, etc.)
  - one or more `trait` `impl` of *#ln_hal* traits for that type
],
de: [
  Eine HAL-Implementierung stellt die Schnittstelle zwischen der Hardware
  und den Nutzern der HAL-Traits bereit. Typische Implementierungen
  bestehen aus drei Teilen:
  - Ein oder mehrere hardwarespezifische Typen
  - Funktionen zum Erstellen und Initialisieren eines solchen Typs, die
    häufig verschiedene Konfigurationsoptionen (Geschwindigkeit,
    Betriebsmodus, verwendete Pins usw.) bereitstellen.
  - eine oder mehrere `trait`-Implementierungen (`impl`) von
    *#ln_hal*-Traits für diesen Typ
],
ja: [
  HAL実装は、ハードウェアとHALトレイトのユーザとの間のインタフェースを実装します。典型的な実装では、3つの部分から構成されます。
  - 1つ以上のハードウェア固有の型
  - そのような型のオブジェクトを作成し、初期化する関数。多くの場合、様々な設定オプションを提供しています（速度、動作モード、使用ピンなど）
  - 1つ以上のその型に対する*embedded-hal*の`trait` `impl`
],
zh: [
  HAL implentation提供硬件和HAL
  traits的用户之间的接口。典型的实现由三部分组成:
  - 一个或者多个硬件特定的类型
  - 生成和初始化这个类型的函数，函数经常提供不同的配置选项(速度，操作模式，使用的管脚，etc 。)
  - 与这个类型有关的一个或者多个 *embedded-hal* traits 的 `trait`
    `impl`
]))

#tr((
en: [
  Such a *HAL implementation* can come in various flavours:
  - Via low-level hardware access, e.g.~via registers
  - Via operating system, e.g.~by using the `sysfs` under Linux
  - Via adapter, e.g.~a mock of types for unit testing
  - Via driver for hardware adapters, e.g.~I2C multiplexer or GPIO expander
],
de: [
  Eine solche *HAL-Implementierung* kann in verschiedenen
  Ausprägungen vorliegen:
  - Über hardwarenahen Zugriff, z. B. über Register
  - Über das Betriebssystem, z. B. durch Verwendung von `sysfs` unter Linux
  - Über einen Adapter, z. B. ein Mock von Typen für Unit-Tests
  - Via-Treiber für Hardware-Adapter, z. B. I2C-Multiplexer oder GPIO-Expander
],
ja: [
  このような*HAL実装*は、様々な種類があります。
  - 低レベルのハードウェアアクセスによるもの、例えばレジスタ
  - オペレーティングシステムによるもの、例えばLinuxの`sysfs`の使用
  - アダプタによるもの、例えばユニットテストのための型のモック
  - ハードウェアアダプタ用のドライバによるもの、例えばI2CマルチプレクサやGPIOエキスパンダ
],
zh: [
  这样的一个 *HAL implementation* 可以有多个方法来实现:
  - 通过低级硬件访问，比如通过寄存器。
  - 通过操作系统，比如通过使用Linux下的 `sysfs`
  - 通过适配器，比如一个与单元测试有关的类型的仿真
  - 通过相关硬件适配器的驱动，e.g.~I2C多路复用器或者GPIO扩展器(I2C multiplexer or GPIO expander)
]))

=== #tr((
  en: [Driver],
  de: [Treiber],
  ja: [ドライバ],
  zh: [驱动],
))

#tr((
en: [
  A driver implements a set of custom functionality for an internal or
  external component, connected to a peripheral implementing the
  #ln_hal traits.
  Typical examples for such drivers include various sensors (temperature,
  magnetometer, accelerometer, light), display devices (LED arrays, LCD
  displays) and actuators (motors, transmitters).
],
de: [
  Ein Treiber implementiert eine Reihe benutzerdefinierter Funktionen für
  eine interne oder externe Komponente, die mit einem Peripheriegerät
  verbunden ist, das die #ln_hal;-Traits
  implementiert. Typische Beispiele für solche Treiber sind verschiedene
  Sensoren (Temperatur-, Magnetometer-, Beschleunigungs- und
  Lichtsensoren), Anzeigegeräte (LED-Arrays, LCD-Displays) und Aktoren
  (Motoren, Sender).
],
ja: [
  ドライバは、embedded-halトレイトを実装しているペリフェラルに接続されている、内部または外部コンポーネントに対するカスタム機能を実装します。
  そのようなドライバの典型的な例は、様々なセンサ（温度、磁気、加速度、輝度）、ディスプレイデバイス（LEDアレイ、LCDディスプレイ）や、アクチュエータ（モータ、トランスミッタ）を含みます。
],
zh: [
  驱动为一个外部或者内部组件实现了一组自定义的功能，被连接到一个实现了embedded-hal
  traits的外设上。这种驱动的典型的例子包括多种传感器(温度计，磁力计，加速度计，光照计)，显示设备(LED阵列，LCD显示屏)和执行器(电机，发送器)。
]))

#tr((
en: [
  A driver has to be initialized with an instance of type that implements
  a certain `trait` of the #ln_hal which is
  ensured via trait bound and provides its own type instance with a custom
  set of methods allowing to interact with the driven device.
],
de: [
  Ein Treiber muss mit einer Instanz eines Typs initialisiert werden, der
  ein bestimmtes `Trait` von
  #ln_hal
  implementiert. Dies wird durch Trait-Bound sichergestellt. Der Treiber
  stellt eine eigene Typinstanz mit einem benutzerdefinierten Satz von
  Methoden bereit, die die Interaktion mit dem angesteuerten Gerät
],
ja: [
  ドライバは、embedded-halの特定のトレイトを実装する型のインスタンスと共に初期化する必要があります。
  そのトレイトは、トレイト境界により保証され、駆動するデバイスとやり取りできるインスタンスをカスタムメソッドと共に提供します。
],
zh: [
  必须使用实现了embedded-hal的某个`trait`的类型的实例来初始化驱动，这是通过trait
  bound来确保的，驱动也提供了它自己的类型实例，这个实例具有一组自定义的方法，这些方法允许与被驱动的设备交互。

]))

=== #tr((
  en: [Application],
  de: [Anwendung],
  ja: [アプリケーション],
  zh: [应用],
))

#tr((
en: [
  The application binds the various parts together and ensures that the
  desired functionality is achieved. When porting between different
  systems, this is the part which requires the most adaptation efforts,
  since the application needs to correctly initialize the real hardware
  via the HAL implementation and the initialisation of different hardware
  differs, sometimes drastically so. Also the user choice often plays a
  big role, since components can be physically connected to different
  terminals, hardware buses sometimes need external hardware to match the
  configuration or there are different trade-offs to be made in the use of
  internal peripherals (e.g.~multiple timers with different capabilities
  are available or peripherals conflict with others).
],
de: [
  Die Anwendung verknüpft die verschiedenen Komponenten miteinander und
  stellt sicher, dass die gewünschte Funktionalität erreicht wird. Bei der
  Portierung zwischen verschiedenen Systemen ist dies der Teil, der den
  größten Anpassungsaufwand erfordert, da die Anwendung die eigentliche
  Hardware über die HAL-Implementierung korrekt initialisieren muss -- und
  die Initialisierung unterschiedlicher Hardware variiert, bisweilen sogar
  drastisch. Zudem spielen oft anwenderspezifische Entscheidungen eine
  wichtige Rolle: Komponenten können physisch an unterschiedliche
  Anschlüsse angebunden sein, Hardware-Busse erfordern mitunter externe
  Hardware zur Konfigurationsanpassung, oder es müssen Abwägungen bei der
  Nutzung interner Peripherie getroffen werden (etwa wenn mehrere Timer
  mit unterschiedlichen Fähigkeiten zur Verfügung stehen oder Konflikte
  zwischen verschiedenen Peripherieeinheiten auftreten).
],
ja: [
  アプリケーションは、様々な部品を結合し、必要な機能が確実に実現できるようにします。
  別システムに移植する際、アプリケーションは最も適合作業が求められる部分です。アプリケーションは、HAL実装を通じて、実際のハードウェアを初期化する必要があるからです。
  異なるハードウェアの初期化は、極端に異なる場合があります。
  ユーザの選択は、多くの場合、大きな影響があります。
  コンポーネントが別の端子に物理的に接続されたり、ハードウェアバスが機器構成を満たすために外部ハードウェアを必要とする場合があったり、内部ペリフェラルを使えるようにするための異なるトレードオフがあったりします。例えば、異なる機能を持つ複数のタイマが利用可能であること、や、ペリフェラルが他のペリフェラルと競合すること、です。
],
zh: [
  应用把多个部分结合在一起并确保需要的功能被实现。当在不同的系统间移植时，这部分的适配是花费最多精力的地方，因为应用需要通过HAL
  implementation正确地初始化真实的硬件，而且不同硬件的初始化也不相同，甚至有时候差别非常大。用户的选择也在其中扮演了非常重大的角色，因为组件能被物理连接到不同的端口，硬件总线有时候需要外部硬件去匹配配置，或者用户在内部外设的使用上有不同的考量。
]))
