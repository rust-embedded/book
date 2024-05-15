# 互操性

Rust和C代码之间的互操性始终依赖于数据在两个语言间的转换．为了互操性，在`stdlib`中有一个专用的模块，叫作
[`std::ffi`](https://doc.rust-lang.org/std/ffi/index.html).

`std::ffi`提供了与C基础类型对应的类型定义，比如`char`， `int`，和`long`．
它也提供了一些工具用于更复杂的类型之间的转换，比如字符串，可以把`&str`和`String`映射成更容易和安全处理的C类型．

从Rust 1.30以来，`std::ffi`的功能也出现在`core::ffi`或者`alloc::ffi`中，取决于是否涉及到内存分配．
[`cty`]库和[`cstr_core`]库也提供了相同的功能．

[`cstr_core`]: https://crates.io/crates/cstr_core
[`cty`]: https://crates.io/crates/cty

| Rust类型      | 间接 | C类型        |
|----------------|--------------|----------------|
| `String`       | `CString`    | `char *`       |
| `&str`         | `CStr`       | `const char *` |
| `()`           | `c_void`     | `void`         |
| `u32` or `u64` | `c_uint`     | `unsigned int` |
| etc            | ...          | ...            |

一个C基本类型的值可以被用来作为相关的Rust类型的值，反之亦然，因此前者仅仅是后者的一个类型伪名．
比如，下列的代码可以在`unsigned int`是32位宽的平台上编译．

```rust,ignore
fn foo(num: u32) {
    let c_num: c_uint = num;
    let r_num: u32 = c_num;
}
```

## 与其它编译系统的互用性

在嵌入式项目中引入Rust的一个常见需求是，把Cargo结合进你现存的编译系统中，比如make或者cmake。

在[issue #61]的issue tracker上，我们正在为这个需求收集例子和用例。

[issue #61]: https://github.com/rust-embedded/book/issues/61


## 与RTOSs的互操性

将Rust和一个RTOS集成在一起，比如FreeRTOS或者ChibiOS仍然在进行中; 尤其是从Rust调用RTOS函数可能很棘手。

在[issue #62]的issue tracker上，我们正为这件事收集例子和用例。

[issue #62]: https://github.com/rust-embedded/book/issues/62
