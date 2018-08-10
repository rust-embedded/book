set -euxo pipefail

main() {
    mdbook build

    mdbook serve &
    sleep 1
    linkchecker http://localhost:3000
    kill $!
}

main
