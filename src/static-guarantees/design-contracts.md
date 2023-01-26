# 设计约定(design contracts)

在我们的上个章节中，我们写了一个接口，但没有强制遵守设计约定。让我们再看下我们假想的GPIO配置寄存器：


| 名字          | 位数(s) | 值 | 含义   | 注释 |
| ---:         | ------------: | ----: | ------:   | ----: |
| 使能       | 0             | 0     | 关闭  | 关闭GPIO |
|              |               | 1     | 使能   | 使能GPIO |
| 方向    | 1             | 0     | 输入     | 方向设置成输入 |
|              |               | 1     | 输出    | 方向设置成输出 |
| 输入模式   | 2..3          | 00    | 高阻态      | 输入设置为高阻态 |
|              |               | 01    | 下拉  | 下拉输入管脚 |
|              |               | 10    | 上拉 | 上拉输入管脚 |
|              |               | 11    | n/a       | 无效状态。不要设置 |
| 输出模式  | 4             | 0     | 拉低   | 把管脚设置成低电平 |
|              |               | 1     | 拉高  | 把管脚设置成高电平 |
| 输入状态 | 5             | x     | 输入电平    | 如果输入 < 1.5v 为0，如果输入 >= 1.5v 为1 |


如果在使用底层硬件之前检查硬件的状态，在运行时强制用户遵守设计约定，代码可能像这一样:

```rust,ignore
/// GPIO接口
struct GpioConfig {
    /// 由svd2rust生成的GPIO配制结构体
    periph: GPIO_CONFIG,
}

impl GpioConfig {
    pub fn set_enable(&mut self, is_enabled: bool) {
        self.periph.modify(|_r, w| {
            w.enable().set_bit(is_enabled)
        });
    }

    pub fn set_direction(&mut self, is_output: bool) -> Result<(), ()> {
        if self.periph.read().enable().bit_is_clear() {
            // 必须被使能配置方向
            return Err(());
        }

        self.periph.modify(|r, w| {
            w.direction().set_bit(is_output)
        });

        Ok(())
    }

    pub fn set_input_mode(&mut self, variant: InputMode) -> Result<(), ()> {
        if self.periph.read().enable().bit_is_clear() {
            // 必须被使能配置输入模式
            return Err(());
        }

        if self.periph.read().direction().bit_is_set() {
            // 方向必须被设置成输入
            return Err(());
        }

        self.periph.modify(|_r, w| {
            w.input_mode().variant(variant)
        });

        Ok(())
    }

    pub fn set_output_status(&mut self, is_high: bool) -> Result<(), ()> {
        if self.periph.read().enable().bit_is_clear() {
            // 设置输出状态必须被使能
            return Err(());
        }

        if self.periph.read().direction().bit_is_clear() {
            // 方向必须是输出
            return Err(());
        }

        self.periph.modify(|_r, w| {
            w.output_mode.set_bit(is_high)
        });

        Ok(())
    }

    pub fn get_input_status(&self) -> Result<bool, ()> {
        if self.periph.read().enable().bit_is_clear() {
            // 获取状态必须被使能
            return Err(());
        }

        if self.periph.read().direction().bit_is_set() {
            // 方向必须是输入
            return Err(());
        }

        Ok(self.periph.read().input_status().bit_is_set())
    }
}
```

因为需要强制遵守硬件上的限制，所以最后做了很多运行时检查，它浪费了我们很多时间和资源，对于开发者来说，这个代码用起来就没那么愉快了。

## 类型状态(Type states)

但是，如果我们让Rust的类型系统去强制遵守状态转换的规则会怎样？看下这个例子:

```rust,ignore
/// GPIO接口
struct GpioConfig<ENABLED, DIRECTION, MODE> {
    /// 由svd2rust产生的GPIO配置结构体
    periph: GPIO_CONFIG,
    enabled: ENABLED,
    direction: DIRECTION,
    mode: MODE,
}

// GpioConfig中MODE的类型状态
struct Disabled;
struct Enabled;
struct Output;
struct Input;
struct PulledLow;
struct PulledHigh;
struct HighZ;
struct DontCare;

/// 这些函数可能被用于所有的GPIO管脚
impl<EN, DIR, IN_MODE> GpioConfig<EN, DIR, IN_MODE> {
    pub fn into_disabled(self) -> GpioConfig<Disabled, DontCare, DontCare> {
        self.periph.modify(|_r, w| w.enable.disabled());
        GpioConfig {
            periph: self.periph,
            enabled: Disabled,
            direction: DontCare,
            mode: DontCare,
        }
    }

    pub fn into_enabled_input(self) -> GpioConfig<Enabled, Input, HighZ> {
        self.periph.modify(|_r, w| {
            w.enable.enabled()
             .direction.input()
             .input_mode.high_z()
        });
        GpioConfig {
            periph: self.periph,
            enabled: Enabled,
            direction: Input,
            mode: HighZ,
        }
    }

    pub fn into_enabled_output(self) -> GpioConfig<Enabled, Output, DontCare> {
        self.periph.modify(|_r, w| {
            w.enable.enabled()
             .direction.output()
             .input_mode.set_high()
        });
        GpioConfig {
            periph: self.periph,
            enabled: Enabled,
            direction: Output,
            mode: DontCare,
        }
    }
}

/// 这个函数可能被用于一个输出管脚
impl GpioConfig<Enabled, Output, DontCare> {
    pub fn set_bit(&mut self, set_high: bool) {
        self.periph.modify(|_r, w| w.output_mode.set_bit(set_high));
    }
}

/// 这些方法可能被用于任意一个使能的输入GPIO
impl<IN_MODE> GpioConfig<Enabled, Input, IN_MODE> {
    pub fn bit_is_set(&self) -> bool {
        self.periph.read().input_status.bit_is_set()
    }

    pub fn into_input_high_z(self) -> GpioConfig<Enabled, Input, HighZ> {
        self.periph.modify(|_r, w| w.input_mode().high_z());
        GpioConfig {
            periph: self.periph,
            enabled: Enabled,
            direction: Input,
            mode: HighZ,
        }
    }

    pub fn into_input_pull_down(self) -> GpioConfig<Enabled, Input, PulledLow> {
        self.periph.modify(|_r, w| w.input_mode().pull_low());
        GpioConfig {
            periph: self.periph,
            enabled: Enabled,
            direction: Input,
            mode: PulledLow,
        }
    }

    pub fn into_input_pull_up(self) -> GpioConfig<Enabled, Input, PulledHigh> {
        self.periph.modify(|_r, w| w.input_mode().pull_high());
        GpioConfig {
            periph: self.periph,
            enabled: Enabled,
            direction: Input,
            mode: PulledHigh,
        }
    }
}
```

现在让我们看下代码如何用这个API:

```rust,ignore
/*
 * 案例 1: 从未配置到高阻输入
 */
let pin: GpioConfig<Disabled, _, _> = get_gpio();

// 不能这么做，pin没有被使能
// pin.into_input_pull_down();

// 现在把管脚从未配置变为高阻输入
let input_pin = pin.into_enabled_input();

// 从管脚读取
let pin_state = input_pin.bit_is_set();

// 不能这么做，输入管脚没有这个接口
// input_pin.set_bit(true);

/*
 * 案例 2: 高阻输入到下拉输入
 */
let pulled_low = input_pin.into_input_pull_down();
let pin_state = pulled_low.bit_is_set();

/*
 * 案例 3: 下拉输入到输出, 拉高
 */
let output_pin = pulled_low.into_enabled_output();
output_pin.set_bit(true);

// 不能这么做，输出管脚没有这个接口
// output_pin.into_input_pull_down();
```

这绝对是存储管脚状态的便捷方法，但是为什么这么做?为什么这比把状态当成一个`enum`存在我们的`GpioConfig`结构体中更好？

## 编译时功能安全(Functional Safety)

因为我们在编译时完全强制遵守设计约定，这造成了没有运行时开销。当管脚处于输入模式时时，是不可能设置输出模式的。必须先把它设置成一个输出管脚，然后再设置输出模式。因为在执行一个函数前会检查现在的状态，因此没有运行时消耗。

也因为这些状态被类型系统强制遵守，因此没有为这个接口的使用者留太多的犯错余地。如果它们尝试执行一个非法的状态转换，代码将不会编译成功！
