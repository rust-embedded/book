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

For `#![no_std]` environments, there is also `core::raw` that
covers all the primitive types.

------------------------------------------
| Rust type | Intermediate | C type       |
|-----------|--------------|--------------|
| String    | CString      | *char        |
| &str      | CStr         | *const char  |
| ()        | c_void       | void         |
| u32 | u64 | c_uint       | unsigned int |
| etc       | ...          | ...          |

As mentioned above, primitive types can be converted
by the compiler implicitly.

```rust
unsafe fn foo(num: u32) {
    let c_num: c_uint = num;
    let r_num: u32 = c_num;
}
```