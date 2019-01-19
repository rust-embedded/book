set -euxo pipefail

main() {
    local tag=$(git ls-remote --tags --refs --exit-code \
                    https://github.com/rust-lang-nursery/mdbook \
                        | cut -d/ -f3 \
                        | grep -E '^v[0.1.0-9.]+$' \
                        | sort --version-sort \
                        | tail -n1)
    # Temporarily use older version until packages are available for 0.2.2 (or newer)
    local tag="v0.2.1"
    curl -LSfs https://japaric.github.io/trust/install.sh | \
        sh -s -- --git rust-lang-nursery/mdbook --tag $tag

    pip install linkchecker --user
}

main
