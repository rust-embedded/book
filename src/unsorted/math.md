# 在`#[no_std]`下执行数学运算

如果你想要执行数学相关的函数，像是计算平方根或者一个数的指数并有完整的标准库支持，代码可能看起来像这样:

```rs
//! 可用一些标准支持的数学函数

fn main() {
    let float: f32 = 4.82832;
    let floored_float = float.floor();

    let sqrt_of_four = floored_float.sqrt();

    let sinus_of_four = floored_float.sin();

    let exponential_of_four = floored_float.exp();
    println!("Floored test float {} to {}", float, floored_float);
    println!("The square root of {} is {}", floored_float, sqrt_of_four);
    println!("The sinus of four is {}", sinus_of_four);
    println!(
        "The exponential of four to the base e is {}",
        exponential_of_four
    )
}
```

没有标准库支持的时候，这些函数不可用。反而可以使用像是[`libm`](https://crates.io/crates/libm)这样一个外部库。示例的代码将会看起来像这样:

```rs
#![no_main]
#![no_std]

use panic_halt as _;

use cortex_m_rt::entry;
use cortex_m_semihosting::{debug, hprintln};
use libm::{exp, floorf, sin, sqrtf};

#[entry]
fn main() -> ! {
    let float = 4.82832;
    let floored_float = floorf(float);

    let sqrt_of_four = sqrtf(floored_float);

    let sinus_of_four = sin(floored_float.into());

    let exponential_of_four = exp(floored_float.into());
    hprintln!("Floored test float {} to {}", float, floored_float).unwrap();
    hprintln!("The square root of {} is {}", floored_float, sqrt_of_four).unwrap();
    hprintln!("The sinus of four is {}", sinus_of_four).unwrap();
    hprintln!(
        "The exponential of four to the base e is {}",
        exponential_of_four
    )
    .unwrap();
    // 退出QEMU
    // 注意不要在硬件上使用这个; 它能破坏OpenOCD的状态
    // debug::exit(debug::EXIT_SUCCESS);

    loop {}
}
```

如果需要在MCU上执行更复杂的操作，像是DSP信号处理或者更高级的线性代数，下列的crates可能可以帮到你

- [CMSIS DSP library binding](https://github.com/jacobrosenthal/cmsis-dsp-sys)
- [`constgebra`](https://crates.io/crates/constgebra)
- [`micromath`](https://github.com/tarcieri/micromath)
- [`microfft`](https://crates.io/crates/microfft)
- [`nalgebra`](https://github.com/dimforge/nalgebra)
