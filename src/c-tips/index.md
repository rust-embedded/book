# 给嵌入式C开发者的贴士

这个章节收集了可能对于刚开始编写Rust的，有经验的嵌入式C开发者来说，有用的各种各样的贴士。它将解释你在C中可能已经用到的那些东西与Rust中的有何不同。

## 预处理器

在嵌入式C中，为了各种各样的目的使用预处理器是很常见的，比如:

* 使用`#ifdef`编译时选择代码块
* 编译时的数组大小和计算
* 用来简化常见的模式的宏(避免调用函数的开销)

在Rust中没有预处理器，所以许多案例有不同的处理方法。本章节剩下的部分，我们将介绍各种替代预处理器的方法。

### 编译时的代码选择

Rust中最接近`#ifdef ... #endif`的是[Cargo features]。这些比C预处理器更正式一点: 每个crate显式列举的，所有可能的features只能是关了的或者打开了的。当你把一个crate列为依赖项时，Features被打开，且是可添加的：如果你依赖树中的任何crate为另一个crate打开了一个feature，那么这个feature将为所有使用那个crate的用户而打开。

[Cargo features]: https://doc.rust-lang.org/cargo/reference/manifest.html#the-features-section

比如，你可能有一个crate，其提供一个信号处理的基本类型库(library of signal processing primitives)。每个基本类型可能带来一些额外的时间去编译大量的常量，你想要避开这些常量。你可以为你的`Cargo.toml`中每个组件声明一个Cargo feature。

```toml
[features]
FIR = []
IIR = []
```

然后，在你的代码中，使用`#[cfg(feature="FIR")]`去控制要包含什么东西。

```rust
/// 在你的顶层的lib.rs中
#[cfg(feature="FIR")]
pub mod fir;

#[cfg(feature="IIR")]
pub mod iir;
```

同样地，你可以控制，只有当某个feature _没有_ 被打开时，包含代码块，或者某些features的组合被打开或者被关闭时。 

另外，Rust提供了许多可以使用的自动配置了的条件，比如`target_arch`用来选择不同的代码所基于的架构。对于条件编译的全部细节，可以参看the Rust reference的[conditional compilation]章节。

[conditional compilation]: https://doc.rust-lang.org/reference/conditional-compilation.html

条件编译将只应用于下一条语句或者块。如果一个块不能在现在的作用域中被使用，那么`cfg`属性将需要被多次使用。值得注意的是大多数时间，仅是包含所有的代码而让编译器在优化时去删除死代码(dead code)更好，通常，在移除不使用的代码方面的工作，编译器做得很好。

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

Rust提供一个极度强大的[宏系统]。虽然C预处理器几乎直接在你的源代码之上进行操作，但是Rust宏系统可以在一个更高的级别上操作。存在两种Rust宏: _声明宏_ 和 _过程宏_ 。前者更简单也最常见; 它们看起来像是函数调用，且能扩展成一个完整的表达式，语句，项，或者模式。过程宏更复杂但是却能让Rust更强大: 它们可以把任一条Rust语法变成一个新的Rust语法。

[宏系统]: https://doc.rust-lang.org/book/ch19-06-macros.html

通常，你可能想知道在那些使用一个C预处理器宏的地方，能否使用一个声明宏做同样的工作。你可以在crate中定义它们，且在你的crate中轻松使用它们或者导出给其他人用。但是请注意，因为它们必须扩展成完整的表达式，语句，项或者模式，因此C预处理器宏的某些用例没法用，比如可以扩展成一个变量名的一部分的宏或者可以把列表中的项扩展成不完整的集合的宏。

和Cargo features一样，值得考虑下你是否真的需要宏。在一些例子中一个常规的函数更容易被理解，它也能被内联成和一个和宏一样的代码。`#[inline]`和`#[inline(always)]` [attributes] 能让你更深入控制这个过程，这里也要小心 - 编译器会从同一个crate的恰当的地方自动地内联函数，因此不恰当地强迫它内联函数实际可能会导致性能下降。

[attributes]: https://doc.rust-lang.org/reference/attributes.html#inline-attribute

研究完整的Rust宏系统超出了本节内容，因此我们鼓励你去查阅Rust文档了解完整的细节。

## 编译系统

大多数Rust crates使用Cargo编译 (即使这不是必须的)。这解决了传统编译系统带来的许多难题。然而，你可能希望自定义编译过程。为了实现这个目的，Cargo提供了[`build.rs`脚本]。它们是可以根据需要与Cargo编译系统进行交互的Rust脚本。

[`build.rs`脚本]: https://doc.rust-lang.org/cargo/reference/build-scripts.html

与编译脚本有关的常见用例包括:

* 提供编译时信息，比如静态嵌入编译日期或者Git commit hash进你的可执行文件中
* 根据被选择的features或者其它逻辑在编译时生成链接脚本
* 改变Cargo的编译配置
* 添加额外的静态链接库以进行链接

现在还不支持post-build脚本，通常将它用于像是从编译的对象自动生生成二进制文件或者打印编译信息这类任务中。

### 交叉编译

为你的编译系统使用Cargo也能简化交叉编译。在大多数例子里，告诉Cargo `--target thumbv6m-none-eabi`就行了，可以在`target/thumbv6m-none-eabi/debug/myapp`中找到一个合适的可执行文件。

对于那些并不是Rust原生支持的平台，将需要自己为那个目标平台编译`libcore`。遇到这样的平台，[Xargo]可以作为Cargo的替代来使用，它可以自动地为你编译`libcore`。

[Xargo]: https://github.com/japaric/xargo

## 迭代器与数组访问

在C中，你可能习惯于通过索引直接访问数组:

```c
int16_t arr[16];
int i;
for(i=0; i<sizeof(arr)/sizeof(arr[0]); i++) {
    process(arr[i]);
}
```

在Rust中，这是一个反模式(anti-pattern)：索引访问可能会更慢(因为它可能需要做边界检查)且可能会阻止编译器的各种优化。这是一个重要的区别，值得再重复一遍: Rust会在手动的数组索引上进行越界检查以保障内存安全性，而C允许索引数组外的内容。

可以使用迭代器来替代:

```rust,ignore
let arr = [0u16; 16];
for element in arr.iter() {
    process(*element);
}
```

迭代器提供了一个有强大功能的数组，在C中你不得不手动实现它，比如chaining，zipping，enumerating，找到最小或最大值，summing，等等。迭代器方法也能被链式调用，提供了可读性非常高的数据处理代码。

阅读[Iterators in the Book]和[Iterator documentation]获取更多细节。

[Iterators in the Book]: https://doc.rust-lang.org/book/ch13-02-iterators.html
[Iterator documentation]: https://doc.rust-lang.org/core/iter/trait.Iterator.html

## 引用和指针

在Rust中，存在指针(被叫做 [_裸指针_])但是只能在特殊的环境中被使用，因为解引用裸指针总是被认为是`unsafe`的 -- Rust通常不能保障指针背后有什么。

[_裸指针_]: https://doc.rust-lang.org/book/ch19-01-unsafe-rust.html#dereferencing-a-raw-pointer

在大多数例子里，我们使用 _引用_ 来替代，由`&`符号指出，或者 _可变引用_，由`&mut`指出。引用与指针相似，因为它能被解引用来访问底层的数据，但是它们是Rust的所有权系统的一个关键部分: Rust将严格强迫你在任何给定时间只有一个可变引用 _或者_ 对相同数据的多个不变引用。

在实践中，这意味着你必须要更加小心你是否需要对数据的可变访问：在C中默认是可变的，你必须显式地使用`const`，在Rust中正好相反。

某个情况下，你可能仍然要使用裸指针直接与硬件进行交互(比如，写入一个指向DMA外设寄存器中的缓存的指针)，它们也被所有的外设访问crates在底层使用，让你可以读取和写入存储映射寄存器。

## Volatile访问

在C中，某个变量可能被标记成`volatile`，向编译器指出，变量中的值在访问间可能改变。Volatile变量通常用于一个与存储映射的寄存器有关的嵌入式上下文中。

在Rsut中，并不使用`volatile`标记变量，我们使用特定的方法去执行volatile访问: [`core::ptr::read_volatile`] 和 [`core::ptr::write_volatile`]。这些方法使用一个 `*const T` 或者一个 `*mut T` (上面说的 _裸指针_ )，执行一个volatile读取或者写入。

[`core::ptr::read_volatile`]: https://doc.rust-lang.org/core/ptr/fn.read_volatile.html
[`core::ptr::write_volatile`]: https://doc.rust-lang.org/core/ptr/fn.write_volatile.html

比如，在C中你可能这样写:

```c
volatile bool signalled = false;

void ISR() {
    // 提醒中断已经发生了
    signalled = true;
}

void driver() {
    while(true) {
        // 睡眠直到信号来了
        while(!signalled) { WFI(); }
        // 重置信号提示符
        signalled = false;
        // 执行一些正在等待这个中断的任务
        run_task();
    }
}
```

在Rust中对每个访问使用volatile方法能达到相同的效果:

```rust,ignore
static mut SIGNALLED: bool = false;

#[interrupt]
fn ISR() {
    // 提醒中断已经发生
    // (在正在的代码中，你应该考虑一个更高级的基本类型,
    // 比如一个原子类型)
    unsafe { core::ptr::write_volatile(&mut SIGNALLED, true) };
}

fn driver() {
    loop {
        // 睡眠直到信号来了
        while unsafe { !core::ptr::read_volatile(&SIGNALLED) } {}
        // 重置信号指示符
        unsafe { core::ptr::write_volatile(&mut SIGNALLED, false) };
        // 执行一些正在等待中断的任务
        run_task();
    }
}
```

在示例代码中有些事情值得注意:
  * 我们可以把`&mut SIGNALLED`传递给要求`*mut T`的函数中，因为`&mut T`会自动转换成一个`*mut T` (对于`*const T`来说是一样的)
  * 我们需要为`read_volatile`/`write_volatile`方法使用`unsafe`块，因为它们是`unsafe`的函数。确保操作安全变成了程序员的责任：看方法的文档获得更多细节。

在你的代码中直接使用这些函数是很少见的，因为它们通常由更高级的库封装起来为你提供服务。对于存储映射的外设，提供外设访问的crates将自动实现volatile访问，而对于并发的基本类型，存在更好的抽象可用。(看[并发章节])

[并发章节]: ../concurrency/index.md

## 填充和对齐类型

在嵌入式C中，告诉编译器一个变量必须遵守某个对齐或者一个结构体必须被填充而不是对齐，是很常见的行为，通常是为了满足特定的硬件或者协议要求。

在Rust中，这由一个结构体或者联合体上的`repr`属性来控制。默认的表示(representation)不保障布局，因此不应该被用于与硬件或者C互用的代码。编译器可能会对结构体成员重新排序或者插入填充，且这种行为可能在未来的Rust版本中改变。

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
// 注意为了改进填充，顺序已经被变成了x, z, y
```

使用`repr(C)`可以确保布局可以与C互用。

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
// 顺序被保留了，布局将不会随着时间而改变
// `z`是两个字节对齐，因此在`y`和`z`之间填充了一个字节。
```

使用`repr(packed)`去确保表示(representation)被填充了:

```rust
#[repr(packed)]
struct Foo {
    x: u16,
    y: u8,
    z: u16,
}

fn main() {
    let v = Foo { x: 0, y: 0, z: 0 };
    // 引用必须总是对齐的，因此为了检查结构体字段的地址，我们使用
    // `std::ptr::addr_of!()`去获取一个裸指针而不仅是打印`&v.x`
    let px = std::ptr::addr_of!(v.x);
    let py = std::ptr::addr_of!(v.y);
    let pz = std::ptr::addr_of!(v.z);
    println!("{:p} {:p} {:p}", px, py, pz);
}

// 0x7ffd33598490 0x7ffd33598492 0x7ffd33598493
// 在`y`和`z`没有填充被插入，因此现在`z`没有被对齐。
```

注意使用`repr(packed)`也会将类型的对齐设置成`1` 。

最后，为了指定一个特定的对齐，可以使用`repr(align(n))`，`n`是要对齐的字节数(必须是2的幂):

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
// `u`和`v`两个实例已经被放置在4096字节的对齐上。
// 它们地址结尾处的`000`证明了这件事。
```

注意我们可以结合`repr(C)`和`repr(align(n))`来获取一个对齐的c兼容的布局。不允许将`repr(align(n))`和`repr(packed)`一起使用，因为`repr(packed)`将对齐设置为`1`。也不允许一个`repr(packed)`类型包含一个`repr(align(n))`类型。

关于类型布局更多的细节，参考the Rust Reference的[type layout]章节。

[type layout]: https://doc.rust-lang.org/reference/type-layout.html

## 其它资源

* 这本书中:
    * [使用C的Rust](../interoperability/c-with-rust.md)
    * [使用Rust的C](../interoperability/rust-with-c.md)
* [The Rust Embedded FAQs](https://docs.rust-embedded.org/faq.html)
* [Rust Pointers for C Programmers](http://blahg.josefsipek.net/?p=580)
* [I used to use pointers - now what?](https://github.com/diwic/reffers-rs/blob/master/docs/Pointers.md)
