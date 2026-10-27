
#let builtin-script(name, ..attrs) = {
  let s = if name == "provide-themes" {
    let root_pth = attrs.at("root_pth")
    "
      const path_to_root = \""+root_pth+"\";
      const default_light_theme = \"light\";
      const default_dark_theme = \"navy\";
      window.path_to_searchindex_js = \""+root_pth+"searchindex-8ec871e3.js\";
    "
  } else if name == "quote-workaround" {
    "
      try {
          let theme = localStorage.getItem('mdbook-theme');
          let sidebar = localStorage.getItem('mdbook-sidebar');

          if (theme.startsWith('\"') && theme.endsWith('\"')) {
              localStorage.setItem('mdbook-theme', theme.slice(1, theme.length - 1));
          }

          if (sidebar.startsWith('\"') && sidebar.endsWith('\"')) {
              localStorage.setItem('mdbook-sidebar', sidebar.slice(1, sidebar.length - 1));
          }
      } catch (e) { }
    "
  } else if name == "init-theme" {
    "
      const default_theme = window.matchMedia(\"(prefers-color-scheme: dark)\").matches ? default_dark_theme : default_light_theme;
      let theme;
      try { theme = localStorage.getItem('mdbook-theme'); } catch(e) { }
      if (theme === null || theme === undefined) { theme = default_theme; }
      const html = document.documentElement;
      html.classList.remove('light')
      html.classList.add(theme);
      html.classList.add(\"js\");
    "
  } else if name == "hide-sidebar" {
    "
      let sidebar = null;
      const sidebar_toggle = document.getElementById(\"mdbook-sidebar-toggle-anchor\");
      if (document.body.clientWidth >= 1080) {
          try { sidebar = localStorage.getItem('mdbook-sidebar'); } catch(e) { }
          sidebar = sidebar || 'visible';
      } else {
          sidebar = 'hidden';
          sidebar_toggle.checked = false;
      }
      if (sidebar === 'visible') {
          sidebar_toggle.checked = true;
      } else {
          html.classList.remove('sidebar-visible');
      }
    "
  } else if name == "apply-aria" {
    "
      document.getElementById('mdbook-sidebar-toggle').setAttribute('aria-expanded', sidebar === 'visible');
      document.getElementById('mdbook-sidebar').setAttribute('aria-hidden', sidebar !== 'visible');
      Array.from(document.querySelectorAll('#mdbook-sidebar a')).forEach(function(link) {
          link.setAttribute('tabIndex', sidebar === 'visible' ? 0 : -1);
      });
    "
  } else if name == "show-language-list" {
    "
      let langToggle = document.getElementById(\"language-toggle\");
      let langList = document.getElementById(\"language-list\");
      langToggle.addEventListener(\"click\", (event) => {
          langList.style.display = langList.style.display == \"block\" ? \"none\" : \"block\";
      });
    "
  }
  html.script(s)
}