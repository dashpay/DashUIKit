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
# Uploads in the form GitHub renders them in body_html: the markdown's
# github.com/user-attachments/assets/<uuid> becomes a signed private-user-images URL, and a
# dragged video becomes a <details> block around a <video>. The UUIDs are made up.
U1, U2, U3, U4 = ("8c0d2014-13e9-49c0-bf2f-8a279af37a55", "20448a6e-2f3b-4c1d-9e8f-0a1b2c3d4e5f",
                  "ca81c104-5d6e-4f70-8a9b-c0d1e2f3a4b5", "0f1e2d3c-4b5a-4697-8877-665544332211")
PRIVATE = "https://private-user-images.githubusercontent.com/270373998/677853016-%s.png?jwt=%s"
IMG = '<a target="_blank" rel="noopener noreferrer" href="%s"><img width="260" alt="x" src="%s" style="max-width: 100%%;"></a>'
A, B = IMG % (PRIVATE % (U1, "a"), PRIVATE % (U1, "a")), IMG % (PRIVATE % (U2, "b"), PRIVATE % (U2, "b"))
ATTACHMENT = "https://github.com/user-attachments/assets/%s"
VIDEO = ('<details open="" class="details-reset border rounded-2"><summary class="px-3 py-2"><span class="m-1">x.mov</span>'
         '</summary><video src="%s" data-canonical-src="%s" controls="controls" muted="muted" class="d-block rounded-bottom-2 border-top width-fit"></video></details>')


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
     + '<img src="%s"><img src="%s">' % (PRIVATE % (U1, "a"), PRIVATE % (U1, "b"))),
    ("images under another heading", "fail", UI, h(2, "Before / After") + "<p>none</p>" + h(2, "How Has This Been Tested?") + A + B),
    ("images above the section", "fail", UI, A + B + h(2, "Before / After")),
    ("the empty template cells", "fail", UI, h(2, "Before / After") + '<img width="260" src=""><img width="260">'),
    ("No visual change ticked", "pass", UI, h(2, "Before / After") + task('No visual change (refactor, tests, docs). Say why in "What was done?".', True)),
    ("No visual change unticked", "fail", UI, task("No visual change (refactor, tests, docs).", False)),
    ("another task ticked", "fail", UI, task("I have performed a self-review of my own code", True)),
    ("empty description", "fail", UI, None),
    ("Before & After heading", "pass", UI, h(2, "Before &amp; After") + A + B),
    ("emoji do not count", "fail", UI, h(2, "Before / After") + A
     + '<img class="emoji" src="https://github.githubassets.com/images/icons/emoji/shipit.png">'),
    ("two videos", "pass", UI, h(2, "Before / After")
     + (VIDEO % (PRIVATE % (U3, "c"), PRIVATE % (U3, "c"))).replace(".png", ".mov")
     + (VIDEO % (PRIVATE % (U4, "d"), PRIVATE % (U4, "d"))).replace(".png", ".mov")),
    ("a newline in a path stays inside the stop block", "fail", [{"filename": "Sources/a\n::error::forged.swift"}], ""),
    ("a Screenshot tests heading is not the section", "fail", UI, h(2, "Screenshot tests") + A + B),
    ("Screenshots with a parenthetical", "pass", UI, h(2, "📸 Screenshots (light and dark)") + A + B),
    ("one upload with and without ?raw=true", "fail", UI, h(2, "Before / After")
     + '<picture><img src="%s"></picture><picture><img src="%s?raw=true"></picture>' % (ATTACHMENT % U3, ATTACHMENT % U3)),
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
    ("UI: Screenshots", "pass", UI, h(2, "UI: Screenshots") + A + B),
    ("a version-specific manifest is a UI change", "fail", [{"filename": "Package@swift-6.2.swift"}], ""),
    ("a manifest backup is not a UI change", "pass", [{"filename": "Package.swift.orig"}], ""),
    ("a legacy ##[ marker in a path stays inside the stop block", "fail", [{"filename": "Sources/##[error]forged.swift"}], ""),
    ("renamed out of Sources/", "fail", [{"filename": "Legacy/Toast.swift", "previous_filename": "Sources/DashUIKit/Components/Toast.swift"}], ""),
    ("a markdown-form upload and its rendered form are one upload", "fail", UI, h(2, "Before / After")
     + '<picture><img src="%s"></picture>' % (ATTACHMENT % U1) + '<img src="%s">' % (PRIVATE % (U1, "z"))),
    ("an older repo-assets upload in a picture", "pass", UI, h(2, "Before / After") + A
     + '<picture><img src="https://github.com/dashpay/DashUIKit/assets/270373998/%s"></picture>' % U3),
    ("the markdown form counts", "pass", UI, h(2, "Before / After") + A + '<img src="%s">' % (ATTACHMENT % U3)),
    ("an upper-case UUID counts", "pass", UI, h(2, "Before / After") + A + '<img src="%s">' % (ATTACHMENT % U3.upper())),
    ("a path after the upload id does not count", "fail", UI, h(2, "Before / After") + A
     + '<img src="%s/extra.png">' % (ATTACHMENT % U3)),
    ("an older rendered upload counts", "pass", UI, h(2, "Before / After") + A
     + '<img src="https://user-images.githubusercontent.com/1/123456-%s.PNG">' % U3),
    ("a markdown-form canonical with a rendered src counts", "pass", UI, h(2, "Before / After")
     + (VIDEO % (PRIVATE % (U3, "c"), ATTACHMENT % U3)).replace(".png", ".mov")
     + (VIDEO % (PRIVATE % (U4, "d"), ATTACHMENT % U4)).replace(".png", ".mov")),
    ("an upload in a picture counts", "pass", UI, h(2, "Before / After") + A
     + '<picture><source media="(prefers-color-scheme: dark)" srcset="%s"><img src="%s"></picture>' % (ATTACHMENT % U4, ATTACHMENT % U3)),
    ("an older user-images upload", "pass", UI, h(2, "Before / After") + A
     + '<img src="https://user-images.githubusercontent.com/1/123456-%s.png">' % U3),
    ("an upload linked through www.github.com does not count", "fail", UI, h(2, "Before / After") + A
     + '<picture><img src="https://camo.githubusercontent.com/1" data-canonical-src="https://www.github.com/user-attachments/assets/%s"></picture>' % U3),
    ("an http upload link does not count", "fail", UI, h(2, "Before / After") + A
     + '<picture><img src="http://github.com/user-attachments/assets/%s"></picture>' % U3),
    ("an upload id that is not a UUID does not count", "fail", UI, h(2, "Before / After") + A
     + '<picture><img src="https://github.com/user-attachments/assets/1111"></picture>'),
    ("a bare upload host does not count", "fail", UI, h(2, "Before / After") + A
     + '<img src="https://private-user-images.githubusercontent.com/">'),
    ("a repo-assets URL with no id does not count", "fail", UI, h(2, "Before / After") + A
     + '<picture><img src="https://github.com/o/r/assets/1/"></picture>'),
    ("an attached file is not a screenshot", "fail", UI, h(2, "Before / After") + A
     + '<picture><img src="https://github.com/user-attachments/files/123/log.zip"></picture>'),
    ("a <source> variant in a picture is a second upload", "pass", UI, h(2, "Before / After") + A
     + '<picture><source media="(prefers-color-scheme: dark)" srcset="%s"><img src=""></picture>' % (ATTACHMENT % U4)),
    ("the canonical src is read before a proxied src", "pass", UI, h(2, "Before / After") + A
     + '<img src="https://camo.githubusercontent.com/1" data-canonical-src="%s">' % (PRIVATE % (U3, "c"))),
    ("the canonical src wins over src", "pass", UI, h(2, "Before / After") + A
     + '<img src="%s" data-canonical-src="%s">' % (PRIVATE % (U1, "a"), ATTACHMENT % U3)),
    ("spaces around src are ignored", "pass", UI, h(2, "Before / After") + A
     + '<img src=" %s ">' % (ATTACHMENT % U3)),
    ("two uploads in the markdown form", "pass", UI, h(2, "Before / After")
     + '<img src="%s"><img src="%s">' % (ATTACHMENT % U3, ATTACHMENT % U4)),
    ("a non-UUID id next to a markdown-form upload does not count", "fail", UI, h(2, "Before / After")
     + '<img src="%s"><img src="https://github.com/user-attachments/assets/1111">' % (ATTACHMENT % U3)),
    ("external images do not count", "fail", UI, h(2, "Before / After")
     + '<img src="https://example.com/light.png"><img src="https://example.com/dark.png">'),
    ("an external image proxied through camo does not count", "fail", UI, h(2, "Before / After") + A
     + '<img src="https://camo.githubusercontent.com/1" data-canonical-src="https://example.com/1.png">'),
    ("camo without a canonical src does not count", "fail", UI, h(2, "Before / After") + A
     + '<img src="https://camo.githubusercontent.com/1">'),
    ("badges do not count", "fail", UI, h(2, "Before / After") + A
     + '<img src="https://img.shields.io/badge/a-b-c"><img src="https://github.com/dashpay/DashUIKit/actions/workflows/ci.yml/badge.svg">'
     + '<img src="https://codecov.io/gh/x/y/graph/badge.svg">'),
    ("a light / dark picture of two uploads counts twice", "pass", UI, h(2, "Before / After")
     + '<picture><source media="(prefers-color-scheme: dark)" srcset="%s 1x"><img src="%s"></picture>' % (ATTACHMENT % U4, ATTACHMENT % U3)),
    ("a <source> outside a picture does not count", "fail", UI, h(2, "Before / After") + A
     + '<video><source src="https://example.com/x.mp4" srcset="%s"></video>' % (ATTACHMENT % U3)),
    ("an extensionless rendered upload counts", "pass", UI, h(2, "Before / After") + A
     + '<img src="https://private-user-images.githubusercontent.com/1/2-%s?jwt=x">' % U3),
    ("an oldest cloud upload counts", "pass", UI, h(2, "Before / After") + A
     + '<img src="https://cloud.githubusercontent.com/assets/1/2/%s.png">' % U3),
    ("commit-pinned raw files count", "pass", UI, h(2, "Before / After")
     + '<img src="https://raw.githubusercontent.com/romchornyi/DashUIKit-fork/d0c798679389e6ba06b9e1bf26942b99483f6dde/pr19/before-light.png">'
     + '<img src="https://raw.githubusercontent.com/romchornyi/DashUIKit-fork/d0c798679389e6ba06b9e1bf26942b99483f6dde/pr19/after-light.png">'),
    ("a commit-pinned raw file through camo counts", "pass", UI, h(2, "Before / After") + A
     + '<img src="https://camo.githubusercontent.com/1" data-canonical-src="https://raw.githubusercontent.com/o/r/d0c798679389e6ba06b9e1bf26942b99483f6dde/a.png">'),
    ("a commit-pinned github.com raw link counts", "pass", UI, h(2, "Before / After") + A
     + '<img src="https://github.com/o/r/raw/d0c798679389e6ba06b9e1bf26942b99483f6dde/docs/a.jpg">'),
    ("a commit-pinned blob with ?raw=true counts", "pass", UI, h(2, "Before / After") + A
     + '<img src="https://github.com/o/r/blob/d0c798679389e6ba06b9e1bf26942b99483f6dde/docs/a.png?raw=true">'),
    ("a commit-pinned blob page does not count", "fail", UI, h(2, "Before / After") + A
     + '<img src="https://github.com/o/r/blob/d0c798679389e6ba06b9e1bf26942b99483f6dde/docs/a.png">'),
    ("a short SHA is not pinned", "fail", UI, h(2, "Before / After") + A
     + '<img src="https://raw.githubusercontent.com/o/r/d0c7986/a.png">'),
    ("a pinned file that is not an image or video does not count", "fail", UI, h(2, "Before / After") + A
     + '<img src="https://raw.githubusercontent.com/o/r/d0c798679389e6ba06b9e1bf26942b99483f6dde/badge.svg">'),
    ("the same pinned file twice counts once", "fail", UI, h(2, "Before / After")
     + '<img src="https://raw.githubusercontent.com/o/r/d0c798679389e6ba06b9e1bf26942b99483f6dde/a.png"><img src="https://github.com/o/r/raw/d0c798679389e6ba06b9e1bf26942b99483f6dde/a.png">'),
    ("a pinned raw link to a file under a blob/ folder counts", "pass", UI, h(2, "Before / After") + A
     + '<img src="https://github.com/o/r/raw/d0c798679389e6ba06b9e1bf26942b99483f6dde/docs/blob/a.png">'),
    ("a blob with any raw= value counts", "pass", UI, h(2, "Before / After")
     + '<img src="https://github.com/o/r/blob/d0c798679389e6ba06b9e1bf26942b99483f6dde/a.png?raw=1"><img src="https://github.com/o/r/blob/d0c798679389e6ba06b9e1bf26942b99483f6dde/b.png?raw=">'),
    ("a doubled slash is the same pinned file", "fail", UI, h(2, "Before / After")
     + '<img src="https://raw.githubusercontent.com/o/r/d0c798679389e6ba06b9e1bf26942b99483f6dde/a.png"><img src="https://raw.githubusercontent.com/o/r/d0c798679389e6ba06b9e1bf26942b99483f6dde//a.png">'),
    ("a raw=true inside another parameter does not count", "fail", UI, h(2, "Before / After") + A
     + '<img src="https://github.com/o/r/blob/d0c798679389e6ba06b9e1bf26942b99483f6dde/a.png?xraw=true">'),
    ("resolution variants of one <source> count once", "fail", UI, h(2, "Before / After")
     + '<picture><source srcset="%s 1x, %s 2x"><img src=""></picture>' % (ATTACHMENT % U3, ATTACHMENT % U4)),
    ("one pinned file through a fork and a dot segment counts once", "fail", UI, h(2, "Before / After")
     + '<img src="https://raw.githubusercontent.com/o/r/d0c798679389e6ba06b9e1bf26942b99483f6dde/a.png"><img src="https://raw.githubusercontent.com/fork/r/d0c798679389e6ba06b9e1bf26942b99483f6dde/x/../a.png">'
     + '<img src="https://raw.githubusercontent.com/o/r/d0c798679389e6ba06b9e1bf26942b99483f6dde/%61.png">'),
    ("pinned files that differ only in case are two files", "pass", UI, h(2, "Before / After")
     + '<img src="https://raw.githubusercontent.com/o/r/d0c798679389e6ba06b9e1bf26942b99483f6dde/docs/Before.png"><img src="https://raw.githubusercontent.com/o/r/d0c798679389e6ba06b9e1bf26942b99483f6dde/docs/before.png">'),
    ("a pinned video in an img does not count", "fail", UI, h(2, "Before / After") + A
     + '<img src="https://raw.githubusercontent.com/o/r/d0c798679389e6ba06b9e1bf26942b99483f6dde/after.mov">'),
    ("a pinned video in a video tag counts", "pass", UI, h(2, "Before / After") + A
     + '<video src="https://raw.githubusercontent.com/o/r/d0c798679389e6ba06b9e1bf26942b99483f6dde/after.mov"></video>'),
    ("a raw file from a branch does not count", "fail", UI, h(2, "Before / After") + A
     + '<img src="https://raw.githubusercontent.com/dashpay/DashUIKit/feat/x/docs/light.png">'),
    ("a github.com raw link on a branch does not count", "fail", UI, h(2, "Before / After") + A
     + '<img src="https://github.com/dashpay/DashUIKit/raw/master/docs/light.png">'),
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
