#!/usr/bin/env bash
# Prints the iOS deployment target a Package.swift declares, as major.minor:
# `.iOS(.v14)` -> 14.0, `.iOS(.v17_4)` -> 17.4.
# Usage: ios-floor.sh [path/to/Package.swift] [label for messages]
set -euo pipefail

manifest=${1:-Package.swift}
label=${2:-$manifest}

# Line comments are dropped; a /* */ block with a platform in it is not supported.
matches=$(sed 's#//.*##' "$manifest" | grep -oE '\.iOS\(\.v[0-9]+(_[0-9]+)?\)' || true)
count=$(printf '%s' "$matches" | grep -c . || true)
if [ "$count" -ne 1 ]; then
  echo "::error::Expected exactly one .iOS(.vNN) platform in ${label}, found ${count}" >&2
  exit 1
fi

sed -E 's/.*\.v([0-9]+)(_([0-9]+))?\)/\1.\3/; s/\.$/.0/' <<< "$matches"
