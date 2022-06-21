# 优化: 速度与大小之间的均衡

每个人都想要它们的程序变得超级快且超级小，但是同时满足这两个条件是不可能的。这部分讨论`rustc`提供的不同的优化等级，和它们是如何影响执行时间和一个程序的二进制文件大小。

## 不优化

这是默认的。当你调用`cargo build`时，你使用的是development(又叫`dev`)配置。这个配置优化的目的是为了调试，因此它使能了调试信息且*关闭*了所有优化，i.e. 它使用 `-C opt-level = 0` 。

至少对于裸机开发来说，调试信息不会占用Flash/ROM中的空间，意味着在这种情况下，调试信息是零开销的，因此实际上我们推荐你在release配置中使能调试信息 -- 默认它被关闭了。那让你调试release版本的固件时可以使用断点。

``` toml
[profile.release]
# 符号很好且它们不会增加Flash上的大小
debug = true
```

不优化对于调试来说是最好的，因为单步调试代码感觉像是你正在逐条语句地执行程序，且你能在GDB中`print`栈变量和函数参数。当代码被优化了，尝试打印变量会导致`$0 = <value optimized out>`被打印出来。

`dev`配置最大的缺点就是最终的二进制文件将会变得巨大且缓慢。大小通常是一个更大的问题，因为未优化的二进制文件会占据大量KiB的Flash，你的目标设备可能没这么多Flash -- 结果: 你未优化的二进制文件无法烧录进你的设备中！

我们可以有更小的，调试友好的二进制文件吗?是的，这里有一个技巧。

### 优化依赖

这里有个名为[`profile-overrides`]的Cargo feature，其可以让你覆盖依赖项的优化等级。你能使用这个feature去优化所有依赖的大小，而保持顶层的crate没有被优化以致调试起来友好。

[`profile-overrides`]: https://doc.rust-lang.org/cargo/reference/profiles.html#overrides

这是一个示例:

``` toml
# Cargo.toml
[package]
name = "app"
# ..

[profile.dev.package."*"] # +
opt-level = "z" # +
```

没有覆盖:

``` text
$ cargo size --bin app -- -A
app  :
section               size        addr
.vector_table         1024   0x8000000
.text                 9060   0x8000400
.rodata               1708   0x8002780
.data                    0  0x20000000
.bss                     4  0x20000000
```

有覆盖:

``` text
$ cargo size --bin app -- -A
app  :
section               size        addr
.vector_table         1024   0x8000000
.text                 3490   0x8000400
.rodata               1100   0x80011c0
.data                    0  0x20000000
.bss                     4  0x20000000
```

在Flash的使用上减少了6KiB，而不会损害顶层crate的可调试性。如果你步进一个依赖项，然后你将开始再次看到那些`<value optimized out>`信息，但是通常的情况下你只想调试顶层的crate而不是依赖项。如果你 *需要* 调试一个依赖项，那么你可以使用`profile-overrides` feature去防止一个特定的依赖项被优化。看下面的例子:

``` toml
# ..

# 不要优化`cortex-m-rt` crate
[profile.dev.package.cortex-m-rt] # +
opt-level = 0 # +

# 但是优化所有其它依赖项
[profile.dev.package."*"]
codegen-units = 1 # better optimizations
opt-level = "z"
```

现在顶层的crate和`cortex-m-rt`对调试器很友好！

## 优化速度

自2018-09-18开始 `rustc` 支持三个 "优化速度" 的等级: `opt-level = 1`, `2` 和 `3` 。当你运行 `cargo build --release` 时，你正在使用的是release配置，其默认是 `opt-level = 3` 。

`opt-level = 2` 和 `3` 都以二进制文件大小为代价优化速度，但是等级`3`比等级`2`做了更多的向量化和内联。特别是，你将看到在`opt-level`等于或者大于`2`时LLVM将展开循环。循环展开在 Flash / ROM 方面的成本相当高(e.g. from 26 bytes to 194 for a zero this array loop)但是如果条件合适(迭代次数足够大)，也可以将执行时间减半。

现在还没有办法在`opt-level = 2`和`3`的情况下关闭循环展开，因此如果你不能接受它的开销，你应该优化你程序的尺寸。

## 优化尺寸

自2018-09-18开始`rustc`支持两个"优化尺寸"的等级: `opt-level = "s"` 和 `"z"` 。这些名字传承自 clang / LLVM 且不具有描述性，但是`"z"`意味着它产生的二进制文件比`"s"`更小。

如果你想要发布一个优化了尺寸的二进制文件，那么改变下面展示的`Cargo.toml`中的`profile.release.opt-level`配置。

``` toml
[profile.release]
# or "z"
opt-level = "s"
```

这两个优化等级极大地减少了LLVM的内联阈值，一个用来决定是否内联或者不内联一个函数的度量。Rust其中一个概念是零成本抽象；这些抽象趋向于去使用许多新类型和小函数去保持不变量(e.g. 像是`deref`，`as_ref`这样借用内部值的函数)因此一个低内联阈值会使LLVM失去优化的机会(e.g. 去掉死分支(dead branches)，内联对闭包的调用)。

当优化尺寸时，你可能想要尝试增加增加内联阈值去观察是否会对你的二进制文件的大小有影响。推荐的改变内联阈值的方法是在`.cargo/config.toml`中往其它rustflags后插入`-C inline-threshold` 。

``` toml
# .cargo/config.toml
# 这里假设你正在使用cortex-m-quickstart模板
[target.'cfg(all(target_arch = "arm", target_os = "none"))']
rustflags = [
  # ..
  "-C", "inline-threshold=123", # +
]
```

用什么值?[从1.29.0开始，这些是不同优化级别使用的内联阈值][inline-threshold]:

[inline-threshold]: https://github.com/rust-lang/rust/blob/1.29.0/src/librustc_codegen_llvm/back/write.rs#L2105-L2122

- `opt-level = 3` 使用 275
- `opt-level = 2` 使用 225
- `opt-level = "s"` 使用 75
- `opt-level = "z"` 使用 25

当优化尺寸时，你应该尝试`225`和`275` 。
