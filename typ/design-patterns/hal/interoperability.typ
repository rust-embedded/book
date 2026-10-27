#import "../../config.typ": *

#h1((en: [Interoperability],
  de: [Interoperabilität],
  zh: [互用性],
), offset: whole*2)
<hal-interoperability>

= #tr((
  en: [Wrapper types provide a destructor method],
  de: [Wrapper-Typen stellen eine Destruktor-Methode bereit],
  zh: [封装类型提供一个析构方法],
)) (C-FREE)
<c-free>

#tr((
en: [
  Any non-`Copy` wrapper type provided by the HAL should provide a `free`
  method that consumes the wrapper and returns back the raw peripheral
  (and possibly other objects) it was created from.
],
de: [
  Jeder vom HAL bereitgestellte Wrapper-Typ, der nicht `Copy`
  implementiert, sollte eine `free`-Methode anbieten; diese verbraucht den
  Wrapper und gibt das rohe Peripheriegerät (sowie gegebenenfalls weitere
  Objekte), aus dem er erstellt wurde, wieder frei.
],
zh: [
  任何由HAL提供的非`Copy`封装类型应该提供一个`free`方法，这个方法消费封装类且返回最初生成它的外设(可能是其它对象)。
]))

#tr((
en: [
  The method should shut down and reset the peripheral if necessary.
  Calling `new` with the raw peripheral returned by `free` should not fail
  due to an unexpected state of the peripheral.
],
de: [
  Die Methode sollte das Peripheriegerät bei Bedarf deaktivieren und
  zurücksetzen. Ein Aufruf von `new` mit dem durch `free` zurückgegebenen
  rohen Peripheriegerät darf nicht aufgrund eines unerwarteten Zustands
  des Geräts fehlschlagen.
],
zh: [
  如果有必要，方法应该关闭和重置外设。使用由`free`返回的原始外设去调用`new`不应该由于设备的意外状态而失败，
]))

#tr((
en: [
  If the HAL type requires other non-`Copy` objects to be constructed (for
  example I/O pins), any such object should be released and returned by
  `free` as well. `free` should return a tuple in that case.
],
de: [
  Falls für die Konstruktion des HAL-Typs weitere Objekte erforderlich
  sind, die nicht `Copy` implementieren (zum Beispiel I/O-Pins), sollten
  auch diese Objekte durch `free` freigegeben und zurückgegeben werden. In
  diesem Fall sollte `free` ein Tupel zurückgeben.
],
zh: [
  如果HAL类型要求构造其它的非`Copy`对象(比如 I/O
  管脚)，任何这样的对象应该也由`free`返回和释放。在这种情况下`free`应该返回一个元组。
]))

#tr((
en: [
  For example:
],
de: [
  Zum Beispiel:
],
zh: [
  比如:
]))

```rust
# pub struct TIMER0;
pub struct Timer(TIMER0);

impl Timer {
    pub fn new(periph: TIMER0) -> Self {
        Self(periph)
    }

    pub fn free(self) -> TIMER0 {
        self.0
    }
}
```

= #tr((
  en: [HALs reexport their register access crate],
  de: [HALs exportieren ihr Registerzugriffs-Crate erneut],
  zh: [HALs重新导出它们的寄存器访问crate],
)) (C-REEXPORT-PAC)
<c-reexport-pac>

#let ln_svd2rust = link("https://github.com/rust-embedded/svd2rust")[svd2rust]
#tr((
en: [
  HALs can be written on top of #ln_svd2rust;-generated
  PACs, or on top of other crates that provide raw register access. HALs
  should always reexport the register access crate they are based on in
  their crate root.
],
de: [
  HALs können auf der Basis von mit
  #ln_svd2rust generierten
  PACs oder anderen Crates implementiert werden, die einen direkten
  Registerzugriff ermöglichen. HALs sollten das Crate für den
  Registerzugriff, auf dem sie aufbauen, stets an der Wurzel ihres eigenen
  Crates erneut exportieren (re-exportieren).
],
zh: [
  可以在#ln_svd2rust;生成的PACs之上，或在其它纯寄存器访问的crates之上编写HALs。HALs需要在crate
  root中重新导出它们所基于的寄存器访问crate
]))

#tr((
en: [
  A PAC should be reexported under the name `pac`, regardless of the
  actual name of the crate, as the name of the HAL should already make it
  clear what PAC is being accessed.
],
de: [
  Ein PAC sollte unter dem Namen `pac` re-exportiert werden -- unabhängig
  vom eigentlichen Namen des Crates --, da bereits der Name der HAL
  verdeutlichen sollte, auf welches PAC zugegriffen wird.
],
zh: [
  一个PAC应该被重新导出在`pac`名下，无论这个crate实际的名字是什么，因为HAL的名字应该已经明确了正被访问的是什么PAC
]))

= #tr((
  en: [Types implement the `embedded-hal` traits],
  de: [Typen implementieren die `embedded-hal`-Traits],
  zh: [类型实现`embedded-hal` traits],
)) (C-HAL-TRAITS)
<c-hal-traits>

#let ln_hal = link("https://github.com/rust-embedded/embedded-hal")[`embedded-hal`]
#tr((
en: [
  Types provided by the HAL should implement all applicable traits
  provided by the #ln_hal crate.
],
de: [
  Vom HAL bereitgestellte Typen sollten alle anwendbaren Traits
  implementieren, die vom #ln_hal;-Crate bereitgestellt werden.
],
zh: [
  HAL提供的类型应该实现所有的由#ln_hal crate提供的能用的traits。
]))

#tr((
en: [
  Multiple traits may be implemented for the same type.
],
de: [
  Für denselben Typ können mehrere Traits implementiert werden.
],
zh: [
  同个类型可能实现多个traits。
]))
