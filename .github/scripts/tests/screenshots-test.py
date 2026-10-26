#!/usr/bin/env python3
"""Pins screenshots-check.py: each case feeds it saved API answers (the changed files, and
the PR with the description rendered as GitHub's body_html) and expects a pass or a failure.
Runs without the network. Run from the repository root."""
import json
import os
import re
import secrets
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
    ("a newline in a path stays inside the stop block", "fail", [{"filename": "Sources/a\n::error::forged.swift"}], ""),
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
    ("Screenshots with more words in the heading", "pass", UI, h(2, "UI screenshots: light / dark") + A + B),
    ("a numbered Screenshots heading", "pass", UI, h(2, "1. Screenshots &amp; video") + A + B),
    ("a struck-out image does not count", "fail", UI, h(2, "Before / After") + A + "<del>%s</del>" % B),
    ("an image in <s> does not count", "fail", UI, h(2, "Before / After") + A + "<s>%s</s>" % B),
    ("a struck-out heading is not the section", "fail", UI, h(2, "<del>Before / After</del>") + A + B),
    ("a plural Screenshots tests heading is not the section", "fail", UI, h(2, "Screenshots tests") + A + B),
    ("a hyphenated Screenshot-testing heading is not the section", "fail", UI, h(2, "Screenshot-testing") + A + B),
    ("Screenshot_tests is not the section", "fail", UI, h(2, "Screenshot_tests") + A + B),
    ("a Screenshot of the test run is not the section", "fail", UI, h(2, "Before / After") + "<p>x</p>"
     + h(2, "How Has This Been Tested?") + h(3, "Screenshot of the test run") + A + B),
    ("Screenshots of the latest build", "pass", UI, h(2, "Screenshots of the latest build") + A + B),
    ("Screenshots (tests) is not the section", "fail", UI, h(2, "Screenshots (tests)") + A + B),
    ("Screenshot/snapshot tests is not the section", "fail", UI, h(2, "Screenshot/snapshot tests") + A + B),
    ("Screenshots anywhere in the heading", "pass", UI, h(2, "iOS screenshots") + A + B),
    ("Light / dark screenshots", "pass", UI, h(2, "Light / dark screenshots") + A + B),
    ("Screenshots (testnet)", "pass", UI, h(2, "Screenshots (testnet)") + A + B),
    ("Screenshots from TestFlight", "pass", UI, h(2, "Screenshots from TestFlight") + A + B),
    ("Screenshots (tested on iPhone 16)", "pass", UI, h(2, "Screenshots (tested on iPhone 16)") + A + B),
    ("screenshots in a Badge folder count", "pass", UI, h(2, "Before / After")
     + '<img src="https://example.com/docs/Badge/light.png"><img src="https://example.com/docs/Badge/dark.png">'),
    ("a goreportcard badge is not a screenshot", "fail", UI, h(2, "Before / After") + A
     + '<img src="https://goreportcard.com/badge/github.com/x/y">'),
    ("a Codacy badge is not a screenshot", "fail", UI, h(2, "Before / After") + A
     + '<img src="https://app.codacy.com/project/badge/Grade/abc">'),
    ("a Read the Docs badge is not a screenshot", "fail", UI, h(2, "Before / After") + A
     + '<img src="https://readthedocs.org/projects/x/badge/?version=latest">'),
    ("a badge in a repo's badges/ folder is not a screenshot", "fail", UI, h(2, "Before / After") + A
     + '<img src="https://raw.githubusercontent.com/o/r/main/.github/badges/jacoco.svg">'),
    ("a badge on a subdomain of a badge host is not a screenshot", "fail", UI, h(2, "Before / After") + A
     + '<img src="https://flat.badgen.net/npm/v/x">'),
    ("LFS screenshots on a badge branch count", "pass", UI, h(2, "Before / After")
     + '<img src="https://media.githubusercontent.com/media/o/r/feat/badge/docs/light.png">'
     + '<img src="https://media.githubusercontent.com/media/o/r/feat/badge/docs/dark.png">'),
    ("screenshots on a badge branch count", "pass", UI, h(2, "Before / After")
     + '<img src="https://raw.githubusercontent.com/dashpay/DashUIKit/feat/badge/docs/light.png">'
     + '<img src="https://raw.githubusercontent.com/dashpay/DashUIKit/feat/badge/docs/dark.png">'),
    ("GitLab badges are not screenshots", "fail", UI, h(2, "Before / After")
     + '<img src="https://gitlab.com/a/b/badges/main/pipeline.svg"><img src="https://gitlab.com/a/b/badges/main/coverage.svg">'),
    ("a /badges leaf is not a screenshot", "fail", UI, h(2, "Before / After") + A
     + '<img src="https://example.com/x/badges">'),
    ("coveralls and netlify badges are not screenshots", "fail", UI, h(2, "Before / After")
     + '<img src="https://coveralls.io/repos/github/x/y/badge.png"><img src="https://api.netlify.com/api/v1/badges/1/deploy-status">'),
    ("badge SVG variants and badge hosts are not screenshots", "fail", UI, h(2, "Before / After")
     + '<img src="https://x.io/a/badge-flat.svg"><img src="https://x.io/b/badge_small.svg">'
     + '<img src="https://badge.fury.io/js/x.svg"><img src="https://badges.gitter.im/x/y.svg">'),
    ("extensionless /badge leaves are not screenshots", "fail", UI, h(2, "Before / After")
     + '<img src="https://www.codefactor.io/repository/github/x/y/badge"><img src="https://api.securityscorecards.dev/projects/github.com/x/y/badge">'),
    ("a host that only starts with badge is not a badge", "pass", UI, h(2, "Before / After")
     + '<img src="https://badger.example.com/light.png"><img src="https://badger.example.com/dark.png">'),
    ("screenshots in a folder named after a badge count", "pass", UI, h(2, "Before / After")
     + '<img src="https://raw.githubusercontent.com/o/r/b/docs/status-badge/light.png"><img src="https://raw.githubusercontent.com/o/r/b/docs/status-badge/dark.png">'),
    ("UI: Screenshots", "pass", UI, h(2, "UI: Screenshots") + A + B),
    ("other badges are not screenshots", "fail", UI, h(2, "Before / After")
     + '<img src="https://gitlab.com/a/b/badges/main/pipeline.svg"><img src="https://example.com/build-badge.svg">'
     + '<img src="https://sonarcloud.io/api/project_badges/measure?k=x">'),
    ("a screenshot of badge UI counts", "pass", UI, h(2, "Before / After")
     + '<img src="https://example.com/coin-selector-badge-light.png"><img src="https://example.com/coin-selector-badge-dark.png">'),
    ("a version-specific manifest is a UI change", "fail", [{"filename": "Package@swift-6.2.swift"}], ""),
    ("a manifest backup is not a UI change", "pass", [{"filename": "Package.swift.orig"}], ""),
    ("a legacy ##[ marker in a path stays inside the stop block", "fail", [{"filename": "Sources/##[error]forged.swift"}], ""),
    ("renamed out of Sources/", "fail", [{"filename": "Legacy/Toast.swift", "previous_filename": "Sources/DashUIKit/Components/Toast.swift"}], ""),
]


def commands_on(stdout):
    """The output with the ::stop-commands:: blocks cut out: what the runner still parses."""
    return re.sub(r"^::stop-commands::(\w+)$.*?^::\1::$", "", stdout, flags=re.M | re.S)


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
              else (r.returncode == 1 and "::error::" in commands_on(r.stdout)))
        if name.startswith(("a newline in a path", "a legacy ##[")) and "forged" in commands_on(r.stdout):
            ok = False
        print(("ok    " if ok else "FAIL  ") + name)
        if not ok:
            failures += 1
            # The child's output is PR-like text: defuse workflow commands before it reaches the log.
            token = secrets.token_hex(16)
            out = (r.stdout + r.stderr).strip().replace("\n", "\n      ")
            print("      expected %s, got exit %d\n::stop-commands::%s\n      %s\n::%s::" % (want, r.returncode, token, out, token))
    print("%d case(s) failed" % failures if failures else "All cases passed")
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
