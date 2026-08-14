#import "../../config.typ": *

#h1((en: [Naming],
  de: [Benennung],
  zh: [命名],
), offset: whole*2)
<hal-naming>

= #tr((
  en: [The crate is named appropriately],
  de: [Das Crate trägt einen passenden Namen],
  zh: [crate要被恰当地命名],
)) (C-CRATE-NAME)
<c-crate-name>

#tr((
en: [
  HAL crates should be named after the chip or family of chips they aim to
  support. Their name should end with `-hal` to distinguish them from
  register access crates. The name should not contain underscores (use
  dashes instead).
],
de: [
  HAL-Crates sollten nach dem Chip oder der Chip-Familie benannt werden,
  die sie unterstützen sollen. Ihr Name sollte auf `-hal` enden, um sie
  von Registerzugriffs-Crates zu unterscheiden. Der Name sollte keine
  Unterstriche enthalten (stattdessen sind Bindestriche zu verwenden).
],
zh: [
  HAL crates应该在目标支持的芯片或者芯片系列之后被命名。它们的名字应该以`-hal`结尾，为了将它们与PAC区分开来。名字不应该包含下划线(请改用破折号)。
]))
