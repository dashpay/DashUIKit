#!/usr/bin/env python3
"""Pins screenshots-check.py: each case feeds it saved API answers (the changed files, and
the PR with the description rendered as GitHub's body_html) and expects a pass or a failure.
Runs without the network. Run from the repository root."""
import json
import os
import subprocess
import sys
import tempfile

SCRIPT = os.path.join(os.getcwd(), ".github", "scripts", "screenshots-check.py")
UI = [{"filename": "Sources/DashUIKit/Components/SearchBar.swift"}]
IMG = '<a target="_blank" rel="noopener noreferrer" href="https://github.com/user-attachments/assets/%s"><img width="260" alt="x" src="https://github.com/user-attachments/assets/%s" style="max-width: 100%%;"></a>'
A, B = IMG % ("1111", "1111"), IMG % ("2222", "2222")


def h(level, text):
    return '<div class="markdown-heading" dir="auto"><h%d class="heading-element" dir="auto">%s</h%d><a id="x" class="anchor" aria-label="Permalink" href="#x"></a></div>' % (level, text, level)


def task(text, ticked):
    box = '<input type="checkbox" id="" disabled="" class="task-list-item-checkbox" aria-label="%s"%s>' % (
        "Completed task" if ticked else "Incomplete task", ' checked=""' if ticked else "")
    return '<ul class="contains-task-list"><li class="task-list-item">%s %s</li></ul>' % (box, text)


CASES = [
    ("no Sources/ files", "pass", [{"filename": ".github/workflows/ci.yml"}], ""),
    ("two images under h2 Before / After", "pass", UI, h(2, "Before / After") + "<p>%s %s</p>" % (A, B)),
    ("emoji and h3", "pass", UI, h(3, "📸 Before / After") + "<table><tr><td>%s</td><td>%s</td></tr></table>" % (A, B)),
    ("an older Screenshots heading", "pass", UI, h(2, "Screenshots") + "<p>%s</p><p>%s</p>" % (A, B)),
    ("subheadings inside the section", "pass", UI, h(2, "Before / After") + h(3, "Light") + A + h(3, "Dark") + B),
    ("one image", "fail", UI, h(2, "Before / After") + A),
    ("the same image with two signed queries", "fail", UI, h(2, "Before / After")
     + '<img src="https://private-user-images.githubusercontent.com/1/x.png?jwt=a"><img src="https://private-user-images.githubusercontent.com/1/x.png?jwt=b">'),
    ("images under another heading", "fail", UI, h(2, "Before / After") + "<p>none</p>" + h(2, "How Has This Been Tested?") + A + B),
    ("images above the section", "fail", UI, A + B + h(2, "Before / After")),
    ("the empty template cells", "fail", UI, h(2, "Before / After") + '<img width="260" src=""><img width="260">'),
    ("data-canonical-src counts", "pass", UI, h(2, "Before / After")
     + '<img src="https://camo.githubusercontent.com/1" data-canonical-src="https://example.com/1.png"><img src="https://camo.githubusercontent.com/2" data-canonical-src="https://example.com/2.png">'),
    ("No visual change ticked", "pass", UI, h(2, "Before / After") + task('No visual change (refactor, tests, docs). Say why in "What was done?".', True)),
    ("No visual change unticked", "fail", UI, task("No visual change (refactor, tests, docs).", False)),
    ("another task ticked", "fail", UI, task("I have performed a self-review of my own code", True)),
    ("empty description", "fail", UI, None),
    ("Before & After heading", "pass", UI, h(2, "Before &amp; After") + A + B),
    ("emoji and badges are not screenshots", "fail", UI, h(2, "Before / After")
     + '<img class="emoji" src="https://github.githubassets.com/images/icons/emoji/shipit.png"><img src="https://img.shields.io/badge/a-b-c">'),
    ("two videos", "pass", UI, h(2, "Before / After")
     + '<video src="https://github.com/user-attachments/assets/aaaa"></video><video src="https://github.com/user-attachments/assets/bbbb"></video>'),
    ("query is the identity on other hosts", "pass", UI, h(2, "Before / After")
     + '<img src="https://host.example/render?id=1"><img src="https://host.example/render?id=2">'),
    ("a newline in a path is escaped", "fail", [{"filename": "Sources/a\n::error::forged.swift"}], ""),
    ("a Screenshot tests heading is not the section", "fail", UI, h(2, "Screenshot tests") + A + B),
    ("Screenshots with a parenthetical", "pass", UI, h(2, "📸 Screenshots (light and dark)") + A + B),
    ("a workflow badge and codecov are not screenshots", "fail", UI, h(2, "Before / After")
     + '<img src="https://github.com/dashpay/DashUIKit/actions/workflows/ci.yml/badge.svg"><img src="https://codecov.io/gh/x/y/graph/badge.svg">'),
    ("one upload with and without ?raw=true", "fail", UI, h(2, "Before / After")
     + '<img src="https://github.com/user-attachments/assets/aaaa"><img src="https://github.com/user-attachments/assets/aaaa?raw=true">'),
    ("a malformed URL does not crash the ticked box", "pass", UI, h(2, "Before / After")
     + '<img src="http://[bad/x.png">' + task("No visual change", True)),
    ("a struck-out tick does not count", "fail", UI, task("<del>No visual change</del>", True)),
    ("Package.swift alone is a UI change", "fail", [{"filename": "Package.swift"}], ""),
    ("one image in each of two sections", "fail", UI, h(2, "Screenshots") + A + h(2, "Other") + "<p>x</p>" + h(2, "Before / After") + B),
    ("a Screenshots heading nested in Before / After", "pass", UI, h(2, "Before / After") + A + h(3, "Screenshots") + h(3, "Dark") + B),
    ("renamed out of Sources/", "fail", [{"filename": "Legacy/Toast.swift", "previous_filename": "Sources/DashUIKit/Components/Toast.swift"}], ""),
]


def run(files, body_html, changed_files=None):
    with tempfile.TemporaryDirectory() as d:
        fj, pj = os.path.join(d, "files.json"), os.path.join(d, "pr.json")
        json.dump(files, open(fj, "w"))
        json.dump({"body_html": body_html, "changed_files": changed_files or len(files)}, open(pj, "w"))
        env = dict(os.environ, GITHUB_STEP_SUMMARY="")
        return subprocess.run([sys.executable, SCRIPT, "--files-json", fj, "--pr-json", pj],
                              capture_output=True, text=True, env=env)


def main():
    failures = 0
    over = [{"filename": "docs/%d.md" % i} for i in range(3000)]
    cases = CASES + [("over the files cap, no Sources/ seen", "fail", over, "", 3500),
                     ("over the files cap, with screenshots", "pass", over, h(2, "Before / After") + A + B, 3500)]
    for case in cases:
        name, want, files, html = case[:4]
        r = run(files, html, case[4] if len(case) > 4 else None)
        # A failure must be the check's own verdict, not a crash that also exits 1.
        ok = ("Traceback" not in r.stderr) and ((r.returncode == 0) if want == "pass"
              else (r.returncode == 1 and "::error::" in r.stdout))
        if name.startswith("a newline in a path") and "\n::error::forged" in r.stdout:
            ok = False
        print(("ok    " if ok else "FAIL  ") + name)
        if not ok:
            failures += 1
            print("      expected %s, got exit %d\n      %s" % (want, r.returncode, (r.stdout + r.stderr).strip().replace("\n", "\n      ")))
    print("%d case(s) failed" % failures if failures else "All cases passed")
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
