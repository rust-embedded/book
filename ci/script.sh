set -euxo pipefail

main() {
    mdbook build

    linkchecker book
}

main
