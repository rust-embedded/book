# 并发

当程序的不同部分有可能会在不同的时刻被执行或者不按顺序地被执行时，那并发就出现了。在一个嵌入式环境中，这包括:

* 中断处理函数，一旦相关的中断发生时，中断处理函数就会运行，
* 不同的多线程形式，在这块，微处理器通常会在程序的不同部分间进行切换，
* 在一些多核微处理器系统中，每个核可以同时独立地运行程序的不同部分。

因为许多嵌入式程序需要处理中断，因此并发迟早会出现，这也是许多微妙和困难的bugs会出现的地方。幸运地是，Rust提供了许多抽象和安全保障去帮助我们写正确的代码。

## 没有并发

对于一个嵌入式程序来说最简单的并发是没有并发: 软件由一个保持运行的main循环组成，一点中断也没有。有时候这非常适合手边的问题! 通常你的循环将会读取一些输入，执行一些处理，且写入一些输出。

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

因为这里没有并发，因此不需要担心程序不同部分间的共享数据或者同步对外设的访问。如果可以使用一个简单的方法来解决问题，这种方法是个不错的选择。

## 全局可变数据

不像非嵌入式Rust，我们通常不能分配堆和将对那个数据的引用传递进一个新创造的线程中。反而，我们的中断处理函数可能在任何时间被调用，且必须知道如何访问我们正在使用的共享内存。从最底层看来，这意味着我们必须有 _静态分配的_ 可变的内存，中断处理函数和main代码都可以引用这块内存。

在Rust中，[`static mut`]这样的变量读取或者写入总是unsafe的，因为不特别关注它们的话，可能会触发一个竞态条件，对变量的访问在中途就被一个也访问那个变量的中断打断了。

[`static mut`]: https://doc.rust-lang.org/book/ch19-01-unsafe-rust.html#accessing-or-modifying-a-mutable-static-variable

为了举例这种行为如何在代码中导致了微妙的错误，思考一个嵌入式程序，这个程序在每一秒的周期内计数一些输入信号的上升沿(一个频率计数器):

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

每秒计时器中断会把计数器设置回0。这期间，main循环连续地测量信号，且当看到从低电平到高电平的变化时，增加计数器的值。因为它是`static mut`的，我们不得不使用`unsafe`去访问`COUNTER`，意思是我们向编译器保证我们的操作不会导致任何未定义的行为。你能发现竞态条件吗？`COUNTER`上的增加并不一定是原子的 - 事实上，在大多数嵌入式平台上，它将被分开成一个读取操作，然后是增加，然后是写回。如果中断在计数器被读取之后但是在被写回之前被激活，在中断返回后，重置回0的操作会被忽略掉 - 那期间，我们会算出两倍的转换次数。

## 临界区(Critical Sections)

因此，关于数据竞争可以做些什么？一个简单的方法是使用 _临界区(critical sections）_ ，在临界区的上下文中中断被关闭了。通过把对`main`中的`COUNTER`访问封装进一个临界区，我们能确保计时器中断将不会激活，直到我们完成了增加`COUNTER`的操作:

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

注意，有两个理由，不需要把一个临界区放进计时器中断中:

  * 向`COUNTER`写入0不会被一个竞争影响，因为我们不需要读取它
  * 无论如何，它永远不会被`main`线程中断

如果`COUNTER`被多个可能相互 _抢占_ 的中断处理函数共享，那么每一个也需要一个临界区。

这解决了我们眼前的问题，但是我们仍然要编写许多unsafe的代码，我们需要仔细推敲这些代码，有些我们可能不需要使用临界区。因为每个临界区暂时暂停了中断处理，就会带来一些相关的成本，一些额外的代码大小，更高的中断延迟和抖动(中断可能花费很长时间去处理，等待被处理的时间变化非常大)。这是否是个问题取决于你的系统，但是通常，我们想要避免它。

值得注意的是，虽然一个临界区保障了不会发生中断，但是它在多核系统上不提供一个排他性保证(exclusivity guarantee)！其它核可能很开心访问与你的核一样的内存区域，即使没有中断。如果你正在使用多核，你将需要更强的同步原语(synchronisation primitives)。

## 原子访问

在一些平台上，可以使用特定的原子指令，它保障了读取-修改-写回操作。针对Cortex-M: `thumbv6`(Cortex-M0，Cortex-M0+)只提供原子读取和存取指令，而`thumv7`(Cortex-M3和其上)提供完整的比较和交换(CAS)指令。这些CAS指令可以替代过重的禁用所有中断的方法: 我们可以尝试执行加法操作，它在大多数情况下都会成功，但是如果它被中断了它将会自动重试完整的加法操作。这些原子操作甚至在多核间也是安全的。

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

这时，`COUNTER`是一个safe的`static`变量。多亏了`AtomicUsize`类型，不需要禁用中断，`COUNTER`能从中断处理函数和main线程被安全地修改。当可以这么做时，这是一个更好的解决方案 - 然而平台上可能不支持这么做。

关于[`Ordering`]的提醒: 它可能影响编译器和硬件如何重新排序指令，也会影响缓存可见性。假设目标是个单核平台，在这个案例里`Relaxed`是充足的和最有效的选择。更严格的排序将导致编译器在原子操作周围产生内存屏障(Memory Barriers)；取决于你做什么原子操作，你可能需要或者不需要这个排序！原子模型的精确细节是复杂的，最好写在其它地方。

关于原子操作和排序的更多细节，可以看这里[nomicon]。

[`Ordering`]: https://doc.rust-lang.org/core/sync/atomic/enum.Ordering.html
[nomicon]: https://doc.rust-lang.org/nomicon/atomics.html


## 抽象，Send和Sync

上面的解决方案都不是特别令人满意。它们需要`unsafe`块，`unsafe`块必须要被十分小心地检查且不符合人体工程学。确实，我们在Rust中可以做得更好！

我们可以把我们的计数器抽象进一个安全的接口中，它可以在代码的其它地方被安全地使用。在这个例子里，我们将使用临界区的(cirtical-section)计数器，但是你可以用原子操作做一些非常类似的事情。

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
    // 避免开销:
    // let cs = unsafe { interrupt::CriticalSection::new() };
}
```

我们已经把我们的`unsafe`代码移进了精心安排的抽象中，现在我们的应用代码不包含任何`unsafe`块。

这个设计要求应用传递一个`CriticalSection` token进来: 这些tokens仅由`interrupt::free`安全地产生，因此通过要求传递进一个`CriticalSection` token，我们确保我们正在一个临界区中操作，不用自己动手锁起来。这个保障由编译器静态地提供: 这将不会带来任何与`cs`有关的运行时消耗。如果我们有多个计数器，它们都可以被指定同一个`cs`，而不用要求多个嵌套的临界区。

这也带来了Rust中关于并发的一个重要主题: [`Send` and `Sync`] traits。总结一下Rust book，当一个类型能够安全地被移动到另一个线程，它是Send，当一个类型能被安全地在多个线程间共享的时候，它是Sync。在一个嵌入式上下文中，我们认为中断是在应用代码的一个独立线程中执行的，因此在一个中断和main代码中都能被访问的变量必须是Sync。

[`Send` and `Sync`]: https://doc.rust-lang.org/nomicon/send-and-sync.html

在Rust中的大多数类型，这两个traits都会由你的编译器为你自动地产生。然而，因为`CSCounter`包含了一个[`UnsafeCell`]，它不是Sync，因此我们不能使用一个`static CSCounter`: `static` 变量 _必须_ 是Sync，因此它们能被多个线程访问。

[`UnsafeCell`]: https://doc.rust-lang.org/core/cell/struct.UnsafeCell.html

为了告诉编译器我们已经注意到`CSCounter`事实上在线程间共享是安全的，我们显式地实现了Sync trait。与之前使用的临界区一样，这只在单核平台上是安全的: 对于多核，你需要做更多的事来确保安全。

## 互斥量(Mutexs)

我们已经为我们的计数器问题创造了一个有用的抽象，但是关于并发这里还存在许多通用的抽象。

一个互斥量(mutex)，互斥(mutual exclusion)的缩写，就是这样的一个 _同步原语_ 。这些构造确保了对一个变量的排他访问，比如我们的计数器。一个线程会尝试 _lock_ (或者 _acquire_) 互斥量，或者当互斥量不能被锁住时返回一个错误。当线程持有锁时，它有权访问被保护的数据，当线程工作完成了，它 _unlocks_ (或者 _releases_) 互斥量，允许其它线程锁住它。在Rust中，我们通常使用[`Drop`] trait实现unlock去确保当互斥量超出作用域时它总是被释放。

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

我们现在使用了[`Cell`]，它与它的兄弟`RefCell`一起被用于提供safe的内部可变性。我们已经见过`UnsafeCell`了，在Rust中它是内部可变性的底层: 它允许你去获得对某个值的多个可变引用，但是只能与不安全的代码一起工作。一个`Cell`像一个`UnsafeCell`一样但是它提供了一个安全的接口: 它只允许拷贝现在的值或者替换它，不允许获取一个引用，因此它不是Sync，它不能被在线程间共享。这些限制意味着它用起来是safe的，但是我们不能直接将它用于`static`变量因为一个`static`必须是Sync。

[`Cell`]: https://doc.rust-lang.org/core/cell/struct.Cell.html

因此为什么上面的例子可以工作?`Mutex<T>`对于任何是Send的`T`实现了Sync - 比如一个`Cell`。因为它只能在临界区对它的内容进行访问，所以它这么做是safe的。因此我们可以即使没有一点unsafe的代码我们也能获取一个safe的计数器！

对于我们的简单类型，像是我们的计数器的`u32`来说是很棒的，但是对于更复杂的不能拷贝的类型呢？在一个嵌入式上下文中一个极度常见的例子是一个外设结构体，通常它们不是Copy。针对那种情况，我们可以使用`RefCell`。

## 共享外设

使用`svd2rust`生成的设备crates和相似的抽象，通过强制要求同时只能存在一个外设结构体的实例，提供了对外设的安全的访问。这个确保了安全性，但是使得它很难从main线程和一个中断处理函数一起访问一个外设。

为了安全地共享对外设的访问，我们能使用我们之前看到的`Mutex`。我们也将需要使用[`RefCell`]，它使用一个运行时检查去确保对一个外设每次只有一个引用被给出。这个比纯`Cell`消耗更多，但是因为我们正给出引用而不是拷贝，我们必须确保每次只有一个引用存在。

[`RefCell`]: https://doc.rust-lang.org/core/cell/struct.RefCell.html

最终，我们也必须考虑在main代码中初始化外设后，如何将外设移到共享变量中。为了做这个，我们使用`Option`类型，初始成`None`，之后设置成外设的实例。

```rust,ignore
use core::cell::RefCell;
use cortex_m::interrupt::{self, Mutex};
use stm32f4::stm32f405;

static MY_GPIO: Mutex<RefCell<Option<stm32f405::GPIOA>>> =
    Mutex::new(RefCell::new(None));

#[entry]
fn main() -> ! {
    // 获得外设的单例并配置它。这个例子来自一个svd2rust生成的crate，
    // 但是大多数的嵌入式设备crates都相似。
    let dp = stm32f405::Peripherals::take().unwrap();
    let gpioa = &dp.GPIOA;

    // 某个配置函数。假设它把PA0设置成一个输入和把PA1设置成一个输出。
    configure_gpio(gpioa);

    // 把GPIOA存进互斥量中，移动它。
    interrupt::free(|cs| MY_GPIO.borrow(cs).replace(Some(dp.GPIOA)));
    // 我可以不再用`gpioa`或者`dp.GPIOA`，反而必须通过互斥量访问它。

    // 请注意，只有在设置MY_GPIO后才能使能中断: 要不然当MY_GPIO还是包含None的时候，
    // 中断可能会发生，然后像上面写的那样操作(使用`unwrap()`)，它将发生运行时恐慌。
    set_timer_1hz();
    let mut last_state = false;
    loop {
        // 我们现在将通过互斥量，读取其作为数字输入时的状态。
        let state = interrupt::free(|cs| {
            let gpioa = MY_GPIO.borrow(cs).borrow();
            gpioa.as_ref().unwrap().idr.read().idr0().bit_is_set()
        });

        if state && !last_state {
            // 如果我们在PA0上已经看到了一个上升沿，拉高PA1。
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
    // 这次在中断中，我们将清除PA0。
    interrupt::free(|cs| {
        // 我们可以使用`unwrap()` 因为我们知道直到MY_GPIO被设置后，中断都是禁用的；
        // 否则我应该处理会出现一个None值的潜在可能
        let gpioa = MY_GPIO.borrow(cs).borrow();
        gpioa.as_ref().unwrap().odr.modify(|_, w| w.odr1().clear_bit());
    });
}
```

这需要理解的内容很多，所以让我们把重要的内容分解一下。

```rust,ignore
static MY_GPIO: Mutex<RefCell<Option<stm32f405::GPIOA>>> =
    Mutex::new(RefCell::new(None));
```

我们的共享变量现在是一个包围了一个`RefCell`的`Mutex`，`RefCell`包含一个`Option`。`Mutex`确保只在一个临界区中的时候可以访问，因此使变量变成了Sync，甚至即使一个纯`RefCell`不是Sync。`RefCell`赋予了我们引用的内部可变性，我们将需要使用我们的`GPIOA`。`Option`让我们可以初始化这个变量成空的东西，只在随后实际移动变量进来。只有在运行时，我们才能静态地访问外设单例，因此这是必须的。

```rust,ignore
interrupt::free(|cs| MY_GPIO.borrow(cs).replace(Some(dp.GPIOA)));
```

在一个临界区中，我们可以在互斥量上调用`borrow()`，其给了我们一个指向`RefCell`的引用。然后我们调用`replace()`去移动我们的新值进来`RefCell`。

```rust,ignore
interrupt::free(|cs| {
    let gpioa = MY_GPIO.borrow(cs).borrow();
    gpioa.as_ref().unwrap().odr.modify(|_, w| w.odr1().set_bit());
});
```

最终，我们用一种安全和并发的方式使用`MY_GPIO`。临界区禁止了中断像往常一样发生，让我们借用互斥量。`RefCell`然后给了我们一个`&Option<GPIOA>`并追踪它还要借用多久 - 一旦引用超出作用域，`RefCell`将会被更新去指出引用不再被借用。

因为我不能把`GPIOA`移出`&Option`，我们需要用`as_ref()`将它转换成一个`&Option<&GPIOA>`，最终我们能使用`unwrap()`获得`&GPIOA`，其让我们可以修改外设。

如果我们需要一个共享的资源的可变引用，那么`borrow_mut`和`deref_mut`应该被使用。下面的代码展示了一个使用TIM2计时器的例子。

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

    // 某个计时器配置函数。假设它配置了TIM2计时器和它的NVIC中断，
    // 最终启动计时器。
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
        if let Some(ref mut tim) =  G_TIM.borrow(cs).borrow_mut().deref_mut() {
            tim.start(1.hz());
        }
    });
}

```

呼！这是安全的，但也有点笨拙。我们还能做些什么吗？

## RTIC

另一个方法是使用[RTIC框架]，Real Time Interrupt-driven Concurrency的缩写。它强制执行静态优先级并追踪对`static mut`变量("资源")的访问去确保共享资源总是能被安全地访问，而不需要总是进入临界区和使用引用计数带来的消耗(如`RefCell`中所示)。这有许多好处，比如保证没有死锁且时间和内存的消耗极度低。

[RTIC框架]: https://github.com/rtic-rs/cortex-m-rtic

这个框架也包括了其它的特性，像是消息传递(message passing)，消息传递减少了对显式共享状态的需要，还提供了在一个给定时间调度任务去运行的功能，这功能能被用来实现周期性的任务。看下[文档]可以知道更多的信息！

[文档]: https://rtic.rs

## 实时操作系统

与嵌入式并发有关的另一个模型是实时操作系统(RTOS)。虽然现在在Rust中的研究较少，但是它们被广泛用于传统的嵌入式开发。开源的例子包括[FreeRTOS]和[ChibiOS](译者注: 目前有个纯Rust实现的[Tock](https://www.tockos.org/))。这些RTOSs提供对运行多个应用线程的支持，CPU在这些线程间进行切换，切换要么发生在当线程让出控制权的时候(被称为非抢占式多任务)，要么是基于一个常规计时器或者中断(抢占式多任务)。RTOS通常提供互斥量或者其它的同步原语，经常与硬件功能相互使用，比如DMA引擎。

[FreeRTOS]: https://freertos.org/
[ChibiOS]: http://chibios.org/

在撰写本文时，没有太多的Rust RTOS示例可供参考，但这是一个有趣的领域，所以请关注这块！

## 多个核心

在嵌入式处理器中有两个或者多个核心很正常，其为并发添加了额外一层复杂性。所有使用临界区的例子(包括`cortex_m::interrupt::Mutex`)都假设了另一个执行的线程仅是中断线程，但是在一个多核系统中，这不再是正确的假设。反而，我们将需要为多核设计的同步原语(也被叫做SMP，symmetric multi-processing的缩写)。

我们之前看到的，这些通常使用原子指令，因为处理系统将确保原子性在所有的核中都保持着。

覆盖这些主题的细节已经超出了本书的范围，但是常规的模式与单核的相似。
