# 引言
欢迎阅读The Embedded Rust Book:一本关于在裸机(比如，微处理器)上使用Rust编程语言的引导书籍。

## Embedded Rust 是为谁准备的
Embedded Rust是为了那些想要进行嵌入式编程，又想使用Rust语言提供的高级语言概念和安全保障的人们准备的(See also [Who Rust Is For](https://doc.rust-lang.org/book/ch00-00-introduction.html))

## 本书范围
这本书的目的是：
+ 让开发者快速上手嵌入式Rust开发，比如，如何设置一个开发环境。
+ 分享那些关于使用Rust进行嵌入式开发的，现存的，最好的实践经验，比如，如何最大程度上地利用好Rust语言的特性去写更正确的嵌入式软件
+ 某种程度下作为工具书，比如，如何在一个项目里将C和Rust混合进去

这本书尽可能地尝试变得适用于所有场景，但是为了使读者和作者更容易理解，在所有的例子中它都使用了ARM Cortex-M架构。然而，这本书并不需要读者熟悉这个特定的架构，书中会在需要时解释这个架构的特定细节。

## 这本书是为谁准备的

这本书适合那些有一些嵌入式背景或者有Rust背景的人，然而我相信每一个对嵌入式Rust编程好奇的人都能从这本书中获得某些东西。对于那些先前没有任何经验的人，我们建议你读一下“要求和前提”部分，从书中获取、补充缺失的知识，这样能提高你的阅读体验。你可以看看“其它资源”章节，以找到你感兴趣的主题的资源。

### 要求和前提

+ 你可以轻松地使用Rust编程语言，且在一个桌面环境上写过，运行过，调试过Rust应用。你也应该熟悉[2018 edition]的术语，因为这本书是面向Rust 2018的。

[2018 edition]: https://doc.rust-lang.org/edition-guide/
+ 你可以轻松地使用其它语言，比如C，C++或者Ada开发和调试嵌入式系统，且熟悉如下的概念：
  + 交叉编译
  + 存储映射的外设（Memory Mapped Peripherals）
  + 中断
  + I2C，SPI，串口等等常见接口

### 其它资源

如果你不熟悉上面提到的东西或者你对这本书中提到的某个特定主题感兴趣，你可能可以从这些资源中找到有用的信息。

| Topic        | Resource | Description |
|--------------|----------|-------------|
| Rust         | [Rust Book](https://doc.rust-lang.org/book/) | 如果你还不能轻松地使用Rust，我们高度地建议读这本书。|
| Rust, Embedded | [Discovery Book](https://docs.rust-embedded.org/discovery/) | 如果你从来没有做过嵌入式编程，这本书可能是个更好的开始。 |
| Rust, Embedded | [Embedded Rust Bookshelf](https://docs.rust-embedded.org) | 这里你能找到许多Rust's Embedded Working Group提供的额外资源。|
| Rust, Embedded | [Embedonomicon](https://docs.rust-embedded.org/embedonomicon/) | 在Rust中进行嵌入式编程的细节。 |
| Rust, Embedded | [embedded FAQ](https://docs.rust-embedded.org/faq.html) | 关于嵌入式环境中的Rust的常见问题。|
| Interrupts | [Interrupt](https://en.wikipedia.org/wiki/Interrupt) | - |
| Memory-mapped IO/Peripherals | [Memory-mapped I/O](https://en.wikipedia.org/wiki/Memory-mapped_I/O) | - |
| SPI, UART, RS232, USB, I2C, TTL | [Stack Exchange about SPI, UART, and other interfaces](https://electronics.stackexchange.com/questions/37814/usart-uart-rs232-usb-spi-i2c-ttl-etc-what-are-all-of-these-and-how-do-th) | - |

### 翻译

这本书是已经被一些慷慨的志愿者翻译了。如果你想要将你的翻译列在这里，请打开一个PR去添加它。

* [Japanese](https://tomoyuki-nakabayashi.github.io/book/)
  ([repository](https://github.com/tomoyuki-nakabayashi/book))

* [Chinese](https://xxchang.github.io/book/)
  ([repository](https://github.com/xxchang/book))

## 如何使用这本书
这本书通常假设你是前后阅读的。之后章节是建立在先前章节中提到的概念之上的，先前章节可能不会深入一个主题的细节，因为在随后的章节将会再次重温这个主题。
这本书将在大多数案例中使用[STM32F3DISCOVERY]开发板。这个板子是基于ARM Cortex-M架构的，且基本功能与大多数基于这个架构的CPUs功能相似。微处理器的外设和其它实现细节在不同的供应商之间是不同的，甚至来自同一个供应商的不同处理器家族也是不同的。
因为这个理由，我们建议购买[STM32F3DISCOVERY]开发板来尝试这本书中的例子。(译者注：我使用[renode](https://renode.io/about/)来测试大多数例子)

[STM32F3DISCOVERY]: http://www.st.com/en/evaluation-tools/stm32f3discovery.html

## 贡献

这本书的工作主要在[这个仓库]里管理，且主要由[resouces team]开发。

[这个仓库]: https://github.com/rust-embedded/book
[resouces team]: https://github.com/rust-embedded/wg#the-resources-team

如果你按着这本书的操作遇到了什么麻烦，或者这本书的一些部分不够清楚，或者很难进行下去，那这本书就是有个bug，它应该被报道给这本书的[the issue tracker] 。

[the issue tracker]: https://github.com/rust-embedded/book/issues/

修改拼写错误和添加新内容的Pull requests非常欢迎！

## 二次使用这个材料

这本书根据以下许可证发布:

* 本书中包含的代码示例和独立的Cargo项目均根据[MIT License]和[Apache License v2.0]发放许可的。
* 本书中包含的written prose(?)，图片和表格均根据[CC-BY-SA v4.0]发放许可的。

[MIT License]: https://opensource.org/licenses/MIT
[Apache License v2.0]: http://www.apache.org/licenses/LICENSE-2.0
[CC-BY-SA v4.0]: https://creativecommons.org/licenses/by-sa/4.0/legalcode

总之：如果你想在你的工作中使用我们的文本或者图片，你需要：

+ 提供合适的授信 (i.e. 在你的幻灯片中提到本书，提供相关页面的连接)
+ 提供[CC-BY-SA v4.0]的许可证的连接
+ 指出你是否改变了材料的内容，在同一个许可证下，可以对材料进行任何改变

也请告诉我这本书对你是否有帮助！

