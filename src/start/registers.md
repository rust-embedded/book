# Memory-mapped Registers

Embedded systems can only get so far by executing normal Rust code and moving
data around in RAM. If we want to get any information into or out of our
system (be that blinking an LED, detecting a button press or communicating
with an off-chip peripheral on some sort of bus) we're going to have to dip
into the world of 'memory mapped registers'.

If you look at the main circuit board in an old-fashioned home computer from
the 1970s or 1980s (and actually, the desktop PCs of yesterday are not so far
removed from the embedded systems of today) you would expect to see:

* A processor
* A RAM chip
* A ROM chip
* An I/O controller

The RAM chip, ROM chip and I/O controller would be joined to the processor
through a series of parallel traces known as a 'bus'. This bus carries address
information, which selects which device on the bus the processor wishes to
communicate with, and a data bus which carries the actual data. In our
embedded microcontrollers, the same principles apply - it's just that
everything is packed on to a single piece of sillicon.

In earlier chapters, we were talking about RAM being located at address
`0x2000_0000`. This is a 32-bit number because the ARM Cortex-M processor
cores have a 32-bit address bus. If our RAM was 64 KiB long (i.e. with a
maximum address of 0xFFFF) then addresses `0x2000_0000` to `0x2000_FFFF` would
correspond to our RAM. When we write to a variable which lives at address
`0x2000_1234`, what happens internally is that some logic detects the upper
portion of the address (0x2000 in this example) and then activates the RAM so
that it can act upon the lower portion of the address (0x1234 in this case).

Going back to our home computer example, our I/O controller needs to operate
in the same fashion as the RAM, as it sits on the same bus. Here though,
instead of having a full 64 Ki (65,536) addressable locations, it might only
have three or four addressable locations. These locations are known as
*memory-mapped registers*. By writing data to these registers, the processor
can affect the operation of the hardware. What happens when you do this is
entirely down to the design of the peripheral. For example, on an I/O
peripheral, each bit of one register might correspond to the output level of an
I/O pin allowing us to turn on some LEDs, while some other register might
allow us to set whether each pin is an Input pin or an Output pin. On a UART
peripheral, we might instead expect to see one register which lets us set the
baud rate of our serial connection, one for data we wish to send over the
serial connection and another which lets us read any buffered data that has
been received.

Let's take the 'SysTick' peripheral - a simple timer which comes with every
Cortex-M processor core. Typically you'll be looking these up in the chip
manufacturer's data sheet or *Technical Reference Manual*, but this example is
common to all ARM Cortex-M cores, let's look in the [ARM reference manual]. we
see there are four registers:

[ARM reference manual]: http://infocenter.arm.com/help/topic/com.arm.doc.dui0553a/Babieigh.html

| Offset | Name        | Description                 | Width  |
|--------|-------------|-----------------------------|--------|
| 0x00   | SYST_CSR    | Control and Status Register | 32 bits|
| 0x04   | SYST_RVR    | Reload Value Register       | 32 bits|
| 0x08   | SYST_CVR    | Current Value Register      | 32 bits|
| 0x0C   | SYST_CALIB  | Calibration Value Regsister | 32 bits|

In Rust, we can represent a collection of registers in exactly the same way as we do in C - with a `struct`.

```rust
#[repr(C)]
struct SysTick {
    pub csr: u32,
    pub rvr: u32,
    pub cvr: u32,
    pub calib: u32,
}
```

The qualifier `#[repr(C)]` tells the Rust compiler to lay this structure out
like a C compiler would. That's very important, as Rust allows structure
fields to be re-ordered, while C does not. You can imagine the debugging we'd
have to do if these fields were silently re-arranged by the compiler! We then
have our four 32-bit fields, which should correspond to the table above. But
of course, this `struct` is of no use by itself - we need a variable.

```rust
let systick = 0xE000_E010 as *mut SysTick;
let time = unsafe { (*systick).cvr };
```

Now, there are a couple of problems with this approach.

1. We have to use unsafe every time we want to access our Peripheral.
2. We've got no way of specifying which registers are read-only or read-write.
3. Any piece of code anywhere in your program could access the hardware
   through this structure.
4. Most importantly, it doesn't actually work...

Now, the problem is that compilers are clever. If you make two writes to the
same piece of RAM, one after the other, the compiler can notice this and just
skip the first write entirely. In C, we can mark variables as `volatile` to
ensure that every read or write occurs as intended. In Rust, we instead mark
the *accesses* as volatie, not the variable.

```rust
let systick = unsafe { &mut *(0xE000_E010 as *mut SysTick) };
let time = unsafe { std::ptr::read_volatile(&mut systick.cvr) };
```

So, we've fixed one of our four problems, but now we have even more `unsafe`
code! Fortunately, there's a third party crate which can help -
[`volatile_register`].

[`volatile_register`]: https://crates.io/crates/volatile_register

```rust
use volatile_register::{RW, RO};

#[repr(C)]
struct SysTick {
    pub csr: RW<u32>,
    pub rvr: RW<u32>,
    pub cvr: RW<u32>,
    pub calib: RO<u32>,
}

fn get_systick() -> &'static mut SysTick {
    unsafe { &mut *(0xE000_E010 as *mut SysTick) }
}

fn test() {
    let systick = get_systick();
    let time = systick.cvr.read();
    unsafe { systick.rvr.write(time) };
}
```

Now, the volatile accesses are performed automatically through the `read` and
`write` methods. It's still `unsafe` to perform writes, but to be fair,
hardware is a bunch of mutable state and there's no way for the compiler to
know whether these writes are actually safe, so this is a good default
position. We can always wrap this `struct` into a higher level API which
verifies when these writes are safe - more on that in the chapter on [Static
Guarantees].

[Static Guarantees]: ../static-guarantees/static-guarantees.md
