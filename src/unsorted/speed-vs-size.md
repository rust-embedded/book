# 优化: 速度与大小之间的均衡

每个人都想要它们的程序变得超级快且超级小，但是同时满足这两个条件是不可能的。这部分讨论`rustc`提供的不同的优化等级，和它们是如何影响执行时间和一个程序的二进制文件大小。

## 没有优化

这是默认的。当你调用`cargo build`时，你使用的是development(又叫`dev`)配置。这个配置优化的目的是为了调试，因此它使能了调试信息且*关闭*了所有优化，i.e. 它使用 `-C opt-level = 0` 。

至少对于裸机开发来说，调试信息不会占用Flash/ROM中的空间，意味着在这种情况下，调试信息是零开销的，因此实际上我们推荐你在release配置中使能调试信息 -- 默认它被关闭了。那可以让你调试release编译时，使用断点。

``` toml
[profile.release]
# 符号很好且它们不会增加Flash上的大小
debug = true
```

没有优化对于调试来说是最好的，因为沿着代码单步调试
No optimizations is great for debugging because stepping through the code feels
like you are executing the program statement by statement, plus you can `print`
stack variables and function arguments in GDB. When the code is optimized, trying
to print variables results in `$0 = <value optimized out>` being printed.

The biggest downside of the `dev` profile is that the resulting binary will be
huge and slow. The size is usually more of a problem because unoptimized
binaries can occupy dozens of KiB of Flash, which your target device may not
have -- the result: your unoptimized binary doesn't fit in your device!

我们可以有更小的，调试友好的二进制文件吗?是的，这里有一个技巧。

### 优化依赖

这里有个名为[`profile-overrides`]的Cargo feature，其可以让你覆盖依赖的优化等级。你能使用那个feature去优化所有依赖的大小，而保持顶层的crate没有被优化且调试起来友好。

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

在Flash的使用上减少了6KiB，而不会损害顶层crate的可调试性。如果你步进一个依赖，然后你将开始再次看到那些`<value optimized out>`信息但是


、 If you step into a dependency then you'll start seeing those
`<value optimized out>` messages again but it's usually the case that you want
to debug the top crate and not the dependencies. And if you *do* need to debug a
dependency then you can use the `profile-overrides` feature to exclude a
particular dependency from being optimized. See example below:

``` toml
# ..

# don't optimize the `cortex-m-rt` crate
[profile.dev.package.cortex-m-rt] # +
opt-level = 0 # +

# but do optimize all the other dependencies
[profile.dev.package."*"]
codegen-units = 1 # better optimizations
opt-level = "z"
```

Now the top crate and `cortex-m-rt` are debugger friendly!

## 优化速度

As of 2018-09-18 `rustc` supports three "optimize for speed" levels: `opt-level
= 1`, `2` and `3`. When you run `cargo build --release` you are using the release
profile which defaults to `opt-level = 3`.

Both `opt-level = 2` and `3` optimize for speed at the expense of binary size,
but level `3` does more vectorization and inlining than level `2`. In
particular, you'll see that at `opt-level` equal to or greater than `2` LLVM will
unroll loops. Loop unrolling has a rather high cost in terms of Flash / ROM
(e.g. from 26 bytes to 194 for a zero this array loop) but can also halve the
execution time given the right conditions (e.g. number of iterations is big
enough).

Currently there's no way to disable loop unrolling in `opt-level = 2` and `3` so
if you can't afford its cost you should optimize your program for size.

## 优化尺寸

自2018-09-18开始`rustc`支持两个"优化尺寸"的等级: `opt-level = "s"` 和 `"z"` 。这些名字传承自 clang / LLVM 且不具有描述性，但是`"z"`意味着它产生的二进制文件比`"s"`更小。

如果你想要发布一个优化了尺寸的二进制文件，那么改变下面展示的`Cargo.toml`中的`profile.release.opt-level`配置。

``` toml
[profile.release]
# or "z"
opt-level = "s"
```

这两个优化等级


These two optimization levels greatly reduce LLVM's inline threshold, a metric
used to decide whether to inline a function or not. One of Rust principles are
zero cost abstractions; these abstractions tend to use a lot of newtypes and
small functions to hold invariants (e.g. functions that borrow an inner value
like `deref`, `as_ref`) so a low inline threshold can make LLVM miss
optimization opportunities (e.g. eliminate dead branches, inline calls to
closures).

When optimizing for size you may want to try increasing the inline threshold to
see if that has any effect on the binary size. The recommended way to change the
inline threshold is to append the `-C inline-threshold` flag to the other
rustflags in `.cargo/config.toml`.

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
