# 引言
欢迎阅读The Embedded Rust Book:一本关于在裸板(比如，微处理器)上使用Rust编程语言的引导书籍

## Embedded Rust 是为谁准备的
Embedded Rust是为了那些想要进行嵌入式编程且又想使用Rust语言提供的高级语言概念和安全保障的人们准备的(See also [Who Rust Is For](https://doc.rust-lang.org/book/ch00-00-introduction.html))

## 本书范围
这本书的目的是：
+ 使开发者快速上手嵌入式Rust开发，比如，如何设置一个开发环境。
+ 分享那些关于使用Rust进行嵌入式开发的，现存的，最好的实践经验，比如，如何最大程度上地利用好Rust语言的特性去写更正确的嵌入式软件
+ 某种程度下作为工具书，比如，如何将C和Rust混进一个单一的项目里

这本书尽可能地尝试变得通用，但是为了使读者和作者更容易理解，在所有的例子中它都使用了ARM Cortex-M架构。然而，这本书并不假设读者熟悉这个特定的架构，并在需要时解释这个架构的特定细节

## 这本书是为谁准备的
这本书适合那些有一些嵌入式背景或者有Rust背景的人，然而我相信每一个对嵌入式Rust编程好奇的人都能从这本书中获得某些东西。对于那些先前没有任何经验的人，我们建议你读一下“要求和前提”章节，从书中获取知识补充缺失的知识，提高你的阅读体验。你可以看看“其它资源”章节，以找到你关心的主题的资源。

### 要求和前提

+ 你可以轻松地使用Rust编程语言，且在一个桌面环境上写过，运行过，调试过Rust应用。你也应该熟悉[2018 edition]的术语，因为这本书是面向Rust 2018的。

[2018 edition]: https://doc.rust-lang.org/edition-guide/

* You are comfortable developing and debugging embedded systems in another
  language such as C, C++, or Ada, and are familiar with concepts such as:
    * Cross Compilation
    * Memory Mapped Peripherals
    * Interrupts
    * Common interfaces such as I2C, SPI, Serial, etc.

### Other Resources
If you are unfamiliar with anything mentioned above or if you want more information about a specific topic mentioned in this book you might find some of these resources helpful.

| Topic        | Resource | Description |
|--------------|----------|-------------|
| Rust         | [Rust Book](https://doc.rust-lang.org/book/) | If you are not yet comfortable with Rust, we highly suggest reading this book. |
| Rust, Embedded | [Discovery Book](https://docs.rust-embedded.org/discovery/) | If you have never done any embedded programming, this book might be a better start |
| Rust, Embedded | [Embedded Rust Bookshelf](https://docs.rust-embedded.org) | Here you can find several other resources provided by Rust's Embedded Working Group. |
| Rust, Embedded | [Embedonomicon](https://docs.rust-embedded.org/embedonomicon/) | The nitty gritty details when doing embedded programming in Rust. |
| Rust, Embedded | [embedded FAQ](https://docs.rust-embedded.org/faq.html) | Frequently asked questions about Rust in an embedded context. |
| Interrupts | [Interrupt](https://en.wikipedia.org/wiki/Interrupt) | - |
| Memory-mapped IO/Peripherals | [Memory-mapped I/O](https://en.wikipedia.org/wiki/Memory-mapped_I/O) | - |
| SPI, UART, RS232, USB, I2C, TTL | [Stack Exchange about SPI, UART, and other interfaces](https://electronics.stackexchange.com/questions/37814/usart-uart-rs232-usb-spi-i2c-ttl-etc-what-are-all-of-these-and-how-do-th) | - |

### Translations

This book has been translated by generous volunteers. If you would like your
translation listed here, please open a PR to add it.

* [Japanese](https://tomoyuki-nakabayashi.github.io/book/)
  ([repository](https://github.com/tomoyuki-nakabayashi/book))

## How to Use This Book

This book generally assumes that you’re reading it front-to-back. Later
chapters build on concepts in earlier chapters, and earlier chapters may
not dig into details on a topic, revisiting the topic in a later chapter.

This book will be using the [STM32F3DISCOVERY] development board from
STMicroelectronics for the majority of the examples contained within. This board
is based on the ARM Cortex-M architecture, and while basic functionality is
the same across most CPUs based on this architecture, peripherals and other
implementation details of Microcontrollers are different between different
vendors, and often even different between Microcontroller families from the same
vendor.

For this reason, we suggest purchasing the [STM32F3DISCOVERY] development board
for the purpose of following the examples in this book.

[STM32F3DISCOVERY]: http://www.st.com/en/evaluation-tools/stm32f3discovery.html

## Contributing to This Book

The work on this book is coordinated in [this repository] and is mainly
developed by the [resources team].

[this repository]: https://github.com/rust-embedded/book
[resources team]: https://github.com/rust-embedded/wg#the-resources-team

If you have trouble following the instructions in this book or find that some
section of the book is not clear enough or hard to follow then that's a bug and
it should be reported in [the issue tracker] of this book.

[the issue tracker]: https://github.com/rust-embedded/book/issues/

Pull requests fixing typos and adding new content are very welcome!

## Re-using this material

This book is distributed under the following licenses:

* The code samples and free-standing Cargo projects contained within this book are licensed under the terms of both the [MIT License] and the [Apache License v2.0].
* The written prose, pictures and diagrams contained within this book are licensed under the terms of the Creative Commons [CC-BY-SA v4.0] license.

[MIT License]: https://opensource.org/licenses/MIT
[Apache License v2.0]: http://www.apache.org/licenses/LICENSE-2.0
[CC-BY-SA v4.0]: https://creativecommons.org/licenses/by-sa/4.0/legalcode

TL;DR: If you want to use our text or images in your work, you need to:

* Give the appropriate credit (i.e. mention this book on your slide, and provide a link to the relevant page)
* Provide a link to the [CC-BY-SA v4.0] licence
* Indicate if you have changed the material in any way, and make any changes to our material available under the same licence

Also, please do let us know if you find this book useful!
