# A `no_std` Rust Environment

The term Embedded Programming is used for a wide range of different classes of programming.
Ranging from programming 8 Bit MCUs (like [ST72325xx](https://www.st.com/resource/en/datasheet/st72325j6.pdf)) with just a few KB of RAM and ROM, up to systems like
the Raspberry Pi ([Model B 3+](https://en.wikipedia.org/wiki/Raspberry_Pi#Specifications)) which has a 32/64-bit 4-core Cortex-A53 @ 1.4 GHz and 1GB of RAM.
Different restrictions/limitations will apply when writing code depending on what kind of target and use case you have.

There are two general Embedded Programming classifications:

## Hosted Environments
These kinds of environments feel pretty close to a normal PC environment.
What this means is you are provided with a System Interface [E.G. POSIX](https://en.wikipedia.org/wiki/POSIX)
that provides you with primitives to interact with various systems, such as file systems, networking, memory management, threads, etc.
Standard libraries in turn usually depend on these primitives to implement their functionality.
You may also have some sort of sysroot and restrictions on RAM/ROM-usage, and perhaps some
special HW or I/Os. Overall it feels like coding in a special-purpose PC environment.

## Bare Metal Environments
In a bare metal environment there will be no high level OS running and hosting our code.
This means there will be no primitives, which means there's also no standard library by default.
By marking our code with `no_std` we indicate that our code is capable of running in such an environment.
This means the rust [libstd](https://doc.rust-lang.org/std/) and dynamic memory allocation can't be used by such code.
However, such code can use [libcore](https://doc.rust-lang.org/core/), which can easily be made available
in any kind of environment by providing just a few symbols (for details see [libcore](https://doc.rust-lang.org/core/)).

### The libstd Runtime
As mentioned before using [libstd](https://doc.rust-lang.org/std/) requires some sort of system integration, but this is not only because
[libstd](https://doc.rust-lang.org/std/) is just providing a common way of accessing OS abstractions, it also provides a runtime.
This runtime, among other things, takes care of setting up stack overflow protection, processing command line arguments,
and spawning the main thread before a program's main function is invoked. This runtime also won't be available in a `no_std` environment.

## Summary
`#![no_std]` is a crate-level attribute that indicates that the crate will link to the core-crate instead of the std-crate.
The [libcore](https://doc.rust-lang.org/core/) crate in turn is a platform-agnostic subset of the std crate, that makes no assumptions about the system the program will run on.
As such, it provides APIs for language primitives like floats, strings and slices, as well as APIs that expose processor features
like atomic operations and SIMD instructions. However it lacks APIs for anything that involves platform integration.
Because of these properties no\_std and [libcore](https://doc.rust-lang.org/core/) code can be used for any kind of bootstrapping (stage 0) code like bootloaders, firmware or kernels.

### Overview

| feature                                                   | no\_std | std |
|-----------------------------------------------------------|--------|-----|
| heap (dynamic memory)                                     |   ✘    |  ✓  |
| stack overflow protection                                 |   ✘    |  ✓  |
| runs init code before main                                |   ✘    |  ✓  |
| libstd available                                          |   ✘    |  ✓  |
| libcore available                                         |   ✓    |  ✓  |
| writing firmware, kernel, or bootloader code              |   ✓    |  ✘  |

## See also
* [FAQ](https://www.rust-lang.org/en-US/faq.html#does-rust-work-without-the-standard-library)
* [RFC-1184](https://github.com/rust-lang/rfcs/blob/master/text/1184-stabilize-no_std.md)
