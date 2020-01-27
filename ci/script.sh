set -euxo pipefail

main() {
    mdbook build
    mdbook test

    linkchecker book

    # now check this as a directory of the bookshelf
    rm -rf shelf
    mkdir shelf
    mv book shelf
    linkchecker shelf

    mv shelf/book .
    rmdir shelf
}

main
