# Interrupts

Interrupts differ from exceptions in a variety of ways but their operation and
use is largely similar and they are also handled by the same interrupt
controller. Whereas exceptions are defined by the Cortex-M architecture,
interrupts are always vendor (and often even chip) specific implementations,
both in naming and functionality.

Interrupts do allow for a lot of flexibility which needs to be accounted for
when attempting to use them in an advanced way. We will not cover those uses in
this book, however it is a good idea to keep the following in mind:

* Interrupts have programmable priorities which determine their handlers' execution order
* Interrupts can nest and preempt, i.e. execution of an interrupt handler might be interrupted by another higher-priority interrupt
* In general the reason causing the interrupt to trigger needs to be cleared to prevent re-entering the interrupt handler endlessly

The general initialization steps at runtime are always the same:
* Setup the peripheral(s) to generate interrupts requests at the desired occasions
* Set the desired priority of the interrupt handler in the interrupt controller
* Enable the interrupt handler in the interrupt controller

Similarly to exceptions, the cortex-m-rt crate exposes an [`interrupt`] attribute for declaring interrupt handlers. However, this 
attribute is only available when the device feature is enabled. That said, this attribute is not intended to be used directly—doing 
so will result in a compilation error.

Instead, you should use the re-exported version of the interrupt attribute provided by the device crate (usually generated using svd2rust). 
This ensures that the compiler can verify that the interrupt actually exists on the target device. The list of available interrupts—and 
their position in the interrupt vector table—is typically auto-generated from an SVD file by svd2rust.

[`interrupt`]: https://docs.rs/cortex-m-rt-macros/0.1.5/cortex_m_rt_macros/attr.interrupt.html

``` rust,ignore
use lm3s6965::interrupt; // Re-exported attribute from the device crate

// Interrupt handler for the Timer2 interrupt
#[interrupt]
fn TIMER2A() {
    // ..
    // Clear reason for the generated interrupt request
}
```

Interrupt handlers look like plain functions (except for the lack of arguments)
similar to exception handlers. However they can not be called directly by other
parts of the firmware due to the special calling conventions. It is however
possible to generate interrupt requests in software to trigger a diversion to
the interrupt handler.

Similar to exception handlers it is also possible to declare `static mut`
variables inside the interrupt handlers for *safe* state keeping.

``` rust,ignore
#[interrupt]
fn TIMER2A() {
    static mut COUNT: u32 = 0;

    // `COUNT` has type `&mut u32` and it's safe to use
    *COUNT += 1;
}
```

For a more detailed description about the mechanisms demonstrated here please
refer to the [exceptions section].

[exceptions section]: ./exceptions.md
