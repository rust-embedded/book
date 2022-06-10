# 设计协约

在我们的上个章节中，我们写了一个接口，其没有强制执行设计协约。让我们再看下我们假想的GPIO配置寄存器:


| 名字          | 位数(s) | 值 | 含义   | 注释 |
| ---:         | ------------: | ----: | ------:   | ----: |
| 使能       | 0             | 0     | 关闭  | 关闭GPIO |
|              |               | 1     | 使能   | 使能GPIO |
| 方向    | 1             | 0     | 输入     | 方向设置成输入 |
|              |               | 1     | 输出    | 方向设置成输出 |
| 输入模式   | 2..3          | 00    | hi-z      | 输入设置为高阻抗 |
|              |               | 01    | 下拉  | 下拉输入管脚 |
|              |               | 10    | 上拉 | 上拉输入管脚 |
|              |               | 11    | n/a       | 无效模式。不要设置 |
| 输出模式  | 4             | 0     | 拉低   | 拉低输出管脚 |
|              |               | 1     | 拉高  | 拉高输出管脚 |
| 输入状态 | 5             | x     | in-val    | 如果输入 < 1.5v 为0，如果输入 >= 1.5v 为1 |


如果我们在使用底层硬件之前检查状态，在运行时强制遵守我们的设计协约，我们写的代码可能像这一样:

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

因为我们不需要强制遵守硬件上的限制，所以我们最后做了很多运行时检查，它浪费了我们很多时间和资源，对于开发者来说，这个代码用起来就没那么愉快了。

## 类型状态(Type states)

但是，如果我们使用Rust的类型系统去强制状态转换的规则会怎样？看下这个例子:

```rust,ignore
/// GPIO接口
struct GpioConfig<ENABLED, DIRECTION, MODE> {
    /// 由svd2rust产生的GPIO配置结构体
    periph: GPIO_CONFIG,
    enabled: ENABLED,
    direction: DIRECTION,
    mode: MODE,
}

// Type states for MODE in GpioConfig
struct Disabled;
struct Enabled;
struct Output;
struct Input;
struct PulledLow;
struct PulledHigh;
struct HighZ;
struct DontCare;

/// These functions may be used on any GPIO Pin
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

/// This function may be used on an Output Pin
impl GpioConfig<Enabled, Output, DontCare> {
    pub fn set_bit(&mut self, set_high: bool) {
        self.periph.modify(|_r, w| w.output_mode.set_bit(set_high));
    }
}

/// These methods may be used on any enabled input GPIO
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

Now let's see what the code using this would look like:

```rust,ignore
/*
 * Example 1: Unconfigured to High-Z input
 */
let pin: GpioConfig<Disabled, _, _> = get_gpio();

// Can't do this, pin isn't enabled!
// pin.into_input_pull_down();

// Now turn the pin from unconfigured to a high-z input
let input_pin = pin.into_enabled_input();

// Read from the pin
let pin_state = input_pin.bit_is_set();

// Can't do this, input pins don't have this interface!
// input_pin.set_bit(true);

/*
 * Example 2: High-Z input to Pulled Low input
 */
let pulled_low = input_pin.into_input_pull_down();
let pin_state = pulled_low.bit_is_set();

/*
 * Example 3: Pulled Low input to Output, set high
 */
let output_pin = pulled_low.into_enabled_output();
output_pin.set_bit(true);

// Can't do this, output pins don't have this interface!
// output_pin.into_input_pull_down();
```

This is definitely a convenient way to store the state of the pin, but why do it this way? Why is this better than storing the state as an `enum` inside of our `GpioConfig` structure?

## Compile Time Functional Safety

Because we are enforcing our design constraints entirely at compile time, this incurs no runtime cost. It is impossible to set an output mode when you have a pin in an input mode. Instead, you must walk through the states by converting it to an output pin, and then setting the output mode. Because of this, there is no runtime penalty due to checking the current state before executing a function.

Also, because these states are enforced by the type system, there is no longer room for errors by consumers of this interface. If they try to perform an illegal state transition, the code will not compile!
