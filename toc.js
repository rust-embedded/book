// Populate the sidebar
//
// This is a script, and not included directly in the page, to control the total size of the book.
// The TOC contains an entry for each page, so if each page includes a copy of the TOC,
// the total size of the page becomes O(n**2).
class MDBookSidebarScrollbox extends HTMLElement {
    constructor() {
        super();
    }
    connectedCallback() {
        this.innerHTML = '<ol class="chapter"><li class="chapter-item expanded "><a href="intro/index.html"><strong aria-hidden="true">1.</strong> Introduction</a></li><li><ol class="section"><li class="chapter-item expanded "><a href="intro/hardware.html"><strong aria-hidden="true">1.1.</strong> Hardware</a></li><li class="chapter-item expanded "><a href="intro/no-std.html"><strong aria-hidden="true">1.2.</strong> no_std</a></li><li class="chapter-item expanded "><a href="intro/tooling.html"><strong aria-hidden="true">1.3.</strong> Tooling</a></li><li class="chapter-item expanded "><a href="intro/install.html"><strong aria-hidden="true">1.4.</strong> Installation</a></li><li><ol class="section"><li class="chapter-item expanded "><a href="intro/install/linux.html"><strong aria-hidden="true">1.4.1.</strong> Linux</a></li><li class="chapter-item expanded "><a href="intro/install/macos.html"><strong aria-hidden="true">1.4.2.</strong> MacOS</a></li><li class="chapter-item expanded "><a href="intro/install/windows.html"><strong aria-hidden="true">1.4.3.</strong> Windows</a></li><li class="chapter-item expanded "><a href="intro/install/verify.html"><strong aria-hidden="true">1.4.4.</strong> Verify Installation</a></li></ol></li></ol></li><li class="chapter-item expanded "><a href="start/index.html"><strong aria-hidden="true">2.</strong> Getting started</a></li><li><ol class="section"><li class="chapter-item expanded "><a href="start/qemu.html"><strong aria-hidden="true">2.1.</strong> QEMU</a></li><li class="chapter-item expanded "><a href="start/hardware.html"><strong aria-hidden="true">2.2.</strong> Hardware</a></li><li class="chapter-item expanded "><a href="start/registers.html"><strong aria-hidden="true">2.3.</strong> Memory-mapped Registers</a></li><li class="chapter-item expanded "><a href="start/semihosting.html"><strong aria-hidden="true">2.4.</strong> Semihosting</a></li><li class="chapter-item expanded "><a href="start/panicking.html"><strong aria-hidden="true">2.5.</strong> Panicking</a></li><li class="chapter-item expanded "><a href="start/exceptions.html"><strong aria-hidden="true">2.6.</strong> Exceptions</a></li><li class="chapter-item expanded "><a href="start/interrupts.html"><strong aria-hidden="true">2.7.</strong> Interrupts</a></li><li class="chapter-item expanded "><a href="start/io.html"><strong aria-hidden="true">2.8.</strong> IO</a></li></ol></li><li class="chapter-item expanded "><a href="peripherals/index.html"><strong aria-hidden="true">3.</strong> Peripherals</a></li><li><ol class="section"><li class="chapter-item expanded "><a href="peripherals/a-first-attempt.html"><strong aria-hidden="true">3.1.</strong> A first attempt in Rust</a></li><li class="chapter-item expanded "><a href="peripherals/borrowck.html"><strong aria-hidden="true">3.2.</strong> The Borrow Checker</a></li><li class="chapter-item expanded "><a href="peripherals/singletons.html"><strong aria-hidden="true">3.3.</strong> Singletons</a></li></ol></li><li class="chapter-item expanded "><a href="static-guarantees/index.html"><strong aria-hidden="true">4.</strong> Static Guarantees</a></li><li><ol class="section"><li class="chapter-item expanded "><a href="static-guarantees/typestate-programming.html"><strong aria-hidden="true">4.1.</strong> Typestate Programming</a></li><li class="chapter-item expanded "><a href="static-guarantees/state-machines.html"><strong aria-hidden="true">4.2.</strong> Peripherals as State Machines</a></li><li class="chapter-item expanded "><a href="static-guarantees/design-contracts.html"><strong aria-hidden="true">4.3.</strong> Design Contracts</a></li><li class="chapter-item expanded "><a href="static-guarantees/zero-cost-abstractions.html"><strong aria-hidden="true">4.4.</strong> Zero Cost Abstractions</a></li></ol></li><li class="chapter-item expanded "><a href="portability/index.html"><strong aria-hidden="true">5.</strong> Portability</a></li><li class="chapter-item expanded "><a href="concurrency/index.html"><strong aria-hidden="true">6.</strong> Concurrency</a></li><li class="chapter-item expanded "><a href="collections/index.html"><strong aria-hidden="true">7.</strong> Collections</a></li><li class="chapter-item expanded "><a href="design-patterns/index.html"><strong aria-hidden="true">8.</strong> Design Patterns</a></li><li><ol class="section"><li class="chapter-item expanded "><a href="design-patterns/hal/index.html"><strong aria-hidden="true">8.1.</strong> HALs</a></li><li><ol class="section"><li class="chapter-item expanded "><a href="design-patterns/hal/checklist.html"><strong aria-hidden="true">8.1.1.</strong> Checklist</a></li><li class="chapter-item expanded "><a href="design-patterns/hal/naming.html"><strong aria-hidden="true">8.1.2.</strong> Naming</a></li><li class="chapter-item expanded "><a href="design-patterns/hal/interoperability.html"><strong aria-hidden="true">8.1.3.</strong> Interoperability</a></li><li class="chapter-item expanded "><a href="design-patterns/hal/predictability.html"><strong aria-hidden="true">8.1.4.</strong> Predictability</a></li><li class="chapter-item expanded "><a href="design-patterns/hal/gpio.html"><strong aria-hidden="true">8.1.5.</strong> GPIO</a></li></ol></li></ol></li><li class="chapter-item expanded "><a href="c-tips/index.html"><strong aria-hidden="true">9.</strong> Tips for embedded C developers</a></li><li class="chapter-item expanded "><a href="interoperability/index.html"><strong aria-hidden="true">10.</strong> Interoperability</a></li><li><ol class="section"><li class="chapter-item expanded "><a href="interoperability/c-with-rust.html"><strong aria-hidden="true">10.1.</strong> A little C with your Rust</a></li><li class="chapter-item expanded "><a href="interoperability/rust-with-c.html"><strong aria-hidden="true">10.2.</strong> A little Rust with your C</a></li></ol></li><li class="chapter-item expanded "><a href="unsorted/index.html"><strong aria-hidden="true">11.</strong> Unsorted topics</a></li><li><ol class="section"><li class="chapter-item expanded "><a href="unsorted/speed-vs-size.html"><strong aria-hidden="true">11.1.</strong> Optimizations: The speed size tradeoff</a></li><li class="chapter-item expanded "><a href="unsorted/math.html"><strong aria-hidden="true">11.2.</strong> Performing Math Functionality</a></li></ol></li><li class="chapter-item expanded "><li class="spacer"></li><li class="chapter-item expanded affix "><a href="appendix/glossary.html">Appendix A: Glossary</a></li></ol>';
        // Set the current, active page, and reveal it if it's hidden
        let current_page = document.location.href.toString().split("#")[0].split("?")[0];
        if (current_page.endsWith("/")) {
            current_page += "index.html";
        }
        var links = Array.prototype.slice.call(this.querySelectorAll("a"));
        var l = links.length;
        for (var i = 0; i < l; ++i) {
            var link = links[i];
            var href = link.getAttribute("href");
            if (href && !href.startsWith("#") && !/^(?:[a-z+]+:)?\/\//.test(href)) {
                link.href = path_to_root + href;
            }
            // The "index" page is supposed to alias the first chapter in the book.
            if (link.href === current_page || (i === 0 && path_to_root === "" && current_page.endsWith("/index.html"))) {
                link.classList.add("active");
                var parent = link.parentElement;
                if (parent && parent.classList.contains("chapter-item")) {
                    parent.classList.add("expanded");
                }
                while (parent) {
                    if (parent.tagName === "LI" && parent.previousElementSibling) {
                        if (parent.previousElementSibling.classList.contains("chapter-item")) {
                            parent.previousElementSibling.classList.add("expanded");
                        }
                    }
                    parent = parent.parentElement;
                }
            }
        }
        // Track and set sidebar scroll position
        this.addEventListener('click', function(e) {
            if (e.target.tagName === 'A') {
                sessionStorage.setItem('sidebar-scroll', this.scrollTop);
            }
        }, { passive: true });
        var sidebarScrollTop = sessionStorage.getItem('sidebar-scroll');
        sessionStorage.removeItem('sidebar-scroll');
        if (sidebarScrollTop) {
            // preserve sidebar scroll position when navigating via links within sidebar
            this.scrollTop = sidebarScrollTop;
        } else {
            // scroll sidebar to current active section when navigating via "next/previous chapter" buttons
            var activeSection = document.querySelector('#sidebar .active');
            if (activeSection) {
                activeSection.scrollIntoView({ block: 'center' });
            }
        }
        // Toggle buttons
        var sidebarAnchorToggles = document.querySelectorAll('#sidebar a.toggle');
        function toggleSection(ev) {
            ev.currentTarget.parentElement.classList.toggle('expanded');
        }
        Array.from(sidebarAnchorToggles).forEach(function (el) {
            el.addEventListener('click', toggleSection);
        });
    }
}
window.customElements.define("mdbook-sidebar-scrollbox", MDBookSidebarScrollbox);
