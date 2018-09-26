# A First Attempt

## Arbitrary Memory Locations and Rust

Although Rust is capable of interacting with arbitrary memory locations, dereferencing any pointer is considered an `unsafe` operation. The most direct way to expose reading from or writing to a peripheral would look something like this:

```rust
use core::ptr;
const SER_PORT_SPEED_REG: *mut u32 = 0x4000_1000 as _;

fn read_serial_port_speed() -> u32 {
    unsafe { // <-- :(
        ptr::read_volatile(SER_PORT_SPEED_REG)
    }
}
fn write_serial_port_speed(val: u32) {
    unsafe { // <-- :(
        ptr::write_volatile(SER_PORT_SPEED_REG, val);
    }
}
```

Although this works, it is subjectively a little messy, so the first reaction might be to wrap these related things into a `struct` to better organize them. A second attempt could come up with something like this:

```rust
use core::ptr;

struct SerialPort;

impl SerialPort {
    // Private Constants (addresses)
    const SER_PORT_SPEED_REG: *mut u32 = 0x4000_1000 as _;

    // Public Constants (enumerated values)
    pub const SER_PORT_SPEED_8MBPS:   u32 = 0x8000_0000;
    pub const SER_PORT_SPEED_125KBPS: u32 = 0x0200_0000;

    fn new() -> SerialPort {
        SerialPort
    }

    fn read_speed(&self) -> u32 {
        unsafe {
            ptr::read_volatile(Self::SER_PORT_SPEED_REG)
        }
    }

    fn write_speed(&mut self, val: u32) {
        unsafe {
            ptr::write_volatile(Self::SER_PORT_SPEED_REG, val);
        }
    }
}
```

And this is a little better! We've hidden that random looking memory address, and presented something that feels a little more rusty. We can even use our new interface:

```rust
fn do_something() {
    let mut serial = SerialPort::new();

    let speed = serial.read_speed();
    // Do some work
    serial.write_speed(speed * 2);
}
```

But the problem with this is that our `SerialPort` struct could be created anywhere. By creating multiple instances of `SerialPort`, we would create aliased mutable pointers, which are typically avoided in Rust.

Consider the following example:

```rust
fn do_something() {
    let mut serial = SerialPort::new();
    let speed = serial.read_speed();

    // Be careful, we have to go slow!
    if speed != SerialPort::SER_PORT_SPEED_LO {
        serial.write_speed(SerialPort::SER_PORT_SPEED_LO)
    }
    // First, send some pre-data
    something_else();
    // Okay, lets send some slow data
    // ...
}

fn something_else() {
    let mut serial = SerialPort::new();
    // We gotta go fast for this!
    serial.write_speed(SerialPort::SER_PORT_SPEED_HI);
    // send some data...
}
```

In this case, if we were only looking at the code in `do_something()`, we would think that we are definitely sending our serial data slowly, and would be confused why our embedded code is not working as expected.

In this case, it is easy to see where the error was introduced. However, once this code is spread out over multiple modules, drivers, developers, and days, it gets easier and easier to make these kinds of mistakes.
