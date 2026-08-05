(() => {
    const fullPath = window.location.pathname;

    // Derive siteRoot from a langtag segment (e.g. /xx-xx/) in the URL.
    function deriveSiteRoot() {
        const m = fullPath.match(/^(.+?)\/([a-z]{2}-[a-z]{2})\//);
        return m ? m[1] : "";
    }

    const siteRoot = deriveSiteRoot();

    function loadConfig() {
        return fetch(siteRoot + "/switcher.json")
            .then((r) => { if (!r.ok) throw new Error("not found"); return r.json(); })
            .catch(() => null);
    }

    function whenReady(fn) {
        if (document.readyState === "loading") {
            document.addEventListener("DOMContentLoaded", fn);
        } else {
            fn();
        }
    }

    whenReady(() => {
        loadConfig().then((data) => {
            if (!data) return;

            const afterSite = fullPath.substring(siteRoot.length);
            const parts = afterSite.split("/").filter(Boolean);

            if (data.languages) renderLanguageSwitcher(data.languages, parts);
            if (data.versions)  renderVersionSwitcher(data.versions, parts);
        });
    });

    // ---- Language switcher ----

    function renderLanguageSwitcher(languages, parts) {
        const knownLangtags = new Set(languages.map((l) => l.langtag));

        let currentLangtag = "";
        let langtagIdx = -1;
        for (let i = 0; i < parts.length; i++) {
            if (knownLangtags.has(parts[i])) {
                langtagIdx = i;
                currentLangtag = parts[i];
                break;
            }
        }
        if (langtagIdx < 0) return;

        const tail = "/" + parts.slice(langtagIdx + 1).join("/");

        const container = document.createElement("div");
        container.className = "language-switcher";
        container.innerHTML =
            '<label for="language-select" title="Language">' +
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="1.25em" height="1.25em" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">' +
            '<circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/>' +
            '<path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"/>' +
            '</svg></label>' +
            '<select id="language-select">' +
            languages.map((lang) =>
                '<option value="' + lang.langtag + '"' + (lang.langtag === currentLangtag ? ' selected' : '') + '>' +
                lang.langname +
                '</option>'
            ).join("") +
            '</select>';

        insert(container);

        document.getElementById("language-select").addEventListener("change", (e) => {
            window.location.href = siteRoot + "/" + e.target.value + tail;
        });
    }

    // ---- Version switcher ----

    function renderVersionSwitcher(versions, parts) {
        const knownVersions = new Set(versions.map((v) => v.version));
        const defaultVersion = versions[0].version;

        let currentVersion = defaultVersion;
        let versionIdx = -1;
        for (let i = 0; i < parts.length; i++) {
            if (knownVersions.has(parts[i])) {
                versionIdx = i;
                currentVersion = parts[i];
                break;
            }
        }
        if (versionIdx < 0) return;

        const prefix   = "/" + parts.slice(0, versionIdx).join("/");
        const pagePath = "/" + parts.slice(versionIdx + 1).join("/");

        const container = document.createElement("div");
        container.className = "version-switcher";
        container.innerHTML =
            '<label for="version-select" title="Version">' +
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="1.25em" height="1.25em" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">' +
            '<line x1="6" y1="3" x2="6" y2="15"/><circle cx="18" cy="6" r="3"/><circle cx="6" cy="18" r="3"/>' +
            '<path d="M18 9a9 9 0 0 1-9 9"/>' +
            '</svg></label>' +
            '<select id="version-select">' +
            versions.map((v) =>
                '<option value="' + v.version + '"' + (v.version === currentVersion ? ' selected' : '') + '>' +
                v.label +
                '</option>'
            ).join("") +
            '</select>';

        insert(container);

        document.getElementById("version-select").addEventListener("change", (e) => {
            const newVersion = e.target.value;
            window.location.href = siteRoot + prefix + "/" + newVersion + pagePath;
        });
    }

    function insert(container) {
        const menuBar = document.querySelector(".right-buttons");
        if (menuBar) {
            menuBar.insertBefore(container, menuBar.firstChild);
        }
    }
})();
