#!/usr/bin/env python3
"""Export the executed Lab 9 HTML notebook as a five-page PDF.

Requires Python packages playwright and pypdf, plus a local Chromium browser.
Run after publish() from the toolbox root: python tools/export_lab09.py
No experiment output is recalculated or replaced by this formatting step.
"""

from pathlib import Path
import base64
import re
import shutil

from playwright.sync_api import sync_playwright
from pypdf import PdfReader


def main():
    root = Path(__file__).resolve().parents[1]
    source = root / "html" / "Lab09" / "Lab09_notebook.html"
    target = root / "docs" / "Team08_Lab09.pdf"
    browser_path = shutil.which("chromium") or shutil.which("google-chrome")
    if not source.is_file():
        raise SystemExit(f"Publish Lab09_notebook.m into {source.parent} first.")
    if not browser_path:
        raise SystemExit("A local Chromium or Google Chrome browser is required.")

    with sync_playwright() as playwright:
        browser = playwright.chromium.launch(
            executable_path=browser_path,
            headless=True,
            args=["--no-sandbox", "--disable-dev-shm-usage"],
        )
        page = browser.new_page()
        # The report uses plain text formulas, so MathJax is unnecessary.
        # Rendering the local notebook and figures needs no network requests.
        page.route("https://**/*", lambda route: route.abort())
        document = source.read_text(encoding="utf-8")

        def inline_image(match):
            image = (source.parent / match.group(1)).resolve()
            if image.parent != source.parent.resolve() or image.suffix != ".png":
                raise ValueError(f"Unexpected notebook image: {image.name}")
            data = base64.b64encode(image.read_bytes()).decode("ascii")
            return f'<img src="data:image/png;base64,{data}"'

        # Inline local figures because managed browsers may disallow file://.
        document = re.sub(r'<img src="([^"]+)"', inline_image, document)
        page.set_content(document, wait_until="load")
        outputs = page.locator("pre.oct-code-output").all_text_contents()
        evidence = "\n\n".join(outputs)
        if "9 passed, 0 failed, 9 total" not in evidence:
            raise SystemExit("The published notebook does not show nine passing labs.")
        images = page.locator("img").evaluate_all(
            "items => items.map(i => ({ok:i.complete && i.naturalWidth>0, src:i.src}))"
        )
        if len(images) != 2 or not all(item["ok"] for item in images):
            raise SystemExit("Both executed notebook figures must be present and loaded.")
        page.evaluate("""() => {
            for (const h of document.querySelectorAll('h2')) {
                if (h.textContent.trim() === 'Contents') {
                    h.classList.add('print-hide');
                    h.nextElementSibling.classList.add('print-hide');
                }
                if (/^(Finite wire|Solenoid aspect|Reversal,|Full Lab)/.test(h.textContent))
                    h.classList.add('new-page');
            }
        }""")
        page.add_style_tag(content="""
            @page { size: Letter; }
            body { font: 10.5pt/1.35 Arial, sans-serif; padding: 0; margin: 0; color: #111; }
            body > * { max-width: none; }
            h1 { font: bold 19pt/1.2 Arial, sans-serif; margin: 0 0 12pt; }
            h2 { font: bold 13pt/1.2 Arial, sans-serif; margin: 16pt 0 8pt; }
            p { margin: 7pt 0; }
            a, a:visited { color: #111; text-decoration: none; }
            pre, code { font-family: 'DejaVu Sans Mono', monospace; max-width: none; }
            pre.oct-code-output { font-size: 8pt; line-height: 1.3; margin: 8pt 0; white-space: pre-wrap; }
            img { display: block; width: 100%; height: auto; break-inside: avoid; margin: 10pt 0; }
            .new-page { break-before: page; margin-top: 0; }
            .print-hide, footer { display: none; }
        """)
        page.pdf(
            path=str(target), format="Letter", print_background=True,
            margin={"top": "0.65in", "bottom": "0.65in", "left": "0.7in", "right": "0.7in"},
            display_header_footer=True,
            header_template="<span></span>",
            footer_template=("<div style='font:9px Arial;width:100%;text-align:center'>"
                             "Team 8 | EECE 306 Lab 9 | <span class='pageNumber'></span>"
                             " / <span class='totalPages'></span></div>"),
        )
        browser.close()

    pages = len(PdfReader(target).pages)
    if not 3 <= pages <= 5:
        raise SystemExit(f"Report has {pages} pages; required length is three to five.")
    (root / "docs" / "Lab09-validation.txt").write_text(
        "Lab 9 validation: output from the executed published notebook\n"
        "GNU Octave 10.3.0; OPENBLAS_NUM_THREADS=2; OMP_NUM_THREADS=2\n"
        "Working directory: EECE306-Toolbox\n"
        "Notebook asserts that all nine cumulative test files pass.\n"
        "See README.md for publishing and PDF export commands.\n\n" + evidence,
        encoding="utf-8",
    )
    print(f"Exported {target} ({pages} pages), two verified figures, nine passing labs.")


if __name__ == "__main__":
    main()
