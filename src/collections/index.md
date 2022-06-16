# 集合

最终，你将希望在你的程序里使用动态数据结构(也称为集合)。`std` 提供了一组常见的集合: [`Vec`]，[`String`]，[`HashMap`]，等等。所有这些在`std`中被实现的集合都使用一个全局动态分配器(也称为堆)。
 
[`Vec`]: https://doc.rust-lang.org/std/vec/struct.Vec.html
[`String`]: https://doc.rust-lang.org/std/string/struct.String.html
[`HashMap`]: https://doc.rust-lang.org/std/collections/struct.HashMap.html

因为`core`的定义是没有内存分配的，所以这些实现在`core`中是没有的，但是我们可以在编译器附带的`alloc` crate中找到。

如果你需要集合，一个堆分配的实现不是你唯一的选择。你也可以使用 *fixed capacity* 集合; 一个这样的实现可以在 [`heapless`] crate中被找到。

[`heapless`]: https://crates.io/crates/heapless

在这部分，我们将研究和比较这两个实现。

## 使用 `alloc`

`alloc` crate与标准的Rust发行版在一起。为了导入这个crate，你可以直接 `use` 它而不需要在你的`Cargo.toml`文件中把它声明为一个依赖。

``` rust,ignore
#![feature(alloc)]

extern crate alloc;

use alloc::vec::Vec;
```

为了能使用集合，你首先需要使用`global_allocator`属性去声明你程序将使用的全局的分配器。它要求你选择的分配器实现了[`GlobalAlloc`] trait 。

[`GlobalAlloc`]: https://doc.rust-lang.org/core/alloc/trait.GlobalAlloc.html

为了完整性和尽可能保持本节的自包含性，我们将实现一个简单线性指针分配器且用它作为全局分配器。然而，我们 *强烈地* 建议你在你的程序中使用一个来自crates.io的久经战斗测试的分配器而不是这个分配器。

``` rust,ignore
// 线性指针分配器实现

extern crate cortex_m;

use core::alloc::GlobalAlloc;
use core::ptr;

use cortex_m::interrupt;

// 用于单核系统的线性指针分配器
struct BumpPointerAlloc {
    head: UnsafeCell<usize>,
    end: usize,
}

unsafe impl Sync for BumpPointerAlloc {}

unsafe impl GlobalAlloc for BumpPointerAlloc {
    unsafe fn alloc(&self, layout: Layout) -> *mut u8 {
        // `interrupt::free`是一个临界区，临界区让我们的分配器在中断中用起来安全
        interrupt::free(|_| {
            let head = self.head.get();
            let size = layout.size();
            let align = layout.align();
            let align_mask = !(align - 1);

            // 将start移至下一个对齐边界。
            let start = (*head + align - 1) & align_mask;

            if start + size > self.end {
                // 一个空指针通知内存不足
                ptr::null_mut()
            } else {
                *head = start + size;
                start as *mut u8
            }
        })
    }

    unsafe fn dealloc(&self, _: *mut u8, _: Layout) {
        // 这个分配器从不释放内存
    }
}

// 全局内存分配器的声明
// 注意 用户必须确保`[0x2000_0100, 0x2000_0200]`内存区域
// 没有被程序的其它部分使用
#[global_allocator]
static HEAP: BumpPointerAlloc = BumpPointerAlloc {
    head: UnsafeCell::new(0x2000_0100),
    end: 0x2000_0200,
};
```

除了选择一个全局分配器，用户也将必须定义如何使用*不稳定的*`alloc_error_handler`属性来处理内存溢出错误。

``` rust,ignore
#![feature(alloc_error_handler)]

use cortex_m::asm;

#[alloc_error_handler]
fn on_oom(_layout: Layout) -> ! {
    asm::bkpt();

    loop {}
}
```

一旦一切都满足了，用户最终可以在`alloc`中使用集合。

```rust,ignore
#[entry]
fn main() -> ! {
    let mut xs = Vec::new();

    xs.push(42);
    assert!(xs.pop(), Some(42));

    loop {
        // ..
    }
}
```

如果你已经使用了`std` crate中的集合，那么这些对你来说将非常熟悉，因为他们的实现一样。

## 使用 `heapless`

`heapless`无需设置因为它的集合不依赖一个全局内存分配器。只是`use`它的集合然后实例化它们:

```rust,ignore
extern crate heapless; // v0.4.x

use heapless::Vec;
use heapless::consts::*;

#[entry]
fn main() -> ! {
    let mut xs: Vec<_, U8> = Vec::new();

    xs.push(42).unwrap();
    assert_eq!(xs.pop(), Some(42));
}
```

你会注意到这些集合与`alloc`中的集合有两个不一样的地方。

第一，你必须预先声明集合的容量。`heapless`集合从来不会发生重分配且具有固定的容量;这个容量是集合的类型签名的一部分。在这个例子里，我们已经声明了`xs`的容量为8个元素，也就是说，这个vector最多只能有八个元素。这是通过类型签名中的`U8` (看[`typenum`])来指定的。

[`typenum`]: https://crates.io/crates/typenum

第二，`push`方法和许多其它方法返回的是一个`Result`。因为`heapless`集合有一个固定的容量，所以所有插入的操作可能会失败。通过返回一个`Result`，API反应了这个问题，指出操作是否成功还是失败。相反，`alloc`集合自己将会在堆上重新分配去增加它的容量。

自v0.4.x版本起，所有的`heapless`集合将它们所有的元素内联地存储起来了。这意味着像是`let x = heapless::Vec::new()`这样的一个操作将会在栈上分配集合，但是它也能够在一个`static`变量上分配集合，或者甚至在堆上(`Box<Vec<_, _>>`)。

## 取舍

当在堆分配的可重定位的集合和固定容量的集合间进行选择的时候，记住这些内容。

### 内存溢出和错误处理

使用堆分配，内存溢出总是有可能出现的且会发生在任何一个集合需要增长的地方: 比如，所有的 `alloc::Vec.push` 调用会潜在地产生一个OOM(Out of Memory)条件。因此一些操作可能会*隐式地*失败。一些`alloc`集合暴露了`try_reserve`方法，可以当增加集合时让你检查潜在的OOM条件，但是你需要主动地使用它们。

如果你排他地使用`heapless`集合且不为其它任何东西使用一个内存分配器，那么一个OOM条件不可能出现。相反，


If you exclusively use `heapless` collections and you don't use a memory
allocator for anything else then an OOM condition is impossible. Instead, you'll
have to deal with collections running out of capacity on a case by case basis.
That is you'll have deal with *all* the `Result`s returned by methods like
`Vec.push`.

OOM failures can be harder to debug than say `unwrap`-ing on all `Result`s
returned by `heapless::Vec.push` because the observed location of failure may
*not* match with the location of the cause of the problem. For example, even
`vec.reserve(1)` can trigger an OOM if the allocator is nearly exhausted because
some other collection was leaking memory (memory leaks are possible in safe
Rust).

### Memory usage

Reasoning about memory usage of heap allocated collections is hard because the
capacity of long lived collections can change at runtime. Some operations may
implicitly reallocate the collection increasing its memory usage, and some
collections expose methods like `shrink_to_fit` that can potentially reduce the
memory used by the collection -- ultimately, it's up to the allocator to decide
whether to actually shrink the memory allocation or not. Additionally, the
allocator may have to deal with memory fragmentation which can increase the
*apparent* memory usage.

On the other hand if you exclusively use fixed capacity collections, store
most of them in `static` variables and set a maximum size for the call stack
then the linker will detect if you try to use more memory than what's physically
available.

Furthermore, fixed capacity collections allocated on the stack will be reported
by [`-Z emit-stack-sizes`] flag which means that tools that analyze stack usage
(like [`stack-sizes`]) will include them in their analysis.

[`-Z emit-stack-sizes`]: https://doc.rust-lang.org/beta/unstable-book/compiler-flags/emit-stack-sizes.html
[`stack-sizes`]: https://crates.io/crates/stack-sizes

However, fixed capacity collections can *not* be shrunk which can result in
lower load factors (the ratio between the size of the collection and its
capacity) than what relocatable collections can achieve.

### Worst Case Execution Time (WCET)

If you are building time sensitive applications or hard real time applications
then you care, maybe a lot, about the worst case execution time of the different
parts of your program.

The `alloc` collections can reallocate so the WCET of operations that may grow
the collection will also include the time it takes to reallocate the collection,
which itself depends on the *runtime* capacity of the collection. This makes it
hard to determine the WCET of, for example, the `alloc::Vec.push` operation as
it depends on both the allocator being used and its runtime capacity.

On the other hand fixed capacity collections never reallocate so all operations
have a predictable execution time. For example, `heapless::Vec.push` executes in
constant time.

### 易用性

`alloc`要求配置一个全局分配器而`heapless`不需要。然而，`heapless`要求你去选择你要实例化的每一个集合的容量。

`alloc` API几乎为每一个Rust开发者所熟知。`heapless` API尝试模仿`alloc` API，但是因为`heapless`的显式错误处理，它们不可能会一模一样 -- 一些开发者可能会觉得显式的错误处理过多或太麻烦。
