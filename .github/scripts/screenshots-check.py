#!/usr/bin/env python3
"""Fails a PR that changes anything under Sources/ (components, design tokens, the asset
catalog) or a package manifest unless its description shows Before / After screenshots or
declares that nothing visible changed:

  - a heading whose text mentions "Before / After", or mentions "Screenshots" and is not
    about tests (any level, any case, with or without an emoji in front), and under it,
    up to the next heading of the same or a higher level, at least two different images; or
  - the ticked task "No visual change".

It reads the description as GitHub renders it (body_html), so comments, code blocks, list
indentation and every other markdown rule are already applied: what counts is what a reader
sees. A file renamed out of Sources/ counts as a UI change, and so does the package manifest
(Package.swift, Package@swift-*.swift), whose platform floor decides which branches the
components compile. Struck-out text and images do not count. Whether the images really show
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
# Images that are not screenshots: emoji and badges.
NOT_SCREENSHOT_HOSTS = ("github.githubassets.com", "img.shields.io", "badgen.net", "codecov.io", "app.codecov.io",
                        "coveralls.io", "api.netlify.com")
# Uploads whose query only signs or tweaks the URL; the same file can come back with another.
UPLOAD_HOSTS = ("private-user-images.githubusercontent.com", "camo.githubusercontent.com",
                "user-images.githubusercontent.com")
# Files whose change alters what components render: the sources and the manifests, which
# set the platform floor.
UI_SOURCES = "Sources/"
MANIFEST = re.compile(r"Package(@swift-[0-9.]+)?\.swift")
# Badge images: a URL ending in "/badge" or "/badges", a lower-case "badges" or
# "project_badges" directory (GitLab, SonarCloud), an SVG named
# after a badge ("badge.svg", "badge-flat.svg"), or a host named "badge" or "badges"
# (badge.fury.io, badges.gitter.im). A PNG screenshot of badge UI, or one in a folder named
# after a badge component ("Badge/light.png"), still counts.
BADGE_LEAF = re.compile(r"badges?", re.I)
BADGE_SVG = re.compile(r".*badge.*\.svg", re.I)


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
            src = attrs.get("data-canonical-src") or attrs.get("src") or ""
            emoji = "emoji" in (attrs.get("class") or "").split()
            if src.startswith(("https://", "http://")) and not emoji and not is_badge(src):
                self.sections[-1].append(src)
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


def is_badge(src):
    parts = split(src)
    if parts is None:
        return True
    host, segments = parts.hostname or "", parts.path.split("/")
    return (host in NOT_SCREENSHOT_HOSTS or host.split(".")[0] in ("badge", "badges")
            or any(s in ("badges", "project_badges") for s in segments) or bool(BADGE_LEAF.fullmatch(segments[-1]))
            or bool(BADGE_SVG.fullmatch(segments[-1])))


def distinct(sources):
    """Different images: the same upload is often linked with different queries."""
    seen = []
    for src in sources:
        parts = split(src)
        if parts is None:
            continue
        parts = parts._replace(fragment="")
        if parts.hostname in UPLOAD_HOSTS or (parts.hostname == "github.com" and parts.path.startswith("/user-attachments/")):
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
    images = max((distinct(section) for section in page.sections), key=len, default=[])
    listed = "\n".join("  - " + shown(p) for p in ui[:10]) + ("\n  - and %d more" % (len(ui) - 10) if len(ui) > 10 else "")

    if len(images) >= 2:
        summary("UI change with %d different screenshots under Before / After." % len(images))
        return 0
    if any(NO_VISUAL_CHANGE.match(t) for t in page.ticked):
        summary("Author declared no visual change for:\n" + listed)
        return 0

    print("::error::This PR changes UI files but shows no Before / After screenshots "
          "(found %d different image(s) under a Before / After or Screenshots heading)." % len(images))
    summary("UI change without Before / After screenshots. Changed UI files:\n" + listed)
    summary('Add at least two images (before and after, light and dark where it differs) under the '
            '"Before / After" heading of the description, or tick "No visual change" and say why. '
            "Editing the description re-runs this check.")
    return 1


if __name__ == "__main__":
    sys.exit(main())
