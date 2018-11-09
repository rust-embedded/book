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

