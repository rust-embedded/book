#import "../../config.typ": *

#h1((en: [Predictability],
  de: [Vorhersehbarkeit],
  zh: [可预见性],
), offset: whole*2)
<hal-predictability>

= #tr((
  en: [Constructors are used instead of extension traits],
  de: [Anstelle von Extension Traits werden Konstruktoren verwendet],
  zh: [使用构造函数而不是扩展traits],
)) (C-CTOR)
<c-ctor>

#tr((
en: [
  All peripherals to which the HAL adds functionality should be wrapped in
  a new type, even if no additional fields are required for that
  functionality.
],
de: [
  Alle Peripheriegeräte, denen die HAL Funktionalität hinzufügt, sollten
  in einen neuen Typ gekapselt werden -- selbst dann, wenn für diese
  Funktionalität keine zusätzlichen Felder erforderlich sind.
],
zh: [
  所有由HAL添加功能的外设应该被封装进一个新类型，即使该功能不需要额外的字段。
]))

#tr((
en: [
  Extension traits implemented for the raw peripheral should be avoided.
],
de: [
  Die Implementierung von Extension Traits für das rohe Peripheriegerät
  (Raw Peripheral) sollte vermieden werden.
],
zh: [
  应该避免为基本外设扩展traits。
]))

= #tr((
  en: [Methods are decorated with `#[inline]` where appropriate],
  de: [Methoden werden dort, wo es angebracht ist, mit `#[inline]`
  versehen],
  zh: [方法在适当的地方用`#[inline]`修饰],
)) (C-INLINE)
<c-inline>

#tr((
en: [
  The Rust compiler does not by default perform full inlining across crate
  boundaries. As embedded applications are sensitive to unexpected code
  size increases, `#[inline]` should be used to guide the compiler as
  follows:
  - All "small" functions should be marked `#[inline]`. What qualifies as
    "small" is subjective, but generally all functions that are expected
    to compile down to single-digit instruction sequences qualify as
    small.
  - Functions that are very likely to take constant values as parameters
    should be marked as `#[inline]`. This enables the compiler to compute
    even complicated initialization logic at compile time, provided the
    function inputs are known.
],
de: [
  Der Rust-Compiler führt standardmäßig kein vollständiges Inlining über
  Crate-Grenzen hinweg durch. Da eingebettete Anwendungen empfindlich auf
  unerwartete Vergrößerungen des Codes reagieren, sollte `#[inline]`
  verwendet werden, um den Compiler wie folgt zu steuern:
  - Alle „kleinen" Funktionen sollten mit `#[inline]` gekennzeichnet
    werden. Was als „klein" gilt, ist subjektiv; im Allgemeinen zählen
    jedoch alle Funktionen dazu, die voraussichtlich zu einer Sequenz von
    nur wenigen Maschinenbefehlen kompiliert werden.
  - Funktionen, die sehr wahrscheinlich konstante Werte als Parameter
    erhalten, sollten mit `#[inline]` gekennzeichnet werden. Dies
    ermöglicht es dem Compiler, selbst komplexe Initialisierungslogik zur
    Kompilierzeit zu berechnen, sofern die Eingabewerte der Funktion
    bekannt sind.
],
zh: [
  Rust编译器默认不会越过crate边界执行完全内联。因为嵌入式应用对于不可预期的代码大小的增加很敏感，`#[inline]`应该如下所示用来指导编译器:
  - 所有的"小"函数应该被标记`#[inline]`。什么是"小"是主观的，但是通常所有有可能被编译成一位数的指令序列(single-digit
  instruction sequences)都可以被视为"小"。
  - 非常有可能把一个常量数值作为参数的函数应该被标记为`#[inline]`。这让编译器在编译时就可以进行计算甚至是复杂的初始化逻辑，前提是函数输入是已知的。
]))
