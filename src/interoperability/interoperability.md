# Interoperability

Iteroperability between Rust and C code is always dependant 
on transforming data between the two languages.
For this purposes there are two dedicated modules 
in the `stdlib` called `std::ffi` and `std::raw`.

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

Primitive types can simply be cast to Rust types.

```rust
unsafe fn foo(num: u32) {
    let c_num: c_uint = num;
    let r_num: u32 = c_num;
}
```