# The Borrow Checker

Which, sounds suspiciously exactly like what the Borrow Checker does already!

Imagine if we could pass around ownership of these peripherals, or offer immutable or mutable references to them?

Well, we can, but for the Borrow Checker, we need to have exactly one instance of each peripheral, so Rust can handle this correctly. Well, luckliy in the hardware, there is only one instance of this specific serial port, but how can we expose that in code?