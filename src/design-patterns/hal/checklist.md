# HAL设计检查清单

- **命名** *(crate要符合Rust命名规则)*
  - [ ] crate被恰当地命名 ([C-CRATE-NAME])
- **互用性** *(crate要很好地与其它的库功能交互)*
  - [ ] 封装类型提供一种析构方法 ([C-FREE])
  - [ ] HALs重新导出了它们的寄存器访问crate ([C-REEXPORT-PAC])
  - [ ] 类型实现了 `embedded-hal` traits ([C-HAL-TRAITS])
- **可预见性** *(crate的代码清晰可读，行为和看起来的一样)*
  - [ ] 使用构造函数而不是扩展traits ([C-CTOR])
- **GPIO接口** *(GPIO接口要遵循一个公共的模式)*
  - [ ] Pin类型默认是零大小类型 ([C-ZST-PIN])
  - [ ] Pin类型提供擦除管脚和端口的方法 ([C-ERASED-PIN])
  - [ ] Pin状态应该被编码为类型参数 ([C-PIN-STATE])

[C-CRATE-NAME]: naming.html#c-crate-name

[C-FREE]: interoperability.html#c-free
[C-REEXPORT-PAC]: interoperability.html#c-reexport-pac
[C-HAL-TRAITS]: interoperability.html#c-hal-traits

[C-CTOR]: predictability.html#c-ctor

[C-ZST-PIN]: gpio.md#c-zst-pin
[C-ERASED-PIN]: gpio.md#c-erased-pin
[C-PIN-STATE]: gpio.md#c-pin-state
