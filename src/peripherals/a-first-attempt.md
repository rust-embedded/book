# Global Instances

Great! We have all of the superpowers of Rust, but how do we interact with those peripherals? They are just arbitrary memory locations, and dereferencing those would be `unsafe`! Do we need to do something like this every time we want to use a peripheral?

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

* Messy
* Not very Rusty
* Lets try something else...

This is a little messy, so the first reaction might be to wrap these related things up in to a `struct` to organize them better. Maybe you would come up with something like this:

```rust
use core::ptr;

struct SerialPort;

impl SerialPort {
    const SER_PORT_SPEED_REG: *mut u32 = 0x4000_1000 as _;
    pub const SER_PORT_SPEED_HI: u32 = 0x8000_0000;
    pub const SER_PORT_SPEED_LO: u32 = 0x0800_0000;

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

* A little better
* This works!

And this is a little better! We've hidden that random looking memory address, and presented something that feels a little more rusty. We can even use our new interface:

```rust
fn do_something() {
    let mut serial = SerialPort::new();

    let speed = serial.read_speed();
    // Do some work
    serial.write_speed(speed * 2);
}
```

* Problem is you can make these anywhere
* When you can make these anywhere, you have aliased pointers!

But the problem with this is that you can create one of these structs anywhere! Imagine this:

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

In this case, if we were only looking at the code in `do_something()`, we would think, we are definitely sending our serial data slowly, why isn't that thing working?

In this example, it is easy to see. However, once this code is spread out over multiple modules, drivers, developers, and days, it gets easier and easier to make these kinds of mistakes.

## This smells like mutable global state

> hardware is basically nothing but mutable global state

## What should our rules be?

1. We should be able to share any number of read-only accesses to these peripherals
2. If something has read-write access to a peripheral, it should be the only reference

If you are already familiar with Rust, this should start to sound familiar, as this is what the Borrow Checker already does!