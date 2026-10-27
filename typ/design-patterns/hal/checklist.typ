#import "../../config.typ": *

#h1((en: [HAL Design Patterns Checklist],
  de: [Checkliste HAL-Design-Muster],
  zh: [HAL设计检查清单],
), offset: whole*2)
<hal-checklist>

#tr((
en: [
  *Naming* (_crate aligns with Rust naming conventions_)
    - ☐ The crate is named appropriately (#link(<c-crate-name>)[C-CRATE-NAME])
  - *Interoperability* (_crate interacts nicely with other library functionality_)
    - ☐ Wrapper types provide a destructor method (#link(<c-free>)[C-FREE])
    - ☐ HALs reexport their register access crate (#link(<c-reexport-pac>)[C-REEXPORT-PAC])
    - ☐ Types implement the `embedded-hal` traits (#link(<c-hal-traits>)[C-HAL-TRAITS])
  - *Predictability* (_crate enables legible code that acts how it looks_)
    - ☐ Constructors are used instead of extension traits (#link(<c-ctor>)[C-CTOR])
  - *GPIO Interfaces* (_GPIO Interfaces follow a common pattern_)
    - ☐ Pin types are zero-sized by default (#link(<c-zst-pin>)[C-ZST-PIN])
    - ☐ Pin types provide methods to erase pin and port (#link(<c-erased-pin>)[C-ERASED-PIN])
    - ☐ Pin state should be encoded as type parameters (#link(<c-pin-state>)[C-PIN-STATE])
],
de: [
  - *Benennung* (_Crate richtet sich nach den Namenskonventionen von Rust_)
    - ☐ Das Crate trägt einen passenden Namen. (#link(<c-crate-name>)[C-CRATE-NAME])
  - *Interoperabilität* (_das Crate harmoniert gut mit der Funktionalität anderer Bibliotheken_)
    - ☐ Wrapper-Typen stellen eine Destruktor-Methode bereit. (#link(<c-free>)[C-FREE])
    - ☐ HALs exportieren ihr Registerzugriffs-Crate erneut. (#link(<c-reexport-pac>)[C-REEXPORT-PAC])
    - ☐ Typen implementieren die `embedded-hal`-Traits. (#link(<c-hal-traits>)[C-HAL-TRAITS])
  - *Vorhersehbarkeit* (_Das Crate ermöglicht gut lesbaren Code, der sich so verhält, wie er aussieht_)
    - ☐ Anstelle von Extension Traits werden Konstruktoren verwendet. (#link(<c-ctor>)[C-CTOR])
  - *GPIO-Schnittstellen* (_GPIO-Schnittstellen folgen einem einheitlichen Muster_)
    - ☐ Pin-Typen haben standardmäßig die Größe Null. (#link(<c-zst-pin>)[C-ZST-PIN])
    - ☐ Pin-Typen stellen Methoden zum Löschen von Pins und Ports bereit. (#link(<c-erased-pin>)[C-ERASED-PIN])
    - ☐ Der Pin-Zustand sollte als Typparameter kodiert werden. (#link(<c-pin-state>)[C-PIN-STATE])
],
zh: [
- *命名* (_crate要符合Rust命名规则_)
  - ☐ crate被恰当地命名 (#link(<c-crate-name>)[C-CRATE-NAME])
- *互用性* (_crate要很好地与其它的库功能交互_)
  - ☐ 封装类型提供一种析构方法 (#link(<c-free>)[C-FREE])
  - ☐ HALs重新导出了它们的寄存器访问crate (#link(<c-reexport-pac>)[C-REEXPORT-PAC])
  - ☐ 类型实现了 `embedded-hal` traits (#link(<c-hal-traits>)[C-HAL-TRAITS])
- *可预见性* (_crate的代码清晰可读，行为和看起来的一样_)
  - ☐ 使用构造函数而不是扩展traits (#link(<c-ctor>)[C-CTOR])
- *GPIO接口* (_GPIO接口要遵循一个公共的模式_)
  - ☐ Pin类型默认是零大小类型 (#link(<c-zst-pin>)[C-ZST-PIN])
  - ☐ Pin类型提供擦除管脚和端口的方法 (#link(<c-erased-pin>)[C-ERASED-PIN])
  - ☐ Pin状态应该被编码为类型参数 (#link(<hal-gpio>)[C-PIN-STATE])
]))
