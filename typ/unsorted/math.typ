#import "../config.typ": *

#h1((en: [Performing math functionality with `#[no_std]`],
  de: [Mathematische Funktionen mit `#[no_std]` nutzen],
  zh: [在`#[no_std]`下执行数学运算],
), offset: whole)

#tr((
en: [
  If you want to perform math related functionality like calculating the
  squareroot or the exponential of a number and you have the full standard
  library available, your code might look like this:
],
de: [
  Wenn Sie mathematische Operationen durchführen möchten -- wie etwa die
  Berechnung der Quadratwurzel aus der Exponentialfunktion einer Zahl --
  und Ihnen die vollständige Standardbibliothek zur Verfügung steht,
  könnte Ihr Code folgendermaßen aussehen:
],
zh: [
  如果你想要执行数学相关的函数，像是计算平方根或者一个数的指数并有完整的标准库支持，代码可能看起来像这样:
]))

#raw(block: true, lang: "rust",
"//! " + ts((
    en: "Some mathematical functions with standard support available",
    de: "Einige mathematische Funktionen mit Standardunterstützung verfügbar",
    zh: "可用一些标准支持的数学函数",
  )) + "

fn main() {
    let float: f32 = 4.82832;
    let floored_float = float.floor();

    let sqrt_of_four = floored_float.sqrt();

    let sinus_of_four = floored_float.sin();

    let exponential_of_four = floored_float.exp();
    println!(\"Floored test float {} to {}\", float, floored_float);
    println!(\"The square root of {} is {}\", floored_float, sqrt_of_four);
    println!(\"The sinus of four is {}\", sinus_of_four);
    println!(
        \"The exponential of four to the base e is {}\",
        exponential_of_four
    )
}
")

#let ln_libm = link("https://crates.io/crates/libm")[`libm`]
#tr((
en: [
  Without standard library support, these functions are not available. An
  external crate like #ln_libm can
  be used instead. The example code would then look like this:
],
de: [
  Ohne Unterstützung durch die Standardbibliothek stehen diese Funktionen
  nicht zur Verfügung. Stattdessen kann ein externes Crate wie
  #ln_libm verwendet werden. Der
  Beispielcode sähe dann folgendermaßen aus:
],
zh: [
  没有标准库支持的时候，这些函数不可用。反而可以使用像是#ln_libm;这样一个外部库。示例的代码将会看起来像这样:
]))

#raw(block: true, lang: "rust",
"#![no_main]
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
    hprintln!(\"Floored test float {} to {}\", float, floored_float).unwrap();
    hprintln!(\"The square root of {} is {}\", floored_float, sqrt_of_four).unwrap();
    hprintln!(\"The sinus of four is {}\", sinus_of_four).unwrap();
    hprintln!(
        \"The exponential of four to the base e is {}\",
        exponential_of_four
    )
    .unwrap();
    // " + ts((
        en: "exit QEMU
    // NOTE do not run this on hardware; it can corrupt OpenOCD state",
        de: "exit QEMU
    // HINWEIS: Fuehren Sie dies nicht auf der Hardware aus; es kann den 
    //          OpenOCD-Zustand beschaedigen.",
        zh: "退出QEMU
    // 注意不要在硬件上使用这个; 它能破坏OpenOCD的状态"
      )) + "
    // debug::exit(debug::EXIT_SUCCESS);

    loop {}
}
")

#tr((
en: [
  If you need to perform more complex operations like DSP signal
  processing or advanced linear algebra on your MCU, the following crates
  might help you
],
de: [
  Wenn Sie komplexere Operationen wie DSP-Signalverarbeitung oder
  fortgeschrittene lineare Algebra auf Ihrem Mikrocontroller durchführen
  müssen, könnten Ihnen die folgenden Crates weiterhelfen.
],
zh: [
  如果需要在MCU上执行更复杂的操作，像是DSP信号处理或者更高级的线性代数，下列的crates可能可以帮到你
]))
- #link("https://github.com/jacobrosenthal/cmsis-dsp-sys")[CMSIS DSP library binding]
- #link("https://crates.io/crates/constgebra")[`constgebra`]
- #link("https://github.com/tarcieri/micromath")[`micromath`]
- #link("https://crates.io/crates/microfft")[`microfft`]
- #link("https://github.com/dimforge/nalgebra")[`nalgebra`]
