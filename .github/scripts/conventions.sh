#!/usr/bin/env bash
# Checks the conventions in CLAUDE.md that a scanner can decide, so a PR breaking
# one fails here instead of in review:
#
#   1. every DashIcon raw value has an imageset, and every imageset is named by a
#      DashIcon case or a literal (rule 3); no name twice;
#   2. the same for dashAsset("…") tokens in Color+DashUI.swift and colorsets; a
#      dashAsset call whose name is not one literal is flagged;
#   3. asset names written as literals (Image("…", bundle:), .custom("…", bundle:),
#      Color("…", bundle:), UIImage(named: "…", in:), …) exist, and are looked up
#      in the package bundle (.module / .dashUIKit), not the host app's (a
#      computed name in .main / nil / .none too); a package-bundle lookup whose
#      name is not one literal (a variable, interpolation, ternary,
#      concatenation) is flagged, since the name escapes this check: a bundled
#      icon is a DashIcon case, a color a Color.dash token; an empty name ("")
#      is flagged too;
#   4. every imageset and colorset has a valid Contents.json naming at least one
#      image or color, every image it names exists, and no catalog folder provides
#      a namespace (names would gain a "Folder/" prefix);
#   5. no color built from components (red:, white:, hue:, gray:, .sRGB, hex,
#      #colorLiteral), Color+DashUI.swift included: every token is a colorset;
#   6. every NSLocalizedString call, and every String(localized:) /
#      AttributedString(localized:) call with a literal key, passes the package
#      bundle;
#   7. no @available / #available / #unavailable for an iOS or macOS version at or
#      below the Package.swift floor: the floor already covers it. Newer versions
#      may still be annotated or checked.
#
# Calls are parsed with their arguments (labels, nesting, several lines); string
# contents and `//` comments are ignored, interpolated code is scanned. Not
# handled: /* block comments */, raw and multi-line string literals (as a name
# they count as computed), computed names inside Icon_DashUI.swift and
# Color+DashUI.swift (the resolvers), ImageResource / ColorResource written as
# .init(name:bundle:), names reaching the DashIconAsset resolver
# from a conformance other than a DashIcon enum case, computed names
# looked up in a bundle passed in as a variable (Image+DashUI.swift resolves a
# host's DashIconSource that way) or without one (Image(name) may be an
# ImageResource; only UIImage(named:) and .custom are checked for their bundle
# then), the host bundle written other than .main / nil / .none (Optional.none,
# Bundle(for:)), a .custom(…) without a bundle that is not after DashIconSource,
# `dash:` or an `…icon:` label, NSImage(named:), SwiftUI Text("…") and
# LocalizedStringResource localization. Icon_DashUI.swift is
# expected to keep each `case` list on one line.
# Run from the repository root (tests: .github/scripts/tests/conventions-test.sh).
# Every rule runs; exits 1 if any reported a violation, 2 if it could not run.
set -euo pipefail

scripts=$(cd "$(dirname "$0")" && pwd)
src=Sources/DashUIKit
catalog=$src/Resources/Media.xcassets
icons=$src/Foundation/Icon_DashUI.swift
tokens=$src/Foundation/Color+DashUI.swift

command -v jq > /dev/null || { echo "conventions.sh needs jq" >&2; exit 2; }
for required in Package.swift "$catalog" "$icons" "$tokens"; do
  [ -e "$required" ] || { echo "conventions.sh: ${required} not found; run from the repository root" >&2; exit 2; }
done

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
# One violation per line: path <TAB> line <TAB> message.
errors=$work/errors
: > "$errors"

# report PATH LINE MESSAGE
report() {
  printf '%s\t%s\t%s\n' "$1" "$2" "$3" >> "$errors"
}

# list_sets EXT: "name <TAB> path" for every *.EXT folder in the catalog.
list_sets() {
  find "$catalog" -type d -name "*.$1" -print0 | sort -z |
    while IFS= read -r -d '' dir; do
      name=${dir##*/}
      printf '%s\t%s\n' "${name%."$1"}" "$dir"
    done
}

# Platform floors as major.minor; macOS falls back to 0 (flag nothing) if undeclared.
ios_floor=$("$scripts/ios-floor.sh" Package.swift) || exit 2
mac_floor=$(sed 's#//.*##' Package.swift | { grep -oE '\.macOS\(\.v[0-9]+(_[0-9]+)?\)' || true; } | awk 'NR == 1' |
  sed -E 's/.*\.v([0-9]+)(_([0-9]+))?\)/\1.\3/; s/\.$/.0/')
if [ -z "$mac_floor" ] && sed 's#//.*##' Package.swift | grep -q '\.macOS('; then
  echo "conventions.sh: could not read the .macOS(.vNN) platform in Package.swift" >&2
  exit 2
fi
mac_floor=${mac_floor:-0}

imagesets=$work/imagesets
colorsets=$work/colorsets
list_sets imageset > "$imagesets"
list_sets colorset > "$colorsets"

# Swift scan (rules 3, 5, 6, 7). Prints "R <TAB> file <TAB> line <TAB> message"
# for a violation and "L <TAB> kind <TAB> name <TAB> file <TAB> line" for each
# literal asset name, checked against the catalog below.
scan=$work/scan
# shellcheck disable=SC2016 # awk fields, not shell variables
find "$src" -name '*.swift' -print0 | sort -z |
  xargs -0 awk -v tokens_file="$tokens" -v icons="$icons" -v ios_floor="$ios_floor" -v mac_floor="$mac_floor" '
    # mask(s): string contents become spaces, so a match in M is always code.
    # Interpolated code ("\(x)") stays visible, its "\(" written as " (".
    function mask(s,   i, c, instr, n, pd, out) {
      out = ""; instr = 0; n = 0
      for (i = 1; i <= length(s); i++) {
        c = substr(s, i, 1)
        if (instr) {
          if (c == "\\") {
            if (substr(s, i + 1, 1) == "(") { out = out " ("; n++; pd[n] = 1; instr = 0 }
            else out = out "  "
            i++; continue
          }
          if (c == "\"") instr = 0
          out = out (c == "\"" ? c : " ")
          continue
        }
        if (c == "\"") { instr = 1; out = out c; continue }
        if (n > 0 && c == "(") pd[n]++
        else if (n > 0 && c == ")" && --pd[n] == 0) { n--; instr = 1 }
        out = out c
      }
      return out
    }
    # pkg(v): v names the package bundle.
    function pkg(v) { return trim(v) ~ /^((Bundle[[:space:]]*)?\.(module|dashUIKit)|#bundle)$/ }
    function trim(s) { gsub(/^[[:space:]]+|[[:space:]]+$/, "", s); return s }
    function out(line, message) { print "R\t" file "\t" line "\t" message }

    # parse(li, col): the arguments of the call whose "(" is at M[li], col.
    # Fills nargs, alabel[k] ("" when unlabeled), atext[k] (source), amask[k],
    # and atop[k]: the source outside nested calls and subscripts.
    function parse(li, col,   d, j, c, line, ml) {
      nargs = 1; alabel[1] = ""; atext[1] = ""; amask[1] = ""; atop[1] = ""
      d = 1; line = li; j = col + 1
      while (line <= nl) {
        ml = M[line]
        for (; j <= length(ml); j++) {
          c = substr(ml, j, 1)
          if (c == "(" || c == "[" || c == "{") d++
          else if (c == ")" || c == "]" || c == "}") { if (--d == 0) return }
          if (d == 1 && c == ",") {
            nargs++; alabel[nargs] = ""; atext[nargs] = ""; amask[nargs] = ""; atop[nargs] = ""
            continue
          }
          if (d == 1 && c == ":" && alabel[nargs] == "" && amask[nargs] ~ /^[[:space:]]*[A-Za-z_][A-Za-z0-9_]*[[:space:]]*$/) {
            alabel[nargs] = trim(amask[nargs]); atext[nargs] = ""; amask[nargs] = ""; atop[nargs] = ""
            continue
          }
          atext[nargs] = atext[nargs] substr(L[line], j, 1)
          amask[nargs] = amask[nargs] c
          if (d == 1) atop[nargs] = atop[nargs] substr(L[line], j, 1)
        }
        atext[nargs] = atext[nargs] " "; amask[nargs] = amask[nargs] " "; atop[nargs] = atop[nargs] " "
        line++; j = 1
      }
    }
    function arg(label,   k) {
      for (k = 1; k <= nargs; k++) if (alabel[k] == label) return k
      return 0
    }
    # bundle_ok(label, li): the bundle argument names the package bundle.
    function bundle_ok(label, li,   k, v) {
      k = arg(label)
      if (k == 0) { out(li, "asset looked up in the host app bundle: pass " label ": .dashUIKit"); return }
      v = trim(amask[k])
      if (!pkg(v)) out(li, label ": " v " is not the package bundle; use .dashUIKit")
    }

    # Rule 3: literal asset names.
    function assets(li,   ml, base, call, before, open, kind, label, k, s, n, name, computed, seen, names, empty, context, k2) {
      ml = M[li]; base = 0
      while (match(substr(ml, base + 1), /(^|[^A-Za-z0-9_])(ImageResource|ColorResource|Image|UIImage|Color|UIColor|Label|Button|Toggle|Menu|Tab|ContentUnavailableView)[[:space:]]*(\.init)?[[:space:]]*\(|\.custom[[:space:]]*\(/)) {
        call = substr(ml, base + RSTART, RLENGTH)
        before = substr(ml, 1, base + RSTART - 1)
        open = base + RSTART + RLENGTH - 1
        base = open
        parse(li, open)
        if (call ~ /Label|Button|Toggle|Menu|Tab|ContentUnavailableView/) {
          # These take an asset name only from the host app bundle.
          k = arg("image")
          if (k && trim(amask[k]) ~ /^"/) out(li, "image: \"…\" is looked up in the host app bundle; pass a label view with Image(…, bundle: .dashUIKit)")
          continue
        }
        kind = (call ~ /Color/) ? "colorset" : "imageset"
        label = (call ~ /UI/) ? "in" : "bundle"
        if (call ~ /UI/) { if (alabel[1] != "named") continue }
        else if (call ~ /Resource/) { if (alabel[1] != "name") continue }
        else if (call ~ /Image/) { if (alabel[1] != "" && alabel[1] != "decorative") continue }
        else if (alabel[1] != "") continue
        # A pattern (`case .custom(let name, let bundle)`, `case let .custom(n,
        # bundle: b)`) is not a lookup.
        if (amask[1] ~ /^[[:space:]]*(let|var)[[:space:]]/ || before ~ /(^|[^A-Za-z0-9_])case([[:space:]]+(let|var))?[[:space:]]*$/) continue
        # A name that is not one literal, looked up in the package bundle, is not
        # checked against the catalog. Icon_DashUI.swift and Color+DashUI.swift are
        # exempt from this check only: they hold the resolvers for DashIcon cases
        # and Color.dash tokens, whose names rules 1 and 2 check where they are
        # declared. In this package
        # only DashIconSource has a .custom case that takes a bundle. A literal
        # with an escape counts as computed: its name is not read below.
        k = arg(label)
        computed = (amask[1] !~ /^[[:space:]]*"[[:space:]]*"[[:space:]]*$/ || index(atop[1], "\\"))
        if (k && pkg(amask[k]) && computed && file != icons && file != tokens_file)
          out(li, "asset name is not one literal, so the catalog check cannot follow it; use " (kind == "colorset" ? "a Color.dash token" : "a DashIcon case (DashIcon.<Group>.<case>.source or .image)"))
        # The literal names in the call, each once. "a" + b is an expression, not
        # a name.
        s = (index(amask[1], "+") ? "" : atop[1]); n = 0; empty = 0
        split("", seen)
        while (match(s, /"([^"\\]|\\.)*"/)) {
          name = substr(s, RSTART + 1, RLENGTH - 2)
          s = substr(s, RSTART + RLENGTH)
          if (name == "") { empty = (trim(amask[1]) == "\"\""); continue }
          if (index(name, "\\") || (name in seen)) continue
          seen[name] = 1; names[++n] = name
        }
        # Other enums have a .custom case too: its literals are read as names only
        # where a DashIconSource is expected (after `DashIconSource`, `dash:` or
        # an `…icon:` / `…Icon:` label) or when it passes a bundle, which in this
        # package only DashIconSource.custom does.
        context = (call !~ /custom/ || arg("bundle") || before ~ /(DashIconSource[[:space:]]*=?|(dash|[A-Za-z]*[Ii]con):)[[:space:]]*$/)
        # A computed name looked up in the host app bundle, unless bundle_ok
        # below reports the same call for the literals inside it.
        if (k && computed && trim(amask[k]) ~ /^(nil|\.none|(Bundle[[:space:]]*)?\.main)$/ && !(context && n))
          out(li, label ": " trim(amask[k]) " is not the package bundle; use .dashUIKit")
        if (!context) continue
        if (empty) out(li, "empty asset name")
        for (k2 = 1; k2 <= n; k2++) print "L\t" kind "\t" names[k2] "\t" file "\t" li
        if (n || empty) bundle_ok(label, li)
        # UIImage(named: name) without in: always looks in the host app bundle,
        # and so does DashIconSource.custom(name) (bundle defaults to nil).
        else if (!arg(label) && call ~ /UI|custom/)
          out(li, "asset looked up in the host app bundle: pass " label ": .dashUIKit")
      }
    }

    # Rule 5: colors from components.
    function colors(li,   ml, base, open, first, k, hit) {
      ml = M[li]; base = 0
      if (ml ~ /#colorLiteral/) out(li, "hardcoded color: add a token to Foundation/Color+DashUI.swift backed by a colorset and use Color.dash.<token>")
      while (match(substr(ml, base + 1), /((^|[^A-Za-z0-9_])(Color|UIColor|NSColor|CGColor|CIColor)[[:space:]]*(\.init)?|\.init)[[:space:]]*\(/)) {
        open = base + RSTART + RLENGTH - 1
        base = open
        parse(li, open)
        first = trim(amask[1]); hit = (alabel[1] == "" && first ~ /^\.(sRGB|sRGBLinear|displayP3)$/)
        for (k = 1; k <= nargs; k++)
          if (alabel[k] ~ /^(red|white|hue|gray|displayP3Red|srgbRed|hex|calibratedRed|calibratedWhite|calibratedHue|deviceRed|deviceWhite|deviceHue|genericGamma22White)$/) hit = 1
        if (hit)
          out(li, "hardcoded color: add a token to Foundation/Color+DashUI.swift backed by a colorset and use Color.dash.<token>")
      }
    }

    # Rule 6: localized strings.
    function localized(li,   ml, base, call, open) {
      ml = M[li]; base = 0
      while (match(substr(ml, base + 1), /(^|[^A-Za-z0-9_])(NSLocalizedString|(Attributed)?String[[:space:]]*(\.init)?)[[:space:]]*\(/)) {
        call = substr(ml, base + RSTART, RLENGTH)
        open = base + RSTART + RLENGTH - 1
        base = open
        parse(li, open)
        # String(localized: resource) takes no bundle; only a literal key needs one.
        if (call !~ /NSLocalizedString/ && (alabel[1] != "localized" || trim(amask[1]) !~ /^"/)) continue
        k = arg("bundle")
        if (k == 0 || !pkg(amask[k]))
          out(li, "localized string without bundle: .module is looked up in the host app bundle")
      }
    }

    # Rule 7: availability at or below the floor.
    # le(a, b): version a <= version b.
    function le(a, b,   x, y, i) {
      split(a, x, "."); split(b, y, ".")
      for (i = 1; i <= 3; i++) if (x[i] + 0 != y[i] + 0) return x[i] + 0 < y[i] + 0
      return 1
    }
    # keeps(): the parsed @available also deprecates, obsoletes, renames or marks
    # unavailable, labelled (deprecated: 17) or bare (deprecated).
    function keeps(   k) {
      for (k = 2; k <= nargs; k++)
        if (alabel[k] ~ /^(deprecated|obsoleted|renamed)$/ || (alabel[k] == "" && trim(amask[k]) ~ /^(deprecated|unavailable)$/)) return 1
      return 0
    }
    function available(li,   ml, base, open, k, t, platform, version, floor) {
      ml = M[li]; base = 0
      while (match(substr(ml, base + 1), /[@#](available|unavailable)[[:space:]]*\(/)) {
        open = base + RSTART + RLENGTH - 1
        base = open
        parse(li, open)
        for (k = 1; k <= nargs; k++) {
          if (alabel[k] != "") continue
          t = trim(amask[k]); version = ""
          if (match(t, /^[A-Za-z]+/)) platform = substr(t, 1, RLENGTH)
          else continue
          if (match(t, /[[:space:]][0-9][0-9.]*$/)) version = trim(substr(t, RSTART))
          else if (k == 1 && t == platform && arg("introduced")) version = trim(amask[arg("introduced")])
          if (version == "") continue
          if (platform ~ /^(iOS|macCatalyst)(ApplicationExtension)?$/) floor = ios_floor
          else if (platform ~ /^macOS(ApplicationExtension)?$/) floor = mac_floor
          else continue
          if (!le(version, floor)) continue
          # Next to a deprecation, obsoletion or rename only introduced: can go;
          # a message: alone would be left with nothing to qualify.
          if (keeps())
            out(li, "introduced: " version " for " platform " is at or below the package floor (" floor "); remove only introduced:, keep the rest of the attribute (CLAUDE.md, Deployment target)")
          else
            out(li, "availability check for " platform " " version " is at or below the package floor (" floor "), declared once in Package.swift; drop it (CLAUDE.md, Deployment target)")
        }
      }
    }

    # Color tokens: dashAsset("Name") calls in Color+DashUI.swift.
    # A token whose name is not one literal is unchecked, like a computed name
    # in rule 3.
    function tokens(li,   ml, base, open, s, before) {
      if (file != tokens_file) return
      ml = M[li]; base = 0
      while (match(substr(ml, base + 1), /(^|[^A-Za-z0-9_])dashAsset[[:space:]]*\(/)) {
        before = substr(ml, 1, base + RSTART)
        open = base + RSTART + RLENGTH - 1
        base = open
        if (before ~ /func[[:space:]]+$/) continue
        parse(li, open)
        s = atop[1]
        if (alabel[1] == "" && match(s, /^[[:space:]]*"[^"\\]+"[[:space:]]*$/)) {
          match(s, /"[^"]+"/)
          print "T\t" substr(s, RSTART + 1, RLENGTH - 2) "\t" file "\t" li
        } else
          out(li, "dashAsset(…) needs one literal colorset name, or it is not checked against the catalog")
      }
    }

    function flush(   i, cut) {
      for (i = 1; i <= nl; i++) {
        assets(i); colors(i); localized(i); available(i); tokens(i)
      }
      nl = 0
    }
    FNR == 1 { if (nl) flush(); file = FILENAME }
    {
      m = mask($0)
      cut = index(m, "//")
      line = $0
      if (cut) { m = substr(m, 1, cut - 1); line = substr(line, 1, cut - 1) }
      nl++; L[nl] = line; M[nl] = m
    }
    END { if (nl) flush() }
  ' > "$scan" || { echo "conventions.sh: the Swift scan failed" >&2; exit 2; }

awk -F'\t' '$1 == "R" { print $2 "\t" $3 "\t" $4 }' "$scan" >> "$errors"
literals=$work/literals
awk -F'\t' '$1 == "L" { print $2 "\t" $3 "\t" $4 "\t" $5 }' "$scan" > "$literals"

# check_sets KIND SETS DECLARED USED: SETS is "name <TAB> path", DECLARED is
# "name <TAB> file <TAB> line" (the enum or token list), USED is extra names that
# keep a set from being an orphan. UNIQUE (any value) also fails a name declared
# twice; two color tokens may alias one colorset, two icon cases may not.
check_sets() {
  local kind=$1 sets=$2 declared=$3 used=$4 unique=${5:-}
  if [ ! -s "$sets" ]; then
    report "$catalog" 1 "no ${kind} found in the catalog"
    return
  fi
  cut -f1 "$sets" | sort | uniq -d | while IFS= read -r name; do
    awk -F'\t' -v n="$name" '$1 == n { print $2 }' "$sets" | while IFS= read -r dir; do
      report "$dir/Contents.json" 1 "${kind} \"${name}\" exists in more than one folder; the catalog is flat, so only one of them is used"
    done
  done
  [ -z "$unique" ] || cut -f1 "$declared" | sort | uniq -d | while IFS= read -r name; do
    awk -F'\t' -v n="$name" '$1 == n { print $2 "\t" $3 }' "$declared" | while IFS=$'\t' read -r file line; do
      report "$file" "$line" "\"${name}\" is declared more than once"
    done
  done
  awk -F'\t' 'FILENAME == ARGV[1] { have[$1] = 1; next } !($1 in have) { print $2 "\t" $3 "\t" $1 }' "$sets" "$declared" |
    while IFS=$'\t' read -r file line name; do
      report "$file" "$line" "no ${kind} named \"${name}\" in ${catalog}"
    done
  awk -F'\t' 'FILENAME != ARGV[3] { named[$1] = 1; next } !($1 in named) { print $1 "\t" $2 }' "$declared" "$used" "$sets" |
    while IFS=$'\t' read -r name dir; do
      report "$dir/Contents.json" 1 "${kind} \"${name}\" is not referenced by any declaration or literal"
    done
}

check_literals() {
  local kind=$1 sets=$2
  awk -F'\t' -v k="$kind" 'FILENAME == ARGV[1] { have[$1] = 1; next } $1 == k && !($2 in have) { print $3 "\t" $4 "\t" $2 }' "$sets" "$literals" |
    while IFS=$'\t' read -r file line name; do
      report "$file" "$line" "no ${kind} named \"${name}\" in ${catalog}"
    done
}

# 1. Icons: `case a = "x"`, `case a` (raw value is the name), `case a, b = "y"`,
# read only directly inside an enum whose declaration (up to its "{", on one line
# or several) names DashIconAsset. Lines of any other shape (`case let …`,
# associated values) are not icons.
icon_values=$work/icon-values
awk -v f="$icons" '
  function cases(text, ln,   item, one, value) {
    sub(/^[[:space:]]+/, "", text)
    sub(/[[:space:]]*\}[[:space:]]*$/, "", text)
    if (text !~ /^case[[:space:]]+[A-Za-z_]/) return
    sub(/^case[[:space:]]+/, "", text)
    item = "[A-Za-z_][A-Za-z0-9_]*([[:space:]]*=[[:space:]]*\"[^\"]*\")?"
    if (text !~ ("^" item "([[:space:]]*,[[:space:]]*" item ")*[[:space:]]*$")) return
    while (match(text, item)) {
      one = substr(text, RSTART, RLENGTH)
      text = substr(text, RSTART + RLENGTH)
      if (match(one, /"[^"]*"/)) value = substr(one, RSTART + 1, RLENGTH - 2)
      else value = one
      print value "\t" f "\t" ln
    }
  }
  {
    line = $0
    sub(/[[:space:]]*\/\/.*$/, "", line)
    opens = gsub(/\{/, "{", line); closes = gsub(/\}/, "}", line)
    if (header == "" && line ~ /(^|[^A-Za-z0-9_])enum[[:space:]]+[A-Za-z_]/) header = " "
    if (header != "") {
      header = header " " line
      brace = index(line, "{")
      if (brace) {
        if (substr(header, 1, index(header, "{")) ~ /DashIconAsset/) {
          icon_depth = depth + 1
          cases(substr(line, brace + 1), FNR)
        }
        header = ""
      }
      depth += opens - closes
      if (icon_depth && depth < icon_depth) icon_depth = 0
      next
    }
    if (icon_depth && depth == icon_depth) cases(line, FNR)
    depth += opens - closes
    if (icon_depth && depth < icon_depth) icon_depth = 0
  }' "$icons" > "$icon_values"
icon_used=$work/icon-used
awk -F'\t' '$1 == "imageset" { print $2 }' "$literals" > "$icon_used"
check_sets imageset "$imagesets" "$icon_values" "$icon_used" unique
check_literals imageset "$imagesets"

# 2. Color tokens, read by the Swift scan above.
color_tokens=$work/color-tokens
awk -F'\t' '$1 == "T" { print $2 "\t" $3 "\t" $4 }' "$scan" > "$color_tokens"
color_used=$work/color-used
awk -F'\t' '$1 == "colorset" { print $2 }' "$literals" > "$color_used"
check_sets colorset "$colorsets" "$color_tokens" "$color_used"
check_literals colorset "$colorsets"

# 4. Set contents and namespaces. One jq run reads every Contents.json; jq stops
# at the first file it cannot parse, so those are found one by one first.
manifests=$work/manifests
: > "$manifests"
while IFS=$'\t' read -r name dir; do
  if [ -s "$dir/Contents.json" ]; then
    printf '%s\0' "$dir/Contents.json" >> "$manifests"
  elif [ -f "$dir/Contents.json" ]; then
    report "$dir/Contents.json" 1 "\"${name}\" has an empty Contents.json"
  else
    report "$dir" 1 "\"${name}\" has no Contents.json"
  fi
done < <(cat "$imagesets" "$colorsets")
find "$catalog" -name Contents.json ! -path '*.imageset/*' ! -path '*.colorset/*' -print0 >> "$manifests"

valid=$work/valid
if xargs -0 jq empty < "$manifests" 2> /dev/null; then
  cp "$manifests" "$valid"
else
  : > "$valid"
  while IFS= read -r -d '' contents; do
    if jq empty "$contents" 2> /dev/null; then
      printf '%s\0' "$contents" >> "$valid"
    else
      report "$contents" 1 "Contents.json is not valid JSON"
    fi
  done < "$manifests"
fi

# Per file: "count <TAB> n" for a set (images with a file, or colors), "file <TAB>
# name" per listed image, "namespace", or "shape" when it is not an object.
# shellcheck disable=SC2016 # jq variables, not shell ones
xargs -0 jq -r '
  input_filename as $f
  | if type != "object" then "\($f)\tshape"
    else
      (if ($f | test("\\.(imageset|colorset)/Contents\\.json$"))
       then "\($f)\tcount\t\(if ($f | test("imageset/")) then [.images | arrays | .[] | objects | .filename | strings] else [.colors | arrays | .[] | objects | .color | objects] end | length)"
       else empty end),
      (.images | arrays | .[] | objects | .filename | strings | "\($f)\tfile\t\(.)"),
      (if (.properties | objects | .["provides-namespace"]) == true or (.properties | objects | .["provides-namespace"]) == "true"
       then "\($f)\tnamespace" else empty end)
    end' < "$valid" |
  while IFS=$'\t' read -r contents what value; do
    dir=${contents%/Contents.json}
    case $what in
      shape) report "$contents" 1 "Contents.json is not a JSON object" ;;
      count) [ "$value" -gt 0 ] || report "$contents" 1 "\"$(basename "$dir")\" defines no image or color" ;;
      file) [ -f "$dir/$value" ] || report "$contents" 1 "lists \"${value}\", which is not in the imageset" ;;
      namespace) report "$contents" 1 "folder provides a namespace, so its assets resolve as \"Folder/name\" and DashIcon / Color.dash names stop matching" ;;
    esac
  done || { echo "conventions.sh: reading Contents.json failed" >&2; exit 2; }

if [ ! -s "$errors" ]; then
  echo "Conventions: OK ($(wc -l < "$imagesets" | tr -d ' ') imagesets, $(wc -l < "$colorsets" | tr -d ' ') colorsets)"
  exit 0
fi

sort -t$'\t' -k1,1 -k2,2n "$errors" | while IFS=$'\t' read -r file line message; do
  echo "${file}:${line}: ${message}"
  if [ -n "${GITHUB_ACTIONS:-}" ]; then
    # Workflow commands escape % everywhere, and : and , in properties.
    message=${message//%/%25}
    property=${file//%/%25}
    property=${property//:/%3A}
    property=${property//,/%2C}
    echo "::error file=${property},line=${line}::${message}"
  fi
done
echo "Conventions: $(wc -l < "$errors" | tr -d ' ') violation(s)"
exit 1
