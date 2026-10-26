#!/usr/bin/env python3
"""Fails a PR that changes anything under Sources/ (components, design tokens, the asset
catalog) or a package manifest unless its description shows Before / After screenshots or
declares that nothing visible changed:

  - a heading whose text mentions "Before / After", or mentions "Screenshots" and is not
    about tests (any heading level, any case), and under it,
    up to the next heading of the same or a higher level, at least two different images or
    videos uploaded to GitHub (dragged into the description); or
  - the ticked task "No visual change".

It reads the description as GitHub renders it (body_html), so comments, code blocks, list
indentation and every other markdown rule are already applied: what counts is what a reader
sees. A file renamed out of Sources/ counts as a UI change, and so does the package manifest
(Package.swift, Package@swift-*.swift), whose platform floor decides which branches the
components compile. Only uploads count, so badges, emoji and externally hosted images never
pass as screenshots. In a <picture>, only its <img> counts, not the <source> variants. An
upload GitHub cannot resolve still counts; a reader sees it as a broken image.
Struck-out text and images do not count. Whether the images really show
light and dark is left to the reviewer.

Usage:
  REPO=dashpay/DashUIKit PR_NUMBER=31 GH_TOKEN=… screenshots-check.py
  screenshots-check.py --files-json <pulls/N/files answer> --pr-json <pulls/N answer, full+json>
Env: GITHUB_STEP_SUMMARY (optional).
"""
import json
import os
import re
import secrets
import subprocess
import sys
from html.parser import HTMLParser
from urllib.parse import urlsplit

# "Before / After" anywhere in the heading, or "Screenshots" anywhere in a heading that is
# not about tests ("Screenshot tests", "Screenshot_testing"; "testnet" and "TestFlight" are
# fine).
BEFORE_AFTER = re.compile(r"before\W*(and|vs\.?|to)?\W*after", re.I)
SCREENSHOTS = re.compile(r"screenshot", re.I)
TESTS = re.compile(r"(?<![a-z])(tests?|testing)(?![a-z])", re.I)
NO_VISUAL_CHANGE = re.compile(r"^\s*no visual change", re.I)
# GitHub's files endpoint stops at 3000 entries, however it is paginated.
FILES_CAP = 3000
# Files dragged into a PR description, images and videos alike, identified by their UUID,
# since one upload can appear in several forms:
#   github.com/user-attachments/assets/<uuid>                    (the markdown form)
#   github.com/<owner>/<repo>/assets/<user>/<uuid>               (older markdown form)
#   private-user-images.githubusercontent.com/<user>/<n>-<uuid>.<ext>?jwt=…  (rendered, signed
#                                                                 per viewer)
#   user-images.githubusercontent.com/<user>/<n>-<uuid>.<ext>    (older rendered form)
# Which form body_html holds depends on the viewer and on the markup (GitHub leaves a
# <picture> alone), so every form counts.
UUID = r"[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"
UPLOAD_HOSTS = ("private-user-images.githubusercontent.com", "user-images.githubusercontent.com")
RENDERED = re.compile(r"/\d+/\d+-(%s)\.\w+" % UUID)
MARKDOWN_FORM = re.compile(r"/user-attachments/assets/(%s)/?|/[^/]+/[^/]+/assets/\d+/(%s)/?" % (UUID, UUID))
# Files whose change alters what components render: the sources and the manifests, which
# set the platform floor.
UI_SOURCES = "Sources/"
MANIFEST = re.compile(r"Package(@swift-[0-9.]+)?\.swift")


class Description(HTMLParser):
    """Collects image sources under a Before / After heading and ticked task items."""

    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.heading_level = 0       # inside <hN>: N
        self.heading_text = ""
        self.section_level = 0       # inside a Before / After section: its heading level
        self.sections = []           # the image sources of each such section, in order
        self.in_task = False         # inside an <li> whose checkbox is ticked
        self.task_text = ""
        self.ticked = []
        self.struck = 0              # inside <del> / <s>: text a reader sees as crossed out

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        level = int(tag[1]) if re.fullmatch(r"h[1-6]", tag) else 0
        if level:
            if self.section_level and level <= self.section_level:
                self.section_level = 0
            self.heading_level, self.heading_text = level, ""
        elif tag in ("img", "video") and self.section_level and not self.struck:
            # Camo keeps the original URL in data-canonical-src; either attribute may hold
            # the upload.
            key = upload(attrs.get("data-canonical-src")) or upload(attrs.get("src"))
            if key:
                self.sections[-1].append(key)
        elif tag in ("del", "s", "strike"):
            self.struck += 1
        elif tag == "input" and attrs.get("type") == "checkbox" and "checked" in attrs:
            self.in_task, self.task_text = True, ""

    def handle_endtag(self, tag):
        if tag in ("del", "s", "strike") and self.struck:
            self.struck -= 1
        if self.heading_level and tag == "h%d" % self.heading_level:
            # A matching heading starts a section, unless it is nested in an open one,
            # which then simply goes on.
            if is_section(self.heading_text.strip()) and not self.section_level:
                self.section_level = self.heading_level
                self.sections.append([])
            self.heading_level = 0
        elif tag == "li" and self.in_task:
            self.ticked.append(self.task_text.strip())
            self.in_task = False

    def handle_data(self, data):
        if self.heading_level and not self.struck:
            self.heading_text += data
        if self.in_task and not self.struck:
            self.task_text += data


def is_section(heading):
    return bool(BEFORE_AFTER.search(heading) or (SCREENSHOTS.search(heading) and not TESTS.search(heading)))


def split(src):
    try:
        return urlsplit(src)
    except ValueError:  # e.g. "http://[bad": not a URL GitHub can show
        return None


def upload(src):
    """The UUID of a file uploaded to GitHub, else None. The query only signs the URL."""
    parts = split((src or "").strip())
    if parts is None or parts.scheme != "https":
        return None
    pattern = RENDERED if parts.hostname in UPLOAD_HOSTS else MARKDOWN_FORM if parts.hostname == "github.com" else None
    match = pattern and pattern.fullmatch(parts.path.lower())
    return match and next(g for g in match.groups() if g)


def gh(path, accept=None, paginate=False):
    cmd = ["gh", "api"] + (["--paginate", "--slurp"] if paginate else []) + [path]
    if accept:
        cmd[2:2] = ["-H", "Accept: " + accept]
    r = subprocess.run(cmd, capture_output=True, text=True)
    if r.returncode:
        print("::error::Reading the PR from the GitHub API failed: %s" % r.stderr.strip().replace("\n", " ")[-400:])
        sys.exit(2)
    data = json.loads(r.stdout)
    return [item for page in data for item in page] if paginate else data


def shown(path):
    """A path as it is printed in the summary list: on one line, and not rendered as markdown.
    Workflow commands in it are stopped by summary(), not here."""
    return "`%s`" % path.replace("\r", "\\r").replace("\n", "\\n").replace("`", "'")


def summary(line):
    # The lines carry PR-controlled text. The runner reads "::" commands at a line start and
    # the legacy "##[" anywhere, and no escape covers every byte it may skip: stop command
    # parsing around the text instead. The summary file is only rendered, as it is.
    token = secrets.token_hex(16)
    print("::stop-commands::%s\n%s\n::%s::" % (token, line, token))
    target = os.environ.get("GITHUB_STEP_SUMMARY")
    if target:
        with open(target, "a") as f:
            f.write(line + "\n")


def main():
    args = sys.argv[1:]
    if len(args) == 4 and args[0] == "--files-json" and args[2] == "--pr-json":
        files = json.load(open(args[1]))
        pr = json.load(open(args[3]))
    elif not args:
        repo, number = os.environ["REPO"], os.environ["PR_NUMBER"]
        # Read live: a re-run reuses the event payload, whose description may be stale.
        files = gh("repos/%s/pulls/%s/files?per_page=100" % (repo, number), paginate=True)
        pr = gh("repos/%s/pulls/%s" % (repo, number), accept="application/vnd.github.full+json")
    else:
        sys.exit(__doc__)

    paths = []
    for f in files:
        paths.append(f["filename"])
        if f.get("previous_filename"):
            paths.append(f["previous_filename"])
    ui = [p for p in paths if p.startswith(UI_SOURCES) or MANIFEST.fullmatch(p)]
    if not ui and len(files) >= FILES_CAP and (pr.get("changed_files") or 0) > len(files):
        # GitHub lists only the first 3000: treat the rest as possibly UI.
        ui = ["(more than %d changed files; the rest are not listed)" % FILES_CAP]

    if not ui:
        summary("No UI files changed: no screenshots needed.")
        return 0

    page = Description()
    page.feed(pr.get("body_html") or "")
    page.close()
    # One section must hold the two images; images from separate sections do not add up.
    images = max((list(dict.fromkeys(section)) for section in page.sections), key=len, default=[])
    listed = "\n".join("  - " + shown(p) for p in ui[:10]) + ("\n  - and %d more" % (len(ui) - 10) if len(ui) > 10 else "")

    if len(images) >= 2:
        summary("UI change with %d different uploaded screenshots or videos under Before / After." % len(images))
        return 0
    if any(NO_VISUAL_CHANGE.match(t) for t in page.ticked):
        summary("Author declared no visual change for:\n" + listed)
        return 0

    print("::error::This PR changes UI files but shows no Before / After screenshots "
          "(found %d different uploaded image(s) or video(s) under a Before / After or Screenshots heading)." % len(images))
    summary("UI change without Before / After screenshots. Changed UI files:\n" + listed)
    summary('Drag at least two images (before and after, light and dark where it differs) into the '
            '"Before / After" section of the description (or a Screenshots section), so GitHub uploads them; links to images '
            'hosted elsewhere do not count. Or tick "No visual change" and say why. '
            "Editing the description re-runs this check.")
    return 1


if __name__ == "__main__":
    sys.exit(main())
