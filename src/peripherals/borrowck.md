## 可变的全局状态

不幸地是，硬件本质上是个可变的全局状态，对于Rust开发者来说可能感到很害怕。硬件独立于我们所写的代码的结构，能被真实世界在任何时候改变。

## 我们应该遵循什么规则?

我们如何才能做到可靠地与这些外设交互?

1. 总是使用 `volatile` 方法去读或者写外设存储器。因为它可以随时改变。(译者注：对于存在多级缓存的MCU，这方法更为重要)
2. 在软件中，我们应该能共享任何数量的 对这些外设的只读访问
3. 如果一些软件对一个外设应该可以读写访问，它应该保有对那个外设的唯一引用。

## The Borrow Checker
## 借用检查器

这些规则最后两个听起来与借用检查器已经做的事相似。

思考一下，我们是否可以分发这些外设的所有权，或者引用它们？

我们当然可以，但是对于借用检查器，每个外设我们都需要一个实例。
Well, we can, but for the Borrow Checker, we need to have exactly one instance of each peripheral, so Rust can handle this correctly. Well, luckily in the hardware, there is only one instance of any given peripheral, but how can we expose that in the structure of our code?
