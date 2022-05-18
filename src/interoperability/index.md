# 互用性

Rust和C代码间的互用性始终取决于两种语言间的数据转换。为了实现它，在`stdlib`中，有两个专用模块，叫做[`std::ffi`](https://doc.rust-lang.org/std/ffi/index.html)和[`std::os::raw`](https://doc.rust-lang.org/std/os/raw/index.html) 。

`std::os::raw`处理底层基本类型，这些类型可以被编译器隐式地转换，因为Rust和C之间的内存布局足够相似或相同。

`std::ffi`提供了一些工具去转换更复杂的类型，比如Strings，将`&str`和`String`映射成更容易和安全处理的C类型。

这两个模块在`core`中都不可用，但是你可以找到一个
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
