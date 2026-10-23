#!/usr/bin/env bash
# Fails on an undeclared breaking change: HEAD is compared with HEAD^1 (on a
# pull_request run, the merge commit and the base it was merged onto). A break is
# declared with a conventional-commit "!" in the PR title ("feat!: …").
#
# Checked: the iOS deployment target in Package.swift, and the public API as
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
if awk -v a="$base_floor" -v b="$head_floor" 'BEGIN { split(a, x, "."); split(b, y, "."); exit !(y[1] > x[1] || (y[1] == x[1] && y[2] > x[2])) }'; then
  breaks+=("iOS deployment target raised from ${base_floor} to ${head_floor}")
fi

sdk_path=$(xcrun --sdk iphonesimulator --show-sdk-path)

# No OS version in the triple: SwiftPM then builds at the package's platform.
set +e
report=$(swift package \
  --triple arm64-apple-ios-simulator \
  --sdk "$sdk_path" \
  diagnose-api-breaking-changes HEAD^1 2>&1)
status=$?
set -e
# Strip colour codes and OSC-8 hyperlinks.
report=$(perl -pe 's/\e\[[0-9;]*m//g; s/\e\]8;;.*?\e\\//g' <<< "$report")
echo "$report"

verdict=$(sed -nE '/breaking changes? detected/,$p' <<< "$report")
if [ -z "$verdict" ]; then
  verdict=$(tail -n 40 <<< "$report")
fi

{
  echo "## API compatibility vs \`${BASE_REF:-base}\` (${base_short})"
  echo
  echo "iOS deployment target: ${base_floor} → ${head_floor}"
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
    | grep -vE 'enumelement DashIcon\.[A-Za-z0-9_.]+ has been added as a new enum case' \
    | sort -u || true)
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
