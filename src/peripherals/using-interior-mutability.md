# Interior Mutability

What's the matter of using `static mut` variables anyway?

In Rust, whenever we have a variable `foo`, only one of the following may happen:

* the variable `foo` is moved to another place. Subsequent reference of `foo` would be a compile failure as the value has been moved. 
* some number of `&foo` borrows, which allow read-only access.
* a single (exclusive) `&mut foo` mutable borrow, which allow read/write. 

One consequence of a `static` variable is that it cannot be moved, as it lives _statically_ in memory, meaning it is in a fixed place.

A `static` variable can be borrowed as `&foo` without much issue as it is just reading.

The problem occurs when we try to borrow is as mutable. Consider the following:

```rust,ignore
static mut flag: bool = false;


fn first() {
    if !flag {
        flag = true;
        println!("first");
    }
}

fn second() {
    if !flag {
        flag = true;
        println!("second");
    }
}
```

The question is, which one would run? It's not obviousy just looking at a code. Perhaps it depends on the order or execution, which would be guaranteed _if_ there's only one active execution at a time.

You may think that because you're in an embedded programming land and you only have single core, you don't have to think about race condition, but even with a single core CPU without making any thread, you may have interrupts and those interrupt requests may access the shared mutable variable `flag`. The issue here is that the compiler cannot prohibit you from taking multiple mutable reference to the shared mutable variable at compile time, especially since it does not know about the order of executions of threads or interrupts, for example.

Also, the use of `static mut` variables _might_ be deprecated in the future. There's a strong indication of this and having the usage `deny` by default since Rust 2024 is one of them.

## So what is interior mutability?

Interior mutability is a way to "trick" the borrow checker to mutate a borrowed reference `&foo` (notice the lack of `&mut`). This is basically us saying to the compiler "I'm going to mutate the shared reference anyway, please don't stop me.".

Of course, mutating something that is borrowed in other places are undefined behaviors (UB), yet there is a way of doing so, using an `UnsafeCell`. As the name implies, you need to use the `unsafe` keyword when using it. 

The usage looks like this:

```rust,ignore
static flag: UnsafeCell<bool> = UnsafeCell::new(false);

fn some_usage() {
    // Here we take a mutable __pointer__ out of `flag`, even though
    // it is a normal static variable without `mut`.

    let my_mutable_flag_ref: *mut bool = flag.get();

    // what we have now is a mutable __pointer__, not a reference.
    // Now, it is obvious that we are dealing with unsafe behavior.

    unsafe {
        if *flag == false {
            *flag = true;
            println!("set the flag to true");
        }
    }
}

```

Compared to `static mut`, now we make it obvious that what we are trying to do is unsafe and we promise to the compiler to be careful.

One small lie here is that you cannot use `UnsafeCell` in a static variable that way because it does not implement `Sync`, which means it is not thread-safe (or interrupt safe for that matter).

We could ignore all of the safety in Rust 2024 by using SyncUnsafeCell. If you want to implement it yourself, this is all you need to write:

```rust,ignore

#[repr(transparent)]
pub struct SyncUnsafeCell<T>(UnsafeCell<T>);

unsafe impl<T: Sync> Sync for SyncUnsafeCell<T> {}

```

where Sync does absolutely nothing.

Another way is to use Rust's `SyncUnsafeCell` which is currently only available in nightly under the flag `#![feature(sync_unsafe_cell)]`.


Of course, none of the above are safe. In order to get a proper interior mutability that is safe, we should implement `Sync` ourself and put in our synchronization primitive specific to the hardware such as locking the resource with atomic swap and guarding the code with interrupt-free section (disable interrupt, run some code, enable interrupt), also known as critical section.

You could check how [rust-console gba](https://github.com/rust-console/gba/blob/6a3fcc1ee6493a499af507f8394ee542500721b7/src/gba_cell.rs#L63) implement it for reference.

Interior mutability and static mutability is a rather deep topic.  I strongly recommend reading more about static mutable references from [the rust edition guide here](https://github.com/rust-lang/edition-guide/blob/master/src/rust-2024/static-mut-references.md).
