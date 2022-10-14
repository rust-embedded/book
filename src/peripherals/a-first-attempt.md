# Rust的首次尝试

## 寄存器

让我们看向 'SysTick' 外设 - 一个简单的计时器，其在每个Cortex-M处理器内核中都有。通常你能在芯片厂商的数据手册或者*技术参考手册*中看到它们，但是下面的例子对所有ARM Cortex-M核心都是通用的，让我们看下[ARM参考手册]。我们能看到这里有四个寄存器:

[ARM参考手册]: http://infocenter.arm.com/help/topic/com.arm.doc.dui0553a/Babieigh.html

| Offset | Name        | Description                 | Width  |
|--------|-------------|-----------------------------|--------|
| 0x00   | SYST_CSR    | 控制和状态寄存器               | 32 bits|
| 0x04   | SYST_RVR    | 重装载值寄存器                | 32 bits|
| 0x08   | SYST_CVR    | 当前值寄存器                  | 32 bits|
| 0x0C   | SYST_CALIB  | 校准值寄存器                  | 32 bits|

## C语言风格的方法(The C Approach)

在Rust中，我们可以像我们在C语言中做的那样，用一个 `struct` 表示一组寄存器。

```rust,ignore
#[repr(C)]
struct SysTick {
    pub csr: u32,
    pub rvr: u32,
    pub cvr: u32,
    pub calib: u32,
}
```
限定符 `#[repr(C)]` 告诉Rust编译器像C编译器一样去布局这个结构体。那是非常重要的，因为Rust允许结构体字段被重新排序，而C语言不允许。你可以想象下如果这些字段被编译器悄悄地重新排了序，在调试时会给我们带来多大的麻烦！有了这个限定符，我们就有了与上表对应的四个32位的字段。但当然，这个 `struct` 本身没什么用处 - 我们需要一个变量。

```rust,ignore
let systick = 0xE000_E010 as *mut SysTick;
let time = unsafe { (*systick).cvr };
```

## volatile访问(Volatile Accesses)

现在，上面的方法有一堆问题。

1. 每次我们想要访问我们的外设，我们不得不使用unsafe 。
2. 我们无法指定哪个寄存器是只读的或者读写的。
3. 你程序中任何地方的任何一段代码都可以通过这个结构体访问硬件。
4. 最重要的是，实际上它并不能工作。

现在的问题是编译器很聪明。如果你往RAM同个地方写两次，一个接着一个，编译器会注意到这个行为，且完全跳过第一个写入操作。在C语言中，我们能标记变量为`volatile`去确保每个读或写操作按预期发生。在Rust中，我们将*访问*操作标记为易变的(volatile)，而不是将变量标记为volatile。

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

现在通过`read`和`write`方法，volatile accesses可以被自动执行。执行写操作仍然是 `unsafe` 的，但是公平地讲，硬件有一堆可变的状态，对于编译器来说没有方法去知道是否这些写操作是真正安全的，因此默认就这样是个不错的选择。

## Rust风格的封装

我们需要把这个`struct`封装进一个更高抽象的API中，这个API对于我们用户来说，可以安全地被调用。作为驱动的作者，我们亲手验证不安全的代码是否正确，然后为我们的用户提供一个safe的API，因此用户们不必担心它(让他们相信我们不会出错!)。

有可能有这样的例子:

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

现在，这种方法带来的问题是，下列的代码完全可以被编译器接受:

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

虽然 `set_reload` 函数的 `&mut self` 参数保证了对某个`SystemTimer`结构体的引用只有一个，但是他们不能阻止用户去创造第二个`SystemTimer`，其指向同个外设！如果作者足够尽力，他能发现所有这些'重复的'驱动实例，那么按这种方式写的代码将可以工作，但是一旦代码被散播几天，散播到多个模块，驱动，开发者，它会越来越容易犯此类错误。
