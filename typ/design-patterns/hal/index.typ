#import "../../config.typ": *

#h1((en: [HAL Design Patterns],
  de: [HAL-Design-Muster],
  zh: [HAL设计模式],
), offset: whole)

#let url_quide = "https://rust-lang.github.io/api-guidelines/"
#tr((
en: [
  This is a set of common and recommended patterns for writing hardware
  abstraction layers (HALs) for microcontrollers in Rust. These patterns
  are intended to be used in addition to the existing
  #link(url_quide)[Rust API Guidelines]
  when writing HALs for microcontrollers.
  - #link(<hal-checklist>)[Checklist]
  - #link(<hal-naming>)[Naming]
  - #link(<hal-interoperability>)[Interoperability]
  - #link(<hal-predictability>)[Predictability]
  - #link(<hal-gpio>)[GPIO]
],
de: [
  Hierbei handelt es sich um eine Sammlung bewährter und empfohlener
  Muster für die Implementierung von Hardware-Abstraktionsschichten (HALs)
  für Mikrocontroller in Rust. Diese Muster sind als Ergänzung zu den
  bestehenden #link(url_quide)[Rust-API-Richtlinien]
  für die Entwicklung von HALs für Mikrocontroller gedacht.
  #link(<hal-checklist>)[Checkliste]
  - #link(<hal-naming>)[Benennung]
  - #link(<hal-interoperability>)[Interoperabilität]
  - #link(<hal-predictability>)[Vorhersehbarkeit]
  - #link(<hal-gpio>)[GPIO]
],
zh: [
  这是一组关于使用Rust为微控制器写硬件抽象层的常见的和推荐的模式。当为微控制器编写HALs时，除了现有的
  #link(url_quide)[Rust API 指南]
  外，也可以使用这些模式。
  #link(<hal-checklist>)[检查清单]
  - #link(<hal-interoperability>)[命名]
  - #link(<hal-predictability>)[互用性]
  - #link(<hal-predictability>)[可预见性]
  - #link(<hal-gpio>)[GPIO]
]))
