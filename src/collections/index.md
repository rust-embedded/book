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

You'll note two differences between these collections and the ones in `alloc`.

First, you have to declare upfront the capacity of the collection. `heapless`
collections never reallocate and have fixed capacities; this capacity is part of
the type signature of the collection. In this case we have declared that `xs`
has a capacity of 8 elements that is the vector can, at most, hold 8 elements.
This is indicated by the `U8` (see [`typenum`]) in the type signature.

[`typenum`]: https://crates.io/crates/typenum

Second, the `push` method, and many other methods, return a `Result`. Since the
`heapless` collections have fixed capacity all operations that insert elements
into the collection can potentially fail. The API reflects this problem by
returning a `Result` indicating whether the operation succeeded or not. In
contrast, `alloc` collections will reallocate themselves on the heap to increase
their capacity.

As of version v0.4.x all `heapless` collections store all their elements inline.
This means that an operation like `let x = heapless::Vec::new();` will allocate
the collection on the stack, but it's also possible to allocate the collection
on a `static` variable, or even on the heap (`Box<Vec<_, _>>`).

## Trade-offs

Keep these in mind when choosing between heap allocated, relocatable collections
and fixed capacity collections.

### Out Of Memory and error handling

With heap allocations Out Of Memory is always a possibility and can occur in
any place where a collection may need to grow: for example, all
`alloc::Vec.push` invocations can potentially generate an OOM condition. Thus
some operations can *implicitly* fail. Some `alloc` collections expose
`try_reserve` methods that let you check for potential OOM conditions when
growing the collection but you need be proactive about using them.

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

### Ease of use

`alloc` requires setting up a global allocator whereas `heapless` does not.
However, `heapless` requires you to pick the capacity of each collection that
you instantiate.

The `alloc` API will be familiar to virtually every Rust developer. The
`heapless` API tries to closely mimic the `alloc` API but it will never be
exactly the same due to its explicit error handling -- some developers may feel
the explicit error handling is excessive or too cumbersome.
