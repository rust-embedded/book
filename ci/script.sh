set -euxo pipefail

main() {
    mdbook build
    mdbook test

    # FIXME(rust-lang-nursery/mdbook#789) remove `--ignore-url` when that bug is fixed
    linkchecker --ignore-url "print.html" book

    # now check this as a directory of the bookshelf
    rm -rf shelf
    mkdir shelf
    mv book shelf
    # FIXME(rust-lang-nursery/mdbook#789) remove `--ignore-url` when that bug is fixed
    linkchecker --ignore-url "print.html" shelf

    mv shelf/book .
    rmdir shelf
}

main
