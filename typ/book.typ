#import "config.typ": *
#import "mdbook/lib.typ": book

#let sources = (
  "intro/index": (
    content: include "intro/index.typ",
    title: tr((
      en: [Introduction],
      de: [Einleitung],
      ja: [導入],
      uk: [Вступ],
      zh: [引言],
    )),
    sub: (
      "intro/hardware": (
        content: include "intro/hardware.typ",
        title: tr((
          en: [Hardware],
          de: [Hardware],
          ja: [ハードウェア],
          uk: [Залізо],
          zh: [硬件],
        )),
      ),
      "intro/no-std": (
        content: include "intro/no-std.typ",
        title: `no_std`
      ),
      "intro/tooling": (
        content: include "intro/tooling.typ",
        title: tr((
          en: [Tooling],
          de: [Werkzeuge],
          ja: [ツール],
          uk: [Інструменти],
          zh: [工具],
        )),
      ),
      "intro/install": (
        content: include "intro/install.typ",
        title: tr((
          en: [Installation],
          de: [Installation],
          ja: [インストール],
          uk: [Встановлення],
          zh: [安装],
        )),
        sub: (
          "intro/install/linux": (
            content: include "intro/install/linux.typ",
            title: [Linux]
          ),
          "intro/install/macos": (
            content: include "intro/install/macos.typ",
            title: [MacOS]
          ),
          "intro/install/windows": (
            content: include "intro/install/windows.typ",
            title: [Windows]
          ),
          "intro/install/verify": (
            content: include "intro/install/verify.typ",
            title: tr((
              en: [Verify Installation],
              de: [Die Installation überprüfen],
              ja: [インストールの確認],
              uk: [Перевірка встановлення],
              zh: [验证工具链的安装],
            )),
          )
        )
      ),
    ),
  ),
  "start/index": (
    content: include "start/index.typ",
    title: tr((
      en: [Getting started],
      de: [Erste Schritte],
      ja: [入門],
      uk: [Початок роботи],
      zh: [开始],
    )),
    sub: (
      "start/qemu": (
        content: include "start/qemu.typ",
        title: [QEMU]
      ),
      "start/hardware": (
        content: include "start/hardware.typ",
        title: tr((
          en: [Hardware],
          de: [Hardware],
          ja: [ハードウェア],
          uk: [Залізо],
          zh: [硬件],
        )),
      ),
      "start/registers": (
        content: include "start/registers.typ",
        title: tr((
          en: [Memory-mapped Registers],
          de: [Im Speicher abgebildete Register],
          ja: [メモリマップドレジスタ],
          uk: [Відображені в пам'яті регістри],
          zh: [存储映射的寄存器],
        )),
      ),
      "start/semihosting": (
        content: include "start/semihosting.typ",
        title: tr((
          ja: [セミホスティング],
          zh: [半主机模式],
        ), default: [Semihosting]),
      ),
      "start/panicking": (
        content: include "start/panicking.typ",
        title: tr((
          en: [Panicking],
          de: [In Panik geraten],
          ja: [パニック],
          uk: [Паніка],
          zh: [运行时恐慌(Panicking)],
        )),
      ),
      "start/exceptions": (
        content: include "start/exceptions.typ",
        title: tr((
          en: [Exceptions],
          de: [Exceptions],
          ja: [例外],
          uk: [Виключення],
          zh: [异常],
        )),
      ),
      "start/interrupts": (
        content: include "start/interrupts.typ",
        title: tr((
          en: [Interrupts],
          de: [Interrupts],
          ja: [割り込み],
          uk: [Переривання],
          zh: [中断],
        )),
      ),
    )
  ),
  "peripherals/index": (
    content: include "peripherals/index.typ",
    title: tr((
      en: [Peripherals],
      de: [Peripheriegeräte],
      ja: [ペリフェラル],
      uk: [Периферійні пристрої],
      zh: [外设],
    )),
    sub: (
      "peripherals/a-first-attempt": (
        content: include "peripherals/a-first-attempt.typ",
        title: tr((
          en: [A first attempt in Rust],
          de: [Ein erster Versuch in Rust],
          ja: [Rustでの最初の試み],
          uk: [Перша спроба на Rust],
          zh: [Rust尝鲜],
        )),
      ),
      "peripherals/borrowck": (
        content: include "peripherals/borrowck.typ",
        title: tr((
          en: [The Borrow Checker],
          de: [Der Borrow-Prüfer],
          ja: [借用チェッカ],
          uk: [Перевірка запозичень],
          zh: [借用检查器],
        )),
      ),
      "peripherals/singletons": (
        content: include "peripherals/singletons.typ",
        title: tr((
          en: [Singletons],
          de: [Singletons],
          ja: [シングルトン],
          uk: [Одинаки],
          zh: [单例],
        )),
      )
    )
  ),
  "static-guarantees/index": (
    content: include "static-guarantees/index.typ",
    title: tr((
      en: [Static Guarantees],
      de: [Statische Garantien],
      ja: [静的な保証],
      uk: [Статичні гарантії],
      zh: [静态保障(static guarantees)],
    )),
    sub: (
      "static-guarantees/typestate-programming": (
        content: include "static-guarantees/typestate-programming.typ",
        title: tr((
          en: [Typestate Programming],
          de: [Typgestützte Programmierung],
          ja: [型状態プログラミング],
          uk: [Програмування типів-станів],
          zh: [类型状态编程],
        )),
      ),
      "static-guarantees/state-machines": (
        content: include "static-guarantees/state-machines.typ",
        title: tr((
          en: [Peripherals as State Machines],
          de: [Peripheriegeräte als Zustandsmaschinen],
          ja: [ステートマシンとしてのペリフェラル],
          uk: [Периферія як кінцеві автомати],
          zh: [把外设当作状态机],
        )),
      ),
      "static-guarantees/design-contracts": (
        content: include "static-guarantees/design-contracts.typ",
        title: tr((
          en: [Design Contracts],
          de: [Designverträge],
          ja: [設計契約],
          uk: [Угоди щодо дизайну],
          zh: [设计约定],
        )),
      ),
      "static-guarantees/zero-cost-abstractions": (
        content: include "static-guarantees/zero-cost-abstractions.typ",
        title: tr((
          en: [Zero Cost Abstractions],
          de: [Abstraktionen ohne Kosten],
          ja: [ゼロコスト抽象化],
          uk: [Безкоштовні абстракції],
          zh: [零成本抽象],
        )),
      ),
    )
  ),
  "portability/index": (
    content: include "portability/index.typ",
    title: tr((
      en: [Portability],
      de: [Portabilität],
      ja: [移植性],
      uk: [Переносимість],
      zh: [可移植性],
    )),
  ),
  "concurrency/index": (
    content: include "concurrency/index.typ",
    title: tr((
      en: [Concurrency],
      de: [Nebenläufigkeit],
      ja: [並行性],
      uk: [Паралелізм],
      zh: [并发],
    )),
  ),
  "collections/index": (
    content: include "collections/index.typ",
    title: tr((
      en: [Collections],
      de: [Sammlungen],
      ja: [コレクション],
      uk: [Колекції],
      zh: [容器],
    )),
  ),
  "design-patterns/index": (
    content: include "design-patterns/index.typ",
    title: tr((
      en: [Design Patterns],
      de: [Desginmuster],
      uk: [Шаблони проектування],
      zh: [设计模式],
    )),
    sub: (
      "design-patterns/hal/index": (
        content: include "design-patterns/hal/index.typ",
        title: tr((
          en: [HALs],
          de: [HALs],
          zh: [HALs],
          uk: [HALи]
        )),
        sub: (
          "design-patterns/hal/checklist": (
            content: include "design-patterns/hal/checklist.typ",
            title: tr((
              en: [Checklist],
              de: [Checkliste],
              uk: [Контрольний список],
              zh: [列表],
            )),
          ),
          "design-patterns/hal/naming": (
            content: include "design-patterns/hal/naming.typ",
            title: tr((
              en: [Naming],
              de: [Benennung],
              uk: [Найменування],
              zh: [命名],
            )),
          ),
          "design-patterns/hal/interoperability": (
            content: include "design-patterns/hal/interoperability.typ",
            title: tr((
              en: [Interoperability],
              de: [Interoperabilität],
              uk: [Сумісність],
              zh: [互操性],
            )),
          ),
          "design-patterns/hal/predictability": (
            content: include "design-patterns/hal/predictability.typ",
            title: tr((
              en: [Predictability],
              de: [Vorhersehbarkeit],
              uk: [Передбачуваність],
              zh: [可预见性],
            )),
          ),
          "design-patterns/hal/gpio": (
            content: include "design-patterns/hal/gpio.typ",
            title: [GPIO]
          ),
        )
      )
    )
  ),
  "c-tips/index": (
    content: include "c-tips/index.typ",
    title: tr((
      en: [Tips for embedded C developers],
      de: [Tipps für Entwickler im Bereich Embedded-C],
      ja: [組込みC開発者へのヒント],
      uk: [Поради для розробників мовою C],
      zh: [给嵌入式C开发者的贴士],
    )),
  ),
  "interoperability/index": (
    content: include "interoperability/index.typ",
    title: tr((
      en: [Interoperability],
      de: [Interoperabilität],
      ja: [相互運用性],
      uk: [Сумісність],
      zh: [互操性],
    )),
    sub: (
      "interoperability/c-with-rust": (
        content: include "interoperability/c-with-rust.typ",
        title: tr((
          en: [A little C with your Rust],
          de: [Ein bisschen C zu Ihrem Rust],
          ja: [Rustと少しのC],
          uk: [Трошки C в вашому Rust],
          zh: [使用C的Rust],
        )),
      ),
      "interoperability/rust-with-c": (
        content: include "interoperability/rust-with-c.typ",
        title: tr((
          en: [A little Rust with your C],
          de: [Ein bisschen Rust zu Ihrem C],
          ja: [Cと少しのRust],
          uk: [Трошки Rust в вашому C],
          zh: [使用Rust的C],
        )),
      )
    )
  ),
  "unsorted/index": (
    content: include "unsorted/index.typ",
    title: tr((
      en: [Unsorted topics],
      de: [Unsortierte Themen],
      ja: [未分類のトピック],
      uk: [Невідсортовані теми],
      zh: [没有排序的主题],
    )),
    sub: (
      "unsorted/speed-vs-size": (
        content: include "unsorted/speed-vs-size.typ",
        title: tr((
          en: [Optimizations: The speed size tradeoff],
          de: [Optimierungen: Der Kompromiss zwischen Geschwindigkeit und Größe],
          ja: [最適化: 速度とサイズのトレードオフ],
          uk: [Оптимізація: компроміс між швидкістю та розміром],
          zh: [优化: 速度与大小间的博弈],
        )),
      ),
      "unsorted/math": (
        content: include "unsorted/math.typ",
        title:  tr((
          en: [Performing Math Functionality],
          de: [Ausführung mathematischer Funktionen],
          uk: [Виконання математики],
          zh: [执行数学运算],
        )),
      )
    )
  ),
  "appendix/glossary": (
    content: include "appendix/glossary.typ",
    title: tr((
      en: [Appendix A: Glossary],
      de: [Anhang A: Glossar],
      uk: [Додаток А: Глосарій],
      zh: [附录A: 词汇表],
    )),
  )
)

#book(
  tgt,
  sources,
  lang,
  languages,
  book_title: "The Embedded Rust Book",
  git: "https://github.com/rust-embedded/book",
)
