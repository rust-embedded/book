# 零成本抽象

类型状态是一个零成本抽象的杰出案例 - 把某些行为移到编译时执行或者分析的能力。这些类型状态不包含真实的数据，只用来作为标记。因为它们不包含数据，在运行时它们在内存中不存在实际的表征。

```rust,ignore
use core::mem::size_of;

let _ = size_of::<Enabled>();    // == 0
let _ = size_of::<Input>();      // == 0
let _ = size_of::<PulledHigh>(); // == 0
let _ = size_of::<GpioConfig<Enabled, Input, PulledHigh>>(); // == 0
```

## 零大小的类型(Zero Sized Types)

```rust,ignore
struct Enabled;
```

像这样定义的结构体被称为零大小的类型，因为它们不包含实际数据。虽然这些类型在编译时像是"真的"(real) - 你可以拷贝它们，移动它们，引用它们，etc.，然而优化器将会完全跳过它们。

在这个代码片段里:

```rust,ignore
pub fn into_input_high_z(self) -> GpioConfig<Enabled, Input, HighZ> {
    self.periph.modify(|_r, w| w.input_mode().high_z());
    GpioConfig {
        periph: self.periph,
        enabled: Enabled,
        direction: Input,
        mode: HighZ,
    }
}
```

我们返回的CpioConfig在运行时并不存在。调用这个函数通常将会总结为一个单一的汇编指令 - 保存一个常量寄存器值进一个寄存器里。这意味着我们开发的类型状态接口是一个零成本抽象 - 它不会用更多的CPU，RAM，或者代码空间去跟踪`GpioConfig`的状态，会渲染成和直接访问寄存器一样的机器码。

## 嵌套

通常，你可能会把这些抽象深深地嵌套起来。一旦所有的被使用的组件是零大小类型，整个结构体将不会在运行时存在。

对于复杂或者深度嵌套的结构体，定义所有可能的状态组合可能很乏味。在这些案例中，宏大概能被用来产生所有的实现。
