#!/usr/bin/env bash
# Prints the iOS deployment target a Package.swift declares, as major.minor:
# `.iOS(.v14)` -> 14.0, `.iOS(.v17_4)` -> 17.4.
# Usage: ios-floor.sh [path/to/Package.swift]
set -euo pipefail

manifest=${1:-Package.swift}

matches=$(grep -vE '^[[:space:]]*//' "$manifest" | grep -oE '\.iOS\(\.v[0-9]+(_[0-9]+)?\)' || true)
count=$(printf '%s' "$matches" | grep -c . || true)
if [ "$count" -ne 1 ]; then
  echo "::error::Expected exactly one .iOS(.vNN) platform in ${manifest}, found ${count}" >&2
  exit 1
fi

sed -E 's/.*\.v([0-9]+)(_([0-9]+))?\)/\1.\3/; s/\.$/.0/' <<< "$matches"
