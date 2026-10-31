#!/usr/bin/env bash
# Replaces the local snapshot references with the ones CI rendered for the checked-out
# commit. The `Snapshot tests (iOS Simulator)` job re-records every missing or changed
# reference, fails, and uploads the whole set as the artifact `snapshots`; this script
# downloads it into SnapshotTests/Tests/DashUIKitSnapshotTests/__Snapshots__.
# Review the result with `git diff`, then commit and push.
#
# Usage: fetch-snapshots.sh [<run-id>]
#   Without a run id: the newest CI run of HEAD, which must be pushed and finished.
# Env: REPO (default dashpay/DashUIKit). Needs gh, logged in.
set -euo pipefail

repo=${REPO:-dashpay/DashUIKit}
root=$(git rev-parse --show-toplevel)
dest="$root/SnapshotTests/Tests/DashUIKitSnapshotTests/__Snapshots__"

if [ $# -gt 1 ]; then
  echo "usage: fetch-snapshots.sh [<run-id>]" >&2
  exit 2
fi

if [ $# -eq 1 ]; then
  run=$1
else
  sha=$(git rev-parse HEAD)
  read -r run status < <(gh run list -R "$repo" --workflow ci.yml --commit "$sha" \
    --limit 1 --json databaseId,status --jq '.[] | "\(.databaseId) \(.status)"') || true
  if [ -z "${run:-}" ]; then
    echo "No CI run for ${sha:0:7} in $repo. Push the branch and wait for CI." >&2
    exit 1
  fi
  if [ "$status" != completed ]; then
    echo "CI run $run for ${sha:0:7} is $status; run this again when it has finished:" >&2
    echo "  gh run watch $run -R $repo" >&2
    exit 1
  fi
fi

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

if ! gh run download "$run" -R "$repo" -n snapshots -D "$work/snapshots"; then
  echo "Run $run has no 'snapshots' artifact: its snapshot job did not fail (nothing to" >&2
  echo "record), or the artifact expired." >&2
  exit 1
fi

rm -rf "$dest"
mkdir -p "$dest"
cp -R "$work/snapshots/." "$dest/"

echo "References from run $run are in ${dest#"$root"/}:"
git -C "$root" status --short -- "$dest"
