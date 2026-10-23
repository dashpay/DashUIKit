#!/usr/bin/env bash
# Pins every rule of conventions.sh: the real tree must pass, and each case breaks
# a copy of it once (a fixture file, an appended declaration, or an edited asset)
# and expects a failure naming the right place, or a pass for allowed shapes.
# Cases add their own code instead of editing components, so they keep working as
# the library changes. Run from the repository root.
set -euo pipefail

root=$(pwd)
script=$root/.github/scripts/conventions.sh
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

src=Sources/DashUIKit
catalog=$src/Resources/Media.xcassets
fixture=$src/Fixture.swift
failures=0

fresh() {
  rm -rf "$work/tree"
  mkdir -p "$work/tree"
  cp -R "$root/Sources" "$work/tree/"
  cp "$root/Package.swift" "$work/tree/"
}

# first_set EXT [UNDER]: path of the first *.EXT set (optionally under a folder).
first_set() {
  find "$work/tree/$catalog${2:+/$2}" -type d -name "*.$1" | sort | head -n 1
}

# set_name PATH: the set's name without its extension.
set_name() {
  local base=${1##*/}
  echo "${base%.*}"
}

# write_fixture LINE...: replaces the fixture file with these lines.
write_fixture() {
  printf '%s\n' "$@" > "$work/tree/$fixture"
}

# expect NAME fail|pass [NEEDLE...]: runs the script on the copy; a failure must
# exit 1 and print every needle.
expect() {
  local name=$1 want=$2 output status=0 needle missing=""
  shift 2
  output=$(cd "$work/tree" && "$script" 2>&1) || status=$?
  for needle in "$@"; do
    [[ "$output" == *"$needle"* ]] || missing="${missing}      missing: ${needle}"$'\n'
  done
  if { [ "$want" = pass ] && [ "$status" -eq 0 ]; } ||
     { [ "$want" = fail ] && [ "$status" -eq 1 ] && [ -z "$missing" ]; }; then
    echo "ok    ${name}"
  else
    echo "FAIL  ${name}: expected ${want}, got exit ${status}"
    printf '%s' "$missing"
    printf '%s\n' "$output" | sed 's/^/      /'
    failures=$((failures + 1))
  fi
}

export GITHUB_ACTIONS=

fresh
expect "the real tree passes" pass

fresh
img=$(set_name "$(first_set imageset)")
col=$(set_name "$(first_set colorset)")

# 1. Icons ↔ imagesets.
fresh; dir=$(first_set imageset); mv "$dir" "${dir%/*}/${img}-renamed.imageset"
expect "renamed imageset" fail \
  "no imageset named \"${img}\"" \
  "imageset \"${img}-renamed\" is not referenced"

fresh; printf '%s\n' 'enum FixtureIcon: String, CaseIterable, DashIconAsset {' \
  '    case ghost = "no-such-icon"' \
  '    case noSuchBare' \
  '    case listA = "nope-a", listB' \
  "    case dup = \"${img}\"" \
  '    func f() { switch self { case let x where x == .ghost: break; default: break } }' \
  '}' >> "$work/tree/$src/Foundation/Icon_DashUI.swift"
expect "enum cases without assets" fail \
  'no imageset named "no-such-icon"' \
  'no imageset named "noSuchBare"' \
  'no imageset named "nope-a"' \
  'no imageset named "listB"' \
  "\"${img}\" is declared more than once"

fresh; mkdir "$work/tree/$catalog/Fixture & Folder"; cp -R "$(first_set imageset)" "$work/tree/$catalog/Fixture & Folder/"
expect "duplicate imageset in a folder with spaces" fail \
  "Fixture & Folder/${img}.imageset/Contents.json:1: imageset \"${img}\" exists in more than one folder"

fresh; printf '%s\n' 'public enum Wrapped: String, CaseIterable,' \
  '    DashIconAsset' \
  '{' \
  '    case ghost = "no-such-wrapped"' \
  '    enum Size {' \
  '        case small' \
  '    }' \
  '    var size: Int {' \
  '        switch self {' \
  '        case ghost: return 1' \
  '        }' \
  '    }' \
  '}' \
  'public enum OneLine: String, CaseIterable, DashIconAsset { case ghost = "no-such-one-line" }' >> "$work/tree/$src/Foundation/Icon_DashUI.swift"
expect "icon enums with wrapped and one-line headers" fail \
  'no imageset named "no-such-wrapped"' 'no imageset named "no-such-one-line"'
status=0; output=$(cd "$work/tree" && "$script" 2>&1) || status=$?
if [ "$status" -eq 1 ] && [[ "$output" != *'"small"'* ]]; then echo "ok    nested enum cases are not icons"
else echo "FAIL  nested enum cases are not icons: exit ${status}"; printf '%s\n' "$output" | sed 's/^/      /'; failures=$((failures + 1)); fi

fresh; printf '%s\n' 'enum IconSize {' '    case small, large' '}' >> "$work/tree/$src/Foundation/Icon_DashUI.swift"
echo "let fixtureAlias = dashAsset(\"${col}\")" >> "$work/tree/$src/Foundation/Color+DashUI.swift"
expect "helper enum among icons; color token alias" pass

fresh; find "$work/tree/$catalog" -type d -name '*.imageset' -exec rm -rf {} +
expect "no imagesets at all" fail 'no imageset found'

# 2. Color tokens ↔ colorsets.
fresh; dir=$(first_set colorset); cp -R "$dir" "${dir%/*}/OrphanColor.colorset"
expect "orphan colorset" fail 'colorset "OrphanColor" is not referenced'

fresh; echo 'let fixtureToken = dashAsset("NoSuchToken")' >> "$work/tree/$src/Foundation/Color+DashUI.swift"
expect "token without colorset" fail 'Color+DashUI.swift:' 'no colorset named "NoSuchToken"'

fresh; echo "let fixtureToken = 1 // was dashAsset(\"NoSuchToken\")" >> "$work/tree/$src/Foundation/Color+DashUI.swift"
dir=$(first_set colorset); cp -R "$dir" "${dir%/*}/LiteralOnly.colorset"
write_fixture 'let a = Color("LiteralOnly", bundle: .module)'
expect "commented token; colorset named only by a literal" pass

fresh; find "$work/tree/$catalog" -type d -name '*.colorset' -exec rm -rf {} +
expect "no colorsets at all" fail 'no colorset found'

# 3. Literal asset references.
fresh; write_fixture \
  'let a = DashIconSource.custom(flag ? "nope-one" : name, bundle: .dashUIKit)' \
  'let b = Color("NoSuchColor", bundle: .module)' \
  "let c = Image(\"${img}\")" \
  "let d = UIImage(named: \"${img}\")" \
  "let e = Color(\"${col}\")" \
  "let f = UIColor(named: \"${col}\", in: nil, compatibleWith: nil)" \
  "let g = Image(\"${img}\", bundle: .main)" \
  'let h = Image(decorative: "nope-two", bundle: .module)' \
  'let i = UIImage(named: "nope-three", in: .module, with: nil)' \
  'let j = UIColor(named: "NoSuchColor2", in: .dashUIKit, compatibleWith: nil)' \
  'let k = Image(' \
  '    "nope-four",' \
  '    bundle : .module)' \
  'let l = SwiftUI.Color.init("NoSuchColor3", bundle: .module)' \
  'let m = UIImage(named: style.iconName)' \
  'let n = Image.init("nope-five")' \
  'let o = Label("Title", image: "nope-six")' \
  'let p = Image(dash: .custom(style.iconName))' \
  'let q = DashButton(title: "x", leadingIcon: .custom(name))' \
  'let r: DashIconSource = .custom(name)' \
  'let s = Tab("Home", image: "nope-tab")'
expect "literal asset names" fail \
  "${fixture}:1: no imageset named \"nope-one\"" \
  "${fixture}:2: no colorset named \"NoSuchColor\"" \
  "${fixture}:3: asset looked up in the host app bundle" \
  "${fixture}:4: asset looked up in the host app bundle" \
  "${fixture}:5: asset looked up in the host app bundle" \
  "${fixture}:6: in: nil is not the package bundle" \
  "${fixture}:7: bundle: .main is not the package bundle" \
  "${fixture}:8: no imageset named \"nope-two\"" \
  "${fixture}:9: no imageset named \"nope-three\"" \
  "${fixture}:10: no colorset named \"NoSuchColor2\"" \
  "${fixture}:11: no imageset named \"nope-four\"" \
  "${fixture}:14: no colorset named \"NoSuchColor3\"" \
  "${fixture}:15: asset looked up in the host app bundle" \
  "${fixture}:16: asset looked up in the host app bundle" \
  "${fixture}:17: image: \"…\" is looked up in the host app bundle" \
  "${fixture}:18: asset looked up in the host app bundle: pass bundle" \
  "${fixture}:19: asset looked up in the host app bundle: pass bundle" \
  "${fixture}:20: asset looked up in the host app bundle: pass bundle" \
  "${fixture}:21: image: \"…\" is looked up in the host app bundle"

fresh; write_fixture \
  'let a = Font.custom("Inter", size: 12)' \
  'let b = Image(dash: .custom("icon-\(n)", bundle: .dashUIKit))' \
  'let c = Image(systemName: "xmark").accessibilityLabel(NSLocalizedString("Close", bundle: .module, comment: ""))' \
  'let d = Image(dash: source).overlay(Text("Done", bundle: .module))' \
  "let e = Image(\"${img}\", bundle: Bundle.dashUIKit)" \
  'let f = Color(uiColor: .systemBackground).opacity(0.5)' \
  'let g = Image(String(format: "menu-%@", x), bundle: .module)' \
  "let h = Image(icons[\"key\"] ?? \"${img}\", bundle: .module)" \
  'let i = Color(UIColor(named: "'"${col}"'", in: .module, compatibleWith: nil)!)' \
  'let j = Image(dash: .custom("icon-\(flag ? "a" : "b")", bundle: .dashUIKit))' \
  'let k = Image(.resourceName)' \
  "let l = Image(\"${img}\", bundle: #bundle)" \
  'let m = Image("icon-" + name, bundle: .module)' \
  'let n = Image(icon.resource)' \
  'let o = Label("Title", systemImage: "xmark")' \
  'func p(s: DashIconSource) { switch s { case let .custom(name, bundle): _ = (name, bundle); default: break } }' \
  'func q(s: DashIconSource) { if case .custom(_, let b) = s { _ = b } }' \
  'let r: Set<PresentationDetent> = [.medium, .custom(Half.self)]' \
  'let t = Button(style: .custom(style))' \
  'let u = Placement.custom("Compact")'
expect "calls that are not literal asset lookups" pass

# 4. Set contents and namespaces.
fresh; dir=$(first_set imageset); png=$(jq -r '.images[] | .filename // empty' "$dir/Contents.json" | head -n 1); rm "$dir/$png"
expect "image file missing" fail "lists \"${png}\", which is not in the imageset"

fresh; dir=$(first_set imageset); echo '{"images":[],"info":{"version":1}}' > "$dir/Contents.json"
expect "imageset without images" fail "\"${img}.imageset\" defines no image or color"

fresh; rm "$(first_set imageset)/Contents.json"
expect "imageset without Contents.json" fail "\"${img}\" has no Contents.json"

fresh; : > "$(first_set colorset)/Contents.json"
expect "empty Contents.json" fail "\"${col}\" has an empty Contents.json"

fresh; echo '{"colors":[]}' > "$(first_set colorset)/Contents.json"
expect "colorset without colors" fail "\"${col}.colorset\" defines no image or color"

fresh; echo '{' > "$(first_set colorset)/Contents.json"; echo '[]' > "$(first_set imageset)/Contents.json"
expect "invalid and non-object JSON" fail 'Contents.json is not valid JSON' 'Contents.json is not a JSON object'

fresh; mkdir "$work/tree/$catalog/Fixture NS" "$work/tree/$catalog/Fixture NS 2"
echo '{"properties":{"provides-namespace":true}}' > "$work/tree/$catalog/Fixture NS/Contents.json"
echo '{"properties":{"provides-namespace":"true"}}' > "$work/tree/$catalog/Fixture NS 2/Contents.json"
expect "namespaced folders" fail \
  'Fixture NS/Contents.json:1: folder provides a namespace' \
  'Fixture NS 2/Contents.json:1: folder provides a namespace'

# 5. Hardcoded colors.
fresh; write_fixture \
  'let a = Color(red: 1, green: 0, blue: 0)' \
  'let b = Color.init(red: 1, green: 0, blue: 0)' \
  'let c: Color = .init(white: 0.5)' \
  'let d = Color(uiColor: UIColor(red: 1, green: 0, blue: 0, alpha: 1))' \
  'let e = Color(' \
  '    hue: 0.5, saturation: 1, brightness: 1)' \
  'let f = CGColor(gray: 0.5, alpha: 1)' \
  'let g = Color(.sRGB, red: 1, green: 0, blue: 0)' \
  'let h = Color(hex: "#ffffff")' \
  'let i = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)' \
  'let j = NSColor(displayP3Red: 1, green: 0, blue: 0, alpha: 1)' \
  'let k = UIColor(white: 1, alpha: 1)' \
  'let l = Color(Color.RGBColorSpace.sRGB, red: 1, green: 0, blue: 0)' \
  'let m = Color(red : 0.1, green: 0, blue: 0)' \
  'let n = Text("\(Color(red: 1, green: 0, blue: 0))")'
expect "colors built from components" fail \
  "${fixture}:1: hardcoded color" "${fixture}:2: hardcoded color" "${fixture}:3: hardcoded color" \
  "${fixture}:4: hardcoded color" "${fixture}:5: hardcoded color" "${fixture}:7: hardcoded color" \
  "${fixture}:8: hardcoded color" "${fixture}:9: hardcoded color" "${fixture}:10: hardcoded color" \
  "${fixture}:11: hardcoded color" "${fixture}:12: hardcoded color" "${fixture}:13: hardcoded color" \
  "${fixture}:14: hardcoded color" "${fixture}:15: hardcoded color"

fresh; write_fixture \
  '// Color(red: 1, green: 0, blue: 0)' \
  'let a = Text("Color(red: 1)") // Color(red: 1)'
expect "comments and strings are not code" pass

# 6. Localized strings.
fresh; write_fixture \
  'let a = NSLocalizedString(' \
  '    "multi-line",' \
  '    comment: "")' \
  'let b = NSLocalizedString("a", bundle: .module, comment: "") + NSLocalizedString("b", comment: "")' \
  'let c = foo() // NSLocalizedString(' \
  'let d = NSLocalizedString("d", comment: "")' \
  'let e = String(localized: "e")' \
  'let f = NSLocalizedString("f", bundle: .main, comment: "")' \
  'let g = NSLocalizedString("g", comment: f(bundle: .module))' \
  'let h = Text("x \(String(localized: "y"))")' \
  'let i = AttributedString(localized: "i")'
expect "localized strings without the package bundle" fail \
  "${fixture}:1: localized string" "${fixture}:4: localized string" "${fixture}:6: localized string" \
  "${fixture}:7: localized string" "${fixture}:8: localized string" "${fixture}:9: localized string" \
  "${fixture}:10: localized string" "${fixture}:11: localized string"

fresh; write_fixture \
  'let a = NSLocalizedString("a (b", bundle: Bundle.dashUIKit, comment: ")")' \
  'let b = String(localized: "c", bundle: .module)' \
  'let c = String(describing: x)' \
  'let d = NSLocalizedString("d", bundle : .module, comment: "")' \
  'let e = String(localized: "e", bundle: #bundle)' \
  'let f = MyNSLocalizedString("f")' \
  'let g = String(localized: resource)'
expect "localized strings with the package bundle" pass

# 7. Availability.
fresh; write_fixture \
  '@available( iOS 13, *)' \
  'struct A {}' \
  '@available(iOS, introduced: 13)' \
  'struct B {}' \
  '@available(macCatalystApplicationExtension 13, *)' \
  'struct C {}' \
  '@available(' \
  '    macOS 10.15, *)' \
  'struct D {}' \
  'func e() { if #available(iOS 13, *) {} }' \
  'func f() { if #unavailable(iOS 13) {} }'
expect "@available at or below the floor" fail \
  "${fixture}:1: availability check for iOS 13 is at or below the package floor" \
  "${fixture}:3: availability check for iOS 13 is at or below" \
  "${fixture}:5: availability check for macCatalystApplicationExtension 13 is at or below" \
  "${fixture}:7: availability check for macOS 10.15 is at or below the package floor" \
  "${fixture}:10: availability check for iOS 13 is at or below" \
  "${fixture}:11: availability check for iOS 13 is at or below"

fresh; write_fixture \
  '@available(*, deprecated, message: "x")' \
  '@available(macOS, unavailable)' \
  'struct A {}' \
  '@available(iOS 99, macOS 99, *)' \
  'struct B {}' \
  '@available(visionOS 1, *)' \
  'struct C {}' \
  'func d() { if #unavailable(iOS 99.0) {} }'
expect "deprecated, unavailable and above the floor are allowed" pass

# Package.swift without a macOS platform: nothing to compare macOS against.
fresh; perl -0pi -e 's/,\s*\.macOS\(\.v\d+\)//' "$work/tree/Package.swift"
write_fixture '@available(macOS 10.15, *)' 'struct A {}'
expect "no macOS floor declared" pass

# A macOS platform in a shape the script cannot read is "could not run" too.
fresh; perl -pi -e 's/\.macOS\(\.v\d+(_\d+)?\)/.macOS("15.0")/' "$work/tree/Package.swift"
status=0; (cd "$work/tree" && "$script" > /dev/null 2>&1) || status=$?
if [ "$status" -eq 2 ]; then echo "ok    unreadable macOS floor exits 2"; else echo "FAIL  unreadable macOS floor: exit ${status}"; failures=$((failures + 1)); fi

# An unreadable iOS floor is "could not run", not a violation.
fresh; perl -pi -e 's/\.iOS\(\.v\d+(_\d+)?\)/.iOS("18.0")/' "$work/tree/Package.swift"
status=0; (cd "$work/tree" && "$script" > /dev/null 2>&1) || status=$?
if [ "$status" -eq 2 ]; then echo "ok    unreadable iOS floor exits 2"; else echo "FAIL  unreadable iOS floor: exit ${status}"; failures=$((failures + 1)); fi

# Output: workflow annotations escape the path.
fresh; printf '%s\n' 'let a = Color(red: 1, green: 0, blue: 0)' > "$work/tree/$src/Fix,ture.swift"
GITHUB_ACTIONS=true expect "annotation escapes the path" fail \
  "::error file=${src}/Fix%2Cture.swift,line=1::hardcoded color"

# Wrong directory: exit 2, not a pass.
status=0; (cd "$work" && "$script" > /dev/null 2>&1) || status=$?
if [ "$status" -eq 2 ]; then echo "ok    wrong directory exits 2"; else echo "FAIL  wrong directory: exit ${status}"; failures=$((failures + 1)); fi

if [ "$failures" -gt 0 ]; then
  echo "${failures} case(s) failed"
  exit 1
fi
echo "All cases passed"
