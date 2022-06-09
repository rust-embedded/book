# Summary

<!--

Definition of the organization of this book is still a work in process.

Refer to https://github.com/rust-embedded/book/issues for
more information and coordination

-->

- [引言](./intro/index.md)
    - [硬件](./intro/hardware.md)
    - [`no_std`](./intro/no-std.md)
    - [工具](./intro/tooling.md)
    - [安装](./intro/install.md)
        - [Linux](./intro/install/linux.md)
        - [MacOS](./intro/install/macos.md)
        - [Windows](./intro/install/windows.md)
        - [安装验证](./intro/install/verify.md)
- [开始](./start/index.md)
  - [QEMU](./start/qemu.md)
  - [硬件](./start/hardware.md)
  - [存储映射的寄存器](./start/registers.md)
  - [半主机模式](./start/semihosting.md)
  - [运行时恐慌(Panicking)](./start/panicking.md)
  - [异常](./start/exceptions.md)
  - [中断](./start/interrupts.md)
  - [IO](./start/io.md)
- [外设](./peripherals/index.md)
    - [首次尝试](./peripherals/a-first-attempt.md)
    - [借用检查器](./peripherals/borrowck.md)
    - [单例](./peripherals/singletons.md)
- [静态保障(static guarantees)](./static-guarantees/index.md)
    - [Typestate Programming](./static-guarantees/typestate-programming.md)
    - [Peripherals as State Machines](./static-guarantees/state-machines.md)
    - [Design Contracts](./static-guarantees/design-contracts.md)
    - [Zero Cost Abstractions](./static-guarantees/zero-cost-abstractions.md)
- [可移植性](./portability/index.md)
- [并发](./concurrency/index.md)
- [Collections](./collections/index.md)
- [设计模式](./design-patterns/index.md)
    - [HALs](./design-patterns/hal/index.md)
        - [Checklist](./design-patterns/hal/checklist.md)
        - [Naming](./design-patterns/hal/naming.md)
        - [互用性](./design-patterns/hal/interoperability.md)
        - [Predictability](./design-patterns/hal/predictability.md)
        - [GPIO](./design-patterns/hal/gpio.md)
- [Tips for embedded C developers](./c-tips/index.md)
    <!-- TODO: Define Sections -->
- [互用性](./interoperability/index.md)
    - [A little C with your Rust](./interoperability/c-with-rust.md)
    - [A little Rust with your C](./interoperability/rust-with-c.md)
- [Unsorted topics](./unsorted/index.md)
  - [Optimizations: The speed size tradeoff](./unsorted/speed-vs-size.md)
  - [Performing Math Functionality](./unsorted/math.md)

---

[Appendix A: Glossary](./appendix/glossary.md)
