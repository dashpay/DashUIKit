#!/usr/bin/env bash
# Fails on an undeclared breaking change: HEAD is compared with HEAD^1 (on a
# pull_request run, the merge commit and the base it was merged onto). A break is
# declared with a conventional-commit "!" in the PR title ("feat!: …").
#
# Checked: the iOS deployment target and swift-tools-version in Package.swift
# (raising either drops consumers), and the public API as
# diagnose-api-breaking-changes sees it when built for the iOS Simulator (on the
# macOS host every `#if canImport(UIKit)` file is compiled out). Not checked: a
# raised @available on a single declaration; the digester ignores availability.
# A case added to a DashIcon.* enum is not counted: icon groups grow with every
# icon import, and nothing is expected to switch over them exhaustively.
#
# Env: PR_TITLE, BASE_REF (for messages), GITHUB_STEP_SUMMARY (optional).
set -euo pipefail

scripts=$(cd "$(dirname "$0")" && pwd)
summary_file=${GITHUB_STEP_SUMMARY:-/dev/null}
base_short=$(git rev-parse --short HEAD^1)

breaks=()

base_floor=$(git show HEAD^1:Package.swift | "$scripts/ios-floor.sh" /dev/stdin "Package.swift at HEAD^1")
head_floor=$("$scripts/ios-floor.sh" Package.swift)
# version_raised OLD NEW: true when NEW is higher than OLD.
version_raised() {
  awk -v a="$1" -v b="$2" 'BEGIN { split(a, x, "."); split(b, y, "."); for (i = 1; i <= 3; i++) { if (y[i] + 0 != x[i] + 0) exit !(y[i] + 0 > x[i] + 0) } exit 1 }'
}
if version_raised "$base_floor" "$head_floor"; then
  breaks+=("iOS deployment target raised from ${base_floor} to ${head_floor}")
fi

tools_version() {
  head -n 1 | grep -ioE 'swift-tools-version:[[:space:]]*[0-9.]+' | grep -oE '[0-9.]+$' || true
}
base_tools=$(git show HEAD^1:Package.swift | tools_version)
head_tools=$(tools_version < Package.swift)
if [ -z "$base_tools" ] || [ -z "$head_tools" ]; then
  echo "::error::Could not read swift-tools-version from Package.swift (base '${base_tools}', head '${head_tools}')"
  exit 1
fi
if version_raised "$base_tools" "$head_tools"; then
  breaks+=("swift-tools-version raised from ${base_tools} to ${head_tools}")
fi

sdk_path=$(xcrun --sdk iphonesimulator --show-sdk-path)

# No OS version in the triple: SwiftPM picks the deployment target (the package
# floor, raised to the SDK's minimum where the floor is older).
# Streamed through tee so a hung build still leaves a log.
log=$(mktemp)
set +e
swift package \
  --triple arm64-apple-ios-simulator \
  --sdk "$sdk_path" \
  diagnose-api-breaking-changes HEAD^1 2>&1 | tee "$log"
status=${PIPESTATUS[0]}
set -e
# Strip colour codes and OSC-8 hyperlinks.
report=$(perl -pe 's/\e\[[0-9;]*m//g; s/\e\]8;;.*?\e\\//g' "$log")
rm -f "$log"

verdict=$(sed -nE '/breaking changes? detected/,$p' <<< "$report")
if [ -z "$verdict" ]; then
  verdict=$(tail -n 40 <<< "$report")
fi

{
  echo "## API compatibility vs \`${BASE_REF:-base}\` (${base_short})"
  echo
  echo "iOS deployment target: ${base_floor} → ${head_floor}, swift-tools-version: ${base_tools} → ${head_tools}"
  echo '```'
  echo "$verdict"
  echo '```'
} >> "$summary_file"

if [ "$status" -ne 0 ]; then
  if ! grep -q "API breakage" <<< "$report"; then
    echo "::error::diagnose-api-breaking-changes failed without reporting a breakage. The base (${BASE_REF:-HEAD^1}) or this PR may not build for the iOS Simulator; see the log."
    exit "$status"
  fi
  counted=$(grep 'API breakage:' <<< "$report" \
    | grep -vE 'enumelement DashIcon\.[A-Za-z0-9_.]+ has been added as a new enum case' || true)
  if [ -n "$counted" ]; then
    breaks+=("public API changed, see the report above")
  else
    echo "Only new DashIcon cases were reported; not counted as breaking."
  fi
fi

if [ "${#breaks[@]}" -eq 0 ]; then
  echo "No breaking changes."
  exit 0
fi

for item in "${breaks[@]}"; do
  echo "Breaking: ${item}"
done

# Same shape the semantic PR title check parses: type, optional scope, "!: ".
if grep -Eq '^[A-Za-z0-9_]+(\(.*\))?!: ' <<< "${PR_TITLE:-}"; then
  echo "Breaking change is declared in the PR title."
  exit 0
fi

echo "::error::This PR makes a breaking change. Mark the title as breaking (e.g. \"feat!: …\") and describe it under \"Breaking Changes\" in the PR description."
exit 1
