# 互用性

Rust和C代码间的互用性始终取决于两种语言间的数据转换。为了实现互操性，在`stdlib`中，有两个专用模块，叫做[`std::ffi`](https://doc.rust-lang.org/std/ffi/index.html)和[`std::os::raw`](https://doc.rust-lang.org/std/os/raw/index.html) 。

`std::os::raw`处理底层的基本类型，这些类型可以被编译器隐式地转换，因为Rust和C之间的内存布局足够相似或相同。

`std::ffi`提供了一些工具去转换更复杂的类型，比如Strings，将`&str`和`String`映射成更容易和安全处理的C类型。

这两个模块在`core`中都没有，但是你可以在[`cstr_core`] crate中找到一个`std::ffi::{CStr,CString}` 的 `#![no_std]`兼容版本，大多数的`std::os::raw`类型在[`cty`] crate中。

[`cstr_core`]: https://crates.io/crates/cstr_core
[`cty`]: https://crates.io/crates/cty

| Rust 类型  | 中间类型 | C type       |
|------------|--------------|--------------|
| String     | CString      | *char        |
| &str       | CStr         | *const char  |
| ()         | c_void       | void         |
| u32 or u64 | c_uint       | unsigned int |
| etc        | ...          | ...          |

像上面提到的基本类型都能被编译器隐式地转换。

```rust,ignore
unsafe fn foo(num: u32) {
    let c_num: c_uint = num;
    let r_num: u32 = c_num;
}
```

## 与其它编译系统的互用性

在嵌入式项目中引入Rust的一个常见需求是，把Cargo结合进你现存的编译系统中，比如make或者cmake。

在[issue #61]的issue tracker上，我们正在为这个需求收集例子和用例。

[issue #61]: https://github.com/rust-embedded/book/issues/61


## 与RTOSs的互用性

将Rust和一个RTOS集成在一起，比如FreeRTOS或者ChibiOS仍然在进行中; 尤其是从Rust调用RTOS函数可能很棘手。

在[issue #62]的issue tracker上，我们正为这件事收集例子和用例。

[issue #62]: https://github.com/rust-embedded/book/issues/62
