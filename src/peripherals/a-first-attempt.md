# 首次尝试

## 寄存器

让我们看向 'SysTick' 外设 - 一个简单的计时器，其在每个Cortex-M处理器内核中都有。通常你能在芯片制造商的数据手册或者*技术参考手册*中看到它们，但是这个例子对所有ARM Cortex-M核心都是通用的，让我们看下[ARM参考手册]。我们能看到这里有四个寄存器:

[ARM参考手册]: http://infocenter.arm.com/help/topic/com.arm.doc.dui0553a/Babieigh.html

| Offset | Name        | Description                 | Width  |
|--------|-------------|-----------------------------|--------|
| 0x00   | SYST_CSR    | Control and Status Register | 32 bits|
| 0x04   | SYST_RVR    | Reload Value Register       | 32 bits|
| 0x08   | SYST_CVR    | Current Value Register      | 32 bits|
| 0x0C   | SYST_CALIB  | Calibration Value Register  | 32 bits|

## C语言风格的方法(The C Approach)

在Rust中，我们可以像我们在C语言中做的那样，用一个 `struct` 表征一组寄存器。

```rust,ignore
#[repr(C)]
struct SysTick {
    pub csr: u32,
    pub rvr: u32,
    pub cvr: u32,
    pub calib: u32,
}
```
限定符 `#[repr(C)]` 告诉Rust编译器像C编译器一样去布局这个结构体。那是非常重要的，因为Rust允许结构体字段被重新排序，而C语言不允许。你可以想象下如果这些字段被编译器悄悄地重新排序，我们将不得不进行的调试！有了这个限定符，我们就有了与上表对应的四个32位的字段。但当然，这个 `struct` 本身没什么用处 - 我们需要一个变量。

```rust,ignore
let systick = 0xE000_E010 as *mut SysTick;
let time = unsafe { (*systick).cvr };
```

## 易变的访问(Volatile Accesses)

现在，上面的方法有一堆问题。

1. 每次我们想要访问我们的外设，我们不得不使用unsafe 。
2. 我们无法指定哪个寄存器是只读的或者读写的。
3. 你程序中任何地方的任何一段代码都可以通过这个结构体访问硬件。
4. 最重要的是，实际上它并不能工作。

现在，问题是编译器很聪明。如果你往RAM同个地方写两次，一个接着一个，编译器会注意到这个且完全跳过第一个写入操作。在C语言中，我们能标记变量为`volatile`去确保每个读或写操作按预期发生。在Rust中，我们将*访问* 标记为易变的(volatile)，而不是变量。

```rust,ignore
let systick = unsafe { &mut *(0xE000_E010 as *mut SysTick) };
let time = unsafe { core::ptr::read_volatile(&mut systick.cvr) };
```
因此，我们已经修复了我们四个问题中的一个，但是现在我们有了更多的 `unsafe` 代码!幸运的是，有个第三方的crate可以帮助到我们 - [`volatile_register`]

[`volatile_register`]: https://crates.io/crates/volatile_register

```rust,ignore
use volatile_register::{RW, RO};

#[repr(C)]
struct SysTick {
    pub csr: RW<u32>,
    pub rvr: RW<u32>,
    pub cvr: RW<u32>,
    pub calib: RO<u32>,
}

fn get_systick() -> &'static mut SysTick {
    unsafe { &mut *(0xE000_E010 as *mut SysTick) }
}

fn get_time() -> u32 {
    let systick = get_systick();
    systick.cvr.read()
}
```

现在通过`read`和`write`方法，volatile accesses可以被自动执行。执行写操作仍然是 `unsafe` 的，但是公平地讲，硬件
Now, the volatile accesses are performed automatically through the `read` and `write` methods. It's still `unsafe` to perform writes, but to be fair, hardware is a bunch of mutable state and there's no way for the compiler to know whether these writes are actually safe, so this is a good default position.

## The Rusty Wrapper

We need to wrap this `struct` up into a higher-layer API that is safe for our users to call. As the driver author, we manually verify the unsafe code is correct, and then present a safe API for our users so they don't have to worry about it (provided they trust us to get it right!).

One example might be:

```rust,ignore
use volatile_register::{RW, RO};

pub struct SystemTimer {
    p: &'static mut RegisterBlock
}

#[repr(C)]
struct RegisterBlock {
    pub csr: RW<u32>,
    pub rvr: RW<u32>,
    pub cvr: RW<u32>,
    pub calib: RO<u32>,
}

impl SystemTimer {
    pub fn new() -> SystemTimer {
        SystemTimer {
            p: unsafe { &mut *(0xE000_E010 as *mut RegisterBlock) }
        }
    }

    pub fn get_time(&self) -> u32 {
        self.p.cvr.read()
    }

    pub fn set_reload(&mut self, reload_value: u32) {
        unsafe { self.p.rvr.write(reload_value) }
    }
}

pub fn example_usage() -> String {
    let mut st = SystemTimer::new();
    st.set_reload(0x00FF_FFFF);
    format!("Time is now 0x{:08x}", st.get_time())
}
```

Now, the problem with this approach is that the following code is perfectly acceptable to the compiler:

```rust,ignore
fn thread1() {
    let mut st = SystemTimer::new();
    st.set_reload(2000);
}

fn thread2() {
    let mut st = SystemTimer::new();
    st.set_reload(1000);
}
```

Our `&mut self` argument to the `set_reload` function checks that there are no other references to *that* particular `SystemTimer` struct, but they don't stop the user creating a second `SystemTimer` which points to the exact same peripheral! Code written in this fashion will work if the author is diligent enough to spot all of these 'duplicate' driver instances, but once the code is spread out over multiple modules, drivers, developers, and days, it gets easier and easier to make these kinds of mistakes.
