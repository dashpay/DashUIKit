#!/usr/bin/env python3
"""Fails a PR that changes anything under Sources/ (components, design tokens, the asset
catalog) unless its description shows Before / After screenshots or declares that nothing
visible changed:

  - a heading whose text mentions "Before / After" or "Screenshots" (any level, any case,
    with or without an emoji in front), and under it, up to the next heading of the same or
    a higher level, at least two different images; or
  - the ticked task "No visual change".

It reads the description as GitHub renders it (body_html), so comments, code blocks, list
indentation and every other markdown rule are already applied: what counts is what a reader
sees. A file renamed out of Sources/ counts as a UI change. Whether the images really show
light and dark is left to the reviewer.

Usage:
  REPO=dashpay/DashUIKit PR_NUMBER=31 GH_TOKEN=… screenshots-check.py
  screenshots-check.py --files-json <pulls/N/files answer> --pr-json <pulls/N answer, full+json>
Env: GITHUB_STEP_SUMMARY (optional).
"""
import json
import os
import re
import subprocess
import sys
from html.parser import HTMLParser
from urllib.parse import urlsplit

SECTION = re.compile(r"before\W*(and|vs\.?|to)?\W*after|screenshots?", re.I)
NO_VISUAL_CHANGE = re.compile(r"^\s*no visual change", re.I)
# GitHub's files endpoint stops at 3000 entries, however it is paginated.
FILES_CAP = 3000
# Images that are not screenshots: emoji, badges.
NOT_SCREENSHOTS = ("https://github.githubassets.com/", "https://img.shields.io/", "https://badgen.net/")
# Hosts whose query only signs the URL; the same upload comes back with a new one each time.
SIGNED_HOSTS = ("private-user-images.githubusercontent.com", "camo.githubusercontent.com")


class Description(HTMLParser):
    """Collects image sources under a Before / After heading and ticked task items."""

    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.heading_level = 0       # inside <hN>: N
        self.heading_text = ""
        self.section_level = 0       # inside the Before / After section: its heading level
        self.images = []
        self.in_task = False         # inside an <li> whose checkbox is ticked
        self.task_text = ""
        self.ticked = []

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        level = int(tag[1]) if re.fullmatch(r"h[1-6]", tag) else 0
        if level:
            if self.section_level and level <= self.section_level:
                self.section_level = 0
            self.heading_level, self.heading_text = level, ""
        elif tag in ("img", "video") and self.section_level:
            src = attrs.get("data-canonical-src") or attrs.get("src") or ""
            emoji = "emoji" in (attrs.get("class") or "").split()
            if src.startswith(("https://", "http://")) and not emoji and not src.startswith(NOT_SCREENSHOTS):
                self.images.append(src)
        elif tag == "input" and attrs.get("type") == "checkbox" and "checked" in attrs:
            self.in_task, self.task_text = True, ""

    def handle_endtag(self, tag):
        if self.heading_level and tag == "h%d" % self.heading_level:
            if SECTION.search(self.heading_text):
                self.section_level = self.heading_level
            self.heading_level = 0
        elif tag == "li" and self.in_task:
            self.ticked.append(self.task_text.strip())
            self.in_task = False

    def handle_data(self, data):
        if self.heading_level:
            self.heading_text += data
        if self.in_task:
            self.task_text += data


def distinct(sources):
    """Different images: the same upload is often linked with different signed queries."""
    seen = []
    for src in sources:
        parts = urlsplit(src)._replace(fragment="")
        if parts.hostname in SIGNED_HOSTS:
            parts = parts._replace(query="")
        key = parts.geturl()
        if key not in seen:
            seen.append(key)
    return seen


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
    """A path as it is printed: PR-controlled text must not start a workflow command."""
    return path.replace("%", "%25").replace("\r", "%0D").replace("\n", "%0A")


def summary(line):
    print(line)
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
    ui = [p for p in paths if p.startswith("Sources/")]
    if not ui and len(files) >= FILES_CAP and (pr.get("changed_files") or 0) > len(files):
        # GitHub lists only the first 3000: treat the rest as possibly UI.
        ui = ["(more than %d changed files; the rest are not listed)" % FILES_CAP]

    if not ui:
        summary("No UI files changed: no screenshots needed.")
        return 0

    page = Description()
    page.feed(pr.get("body_html") or "")
    page.close()
    images = distinct(page.images)
    listed = "\n".join("  - " + shown(p) for p in ui[:10]) + ("\n  - and %d more" % (len(ui) - 10) if len(ui) > 10 else "")

    if len(images) >= 2:
        summary("UI change with %d different screenshots under Before / After." % len(images))
        return 0
    if any(NO_VISUAL_CHANGE.match(t) for t in page.ticked):
        summary("Author declared no visual change for:\n" + listed)
        return 0

    print("::error::This PR changes UI files but shows no Before / After screenshots "
          "(found %d different image(s) under a Before / After or Screenshots heading)." % len(images))
    summary("UI change without Before / After screenshots. Changed under Sources/:\n" + listed)
    summary('Add at least two images (before and after, light and dark where it differs) under the '
            '"Before / After" heading of the description, or tick "No visual change" and say why. '
            "Editing the description re-runs this check.")
    return 1


if __name__ == "__main__":
    sys.exit(main())
