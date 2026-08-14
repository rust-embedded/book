#import "icons.typ": builtin-icon
#import "scripts.typ": builtin-script

#let lbl(path) = label(path.replace("/","-"))

#let to-string(content) = {
    if content.has("text") {
        content.text
    } else if content.has("children") {
        content.children.map(to-string).join("")
    } else if content.has("body") {
        to-string(content.body)
    } else if content == [] {
        " "
    }
}

#let elem-to-string(content) = {
  if content == none {
    ""
  } else if content.has("children") {
    content.children.map(elem-to-string).join("")
  } else if content.has("tag") {
    let attrs = ""
    if content.has("attrs") {
      for (k, v) in content.attrs {
        attrs = attrs+" "+k+"=\""+v+"\""
      }
    }
    "<"+content.tag+attrs+">"+elem-to-string(content.body)+"</"+content.tag+">"
  } else {
    to-string(content)
  }
}

#let html_head_common(pth) = {
  html.link(rel: "stylesheet", href: pth+"css/variables-8adf115d.css")
  html.link(rel: "stylesheet", href: pth+"css/general-e96d0476.css")
  html.link(rel: "stylesheet", href: pth+"css/chrome-d279d366.css")
  html.link(rel: "stylesheet", href: pth+"css/print-9e4910d8.css", media: "print")
  // Fonts
  html.link(rel: "stylesheet", href: pth+"fonts/fonts-9644e21d.css")
}

#let html_head(title, root_pth, lang-list: true) = html.head({
  html.meta(charset: "utf-8")
  html.title(title)

  html.meta(name: "description", content:"")
  html.meta(name: "viewport", content: "width=device-width, initial-scale=1")
  html.meta(name: "theme-color", content: "#ffffff")

  // Custom HTML head
  html.link(rel: "icon", href: root_pth+"favicon-de23e50b.svg")
  html.elem("link", attrs: (rel: "shortcut icon", href: root_pth+"favicon-8114d1fc.png"))
  html_head_common(root_pth)

  if lang-list {
    html.style("#language-list { left: auto; right: 10px; } #language-list a { color: inherit; }")
  }

  // Highlight.js Stylesheets
  html.link(rel: "stylesheet", id: "mdbook-highlight-css", href: root_pth+"highlight-493f70e1.css")
  html.link(rel: "stylesheet", id: "mdbook-tomorrow-night-css", href: root_pth+"tomorrow-night-4c0ae647.css")
  html.link(rel: "stylesheet", id: "mdbook-ayu-highlight-css", href: root_pth+"ayu-highlight-3fdfc3ac.css")

  // Provide site root and default themes to javascript
  builtin-script("provide-themes", root_pth: root_pth)
})

#let help_container() = html.div(id: "mdbook-help-container",
  html.div(id: "mdbook-help-popup", {
    html.h2(class: "mdbook-help-title")[Keyboard shortcuts]
    html.div({
        html.p[Press #html.kbd[←] or #html.kbd[→] to navigate between chapters]
        html.p[Press #html.kbd[S] or #html.kbd[/] to search in the book]
        html.p[Press #html.kbd[?] to show this help]
        html.p[Press #html.kbd[Esc] to hide this help]
    })
  })
)

#let body_header() = {
  // Work around some values being stored in localStorage wrapped in quotes
  builtin-script("quote-workaround")
  // Set the theme before any content is loaded, prevents flash
  builtin-script("init-theme")
  html.input(type: "checkbox", id: "mdbook-sidebar-toggle-anchor", class: "hidden")
  // Hide / unhide sidebar before it is displayed
  builtin-script("hide-sidebar")
}

#let icon_templates() = {
  html.template(id: "fa-eye", builtin-icon("eye"))
  html.template(id: "fa-eye-slash", builtin-icon("eye-slash"))
  html.template(id: "fa-copy", builtin-icon("copy"))
  html.template(id: "fa-play", builtin-icon("play"))
  html.template(id: "fa-clock-rotate-left", builtin-icon("clock-rotate-left"))
}

#let footer_scripts(pth) = {
  html.script("window.playground_copyable = true;")
  html.script(src: pth+"elasticlunr-ef4e11c1.min.js")
  html.script(src: pth+"mark-09e88c2c.min.js")
  html.script(src: pth+"searcher-09f2665d.js")
  html.script(src: pth+"clipboard-1626706a.min.js")
  html.script(src: pth+"highlight-abc7f01d.js")
  html.script(src: pth+"book-609e4cb8.js")
}

#let source_array(sources) = {
  let items = ()
  for (path, src) in sources.pairs() {
    items.push((path, src.at("content"), src.at("title")))
    let sub = src.at("sub", default: none)
    if sub != none {
      for (path, src) in sub.pairs() {
        items.push((path, src.at("content"), src.at("title")))
        let sub = src.at("sub", default: none)
        if sub != none {
          for (path, src) in sub.pairs() {
            items.push((path, src.at("content"), src.at("title")))
          }
        }
      }
    }
  }
  items
}

#let page_header(data, pth) = {
  let root_pth = data.root_prefix+pth
  html.div(id: "mdbook-menu-bar-hover-placeholder")
  html.div(id: "mdbook-menu-bar", class: ("menu-bar", "sticky"), {
    html.div(class: "left-buttons", {
      let attrs = (id: "mdbook-sidebar-toggle", class: "icon-button", title: "Toggle Table of Contents", aria-label: "Toggle Table of Contents", aria-controls: "mdbook-sidebar")
      attrs.insert("for", "mdbook-sidebar-toggle-anchor")
      html.elem("label", attrs: attrs, builtin-icon("bars"))
      html.button(id: "mdbook-theme-toggle", class: "icon-button", type: "button", title: "Change theme", aria-label: "Change theme", aria-haspopup: true, aria-expanded: false, aria-controls: "mdbook-theme-list", builtin-icon("paintbrush"))
      html.ul(id: "mdbook-theme-list", class: "theme-popup", aria-label: "Themes", role: "menu", {
        let themes = (
          default_theme: "Auto",
          light: "Light",
          rust: "Rust",
          coal: "Coal",
          navy: "Navy",
          ayu: "Ayu",
        )
        for (id, name) in themes.pairs() {
          html.li(role: none,
            html.button(role: "menuitem", class: "theme", id: "mdbook-theme-"+id, name)
          )
        }
      })
      html.button(id: "mdbook-search-toggle", class: "icon-button", type: "button", title: "Search (`/`)", aria-label: "Toggle Searchbar", aria-expanded: false, aria-keyshortcuts: "/ s", aria-controls: "mdbook-searchbar", builtin-icon("search"))
    })
    html.h1(class: "menu-title", data.book_title)
    html.div(class: "right-buttons", {
      if data.multilingual {
        html.button(id: "language-toggle", class: "icon-button", type: "button", title: "Change language", aria-label: "Change language", aria-haspopup: true, aria-expanded: false, aria-controls: "language-list", builtin-icon("globe"))
        html.ul(id: "language-list", class: "theme-popup", aria-label: "Languages", role: "menu",
          for (l, name) in data.languages {
            html.li(role: none,
              html.a(role: "menuitem", class: "theme", id: "lang-"+l, name, href: root_pth+if l == data.default_lang {
                ""
              } else {
                l+"/"
              }+"index.html"))
          }
        )
        builtin-script("show-language-list")
      }
      html.a(href: root_pth+"book_"+data.lang+".pdf", title: "PDF version of this book", aria-label: "PDF", builtin-icon("pdf", id: "book-pdf"))
      if data.git != none {
        html.a(href: data.git, title: "Git repository", aria-label: "Git repository", builtin-icon("github"))
      }
    })
  })
  html.div(id: "mdbook-search-wrapper", class: "hidden", {
    html.form(id: "mdbook-searchbar-outer", class: "searchbar-outer",
        html.div(class: "search-wrapper", {
          html.input(type: "search", id: "mdbook-searchbar", name: "searchbar", placeholder: "Search this book ...", aria-controls: "mdbook-searchresults-outer", aria-describedby: "searchresults-header")
          html.div(class: "spinner-wrapper", builtin-icon("spinner", id: "fa-spin"))
        })
    )
    html.div(id: "mdbook-searchresults-outer", class: "searchresults-outer hidden", {
        html.div(id: "mdbook-searchresults-header", class: "searchresults-header")
        html.ul(id: "mdbook-searchresults")
    })
  })

  // Apply ARIA attributes after the sidebar and the sidebar toggle button are added to the DOM
  builtin-script("apply-aria")
}

#let sidebar(depth) = html.nav(id: "mdbook-sidebar", class: "sidebar", aria-label: "Table of contents", {
  html.elem("mdbook-sidebar-scrollbox", attrs:(class: "sidebar-scrollbox"))
  html.noscript({
    let pth = (("../",)*depth).join("")
    html.iframe(class: "sidebar-iframe-outer", src: pth+"toc.html")
  })
  html.div(id: "mdbook-sidebar-resize-handle", class:"sidebar-resize-handle",
    html.div(class: "sidebar-resize-indicator")
  )
})
#let toc_tree(sources, prefix: "") = html.ol(class: "chapter", {
  let num = (0,)
  for (path, src) in sources.pairs() {
    let d = 0
    num = num.slice(0, d+1)
    num.at(d) = num.at(d) + 1
    html.li(class: ("chapter-item", "expanded"), html.span(class: "chapter-link-wrapper",
      html.a(href: prefix+path+".html", target: "_parent", [#html.strong(aria-hidden: true, num.map(i => [#i.]).join[]) #src.at("title")])
    ))
    if "sub" in src {
      html.ol(class: "section", {
        num.push(0)
        for (path, src) in src.at("sub").pairs() {
          let d = 1
          num = num.slice(0, d+1)
          num.at(d) = num.at(d) + 1
          html.li(class: ("chapter-item", "expanded"), html.span(class: "chapter-link-wrapper",
            html.a(href: prefix+path+".html", target: "_parent", [#html.strong(aria-hidden: true, num.map(i => [#i.]).join[]) #src.at("title")])
          ))
          if "sub" in src {
            html.ol(class: "section", {
              num.push(0)
              for (path, src) in src.at("sub").pairs() {
                let d = 2
                num = num.slice(0, d+1)
                num.at(d) = num.at(d) + 1
                html.li(class: ("chapter-item", "expanded"), html.span(class: "chapter-link-wrapper",
                  html.a(href: prefix+path+".html", target: "_parent", [#html.strong(aria-hidden: true, num.map(i => [#i.]).join[]) #src.at("title")])
                ))
              }
            })
          }
        }
      })
    }
  }
})
#let toc(tree, out, data) = document(out,
  html.html(lang: data.lang, class: "light", dir: ltr, {
    html.head({
      html.meta(charset: "utf-8")
      html.meta(name:"robots", content: "noindex")
      html.meta(name: "viewport", content: "width=device-width, initial-scale=1")
      html.meta(name: "theme-color", content: "#ffffff")
      html_head_common(data.root_prefix)
      html.title()
    })
    html.body(class: "sidebar-iframe-inner", tree)
  })
)

// Navigation buttons
#let nav_buttons(pth, prev, next, wide: false) = html.nav(class: if wide { "nav-wide-wrapper" } else { "nav-wrapper" }, aria-label: "Page navigation", {
  let c = if wide { "nav-chapters" } else { "mobile-nav-chapters" }
  if prev != none {
    html.a(rel: "prev", href: pth+prev+".html", class: c + " previous", title: "Previous chapter", aria-label: "Previous chapter", aria-keyshortcuts: "Left", builtin-icon("left"))
  }
  if next != none {
    html.a(rel: "next", href: pth+next+".html", class: c + " next", title: "Next chapter", aria-label: "Next chapter", aria-keyshortcuts: "Right", builtin-icon("right"))
  }
})

#let book_page(
  source,
  out,
  data,
  title,
  depth,
  sidebar,
  prev_path,
  next_path,
) = document(out,
  html.html(lang: data.lang, class: ("light", "sidebar-visible"), dir: ltr, {
    let pth = (("../",)*depth).join("")
    let root_pth = data.root_prefix+pth
    html_head(to-string(title) + " - " + data.book_title, root_pth, lang-list: data.multilingual)
    // Start loading toc.js asap
    html.script(src: pth+"toc-7ac66f26_"+data.lang+".js")
    html.body({
      help_container()
      html.div(id: "mdbook-body-container", {
        body_header()
        sidebar
        html.div(id: "mdbook-page-wrapper", class: "page-wrapper", {
          html.div(class: "page", {
            page_header(data, pth)
            html.div(id: "mdbook-content", class: "content", {
              html.main(source)
              nav_buttons(pth, prev_path, next_path)
            })
          })
          nav_buttons(pth, prev_path, next_path, wide: true)
        })
        icon_templates()
        footer_scripts(root_pth)
      })
    })
  })
)

#let asset_list = (
  "ayu-highlight-3fdfc3ac.css",
  "book-609e4cb8.js",
  "clipboard-1626706a.min.js",
  "css/chrome-d279d366.css",
  "css/general-e96d0476.css",
  "css/print-9e4910d8.css",
  "css/variables-8adf115d.css",
  "elasticlunr-ef4e11c1.min.js",
  "favicon-8114d1fc.png",
  "favicon-de23e50b.svg",
  "fonts/fonts-9644e21d.css",
  "fonts/OPEN-SANS-LICENSE.txt",
  "fonts/open-sans-v17-all-charsets-300-7736aa35.woff2",
  "fonts/open-sans-v17-all-charsets-300italic-2c7b95c0.woff2",
  "fonts/open-sans-v17-all-charsets-600-486c6759.woff2",
  "fonts/open-sans-v17-all-charsets-600italic-1a3e8659.woff2",
  "fonts/open-sans-v17-all-charsets-700-c22fe8c7.woff2",
  "fonts/open-sans-v17-all-charsets-700italic-238ae959.woff2",
  "fonts/open-sans-v17-all-charsets-800-3d2c812a.woff2",
  "fonts/open-sans-v17-all-charsets-800italic-ba1521ec.woff2",
  "fonts/open-sans-v17-all-charsets-italic-6c9463f7.woff2",
  "fonts/open-sans-v17-all-charsets-regular-2e3b1d34.woff2",
  "fonts/SOURCE-CODE-PRO-LICENSE.txt",
  "fonts/source-code-pro-v11-all-charsets-500-2bdd9410.woff2",
  "highlight-493f70e1.css",
  "highlight-abc7f01d.js",
  "mark-09e88c2c.min.js",
  "searcher-09f2665d.js",
  "searchindex-8ec871e3.js",
  "tomorrow-night-4c0ae647.css",
)

#let html_book(
  sources,
  data,
) = {
  let sa = source_array(sources)
  if data.is_root {
    for path in asset_list {
      asset(path, read("assets/"+path, encoding: none))
    }
  }
  asset(data.prefix+"toc-7ac66f26_"+data.lang+".js", read("assets/"+"toc-7ac66f26.js_part1")+elem-to-string(toc_tree(sources, prefix: data.prefix))+read("assets/"+"toc-7ac66f26.js_part2"))

  toc(toc_tree(sources), data.prefix+"toc.html", data)
  for (i, (path, source, title)) in sa.enumerate() {
    let (prev_path, _, _) = if i > 0 { sa.at(i - 1) } else { (none, none, none) }
    let (next_path, _, _) = sa.at(i + 1, default: (none, none, none))
    let out = data.prefix+path + ".html"
    let depth = path.split("/").len() - 1
    [
      #book_page(source, out, data, title, depth, sidebar(depth), prev_path, next_path) #lbl(path)
    ]
    if i == 0 {
      let depth = 0
      book_page(source, data.prefix+"index.html", data, title, depth, sidebar(depth), prev_path, next_path)
    }
  }
}

#let pdf_book(title_page, sources) = {
  import "@preview/codly:1.3.0": *
  import "@preview/codly-languages:0.1.10": *
  show: codly-init.with()
  codly(
    languages: codly-languages + (console: codly-languages.shell),
    number-format: none,
    fill: luma(250),
    zebra-fill: luma(245)
  )

  let sa = source_array(sources)
  set par(justify: true)
  set heading(numbering: "1.")
  show heading.where(level: 1): it => { pagebreak();it }

  show link: it => { text(fill: blue, it) }

  title_page

  outline(depth: 3)
  let part = "main"
  
  set page(numbering: "1", number-align: right + top)

  for (path, source, _) in sa {
    let offset = path.split("/").len() - 1
    if path.ends-with("/index") {
      offset = offset - 1
    }
    if part == "main" and path.starts-with("appendix/") {
      path = "appendix"
      counter(heading).update(0)
      set heading(numbering: "A.1.", offset: offset+1)
      source
    } else {
      set heading(offset: offset+1)
      source
    }
  }
}

#let book(
  tgt,
  sources,
  lang,
  languages,
  default_lang: "en",
  book_title: "The Book",
  title_page: none,
  git: none,
) = {
  let is_root = lang == default_lang
  let data = (
    lang: lang,
    languages: languages,
    is_root: is_root,
    multilingual: languages.keys().len() > 1,
    prefix: if is_root { "" } else { lang+"/" },
    root_prefix: if is_root {
      ""
    } else {
      "../"
    },
    book_title: book_title,
    git: git,
    default_lang: default_lang,
  )
  if tgt == "pdf" {
    pdf_book(
      if title_page == none [
        #v(1fr)
        #align(center, text(size: 40pt, [#book_title\ (#data.languages.at(data.lang))]))
        #v(1fr)
      ] else { title_page },
      sources,
    )
  } else if tgt == "html" {
    html_book(
      sources,
      data,
    )
  }
}
