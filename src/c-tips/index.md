# 给嵌入式C开发者的贴士

这个章节收集了可能对于正在寻求开始编写Rust有经验的嵌入式C开发者有用的各种各样的贴士。它将解释你在C中可能已经用到的那些东西与Rust中有多不同。

## 预处理器

在嵌入式C中，为了各种各样的目的使用预处理器是很常见的，比如:

* 使用`#ifdef`编译时选择代码块
* 编译时的数组大小和计算
* 用来简化常见模式的宏(避免函数调用的开销)

在Rust中没有预处理器，所以许多用例有不同的处理方法。本章节剩下的部分，我们将介绍使用预处理器的各种替代方法。

### 编译时的代码选择

Rust中最接近`#ifdef ... #endif`的是[Cargo features]。这些比C预处理器更正式一点: 每个crate显式列举的所有可能的features只能是关了的或者打开了的。当你把一个crate列为依赖项时，Features被打开，且是可添加的: 如果你依赖树中的任何crate为另一个crate打开了一个feature，那么这个feature将为所有那个crate的用户而打开。

[Cargo features]: https://doc.rust-lang.org/cargo/reference/manifest.html#the-features-section

比如，你可能有一个crate，其提供一个信号处理的原语库(library of signal processing primitives)。每个原语可能带来一些额外的时间去编译大量的常量，你想要躲开这些常量。你可以为你的`Cargo.toml`中每个组件声明一个Cargo feature。

```toml
[features]
FIR = []
IIR = []
```

然后，在你的代码中，使用`#[cfg(feature="FIR")]`去控制什么东西应该被包含。

```rust
/// 在你的顶层的lib.rs中
#[cfg(feature="FIR")]
pub mod fir;

#[cfg(feature="IIR")]
pub mod iir;
```

同样地，你可以控制，只有当某个feature _没有_ 被打开时，包含代码块，或者某些features的组合被打开或者被关闭时。 

另外，Rust提供许多你可以使用的自动配置了的条件，比如`target_arch`用来选择不同的代码所基于的架构。对于条件编译的全部细节，可以参看the Rust reference的[conditional compilation]章节。

[conditional compilation]: https://doc.rust-lang.org/reference/conditional-compilation.html

条件编译将只应用于下一条语句或者块。如果一个块不能在现在的作用域中被使用，那么`cfg`属性将需要被多次使用。值得注意的是大多数时间，仅是包含所有的代码，让编译器在优化时去删除死代码(dead code)更好，通常，在移除不使用的代码方面的工作，编译器做得很好。

### Compile-Time Sizes and Computation
### 编译时大小和计算

Rust支持`const fn`，`const fn`是在编译时可以被计算的函数，因此可以被用在需要常量的地方，比如在数组的大小中。这个能与上述的features一起使用，比如:

```rust
const fn array_size() -> usize {
    #[cfg(feature="use_more_ram")]
    { 1024 }
    #[cfg(not(feature="use_more_ram"))]
    { 128 }
}

static BUF: [u32; array_size()] = [0u32; array_size()];
```

这些对于stable版本的Rust来说是新的特性，从1.31开始引入，因此文档依然很少。在写这篇文章的时候`const fn`可用的功能也非常有限; 在未来的Rust release版本中，我们可以期望`const fn`将带来更多的功能。

### 宏

Rust提供一个极度强大的[宏系统]。虽然C预处理器几乎直接在你的源代码之上进行操作，但是Rust宏系统可以在一个更高的级别上操作。存在两种C宏: _声明宏_ 和 _过程宏_ 。前者更简单也最常见; 它们看起来像是函数调用，且能扩展成一个完整的表达式，语句，项目，或者模式。过程宏更复杂但是却能让Rust更强大: 它们可以把任一条Rust语法变成一个新的Rust语法。

[宏系统]: https://doc.rust-lang.org/book/ch19-06-macros.html

通常，你可能想知道在那些你可能使用一个C预处理器宏的地方，能否使用一个声明宏做同样的工作。你能在你的crate中定义它们，且在你的crate中轻松使用它们或者导出给其他人用。但是请注意，因为它们必须扩展成完整的表达式，语句，项或者模式，因此C预处理器的某些用例将无法工作，比如扩展成一个变量名的一部分或者一个列表中不完整的项目集。

和Cargo features一样，值得考虑下你是否真的需要宏。在一些例子中一个常规的函数更容易去理解且将被内联成和一个宏一样的代码。`#[inline]`和`#[inline(always)]` [attributes] 能让你更深入控制这个过程，虽然这里也要小心 - 

As with Cargo features, it is worth considering if you even need the macro. In
many cases a regular function is easier to understand and will be inlined to
the same code as a macro. The `#[inline]` and `#[inline(always)]` [attributes]
give you further control over this process, although care should be taken here
as well — the compiler will automatically inline functions from the same crate
where appropriate, so forcing it to do so inappropriately might actually lead
to decreased performance.

[attributes]: https://doc.rust-lang.org/reference/attributes.html#inline-attribute

研究完整的Rust宏系统超出了本节内容，因此我们鼓励你去查阅Rust文档了解完整的细节。

## 编译系统

Most Rust crates are built using Cargo (although it is not required). This
takes care of many difficult problems with traditional build systems. However,
you may wish to customise the build process. Cargo provides [`build.rs`
scripts] for this purpose. They are Rust scripts which can interact with the
Cargo build system as required.

[`build.rs` scripts]: https://doc.rust-lang.org/cargo/reference/build-scripts.html

Common use cases for build scripts include:

* provide build-time information, for example statically embedding the build
  date or Git commit hash into your executable
* generate linker scripts at build time depending on selected features or other
  logic
* change the Cargo build configuration
* add extra static libraries to link against

At present there is no support for post-build scripts, which you might
traditionally have used for tasks like automatic generation of binaries from
the build objects or printing build information.

### Cross-Compiling

Using Cargo for your build system also simplifies cross-compiling. In most
cases it suffices to tell Cargo `--target thumbv6m-none-eabi` and find a
suitable executable in `target/thumbv6m-none-eabi/debug/myapp`.

For platforms not natively supported by Rust, you will need to build `libcore`
for that target yourself. On such platforms, [Xargo] can be used as a stand-in
for Cargo which automatically builds `libcore` for you.

[Xargo]: https://github.com/japaric/xargo

## Iterators vs Array Access

In C you are probably used to accessing arrays directly by their index:

```c
int16_t arr[16];
int i;
for(i=0; i<sizeof(arr)/sizeof(arr[0]); i++) {
    process(arr[i]);
}
```

In Rust this is an anti-pattern: indexed access can be slower (as it needs to
be bounds checked) and may prevent various compiler optimisations. This is an
important distinction and worth repeating: Rust will check for out-of-bounds
access on manual array indexing to guarantee memory safety, while C will
happily index outside the array.

Instead, use iterators:

```rust,ignore
let arr = [0u16; 16];
for element in arr.iter() {
    process(*element);
}
```

Iterators provide a powerful array of functionality you would have to implement
manually in C, such as chaining, zipping, enumerating, finding the min or max,
summing, and more. Iterator methods can also be chained, giving very readable
data processing code.

See the [Iterators in the Book] and [Iterator documentation] for more details.

[Iterators in the Book]: https://doc.rust-lang.org/book/ch13-02-iterators.html
[Iterator documentation]: https://doc.rust-lang.org/core/iter/trait.Iterator.html

## References vs Pointers

In Rust, pointers (called [_raw pointers_]) exist but are only used in specific
circumstances, as dereferencing them is always considered `unsafe` -- Rust
cannot provide its usual guarantees about what might be behind the pointer.

[_raw pointers_]: https://doc.rust-lang.org/book/ch19-01-unsafe-rust.html#dereferencing-a-raw-pointer

In most cases, we instead use _references_, indicated by the `&` symbol, or
_mutable references_, indicated by `&mut`. References behave similarly to
pointers, in that they can be dereferenced to access the underlying values, but
they are a key part of Rust's ownership system: Rust will strictly enforce that
you may only have one mutable reference _or_ multiple non-mutable references to
the same value at any given time.

In practice this means you have to be more careful about whether you need
mutable access to data: where in C the default is mutable and you must be
explicit about `const`, in Rust the opposite is true.

One situation where you might still use raw pointers is interacting directly
with hardware (for example, writing a pointer to a buffer into a DMA peripheral
register), and they are also used under the hood for all peripheral access
crates to allow you to read and write memory-mapped registers.

## Volatile Access

In C, individual variables may be marked `volatile`, indicating to the compiler
that the value in the variable may change between accesses. Volatile variables
are commonly used in an embedded context for memory-mapped registers.

In Rust, instead of marking a variable as `volatile`, we use specific methods
to perform volatile access: [`core::ptr::read_volatile`] and
[`core::ptr::write_volatile`]. These methods take a `*const T` or a `*mut T`
(_raw pointers_, as discussed above) and perform a volatile read or write.

[`core::ptr::read_volatile`]: https://doc.rust-lang.org/core/ptr/fn.read_volatile.html
[`core::ptr::write_volatile`]: https://doc.rust-lang.org/core/ptr/fn.write_volatile.html

For example, in C you might write:

```c
volatile bool signalled = false;

void ISR() {
    // Signal that the interrupt has occurred
    signalled = true;
}

void driver() {
    while(true) {
        // Sleep until signalled
        while(!signalled) { WFI(); }
        // Reset signalled indicator
        signalled = false;
        // Perform some task that was waiting for the interrupt
        run_task();
    }
}
```

The equivalent in Rust would use volatile methods on each access:

```rust,ignore
static mut SIGNALLED: bool = false;

#[interrupt]
fn ISR() {
    // Signal that the interrupt has occurred
    // (In real code, you should consider a higher level primitive,
    //  such as an atomic type).
    unsafe { core::ptr::write_volatile(&mut SIGNALLED, true) };
}

fn driver() {
    loop {
        // Sleep until signalled
        while unsafe { !core::ptr::read_volatile(&SIGNALLED) } {}
        // Reset signalled indicator
        unsafe { core::ptr::write_volatile(&mut SIGNALLED, false) };
        // Perform some task that was waiting for the interrupt
        run_task();
    }
}
```

A few things are worth noting in the code sample:
  * We can pass `&mut SIGNALLED` into the function requiring `*mut T`, since
    `&mut T` automatically converts to a `*mut T` (and the same for `*const T`)
  * We need `unsafe` blocks for the `read_volatile`/`write_volatile` methods,
    since they are `unsafe` functions. It is the programmer's responsibility
    to ensure safe use: see the methods' documentation for further details.

It is rare to require these functions directly in your code, as they will
usually be taken care of for you by higher-level libraries. For memory mapped
peripherals, the peripheral access crates will implement volatile access
automatically, while for concurrency primitives there are better abstractions
available (see the [Concurrency chapter]).

[Concurrency chapter]: ../concurrency/index.md

## Packed and Aligned Types

In embedded C it is common to tell the compiler a variable must have a certain
alignment or a struct must be packed rather than aligned, usually to meet
specific hardware or protocol requirements.

In Rust this is controlled by the `repr` attribute on a struct or union. The
default representation provides no guarantees of layout, so should not be used
for code that interoperates with hardware or C. The compiler may re-order
struct members or insert padding and the behaviour may change with future
versions of Rust.

```rust
struct Foo {
    x: u16,
    y: u8,
    z: u16,
}

fn main() {
    let v = Foo { x: 0, y: 0, z: 0 };
    println!("{:p} {:p} {:p}", &v.x, &v.y, &v.z);
}

// 0x7ffecb3511d0 0x7ffecb3511d4 0x7ffecb3511d2
// Note ordering has been changed to x, z, y to improve packing.
```

To ensure layouts that are interoperable with C, use `repr(C)`:

```rust
#[repr(C)]
struct Foo {
    x: u16,
    y: u8,
    z: u16,
}

fn main() {
    let v = Foo { x: 0, y: 0, z: 0 };
    println!("{:p} {:p} {:p}", &v.x, &v.y, &v.z);
}

// 0x7fffd0d84c60 0x7fffd0d84c62 0x7fffd0d84c64
// Ordering is preserved and the layout will not change over time.
// `z` is two-byte aligned so a byte of padding exists between `y` and `z`.
```

To ensure a packed representation, use `repr(packed)`:

```rust
#[repr(packed)]
struct Foo {
    x: u16,
    y: u8,
    z: u16,
}

fn main() {
    let v = Foo { x: 0, y: 0, z: 0 };
    // Unsafe is required to borrow a field of a packed struct.
    unsafe { println!("{:p} {:p} {:p}", &v.x, &v.y, &v.z) };
}

// 0x7ffd33598490 0x7ffd33598492 0x7ffd33598493
// No padding has been inserted between `y` and `z`, so now `z` is unaligned.
```

Note that using `repr(packed)` also sets the alignment of the type to `1`.

Finally, to specify a specific alignment, use `repr(align(n))`, where `n` is
the number of bytes to align to (and must be a power of two):

```rust
#[repr(C)]
#[repr(align(4096))]
struct Foo {
    x: u16,
    y: u8,
    z: u16,
}

fn main() {
    let v = Foo { x: 0, y: 0, z: 0 };
    let u = Foo { x: 0, y: 0, z: 0 };
    println!("{:p} {:p} {:p}", &v.x, &v.y, &v.z);
    println!("{:p} {:p} {:p}", &u.x, &u.y, &u.z);
}

// 0x7ffec909a000 0x7ffec909a002 0x7ffec909a004
// 0x7ffec909b000 0x7ffec909b002 0x7ffec909b004
// The two instances `u` and `v` have been placed on 4096-byte alignments,
// evidenced by the `000` at the end of their addresses.
```

Note we can combine `repr(C)` with `repr(align(n))` to obtain an aligned and
C-compatible layout. It is not permissible to combine `repr(align(n))` with
`repr(packed)`, since `repr(packed)` sets the alignment to `1`. It is also not
permissible for a `repr(packed)` type to contain a `repr(align(n))` type.

For further details on type layouts, refer to the [type layout] chapter of the
Rust Reference.

[type layout]: https://doc.rust-lang.org/reference/type-layout.html

## 其它资源

* 在这本书中:
    * [A little C with your Rust](../interoperability/c-with-rust.md)
    * [A little Rust with your C](../interoperability/rust-with-c.md)
* [The Rust Embedded FAQs](https://docs.rust-embedded.org/faq.html)
* [Rust Pointers for C Programmers](http://blahg.josefsipek.net/?p=580)
* [I used to use pointers - now what?](https://github.com/diwic/reffers-rs/blob/master/docs/Pointers.md)
