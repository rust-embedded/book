# 并发

无论何时你程序的不同部分可能会在不同时刻执行或者不按顺序执行，那并发就发生了。在一个嵌入式环境中，这包括:

* 中断处理函数，无论何时相关的中断发生时，其会运行，
* 不同的多线程形式，在这块，你的微处理器通常会在你的程序的不同部分间进行切换，
* 在一些多核微处理器系统中，每个核可以同时独立地运行你的程序的不同部分。

因为许多嵌入式程序需要处理中断，因此并发迟早会出现，这也是许多微妙和困难的bugs会出现的地方。幸运地是，Rust提供了许多抽象和安全保障去帮助我们写正确的代码。

## 没有并发

对于一个嵌入式程序来说最简单的并发是没有并发: 你的软件由单个保持运行的main循环组成，一点中断也没有。有时候这非常适合手边的问题! 通常你的循环将会读取一些输入，执行一些处理，且写入一些输出。

```rust,ignore
#[entry]
fn main() {
    let peripherals = setup_peripherals();
    loop {
        let inputs = read_inputs(&peripherals);
        let outputs = process(inputs);
        write_outputs(&peripherals, outputs);
    }
}
```

因为这里没有并发，因此不需要担心程序不同部分间的共享数据或者同步对外设的访问。如果你可以使用一个简单的方法来解决问题，这种方法是个不错的选择。

## 全局可变数据

不像非嵌入式Rust，我们通常不能分配堆和将对那个数据的引用传递进一个新创造的线程。反而，我们的中断处理函数可能在任何时间被调用，且必须知道如何访问我们正在使用的共享内存。从最底层看来，这意味着我们必须有 _static allocated_ 可变的内存，中断处理函数和main代码都可以引用这块内存。

在Rust中，[`static mut`]这样的变量读取或者写入总是不安全的，因为不特别关注它们的话，你可能会触发一个竞态条件，你对变量的访问在中途就被一个也访问那个变量的中断打断。

[`static mut`]: https://doc.rust-lang.org/book/ch19-01-unsafe-rust.html#accessing-or-modifying-a-mutable-static-variable

为了举例这种行为如何在你的代码中导致了微妙的错误，思考一个嵌入式程序，这个程序在每个一秒的周期内计数一些输入信号的上升沿(一个频率计数器):

```rust,ignore
static mut COUNTER: u32 = 0;

#[entry]
fn main() -> ! {
    set_timer_1hz();
    let mut last_state = false;
    loop {
        let state = read_signal_level();
        if state && !last_state {
            // 危险 - 实际不安全! 可能导致数据竞争。
            unsafe { COUNTER += 1 };
        }
        last_state = state;
    }
}

#[interrupt]
fn timer() {
    unsafe { COUNTER = 0; }
}
```

每秒计时器中断会把计数器设置回0。这期间，main循环连续地测量信号，且当它看到从低电平到高电平的变化时，增加计数器的值。因为它是`static mut`，我们不得不使用`unsafe`去访问`COUNTER`，意思是我们向编译器保证我们的操作不会导致任何未定义的行为。你能发现竞态条件吗？`COUNTER`上的增加并不一定是原子的 - 事实上，在大多数嵌入式平台上，它将被分开成一个读取操作，然后是增加，然后是写回。如果中断在读取之后但是写回之前被激活，在中断返回后，重置回0的操作会被忽略 - 那段时间，一些变化我们会计算两次。

## 临界区(Critical Sections)

因此，关于数据竞争我们能做些什么？一个简单的方法是使用 _临界区(critical sections）_ ，在临界区的上下文中中断被关闭了。通过把对`main`中的`COUNTER`访问封装进一个临界区，我们能确保计时器中断将不会激活，直到我们完成了增加`COUNTER`的操作:

```rust,ignore
static mut COUNTER: u32 = 0;

#[entry]
fn main() -> ! {
    set_timer_1hz();
    let mut last_state = false;
    loop {
        let state = read_signal_level();
        if state && !last_state {
            // 新的临界区确保对COUNTER的同步访问
            cortex_m::interrupt::free(|_| {
                unsafe { COUNTER += 1 };
            });
        }
        last_state = state;
    }
}

#[interrupt]
fn timer() {
    unsafe { COUNTER = 0; }
}
```

在这个例子里，我们使用 `cortex_m::interrupt::free`，但是其它平台将会有更简单的机制在一个临界区中执行代码。它们都有一样的逻辑，关闭中断，运行一些代码，然后重新使能中断。

注意，有两个理由，我们不需要把一个临界区放进计时器中断中:

  * 向`COUNTER`写入0不会被一个竞争影响，因为我们不需要读取它
  * 无论如何，它永远不会被`main`线程中断

如果`COUNTER`被多个可能相互 _抢占_ 的中断处理函数共享，那么每一个也需要一个临界区。

这解决了我们的眼前问题，但是我们仍然要编写许多不安全的代码，我们需要仔细推敲这些代码，有些我们可能不需要使用临界区。因为每个临界区暂时地暂停了中断处理，就会出现一些消耗，其与一些额外的代码大小和更高的中断延迟和抖动有关(中断可能花费很长时间去处理，等待被处理的时间变化非常大)。这是否是个问题取决于你的系统，但是通常，我们想要避免它。

值得注意的是，虽然一个临界区保障了没有中断将会发生，但是它在多核系统上不提供一个排他性保证(exclusivity guarantee)！其它核可能很开心访问与你的核一样的内存区域，设置不用中断。如果你正在使用多核，你将需要更强的同步原语(synchronisation primitives)。

## 原子访问

在一些平台上，可以使用特定的原子指令，它保障了读取-修改-写回操作。针对Cortex-M: `thumbv6`(Cortex-M0，Cortex-M0+)只提供原子读取和存取指令，而`thumv7`(Cortex-M3和其上)提供完全的比较和交换(CAS)指令。这些CAS指令提供了一种对所有中断禁用的替代方法: 我们可以尝试执行增加操作，它在大多数情况下都会成功，但是如果它被中断了它将会自动重试完整的增加操作。这些原子操作甚至在多核间也是安全的。

```rust,ignore
use core::sync::atomic::{AtomicUsize, Ordering};

static COUNTER: AtomicUsize = AtomicUsize::new(0);

#[entry]
fn main() -> ! {
    set_timer_1hz();
    let mut last_state = false;
    loop {
        let state = read_signal_level();
        if state && !last_state {
            // Use `fetch_add` to atomically add 1 to COUNTER
            COUNTER.fetch_add(1, Ordering::Relaxed);
        }
        last_state = state;
    }
}

#[interrupt]
fn timer() {
    // Use `store` to write 0 directly to COUNTER
    COUNTER.store(0, Ordering::Relaxed)
}
```

这时，`COUNTER`是一个安全的`static`变量。多亏了`AtomicUsize`类型，不需要禁用中断，`COUNTER`能从中断处理函数和main线程被安全地修改。当可以这么做时，这是一个更好的解决方案 - 然而你的平台上可能不支持。

一个关于[`Ordering`]的提示: 这影响编译器和硬件可能如何重新排序指令，也会影响缓存可见性。假设目标是个单核平台，在这个案例里`Relaxed`是充足和最有效的选择。更严格的排序将导致编译器在原子操作周围产生内存屏障(Memory Barriers)；取决于你做什么原子操作，你可能需要或者不需要这个！原子模型的精确细节是复杂的，最好写在其它地方。

关于原子操作和排序的更多细节，可以看这里[nomicon]。

[`Ordering`]: https://doc.rust-lang.org/core/sync/atomic/enum.Ordering.html
[nomicon]: https://doc.rust-lang.org/nomicon/atomics.html


## 抽象，Send和Sync

上面的解决方案都不是特别令人满意。它们需要`unsafe`块，`unsafe`块必须要被十分小心地检查且符合人体工程学。确实，我们在Rust中可以做得更好！

我们可以把我们的计数器抽象进一个安全的接口，其可以在我们代码的其它地方被安全地使用。对于这个例子，我们将使用临界区的(cirtical-section)计数器，但是你可以用原子操作做一些非常类似的事情。

```rust,ignore
use core::cell::UnsafeCell;
use cortex_m::interrupt;

// 我们的计数器只是包围UnsafeCell<u32>的一个封装，它是Rust中内部可变性
// (interior mutability)的关键。通过使用内部可变性，我们能让COUNTER
// 变成`static`而不是`static mut`，但是仍能改变它的计数器值。
struct CSCounter(UnsafeCell<u32>);

const CS_COUNTER_INIT: CSCounter = CSCounter(UnsafeCell::new(0));

impl CSCounter {
    pub fn reset(&self, _cs: &interrupt::CriticalSection) {
        // 通过要求一个CriticalSection被传递进来，我们知道我们肯定正在一个
        // CriticalSection中操作，且因此可以自信地使用这个unsafe块(调用UnsafeCell::get的前提)。
        unsafe { *self.0.get() = 0 };
    }

    pub fn increment(&self, _cs: &interrupt::CriticalSection) {
        unsafe { *self.0.get() += 1 };
    }
}

// 允许静态CSCounter的前提。看下面的解释。
unsafe impl Sync for CSCounter {}

// COUNTER不再是`mut`的因为它使用内部可变性;
// 因此访问它也不再需要unsafe块。
static COUNTER: CSCounter = CS_COUNTER_INIT;

#[entry]
fn main() -> ! {
    set_timer_1hz();
    let mut last_state = false;
    loop {
        let state = read_signal_level();
        if state && !last_state {
            // 这里不用unsafe!
            interrupt::free(|cs| COUNTER.increment(cs));
        }
        last_state = state;
    }
}

#[interrupt]
fn timer() {
    // 这里我们需要进入一个临界区，只是为了传递进一个有效的cs token，尽管我们知道
    // 没有其它中断可以抢占这个中断。 
    interrupt::free(|cs| COUNTER.reset(cs));

    // 如果我们真的需要，我们可以使用unsafe代码去生成一个假CriticalSection，
    // 避免消耗:
    // let cs = unsafe { interrupt::CriticalSection::new() };
}
```

我们已经把我们的`unsafe`代码移进了精心安排的抽象中，现在我们的应用代码不包含任何`unsafe`块。

这个设计要求应用传递一个`CriticalSection` token进来: 这些tokens仅由`interrupt::free`安全地产生，因此通过要求传递进一个`CriticalSection` token，我们确保我们正在一个临界区中操作，不用自己动手锁起来。这个保障由编译器静态地提供: 这将不会有任何与`cs`有关的运行时消耗。如果我们由多个计数器，它们都可以被指定同一个`cs`，而不用要求多个嵌套的临界区。

这也带来了Rust中关于并发的一个重要主题: [`Send` and `Sync`] traits。总结一下Rust book，当一个类型能够安全地被移动到另一个线程，它是Send，当一个类型能被安全地在多个线程间共享的时候，它是Sync。在一个嵌入式上下文中，我们认为中断是在应用代码的一个独立线程中执行的，因此在一个中断和main代码中都被访问的变量必须是Sync。

[`Send` and `Sync`]: https://doc.rust-lang.org/nomicon/send-and-sync.html

在Rust中的大多数类型，这两个traits都会由你的编译器为你自动地产生。然而，因为`CSCounter`包含了一个[`UnsafeCell`]，它不是Sync，因此我们不能使用一个`static CSCounter`: `static` 变量 _必须_ 是Sync，因此它们能被多个线程访问。

[`UnsafeCell`]: https://doc.rust-lang.org/core/cell/struct.UnsafeCell.html

为了告诉编译器我们已经注意到`CSCounter`事实上在线程间共享是安全的，我们显式地实现了Sync trait。与之前使用的临界区一样，这只在单核平台上是安全的: 对于多核，你需要做更多的事来确保安全。

## 互斥量(Mutexs)

我们已经为我们的计数器问题创造了一个有用的抽象，但是关于并发这里存在许多通用的抽象。

一个这样的 _同步原语_ 是一个互斥量(mutex)，互斥(mutual exclusion)的缩写。这些构造确保了对一个变量的排他访问，比如我们的计数器。一个线程尝试 _lock_ (或者 _acquire_) 互斥量，或者当互斥量不能被锁住时返回一个错误。当线程持有锁时，它有权访问被保护的数据，当线程工作完成了，它 _unlocks_ (或者 _releases_) 互斥量，允许其它线程锁住它。在Rust中，我们通常使用[`Drop`] trait实现unlock去确保当互斥量超出作用域时它总是被释放。

[`Drop`]: https://doc.rust-lang.org/core/ops/trait.Drop.html

将中断处理函数与一个互斥量一起使用可能有点棘手: 阻塞中断处理函数通常是不可接受的，如果它阻塞等待main线程去释放一个锁，那将是一场灾难。因为我们会 _死锁_ (因为执行停留在中断处理函数中，主线程将永远不会释放锁)。死锁被认为是不安全的: 即使在安全的Rust中这也是可能发生的。

为了完全避免这个行为，我们可以实现一个要求临界区的互斥量去锁住，就像我们的计数器例子一样。临界区的存在时间必须和锁存在的时间一样长，我们能确保我们对被封装的变量有排他式访问，甚至不需要跟踪互斥量的 lock/unlock 状态。

实际上我们在 `cortex_m` crate中就是这么做的！我们可以用它来写入我们的计数器:

```rust,ignore
use core::cell::Cell;
use cortex_m::interrupt::Mutex;

static COUNTER: Mutex<Cell<u32>> = Mutex::new(Cell::new(0));

#[entry]
fn main() -> ! {
    set_timer_1hz();
    let mut last_state = false;
    loop {
        let state = read_signal_level();
        if state && !last_state {
            interrupt::free(|cs|
                COUNTER.borrow(cs).set(COUNTER.borrow(cs).get() + 1));
        }
        last_state = state;
    }
}

#[interrupt]
fn timer() {
    // 这里我们仍然需要进入一个临界区去满足互斥量。
    interrupt::free(|cs| COUNTER.borrow(cs).set(0));
}
```

我们现在使用了[`Cell`]，它与它的兄弟`RefCell`一起被用于提供安全的内部可变性。我们已经见过`UnsafeCell`了，在Rust中它是内部可变性的底层: 它允许你去获得多个对值的可变引用，但是只能与不安全的代码一起工作。一个`Cell`像一个`UnsafeCell`一样但是它提供了一个安全的接口: 它只允许拷贝现在的值或者替换它，不允许获取一个引用，因此它不是Sync，它不能被在线程间共享。这些限制意味着它用起来是安全的，但是我们不能直接将它用于`static`变量因为一个`static`必须是Sync。

[`Cell`]: https://doc.rust-lang.org/core/cell/struct.Cell.html

So why does the example above work? The `Mutex<T>` implements Sync for any
`T` which is Send — such as a `Cell`. It can do this safely because it only
gives access to its contents during a critical section. We're therefore able
to get a safe counter with no unsafe code at all!

This is great for simple types like the `u32` of our counter, but what about
more complex types which are not Copy? An extremely common example in an
embedded context is a peripheral struct, which generally is not Copy.
For that, we can turn to `RefCell`.

## 共享外设

Device crates generated using `svd2rust` and similar abstractions provide
safe access to peripherals by enforcing that only one instance of the
peripheral struct can exist at a time. This ensures safety, but makes it
difficult to access a peripheral from both the main thread and an interrupt
handler.

To safely share peripheral access, we can use the `Mutex` we saw before. We'll
also need to use [`RefCell`], which uses a runtime check to ensure only one
reference to a peripheral is given out at a time. This has more overhead than
the plain `Cell`, but since we are giving out references rather than copies,
we must be sure only one exists at a time.

[`RefCell`]: https://doc.rust-lang.org/core/cell/struct.RefCell.html

Finally, we'll also have to account for somehow moving the peripheral into
the shared variable after it has been initialised in the main code. To do
this we can use the `Option` type, initialised to `None` and later set to
the instance of the peripheral.

```rust,ignore
use core::cell::RefCell;
use cortex_m::interrupt::{self, Mutex};
use stm32f4::stm32f405;

static MY_GPIO: Mutex<RefCell<Option<stm32f405::GPIOA>>> =
    Mutex::new(RefCell::new(None));

#[entry]
fn main() -> ! {
    // Obtain the peripheral singletons and configure it.
    // This example is from an svd2rust-generated crate, but
    // most embedded device crates will be similar.
    let dp = stm32f405::Peripherals::take().unwrap();
    let gpioa = &dp.GPIOA;

    // Some sort of configuration function.
    // Assume it sets PA0 to an input and PA1 to an output.
    configure_gpio(gpioa);

    // Store the GPIOA in the mutex, moving it.
    interrupt::free(|cs| MY_GPIO.borrow(cs).replace(Some(dp.GPIOA)));
    // We can no longer use `gpioa` or `dp.GPIOA`, and instead have to
    // access it via the mutex.

    // Be careful to enable the interrupt only after setting MY_GPIO:
    // otherwise the interrupt might fire while it still contains None,
    // and as-written (with `unwrap()`), it would panic.
    set_timer_1hz();
    let mut last_state = false;
    loop {
        // We'll now read state as a digital input, via the mutex
        let state = interrupt::free(|cs| {
            let gpioa = MY_GPIO.borrow(cs).borrow();
            gpioa.as_ref().unwrap().idr.read().idr0().bit_is_set()
        });

        if state && !last_state {
            // Set PA1 high if we've seen a rising edge on PA0.
            interrupt::free(|cs| {
                let gpioa = MY_GPIO.borrow(cs).borrow();
                gpioa.as_ref().unwrap().odr.modify(|_, w| w.odr1().set_bit());
            });
        }
        last_state = state;
    }
}

#[interrupt]
fn timer() {
    // This time in the interrupt we'll just clear PA0.
    interrupt::free(|cs| {
        // We can use `unwrap()` because we know the interrupt wasn't enabled
        // until after MY_GPIO was set; otherwise we should handle the potential
        // for a None value.
        let gpioa = MY_GPIO.borrow(cs).borrow();
        gpioa.as_ref().unwrap().odr.modify(|_, w| w.odr1().clear_bit());
    });
}
```

That's quite a lot to take in, so let's break down the important lines.

```rust,ignore
static MY_GPIO: Mutex<RefCell<Option<stm32f405::GPIOA>>> =
    Mutex::new(RefCell::new(None));
```

Our shared variable is now a `Mutex` around a `RefCell` which contains an
`Option`. The `Mutex` ensures we only have access during a critical section,
and therefore makes the variable Sync, even though a plain `RefCell` would not
be Sync. The `RefCell` gives us interior mutability with references, which
we'll need to use our `GPIOA`. The `Option` lets us initialise this variable
to something empty, and only later actually move the variable in. We cannot
access the peripheral singleton statically, only at runtime, so this is
required.

```rust,ignore
interrupt::free(|cs| MY_GPIO.borrow(cs).replace(Some(dp.GPIOA)));
```

Inside a critical section we can call `borrow()` on the mutex, which gives us
a reference to the `RefCell`. We then call `replace()` to move our new value
into the `RefCell`.

```rust,ignore
interrupt::free(|cs| {
    let gpioa = MY_GPIO.borrow(cs).borrow();
    gpioa.as_ref().unwrap().odr.modify(|_, w| w.odr1().set_bit());
});
```

Finally, we use `MY_GPIO` in a safe and concurrent fashion. The critical section
prevents the interrupt firing as usual, and lets us borrow the mutex.  The
`RefCell` then gives us an `&Option<GPIOA>`, and tracks how long it remains
borrowed - once that reference goes out of scope, the `RefCell` will be updated
to indicate it is no longer borrowed.

Since we can't move the `GPIOA` out of the `&Option`, we need to convert it to
an `&Option<&GPIOA>` with `as_ref()`, which we can finally `unwrap()` to obtain
the `&GPIOA` which lets us modify the peripheral.

If we need a mutable reference to a shared resource, then `borrow_mut` and `deref_mut`
should be used instead. The following code shows an example using the TIM2 timer.

```rust,ignore
use core::cell::RefCell;
use core::ops::DerefMut;
use cortex_m::interrupt::{self, Mutex};
use cortex_m::asm::wfi;
use stm32f4::stm32f405;

static G_TIM: Mutex<RefCell<Option<Timer<stm32::TIM2>>>> =
	Mutex::new(RefCell::new(None));

#[entry]
fn main() -> ! {
    let mut cp = cm::Peripherals::take().unwrap();
    let dp = stm32f405::Peripherals::take().unwrap();

    // Some sort of timer configuration function.
    // Assume it configures the TIM2 timer, its NVIC interrupt,
    // and finally starts the timer.
    let tim = configure_timer_interrupt(&mut cp, dp);

    interrupt::free(|cs| {
        G_TIM.borrow(cs).replace(Some(tim));
    });

    loop {
        wfi();
    }
}

#[interrupt]
fn timer() {
    interrupt::free(|cs| {
        if let Some(ref mut tim)) =  G_TIM.borrow(cs).borrow_mut().deref_mut() {
            tim.start(1.hz());
        }
    });
}

```

Whew! This is safe, but it is also a little unwieldy. Is there anything else
we can do?

## RTIC

One alternative is the [RTIC framework], short for Real Time Interrupt-driven Concurrency. It
enforces static priorities and tracks accesses to `static mut` variables
("resources") to statically ensure that shared resources are always accessed
safely, without requiring the overhead of always entering critical sections and
using reference counting (as in `RefCell`). This has a number of advantages such
as guaranteeing no deadlocks and giving extremely low time and memory overhead.

[RTIC framework]: https://github.com/rtic-rs/cortex-m-rtic

The framework also includes other features like message passing, which reduces
the need for explicit shared state, and the ability to schedule tasks to run at
a given time, which can be used to implement periodic tasks. Check out [the
documentation] for more information!

[the documentation]: https://rtic.rs

## 实时操作系统

Another common model for embedded concurrency is the real-time operating system
(RTOS). While currently less well explored in Rust, they are widely used in
traditional embedded development. Open source examples include [FreeRTOS] and
[ChibiOS]. These RTOSs provide support for running multiple application threads
which the CPU swaps between, either when the threads yield control (called
cooperative multitasking) or based on a regular timer or interrupts (preemptive
multitasking). The RTOS typically provide mutexes and other synchronisation
primitives, and often interoperate with hardware features such as DMA engines.

[FreeRTOS]: https://freertos.org/
[ChibiOS]: http://chibios.org/

At the time of writing, there are not many Rust RTOS examples to point to,
but it's an interesting area so watch this space!

## 多个核心

It is becoming more common to have two or more cores in embedded processors,
which adds an extra layer of complexity to concurrency. All the examples using
a critical section (including the `cortex_m::interrupt::Mutex`) assume the only
other execution thread is the interrupt thread, but on a multi-core system
that's no longer true. Instead, we'll need synchronisation primitives designed
for multiple cores (also called SMP, for symmetric multi-processing).

These typically use the atomic instructions we saw earlier, since the
processing system will ensure that atomicity is maintained over all cores.

Covering these topics in detail is currently beyond the scope of this book,
but the general patterns are the same as for the single-core case.
