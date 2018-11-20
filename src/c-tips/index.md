# Tips for embedded C developers

This chapter collects a variety of tips that might be useful to experienced
embedded C developers looking to start writing Rust. It will especially
highlight how things you might already be used to in C are different in Rust.

## Preprocessor

In embedded C it is very common to use the preprocessor for a varity of
purposes, such as:

* Compile-time selection of code blocks with `#ifdef`
* Compile-time array sizes and computations
* Macros to simplify common patterns (to avoid function call overhead)

In Rust there is no preprocessor, and so many of these use cases are addressed
differently. In the rest of this section we cover various alternatives to
using the preprocessor.

### Compile-Time Code Selection

The closest match to `#ifdef ... #endif` in Rust are [Cargo features]. These
are a little more formal than the C preprocessor: all possible features are
explicitly listed per crate, and can only be either on or off. Features are
turned on when you list a crate as a dependency, and are additive: if any crate
in your dependency tree enables a feature for another crate, that feature will
be enabled for all users of that crate.

[Cargo features]: https://doc.rust-lang.org/cargo/reference/manifest.html#the-features-section

For example, you might have a crate which provides a library of signal
processing primitives. Each one might take some extra time to compile or
declare some large table of constants which you'd like to avoid. You could
declare a Cargo feature for each component in your `Cargo.toml`:

```toml
[features]
FIR = []
IIR = []
```

Then, in your code, use `#[cfg(feature="FIR")]` to control what is included.

```rust
/// In your top-level lib.rs

#[cfg(feature="FIR")]
pub mod fir;

#[cfg(feature="IIR")]
pub mod iir;
```

You can similarly include code blocks only if a feature is _not_ enabled, or if
any combination or features is or is not enabled.

The feature selection will only apply to the next statement or block. If a block can not be used in the current scope then then `cfg` attribute will need to be used multiple times.
It's worth noting that most of the time it is better to simply include all the
code and allow the compiler to remove dead code when optimising: it's simpler
for you and your users, and in general the compiler will do a good job of
removing unused code.

### Compile-Time Sizes and Computation

Rust supports `const fn`, functions which are guaranteed to be evaluable at
compile-time and can therefore be used where constants are required, such as
in the size of arrays. This can be used alongside features mentioned above,
for example:

```rust
const fn array_size() -> usize {
    #[cfg(feature="use_more_ram")]
    { 1024 }
    #[cfg(not(feature="use_more_ram")]
    { 128 }
}

static BUF: [u32; array_size()] = [0u32; array_size()];
```

These are new to stable Rust as of 1.31, so documentation is still sparse. The
functionality available to `const fn` is also very limited at the time of
writing; in future Rust releases it is expected to expand on what is permitted
in a `const fn`.

### Macros

Rust provides an extremely powerful [macro system]. While the C preprocessor
operates almost directly on the text of your source code, the Rust macro system
operates at a higher level. There are two varieties of Rust macro: _macros by
example_ and _procedural macros_. The former are simpler and most common; they
look like function calls and can expand to a complete expression, statement,
item, or pattern. Procedural macros are more complex but permit extremely
powerful additions to the Rust language: they can transform arbitrary Rust
syntax into new Rust syntax.

[macro system]: https://doc.rust-lang.org/book/second-edition/appendix-04-macros.html

In general, where you might have used a C preprocessor macro, you probably want
to see if a macro-by-example can do the job instead. They can be defined in
your crate and easily used by your own crate or exported for other users. Be
aware that since they must expand to complete expressions, statements, items,
or patterns, some use cases of C preprocessor macros will not work, for example
a macro that expands to part of a variable name or an incomplete set of items
in a list.

As with Cargo features, it is worth considering if you even need the macro. In
many cases a regular function is easier to understand and will be inlined to
the same code as a macro. The `#[inline]` and `#[inline(always)]` [attributes]
give you further control over this process, although care should be taken here
as well — the compiler will automatically inline functions from the same crate
where appropriate, so forcing it to do so inappropriately might actually lead
to decreased performance.

[attributes]: https://doc.rust-lang.org/reference/attributes.html#inline-attribute

Explaining the entire Rust macro system is out of scope for this tips page, so
you are encouraged to consult the Rust documentation for full details.

## Build System

Most Rust crates are built using Cargo (although it is not required). This
takes care of many difficult problems with traditional build systems. However,
you may wish to customise the build process. Cargo provides [`build.rs`
scripts] for this purpose. They are Rust scripts which can interact with the
Cargo build system as required.

[`build.rs` scripts]: https://doc.rust-lang.org/cargo/reference/build-scripts.html

Common use cases for build scripts include:

* provide build-time information, for example statically embedding the build
  date or Git commit hash into your executable
* generate linker scripts at build time depending on selected features or other
  logic
* change the Cargo build configuration
* add extra static libraries to link against

### Cross-Compiling

Using Cargo for your build system also simplifies cross-compiling. In most
cases it suffices to tell Cargo `--target thumbv6m-none-eabi` and find a
suitable executable in `target/thumbv6m-none-eabi/debug/myapp`.

For platforms not natively supported by Rust, you will need to build `libcore`
for that target yourself. On such platforms, [Xargo] can be used as a stand-in
for Cargo which automatically builds `libcore` for you.

[Xargo]: https://github.com/japaric/xargo

## Iterators vs Array Access

In C you are probably used to accessing arrays directly by their index:

```c
int16_t arr[16];
int i;
for(i=0; i<sizeof(arr)/sizeof(arr[0]); i++) {
    process(arr[i]);
}
```

In Rust this is an anti-pattern: indexed access can be slower (as it needs to
be bounds checked) and may prevent various compiler optimisations.

Instead, use iterators:

```rust
let arr = [0u16; 16];
for element in arr.iter() {
    process(*arr);
}
```

Iterators provide a powerful array of functionality you would have to implement
manually in C, such as chaining, zipping, enumerating, finding the min or max,
summing, and more. Iterator methods can also be chained, giving very readable
data processing code.

See the [Iterators in the Book] and [Iterator documentation] for more details.

[Iterators in the Book]: https://doc.rust-lang.org/book/second-edition/ch13-02-iterators.html
[Iterator method documentation]: https://doc.rust-lang.org/core/iter/trait.Iterator.html

## References vs Pointers

In Rust, pointers (called [_raw pointers_]) exist but are rarely used:
dereferencing them is always considered `unsafe` as Rust cannot provide its
usual guarantees about what might be behind the pointer.

[_raw pointers_]: https://doc.rust-lang.org/book/second-edition/ch19-01-unsafe-rust.html#dereferencing-a-raw-pointer

In most cases, we instead use _references_, indicated by the `&` symbol, or
_mutable references_, indicated by `&mut`. References behave similarly to
pointers, in that they can be dereferenced to access the underlying values, but
they are a key part of Rust's ownership system: Rust will strictly enforce that
you may only have one mutable reference _or_ multiple non-mutable references to
the same value at any given time.

In practice this means you have to be more careful about whether you need
mutable access to data: where in C the default is mutable and you must be
explicit about `const`, in Rust the opposite is true.

## Other Resources

* In this book: [A little C with your Rust](../interoperability/c-with-rust.md)
* In this book: [A little Rust with your C](../interoperability/rust-with-c.md)
* [The Rust Embedded FAQs](https://docs.rust-embedded.org/faq.html)
* [Rust Pointers for C Programmers](http://blahg.josefsipek.net/?p=580)
* [I used to use pointers - now what?](https://github.com/diwic/reffers-rs/blob/master/docs/Pointers.md)
