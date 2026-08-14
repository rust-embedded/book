#import "@preview/codly:1.3.0": codly

#let insert-code(
  full_code,
  tgt: "html",
  lang: "rust",
  block: true,
  anchor: none,
  lines: none,
  offset: 0,
  line-numbers: false,
) = {
  let offset = offset
  let code = if type(anchor) == str {
    let lines = full_code.split("\n")
    let left = lines.position(l => { regex("ANCHOR:\s+"+anchor) in l })
    offset = offset + left
    let right = lines.position(l => { regex("ANCHOR_END:\s+"+anchor) in l })
    lines.slice(left+1, right).join("\n")
  } else if type(lines) == int {
    offset = offset + lines - 1
    full_code.split("\n").at(lines - 1)
  } else if type(lines) == array {
    offset = offset + lines.at(0) - 1
    full_code.split("\n").slice(lines.at(0) - 1, lines.at(1)).join("\n")
  } else {
    full_code
  }
  if tgt == "pdf" {
    if line-numbers {
      codly(number-format: numbering.with("1"))
    }
    codly(offset: offset)
    raw(code, lang: lang, block: block)
    codly(number-format: none)
  } else {
    raw(code, lang: lang, block: block)
  }
}
