# 集合

最后，还希望在程序里使用动态数据结构(也称为集合)。`std` 提供了一组常见的集合: [`Vec`]，[`String`]，[`HashMap`]，等等。所有这些在`std`中被实现的集合都使用一个全局动态分配器(也称为堆)。
 
[`Vec`]: https://doc.rust-lang.org/std/vec/struct.Vec.html
[`String`]: https://doc.rust-lang.org/std/string/struct.String.html
[`HashMap`]: https://doc.rust-lang.org/std/collections/struct.HashMap.html

因为`core`的定义中是没有内存分配的，所以这些实现在`core`中是没有的，但是我们可以在编译器附带的`alloc` crate中找到。

如果需要集合，一个基于堆分配的实现不是唯一的选择。也可以使用 *fixed capacity* 集合; 其实现可以在 [`heapless`] crate中被找到。

[`heapless`]: https://crates.io/crates/heapless

在这部分，我们将研究和比较这两个实现。

## 使用 `alloc`

`alloc` crate与标准的Rust发行版在一起。你可以直接 `use` 导入这个crate，而不需要在`Cargo.toml`文件中把它声明为一个依赖。

``` rust,ignore
#![feature(alloc)]

extern crate alloc;

use alloc::vec::Vec;
```

为了能使用集合，首先需要使用`global_allocator`属性去声明程序将使用的全局分配器。它要求选择的分配器实现了[`GlobalAlloc`] trait 。

[`GlobalAlloc`]: https://doc.rust-lang.org/core/alloc/trait.GlobalAlloc.html

为了完整性和尽可能保持本节的自包含性，我们将实现一个简单线性指针分配器且用它作为全局分配器。然而，我们 *强烈地* 建议你在你的程序中使用一个来自crates.io的久经战斗测试的分配器而不是这个分配器。

``` rust,ignore
// 线性指针分配器实现

use core::alloc::{GlobalAlloc, Layout};
use core::cell::UnsafeCell;
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

除了选择一个全局分配器，用户也必须要定义如何使用*不稳定的*`alloc_error_handler`属性来处理内存溢出错误。

``` rust,ignore
#![feature(alloc_error_handler)]

use cortex_m::asm;

#[alloc_error_handler]
fn on_oom(_layout: Layout) -> ! {
    asm::bkpt();

    loop {}
}
```

一旦一切都完成了，用户最后就可以在`alloc`中使用集合。

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

`heapless`无需设置，因为它的集合不依赖一个全局内存分配器。只是`use`它的集合然后实例化它们:

```rust,ignore
// heapless version: v0.4.x
use heapless::Vec;
use heapless::consts::*;

#[entry]
fn main() -> ! {
    let mut xs: Vec<_, U8> = Vec::new();

    xs.push(42).unwrap();
    assert_eq!(xs.pop(), Some(42));
    loop {}
}
```

你会注意到这些集合与`alloc`中的集合有两个不一样的地方。

第一，你必须预先声明集合的容量。`heapless`集合从来不会发生重分配且具有固定的容量;这个容量是集合的类型签名的一部分。在这个例子里，我们已经声明了`xs`的容量为8个元素，也就是说，这个vector最多只能有八个元素。这是通过类型签名中的`U8` (看[`typenum`])来指定的。

[`typenum`]: https://crates.io/crates/typenum

第二，`push`方法和另外一些方法返回的是一个`Result`。因为`heapless`集合有一个固定的容量，所以所有插入的操作都可能会失败。通过返回一个`Result`，API反应了这个问题，指出操作是否成功还是失败。相反，`alloc`集合自己将会在堆上重新分配去增加它的容量。

自v0.4.x版本起，所有的`heapless`集合将所有的元素内联地存储起来了。这意味着像是`let x = heapless::Vec::new()`这样的一个操作将会在栈上分配集合，但是它也能够在一个`static`变量上分配集合，或者甚至在堆上(`Box<Vec<_, _>>`)。

## 取舍

当在堆分配的可重定位的集合和固定容量的集合间进行选择的时候，记住这些内容。

### 内存溢出和错误处理

使用堆分配，内存溢出总是有可能出现的且会发生在任何一个集合需要增长的地方: 比如，所有的 `alloc::Vec.push` 调用会潜在地产生一个OOM(Out of Memory)条件。因此一些操作可能会*隐式地*失败。一些`alloc`集合暴露了`try_reserve`方法，可以当增加集合时让你检查潜在的OOM条件，但是你需要主动地使用它们。

如果你只使用`heapless`集合，而不使用内存分配器，那么一个OOM条件不可能出现。反而，你必须逐个处理容量不足的集合。也就是必须处理*所有*的`Result`，`Result`由像是`Vec.push`这样的方法返回的。

与在所有由`heapless::Vec.push`返回的`Result`上调用`unwrap`相比，OOM错误更难调试，因为错误被发现的位置可能与导致问题的位置*不*一致。比如，甚至如果分配器接近消耗完`vec.reserve(1)`都能触发一个OOM，因为一些其它的集合正在泄露内存(内存泄露在安全的Rust是会发生的)。

### 内存使用

推理堆分配集合的内存使用是很难的因为长期使用的集合的大小会在运行时改变。一些操作可能隐式地重分配集合，增加了它的内存使用，一些集合暴露的方法，像是`shrink_to_fit`，会潜在地减少集合使用的内存 -- 最终，它由分配器去决定是否确定减小内存的分配或者不。另外，分配器可能不得不处理内存碎片，它会*明显*增加内存的使用。

另一方面，如果你只使用固定容量的集合，请把大多数的数据保存在`static`变量中，并为调用栈设置一个最大尺寸，随后如果你尝试使用大于可用的物理内存的内存大小时，链接器会发现它。

另外，在栈上分配的固定容量的集合可以通过[`-Z emit-stack-sizes`]标识来报告，其意味着用来分析栈使用的工具(像是[`stack-sizes`])将会把在栈上分配的集合包含进它们的分析中。

[`-Z emit-stack-sizes`]: https://doc.rust-lang.org/beta/unstable-book/compiler-flags/emit-stack-sizes.html
[`stack-sizes`]: https://crates.io/crates/stack-sizes

然而，固定容量的集合*不*能被减少，与可重定位集合所能达到的负载系数(集合的大小和它的容量之间的比值)相比，它能产生更低的负载系数。

### 最坏执行时间 (WCET)

如果你正在搭建时间敏感型应用或者硬实时应用，那么你可能更关心你程序的不同部分的最坏执行时间。

`alloc`集合能重分配，所以操作的WCET可能会增加，集合也将包括它用来重分配集合所需的时间，它取决于集合的*运行时*容量。这使得它更难去决定操作，比如`alloc::Vec.push`，的WCET，因为它依赖被使用的分配器和它的运行时容量。

另一方面固定容量的集合不会重分配，因此所有的操作有个可预期的执行时间。比如，`heapless::Vec.push`以固定时间执行。

### 易用性

`alloc`要求配置一个全局分配器而`heapless`不需要。然而，`heapless`要求你去选择你要实例化的每一个集合的容量。

`alloc` API几乎为每一个Rust开发者所熟知。`heapless` API尝试模仿`alloc` API，但是因为`heapless`的显式错误处理，它们不可能会一模一样 -- 一些开发者可能会觉得显式的错误处理过多或太麻烦。
