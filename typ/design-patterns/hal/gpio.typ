#import "../../config.typ": *

#h1((en: [Recommendations for GPIO Interfaces],
  de: [Empfehlungen für GPIO-Schnittstellen],
  zh: [关于GPIO接口的建议],
), offset: whole*2)
<hal-gpio>

= #tr((
  en: [Pin types are zero-sized by default],
  de: [Pin-Typen haben standardmäßig die Größe Null],
  zh: [Pin类型默认是零大小的],
)) (C-ZST-PIN)
<c-zst-pin>

#tr((
en: [
  GPIO Interfaces exposed by the HAL should provide dedicated zero-sized
  types for each pin on every interface or port, resulting in a zero-cost
  GPIO abstraction when all pin assignments are statically known.
],
de: [
  Die von der HAL bereitgestellten GPIO-Schnittstellen sollten für jeden
  Pin jeder Schnittstelle oder jedes Ports einen dedizierten Datentyp der
  Größe Null bereitstellen. Dies führt zu einer kostenlosen
  GPIO-Abstraktion, wenn alle Pinbelegungen statisch bekannt sind.
],
zh: [
  由HAL暴露的GPIO接口应该为所有接口或者端口上的每一个管脚提供一个专用的零大小类型，从而当所有的管脚分配静态已知时，提供一个零开销抽象。
]))

#tr((
en: [
  Each GPIO Interface or Port should implement a `split` method returning
  a struct with every pin.
],
de: [
  Jede GPIO-Schnittstelle oder jeder Port sollte eine `split`-Methode
  implementieren, die eine Struktur mit allen Pins zurückgibt.
],
zh: [
  每个GPIO接口或者端口应该实现一个`split`方法，它返回一个拥有所有管脚的结构体。
]))

#tr((
en: [
  Example:
],
de: [
  Beispiel:
]))

```rust
pub struct PA0;
pub struct PA1;
// ...

pub struct PortA;

impl PortA {
    pub fn split(self) -> PortAPins {
        PortAPins {
            pa0: PA0,
            pa1: PA1,
            // ...
        }
    }
}

pub struct PortAPins {
    pub pa0: PA0,
    pub pa1: PA1,
    // ...
}
```

= #tr((
  en: [Pin types provide methods to erase pin and port],
  de: [Pin-Typen stellen Methoden zum Löschen von Pins und Ports bereit],
  zh: [管脚类型提供方法去擦除管脚和端口],
)) (C-ERASED-PIN)
<c-erased-pin>

#tr((
en: [
  Pins should provide type erasure methods that move their properties from
  compile time to runtime, and allow more flexibility in applications.
],
de: [
  Pins sollten Methoden zur Typeliminierung (Type Erasure) bereitstellen,
  die ihre Eigenschaften von der Kompilierzeit in die Laufzeit verlagern
  und so mehr Flexibilität in Anwendungen ermöglichen.
],
zh: [
  从编译时到运行时，管脚都应该提供可以改变属性的类型擦出方法，允许在应用中有更多的灵活性。
]))

#tr((
en: [
  Example:
],
de: [
  Beispiel:
],
zh: [
  案例:
]))

#raw(block: true, lang: "rust",
"/// " + ts((
    en: "Port A, pin 0.",
    de: "Port A, pin 0.",
    zh: "端口 A, 管脚 0。",
  )) + "
pub struct PA0;

impl PA0 {
    pub fn erase_pin(self) -> PA {
        PA { pin: 0 }
    }
}

/// " + ts((
    en: "A pin on port A.",
    de: "A pin on port A.",
    zh: "端口A上的A管脚。",
  )) + "
pub struct PA {
    /// " + ts((
        en: "The pin number.",
        zh: "管脚号。",
      )) + "
    pin: u8,
}

impl PA {
    pub fn erase_port(self) -> Pin {
        Pin {
            port: Port::A,
            pin: self.pin,
        }
    }
}

pub struct Pin {
    port: Port,
    pin: u8,
    // " + ts((
        en: "(these fields can be packed to reduce the memory footprint)",
        de: "(Diese Felder koennen gepackt werden, um den Speicherbedarf zu 
    // verringern.)",
        zh: "(这些字段)
    // (这些字段可以打包以减少内存占用)",
      )) + "
}

enum Port {
    A,
    B,
    C,
    D,
}
")

= #tr((
  en: [Pin state should be encoded as type parameters],
  de: [Der Pin-Zustand sollte als Typparameter kodiert werden],
  zh: [管脚状态应该被编码成类型参数],
)) (C-PIN-STATE)
<c-pin-state>

#tr((
en: [
  Pins may be configured as input or output with different characteristics
  depending on the chip or family. This state should be encoded in the
  type system to prevent use of pins in incorrect states.
],
de: [
  Je nach Chip oder Chipfamilie können Pins als Eingang oder Ausgang mit
  unterschiedlichen Eigenschaften konfiguriert werden. Dieser Zustand
  sollte im Typsystem abgebildet werden, um eine Verwendung der Pins in
  einem falschen Zustand zu verhindern.
],
zh: [
  取决于芯片或者芯片系列，管脚可能被配置为具有不同特性的输出或者输入。这个状态应该编码进类型系统中以避免在错误的状态中使用管脚。
]))

#tr((
en: [
  Additional, chip-specific state (eg. drive strength) may also be encoded
  in this way, using additional type parameters.
],
de: [
  Auch zusätzliche, chip-spezifische Zustände (z. B. die Treiberstärke)
  lassen sich auf diese Weise mittels zusätzlicher Typparameter kodieren.
],
zh: [
  另外，也可以用这个方法使用额外的类型参数编码芯片特定的状态(eg.
  驱动强度)。
]))

#tr((
en: [
  Methods for changing the pin state should be provided as `into_input`
  and `into_output` methods.
],
de: [
  Methoden zur Änderung des Pin-Zustands sollten als `into_input` und
  `into_output` bereitgestellt werden.
],
zh: [
  用来改变管脚状态的方法应该被实现成`into_input`和`into_output`方法。
]))

#tr((
en: [
  Additionally, `with_{input,output}_state` methods should be provided
  that temporarily reconfigure a pin in a different state without moving it.
],
de: [
  Zusätzlich sollten Methoden wie `with_{input,output}_state` angeboten
  werden, die einen Pin vorübergehend in einen anderen Zustand versetzen,
  ohne ihn zu verschieben (d.~h. ohne Eigentumsübergang).
],
zh: [
  另外，应该提供`with_{input,output}_state`方法，在一个不同的状态中临时配置一个管脚而不是移动它。
]))

#tr((
en: [
  The following methods should be provided for every pin type (that is,
  both erased and non-erased pin types should provide the same API):
],
de: [
  Für jeden Pin-Typ sollten die folgenden Methoden bereitgestellt werden
  (das heißt, sowohl „erased" als auch „non-erased" Pin-Typen müssen
  dieselbe API bieten):
],
zh: [
  应该为每个的管脚类型提供下列的方法(也就是说，已擦除和未擦除的管脚类型应该提供一样的API):
]))
- `pub fn into_input<N: InputState>(self, input: N) -> Pin<N>`
- `pub fn into_output<N: OutputState>(self, output: N) -> Pin<N>`
- ```rust
  pub fn with_input_state<N: InputState, R>(
      &mut self,
      input: N,
      f: impl FnOnce(&mut PA1<N>) -> R,
  ) -> R
  ```
- ```rust
  pub fn with_output_state<N: OutputState, R>(
      &mut self,
      output: N,
      f: impl FnOnce(&mut PA1<N>) -> R,
  ) -> R
  ```

#tr((
en: [
  Pin state should be bounded by sealed traits. Users of the HAL should
  have no need to add their own state. The traits can provide HAL-specific
  methods required to implement the pin state API.
],
de: [
  Der Pin-Zustand sollte durch „Sealed Traits" eingeschränkt sein. Nutzer
  des HAL sollten keinen eigenen Zustand hinzufügen müssen. Die Traits
  können HAL-spezifische Methoden bereitstellen, die für die
  Implementierung der Pin-Zustands-API erforderlich sind.
],
zh: [
  管脚状态应该用sealed
  traits来绑定。HAL的用户不必添加他们自己的状态。这个traits能提供HAL特定的方法，实现管脚状态API需要这些方法。
]))

#tr((
en: [
  Example:
],
de: [
  Beispiel:
],
zh: [
  案例:
]))

#raw(block: true, lang: "rust",
"# use std::marker::PhantomData;
mod sealed {
    pub trait Sealed {}
}

pub trait PinState: sealed::Sealed {}
pub trait OutputState: sealed::Sealed {}
pub trait InputState: sealed::Sealed {
    // ...
}

pub struct Output<S: OutputState> {
    _p: PhantomData<S>,
}

impl<S: OutputState> PinState for Output<S> {}
impl<S: OutputState> sealed::Sealed for Output<S> {}

pub struct PushPull;
pub struct OpenDrain;

impl OutputState for PushPull {}
impl OutputState for OpenDrain {}
impl sealed::Sealed for PushPull {}
impl sealed::Sealed for OpenDrain {}

pub struct Input<S: InputState> {
    _p: PhantomData<S>,
}

impl<S: InputState> PinState for Input<S> {}
impl<S: InputState> sealed::Sealed for Input<S> {}

pub struct Floating;
pub struct PullUp;
pub struct PullDown;

impl InputState for Floating {}
impl InputState for PullUp {}
impl InputState for PullDown {}
impl sealed::Sealed for Floating {}
impl sealed::Sealed for PullUp {}
impl sealed::Sealed for PullDown {}

pub struct PA1<S: PinState> {
    _p: PhantomData<S>,
}

impl<S: PinState> PA1<S> {
    pub fn into_input<N: InputState>(self, input: N) -> PA1<Input<N>> {
        todo!()
    }

    pub fn into_output<N: OutputState>(self, output: N) -> PA1<Output<N>> {
        todo!()
    }

    pub fn with_input_state<N: InputState, R>(
        &mut self,
        input: N,
        f: impl FnOnce(&mut PA1<N>) -> R,
    ) -> R {
        todo!()
    }

    pub fn with_output_state<N: OutputState, R>(
        &mut self,
        output: N,
        f: impl FnOnce(&mut PA1<N>) -> R,
    ) -> R {
        todo!()
    }
}

// " + ts((
    en: "Same for `PA` and `Pin`, and other pin types.",
    de: "Dasselbe gilt fuer `PA` und `Pin` sowie andere Pin-Typen.",
    zh: "对于`PA`和`Pin`一样的，对于其它管脚类型来说也是。",
  )) + "
")
