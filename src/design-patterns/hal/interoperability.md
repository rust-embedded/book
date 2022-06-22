# 互用性


<a id="c-free"></a>
## 封装类型提供一个析构方法 (C-FREE)

任何由HAL提供的非`Copy`封装类型应该提供一个`free`方法，这个方法消费封装类且返回最初生成它的外设(可能是其它对象)。

如果有必要方法应该关闭和重置外设。使用由`free`返回的原始外设调用`new`不应该由于设备的意外状态而失败，

如果HAL类型要求构造其它的非`Copy`对象(比如 I/O 管脚)，任何这样的对象应该也由`free`返回和释放。在那个案例中`free`应该返回一个元组。

比如:

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

<a id="c-reexport-pac"></a>
## HALs重新导出它们的寄存器访问crate(C-REEXPORT-PAC)

HALs能被编写在[svd2rust]生成的PACs之上，或在其它纯寄存器访问的crates之上。HALs应该总是能在它们的crate root中重新导出它们所基于的寄存器访问crate

一个PAC应该被重新导出在名字`pac`下，无论这个crate实际的名字是什么，因为HAL的名字应该已经明确了正被访问的是什么PAC 。

[svd2rust]: https://github.com/rust-embedded/svd2rust

<a id="c-hal-traits"></a>
## 类型实现`embedded-hal` traits (C-HAL-TRAITS)

HAL提供的类型应该实现所有的由[`embedded-hal`] crate提供的能用的traits。

同个类型可能实现多个traits。

[`embedded-hal`]: https://github.com/rust-embedded/embedded-hal
