# A `no_std` Rust Environment

As mentioned earlier, this book is all about "bare metal" programming. Standard libraries in turn usually
require some sort of system (os) integration and higher level functionality, on top of which they implement their functionality.
Such functionalities are for example I/O (files, networking), Threads, and Heap (dynamic memory allocation).

But don't worry, this does not mean you have to code everything from scratch.
In an `no_std` environment you still will be able to use the [libcore](https://doc.rust-lang.org/core/),
if you provide a few basic functions (Either by pulling in in the [rlibc](https://crates.io/crates/rlibc) crate,
or by implementing them by yourself).

See also:
* [FAQ](https://www.rust-lang.org/en-US/faq.html#does-rust-work-without-the-standard-library)
* [RFC-1184](https://github.com/rust-lang/rfcs/blob/master/text/1184-stabilize-no_std.md)


## Does this mean I can't use dynamic memory or any kind of I/O?
No it doesen't! It just means you need to do some work in order to bootstrap it.
For the cortex-m based setup this book is based on there are even some creates
which will simplify some of bootstraping.

So if you curios check out this crates:
* [cortex-m-quickstart](https://crates.io/crates/cortex-m-quickstart)
* [cortex-m-rt](https://crates.io/crates/cortex-m-rt),
* [cortex-m-log](https://crates.io/crates/cortex-m-log)
* [cortex-m-semihosting](https://crates.io/crates/cortex-m-semihosting)
* [alloc-cortex-m](https://crates.io/crates/alloc-cortex-m)
* [linked_list_allocator](https://crates.io/crates/linked_list_allocator).

But before you start adding those crates and start allocating consider reading the next section
`"Static" vs Dynamic memory alloctation` beforehand.

## "Static" vs. Dynmaic memory allocation
First let us define what we mean with when using the terms "Static" and Dynamic memory allocation in this section.

"Static":
```
Means all memory that can be reserved and calculated at compile time,
assuming no computiation based on dynamic inputs is done (e.g. recursion based on "user input").
```
Pros:
* Memory usage can be known upfront
* Faster than dynamic memory allocation
* Time used for "allocation" predictable

Cons:
* Maxias need to be known before hand
* Code will be less dynamic even if enough memory would be available

Dynamic:
```
Means all heap allocations in this context, assuming a heap was set up.
```

Pros:
* Code can be more dynamic
* Freed memory can be reused

Cons:
* Overall memory usage hard to predict
* Memory fragmentation/waste
* Runtime impact, depending on the implementation and strategies of the allocator memory allocations
  can take a significant amount of time.

In embeded especially in embedded rt systems its often benefical if not required to have a predictable runtime
behaviour. Meaning the more of the system behaviour you can verify and guarentee before its even running the better.
Dynamic memory allocation can complicate this quite a bit.
This is why such systems do not use dynamic memory alloction, or only use an known amount of allocations right
at the startup/init.


> ❌: For more details on best practises / dev patterns in embedded environment see XYZ

>     Should we add chapter for that (e.g. no recursion etc.)
