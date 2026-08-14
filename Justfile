clean:
    rm -r book

build-en:
    typst compile typ/book.typ --input lang=en --input target=html book --features bundle,html -f bundle
    typst compile typ/book.typ --input lang=en --input target=pdf book/book_en.pdf

build-de:
    typst compile typ/book.typ --input lang=de --input target=html book --features bundle,html -f bundle
    typst compile typ/book.typ --input lang=de --input target=pdf book/book_de.pdf
    typst compile typ/book.typ --input lang=de --input target=pdf book/book_de_tr.pdf --input goal=translation

build-ja:
    typst compile typ/book.typ --input lang=ja --input target=html book --features bundle,html -f bundle
    typst compile typ/book.typ --input lang=ja --input target=pdf book/book_ja.pdf
    typst compile typ/book.typ --input lang=ja --input target=pdf book/book_ja_tr.pdf --input goal=translation

build-uk:
    typst compile typ/book.typ --input lang=uk --input target=html book --features bundle,html -f bundle
    typst compile typ/book.typ --input lang=uk --input target=pdf book/book_uk.pdf
    typst compile typ/book.typ --input lang=uk --input target=pdf book/book_uk_tr.pdf --input goal=translation

build-zh:
    typst compile typ/book.typ --input lang=zh --input target=html book --features bundle,html -f bundle
    typst compile typ/book.typ --input lang=zh --input target=pdf book/book_zh.pdf
    typst compile typ/book.typ --input lang=zh --input target=pdf book/book_zh_tr.pdf --input goal=translation

build: build-en build-de build-ja build-uk build-zh

check-links:
    linkchecker book

format-html:
    for file in `find book -name "*.html"`; do \
        echo $file; \
        tidy -qim --alt-text "inlined image" --tidy-mark no --warn-proprietary-attributes no -w 120 --custom-tags blocklevel $file; \
    done
