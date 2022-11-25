# 作为状态机的外设

一个微控制器的外设可以被想成是一组状态机。比如，一个简化的[GPIO管脚]的配置可以被表达成下列的状态树:

[GPIO管脚]: https://en.wikipedia.org/wiki/General-purpose_input/output

* 关闭
* 使能
    * 配置成输出
        * 输出: 高
        * 输出: 低
    * 配置成输入
        * 输入: 高阻态
        * 输入: 下拉
        * 输入: 上拉

如果外设开始于`关闭`模式，切换到`输入: 高阻态`模式，我们必须执行下面的步骤:

1. 关闭
2. 使能
3. 配置成输入
4. 输入: 高阻态

如果我们想要从`输入: 高阻态`切换到`输入: 下拉`，我们必须执行下列的步骤:

1. 输入: 高阻抗
2. 输入: 下拉

同样地，如果我们想要把一个GPIO管脚从`输入: 下拉`切换到`输出: 高`，我们必须执行下列的步骤:
1. 输入: 下拉
2. 配置成输入
3. 配置成输出
4. 输出: 高

## 硬件表征(Hardware Representation)

通常，通过向映射到GPIO外设上的指定的寄存器中写入值可以配置上面列出的状态。让我们定义一个假想的GPIO配置寄存器来解释下它:

| 名字          | 位数(s) | 值 | 含义   | 注释 |
| ---:         | ------------: | ----: | ------:   | ----: |
| 使能       | 0             | 0     | 关闭  | 关闭GPIO |
|              |               | 1     | 使能   | 使能GPIO |
| 方向    | 1             | 0     | 输入     | 方向设置成输入 |
|              |               | 1     | 输出    | 方向设置成输出 |
| 输入模式   | 2..3          | 00    | hi-z      | 输入设置为高阻态 |
|              |               | 01    | 下拉  | 下拉输入管脚 |
|              |               | 10    | 上拉 | 上拉输入管脚 |
|              |               | 11    | n/a       | 无效状态。不要设置 |
| 输出模式  | 4             | 0     | 拉低   | 输出管脚变成地电平 |
|              |               | 1     | 拉高  | 输出管脚变成高电平 |
| 输入状态 | 5             | x     | in-val    | 如果输入 < 1.5v为0，如果输入 >= 1.5v为1 |

_可以_ 在Rust中暴露下列的结构体来控制这个GPIO:

```rust,ignore
/// GPIO接口
struct GpioConfig {
    /// 由svd2rust生成的GPIO配置结构体
    periph: GPIO_CONFIG,
}

impl GpioConfig {
    pub fn set_enable(&mut self, is_enabled: bool) {
        self.periph.modify(|_r, w| {
            w.enable().set_bit(is_enabled)
        });
    }

    pub fn set_direction(&mut self, is_output: bool) {
        self.periph.modify(|_r, w| {
            w.direction().set_bit(is_output)
        });
    }

    pub fn set_input_mode(&mut self, variant: InputMode) {
        self.periph.modify(|_r, w| {
            w.input_mode().variant(variant)
        });
    }

    pub fn set_output_mode(&mut self, is_high: bool) {
        self.periph.modify(|_r, w| {
            w.output_mode.set_bit(is_high)
        });
    }

    pub fn get_input_status(&self) -> bool {
        self.periph.read().input_status().bit_is_set()
    }
}
```

然而，这会允许我们修改某些没有意义的寄存器。比如，如果当我们的GPIO被配置为输入时我们设置`output_mode`字段，将会发生什么？

通常使用这个结构体会允许我们访问到上面的状态机没有定义的状态：比如，一个被上拉的输出，或者一个被拉高的输入。对于一些硬件，这并没有关系。对另外一些硬件来说，这将会导致不可预期或者没有定义的行为！

虽然这个接口很方便写入，但是它没有强制我们遵守硬件实现所设的设计约定。
