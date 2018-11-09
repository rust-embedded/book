# Memory Mapped Registers

> The getting started chapter is about "how do I" and "what can I do with this". Later chapters cover "how does this works" and "why does it look like this". So start/peripherals.md should cover one of the cortex-m peripheral APIs, e.g. peripheral::SYST. Specifically it should cover: taking peripherals into the current scope (skipping explaining why is done like that), the low level API (read / write on individual registers: e.g. SYST.rvr.write) and the high level API (SYST.enable_counter, which is just some registers reads / writes).

Embedded systems can only get so far by executing normal Rust code and moving data around in RAM. If we want to get any information into or out of our system (be that blinking an LED, detecting a button press or communicating with an off-chip peripheral on some sort of bus) we're going to have to dip into the world of Peripherals and their 'memory mapped registers'.

You may well find that the code you need to access the peripherals in your microcontroller has already been written, at one of the following levels:

* Microarchitecture Crate - This sort of crate handles any useful routines common to the processor core your microcontroller is using, as well as any peripherals that are common to all microcontrollers that use that particular type of processor core. For example the [cortex-m] crate gives you functions to enable and disable interrupts, which are the same for all Cortex-M based microcontrollers. It also gives you access to the 'SysTick' peripheral included with all Cortex-M based microcontrollers.
* Peripheral Access Crate (PAC) - This sort of crate is a thin wrapper over the various memory-wrapper registers defined for your particular part-number of microcontroller you are using. For example, [tm4c123x] for the Texas Instruments Tiva-C TM4C123 series, or [stm32f30x] for the ST-Micro STM32F30x series. Here, you'll be interacting with the registers directly, following each peripheral's operating instructions given in your microcontroller's Technical Reference Manual.
* HAL Crate - These crates offer a more user-friendly API for your particular processor, often by implementing some common traits defined in [embedded-hal]. For example, this crate might offer a `Serial` struct, with a constructor that takes an appropriate set of GPIO pins and a board rate, and offers some sort of `write_byte` method for sending data. See the chapter on [Portability] for more information on [embedded-hal].
* Board Crate - These crates go one step further than a HAL Crate by pre-configuring various peripherals and GPIO pins to suit the specific developer kit or board you are using, such as [F3] for the STM32F3DISCOVERY board.

[cortex-m]: https://crates.io/crates/cortex-m
[tm4c123x]: https://crates.io/crates/tm4c123x
[stm32f30x]: https://crates.io/crates/stm32f30x
[embedded-hal]: https://crates.io/crates/embedded-hal
[Portability]: ../portability/portability.md
[F3]: https://crates.io/crates/f3


## Starting at the bottom

Let's look at the SysTick peripheral that's common to all Cortex-M based microcontrollers. We can find a pretty low-level API in the [cortex-m] crate, and we can use it like this:

```rust
use cortex_m::peripheral::{syst, Peripherals};
use cortex_m_rt::entry;

#[entry]
fn main() {
    let mut peripherals = Peripherals::take().unwrap();
    let mut systick = peripherals.SYST;
    systick.set_clock_source(syst::SystClkSource::Core);
    systick.clear_current();
    systick.enable_counter();
    while systick.get_current() < 1_000 {
        // Loop
    }
}
```

The methods on the `SYST` struct map pretty closely to the functionality defined by the ARM Technical Reference Manual for this peripheral. There's nothing in this API about 'delaying for X milliseconds' - we have to crudely implement that ourselves using a `while` loop. Note that we can't access our `SYST` struct until we have called `Peripherals::take()` - this is a special routine that guarantees that there is only one `SYST` structure in our entire program. For more on that, see the [Peripherals] section.

[Peripherals]: ../peripherals/peripherals.md

## Using a chip crate

We won't get very far with our embedded software development if we restrict ourselves to only the basic peripherals included with every Cortex-M. At some point, we're going to need to write some code that's specific to the particular microcontroller we're using. In this example, let's assume we have an Texas Instruments TM4C123 - a middling 80MHz Cortex-M4 with 256 KiB of Flash. We're going to pull in the [tm4c123x] crate to make use of this chip.

```rust
#![no_std]
#![no_main]

extern crate panic_halt; // panic handler

use cortex_m_rt::entry;
use tm4c123x;

#[entry]
pub fn init() -> (Delay, Leds) {
    let cp = cortex_m::Peripherals::take().unwrap();
    let p = tm4c123x::Peripherals::take().unwrap();

    let pwm = p.PWM0;
    pwm.ctl.write(|w| w.globalsync0().clear_bit());
    // Mode = 1 => Count up/down mode
    pwm._2_ctl.write(|w| w.enable().set_bit().mode().set_bit());
    pwm._2_gena.write(|w| w.actcmpau().zero().actcmpad().one());
    // 528 cycles (264 up and down) = 4 loops per video line (2112 cycles)
    pwm._2_load.write(|w| unsafe { w.load().bits(263) });
    pwm._2_cmpa.write(|w| unsafe { w.compa().bits(64) });
    pwm.enable.write(|w| w.pwm4en().set_bit());
}

```

We've access the `PWM0` peripheral in exactly the same as as we access the `SYST` peripheral earlier, except we called `tm4c123x::Peripherals::take()`. As this crate was auto-generated using [svd2rust], the access methods for our register fields take a closure, rather than a numeric argument. While this looks like a lot of code, the Rust compiler can use it to perform a bunch of checks for us, but then generate machine-code which is pretty close to hand-written assembler!

### Reading

The `read()` method takes a closure with a single argument. Typically we call this `r`. This argument then gives read-only access to the various sub-fields within this register, as defined by the manufacturer's SVD file for this chip. You can find all the methods available on the 'r' for this particular register, in this particular peripheral, on this particular chip, in the [tm4c123x documentation].

```rust
if pwm.ctl.read(|r| r.globalsync0().is_set()) {
    // Do a thing
}
```

### Writing

The `write()` method takes a closure with a single argument. Typically we call this `w`. This argument then gives read-write access to the various sub-fields within this register, as defined by the manufacturer's SVD file for this chip. Again, you can find all the methods available on the 'w' for this particular register, in this particular peripheral, on this particular chip, in the [tm4c123x documentation]. Note that all of the sub-fields that we do not set will be set to a default value for us - any existing content in the register will be lost.

```rust
pwm.ctl.write(|w| w.globalsync0().clear_bit());
```

### Modifying

If we wish to change only on particular sub-field in this register and leave the other sub-fields unchanged, we can use the `modify` function. This function takes a closure with two arguments - one for reading and one for writing. Typically we call these `r` and `w` respectively. The `r` argument can be used to inspect the current contents of the register, and the `w` argument can be used to modify the register contents.

```rust
pwm.ctl.modify(|r, w| w.globalsync0().clear_bit());
```

The `modify` function really shows the power of closures here. In C, we'd have to read into some temporary value, modify the correct bits and then write the value back. This mean's there's considerable scope for error:

```C
uint32_t temp = pwm0.ctl.read();
temp |= PWM0_CTL_GLOBALSYNC0;
pwm0.ctl.write(temp);
uint32_t temp2 = pwm0.enable.read();
temp2 |= PWM0_ENABLE_PWM4EN;
pwm0.enable.write(temp); // Uh oh! Wrong variable!
```

[svd2rust]: https://crates.io/crates/svd2rust
[tm4c123x documentation]: https://docs.rs/tm4c123x/0.7.0/tm4c123x/pwm0/ctl/struct.R.html


## Using a HAL crate
