# Introduction

Welcome to "The Embedded Rust Book", an introductory book about using the Rust
Programming Language on "Bare Metal" embedded systems, such as Microcontrollers.

## Who Embedded Rust is For

> **TODO**

## Scope

The goals of this book are:

* Get developers up to speed with embedded Rust development. i.e. How to set
  up a development environment.

* Share *current* best practices about using Rust for embedded development. i.e.
  How to best use Rust language features to write more correct embedded
  software.

* Serve as a cookbook in some cases. e.g. How do I do mix C and Rust in a single
  project?

This book tries to be as general as possible but to make things easier for both
the readers and the writers it uses the ARM Cortex-M architectures in all its
examples. However, the book assumes that the reader is not familiar with this
particular architecture and explains details particular to this architecture
where required.

## Who This Book is For

This book assumes the following:

* You are comfortable using the Rust Programming Language, and have written,
  run, and debugged Rust applications on a desktop environment. You should also
  be familiar with the idioms of the [2018 edition] as this book targets
  Rust 2018.

[2018 edition]: https://rust-lang-nursery.github.io/edition-guide/

* You are comfortable developing and debugging embedded systems in another
  language such as C, C++, or Ada, and are familiar with concepts such as:
    * Cross Compilation
    * Memory Mapped Peripherals
    * Interrupts
    * Common interfaces such as I2C, SPI, Serial, and others

If you are not yet comfortable with Rust, we highly suggest completing the [Rust
Book] before attempting to learn with this book.

If you are not yet comfortable with Embedded Systems, we highly suggest checking
our other resources before attempting to learn with this book.

> **TODO** "other resources" should link to docs.rust-embedded.org when that's
> live. In the meantime you can check the [Discovery] book.

[Discovery]: https://rust-embedded.github.io/discovery/
[Rust Book]: https://doc.rust-lang.org/book/second-edition

## How to Use This Book

This book generally assumes that you’re reading it front-to-back, that is, later
chapters build on top of concepts in earlier chapters, and earlier chapters may
not dig into details on a topic, revisiting the topic in a later chapter.

This book will be using the [STMF3DISCOVERY] development board from
STMicroelectronics for the majority of the examples contained within. This board
is based on the ARM Cortex-M architecture, and while basic functionality is
common across most CPUs based on this architecture, peripherals and other
implementation details of Microcontrollers are different between different
vendors, and often even different between Microcontroller families from the same
vendor.

For this reason, we suggest purchasing the [STMF3DISCOVERY] development board
for the purpose of following this book.

[STMF3DISCOVERY]: http://www.st.com/en/evaluation-tools/stm32f3discovery.html

> **HEADS UP** Until the official release of this book, which is planned to
> coincide with the 2018 edition release of the Rust Programming Language,
> expect the sections of this book to shift quite a bit. We recommend
> bookmarking the root of this book instead of any specific section.

## Contributing to This Book

The work on this book is coordinated in [this repository] and is mainly
developed by the [resources team].

[this repository]: https://github.com/rust-lang-nursery/embedded-wg/book
[resources team]: https://github.com/rust-embedded/wg

If you have trouble following the instructions in this book or find that some
section of the book is not clear enough or hard to follow that's a bug and it
should be reported in [the issue tracker] of this book.

[the issue tracker]: https://github.com/rust-lang-nursery/embedded-wg/book/issues

Pull requests fixing typos and adding new content are very welcome!
