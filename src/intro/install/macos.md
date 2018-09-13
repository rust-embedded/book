> **⚠️: This section has not been checked as of 2018-09-13**

# macOS

All the tools can be install using [Homebrew]:

[Homebrew]: http://brew.sh/

``` console
$ # GDB
$ brew cask install gcc-arm-embedded

$ brew install openocd
```

If the `brew cask` command doesn't work (e.g. `error: unknown command: cask`),
then first run `brew tap Caskroom/tap` and try again.

> **HELP WANTED** How do we install qemu-system-arm on macOS? If you know please
> send us a [pull request].

[pull request]: https://github.com/rust-embedded/book

That's all! Go to the [next section].

[next section]: /intro/install/verify.html
