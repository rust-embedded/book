# Interoperability

Interoperability between Rust and C code is always dependent
on transforming data between the two languages.
For this purposes there are two dedicated modules
in the `stdlib` called
[`std::ffi`](https://doc.rust-lang.org/std/ffi/index.html) and
[`std::os::raw`](https://doc.rust-lang.org/std/os/raw/index.html).

`std::os::raw` deals with low-level primitive types that can
be converted implicitly by the compiler
because the memory layout between Rust and C
is similar enough or the same.

`std::ffi` provides some utility for converting more complex
types such as Strings, mapping both `&str` and `String`
to C-types that are easier and safer to handle.

Neither of these modules are available in `core`, but you can find a `#![no_std]`
compatible version of `std::ffi::{CStr,CString}` in the [`cstr_core`] crate, and
most of the `std::os::raw` types in the [`cty`] crate.

[`cstr_core`]: https://crates.io/crates/cstr_core
[`cty`]: https://crates.io/crates/cty

| Rust type  | Intermediate | C type       |
|------------|--------------|--------------|
| String     | CString      | *char        |
| &str       | CStr         | *const char  |
| ()         | c_void       | void         |
| u32 or u64 | c_uint       | unsigned int |
| etc        | ...          | ...          |

As mentioned above, primitive types can be converted
by the compiler implicitly.

```rust,ignore
unsafe fn foo(num: u32) {
    let c_num: c_uint = num;
    let r_num: u32 = c_num;
}
```

## Interoperability with other build systems

A common requirement for including Rust in your embedded project is combining
Cargo with your existing build system, such as make or cmake.

We are collecting examples and use cases for this on our issue tracker in
[issue #61].

[issue #61]: https://github.com/rust-embedded/book/issues/61


## Interoperability with RTOSs

Integrating Rust with an RTOS such as FreeRTOS or ChibiOS is still a work in
progress; especially calling RTOS functions from Rust can be tricky.

We are collecting examples and use cases for this on our issue tracker in
[issue #62].

[issue #62]: https://github.com/rust-embedded/book/issues/62
