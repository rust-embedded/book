# 类型状态编程(Typestate Programming)

[typestates]的概念是指将有关对象当前状态的信息编码进该对象的类型中。虽然这听起来有点神秘，如果你在Rust中用过[建造者模式]，你就已经开始使用类型状态编程了！

[typestates]: https://en.wikipedia.org/wiki/Typestate_analysis
[建造者模式]: https://doc.rust-lang.org/1.0.0/style/ownership/builders.html

```rust
pub mod foo_module {
    #[derive(Debug)]
    pub struct Foo {
        inner: u32,
    }

    pub struct FooBuilder {
        a: u32,
        b: u32,
    }

    impl FooBuilder {
        pub fn new(starter: u32) -> Self {
            Self {
                a: starter,
                b: starter,
            }
        }

        pub fn double_a(self) -> Self {
            Self {
                a: self.a * 2,
                b: self.b,
            }
        }

        pub fn into_foo(self) -> Foo {
            Foo {
                inner: self.a + self.b,
            }
        }
    }
}

fn main() {
    let x = foo_module::FooBuilder::new(10)
        .double_a()
        .into_foo();

    println!("{:#?}", x);
}
```

在这个例子里，不能直接生成一个`Foo`对象。必须先生成一个`FooBuilder`，并且恰当地初始化`FooBuilder`后，才能获取到需要的`Foo`对象。

这个最小的例子编码了两个状态:

* `FooBuilder`，其表示一个"没有被配置"，或者"正在配置"状态
* `Foo`，其表示了一个"被配置"，或者"可以使用"状态。

## 强类型

因为Rust有一个[强类型系统]，没有什么简单的方法可以奇迹般地生成一个`Foo`实例，也没有简单的方法可以不用调用`into_foo()`方法而把一个`FooBuilder`变成一个`Foo`。另外，调用`into_foo()`方法消费了最初的`FooBuilder`结构体，意味着不生成一个新的实例就不能被再次使用它。

[强类型系统]: https://en.wikipedia.org/wiki/Strong_and_weak_typing

这允许我们可以将系统的状态表示成类型，把状态转换必须的动作包括进转换两个类型的方法中。通过生成一个 `FooBuilder`，转换成一个 `Foo` 对象，我们已经使用了一个基本的状态机。

