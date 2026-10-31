#!/usr/bin/env bash
# Replaces the local snapshot references with the ones CI rendered for the checked-out
# commit. The `Snapshot tests (iOS Simulator)` job re-records every missing or changed
# reference, fails, and uploads the whole set as the artifact `snapshots`; this script
# downloads it into SnapshotTests/Tests/DashUIKitSnapshotTests/__Snapshots__.
# Review the result with `git diff`, then commit and push.
#
# Usage: fetch-snapshots.sh [<run-id>]
#   Without a run id: the newest CI run of HEAD, which must be pushed, in an open PR
#   (CI runs on pull requests and on master), and finished.
#   A run id must be a run of HEAD too.
# Env: REPO (default dashpay/DashUIKit). Needs gh, logged in.
set -euo pipefail

repo=${REPO:-dashpay/DashUIKit}
root=$(git rev-parse --show-toplevel)
dest="$root/SnapshotTests/Tests/DashUIKitSnapshotTests/__Snapshots__"

if [ $# -gt 1 ]; then
  echo "usage: fetch-snapshots.sh [<run-id>]" >&2
  exit 2
fi

if [ -n "$(git -C "$root" status --porcelain --untracked-files=all -- "$dest")" ]; then
  echo "${dest#"$root"/} has uncommitted changes; commit or discard them first:" >&2
  git -C "$root" status --short --untracked-files=all -- "$dest" >&2
  exit 1
fi

sha=$(git rev-parse HEAD)
if [ $# -eq 1 ]; then
  run=$1
  info=$(gh run view "$run" -R "$repo" --json headSha,status --jq '"\(.headSha) \(.status)"')
  read -r run_sha status <<< "$info"
  if [ "$run_sha" != "$sha" ]; then
    echo "Run $run is for ${run_sha:0:7}, not HEAD ${sha:0:7}; its references would not match" >&2
    echo "this commit. Check out ${run_sha:0:7} or pass a run of HEAD." >&2
    exit 1
  fi
else
  # gh errors (not logged in, no network) end the script here, with gh's message.
  info=$(gh run list -R "$repo" --workflow ci.yml --commit "$sha" \
    --limit 1 --json databaseId,status --jq '.[] | "\(.databaseId) \(.status)"')
  if [ -z "$info" ]; then
    echo "No CI run for ${sha:0:7} in $repo. Push it to a branch with an open PR and wait" >&2
    echo "for CI." >&2
    exit 1
  fi
  read -r run status <<< "$info"
fi
if [ "$status" != completed ]; then
  echo "CI run $run for ${sha:0:7} is $status; run this again when it has finished:" >&2
  echo "  gh run watch $run -R $repo" >&2
  exit 1
fi

# Jobs of the run's latest attempt. A passing re-run of a failed attempt keeps the
# failed attempt's artifact; it must not be installed.
job=$(gh run view "$run" -R "$repo" --json jobs \
  --jq '.jobs[] | select(.name == "Snapshot tests (iOS Simulator)") | "\(.conclusion) \(.startedAt)"')
read -r conclusion started <<< "$job"
if [ "${conclusion:-}" != failure ]; then
  echo "The snapshot job of run $run ended with '${conclusion:-no such job}', not 'failure':" >&2
  echo "there is nothing it recorded to fetch." >&2
  exit 1
fi
# The artifact must come from that attempt, not from an earlier one of the same run.
created=$(gh api "repos/$repo/actions/runs/$run/artifacts" \
  --jq '.artifacts[] | select(.name == "snapshots" and (.expired | not)) | .created_at')
if [ -z "$created" ] || [[ "$created" < "$started" ]]; then
  echo "Run $run has no 'snapshots' artifact from its latest attempt: the job re-recorded" >&2
  echo "nothing (it failed before rendering; see its log), or the artifact expired." >&2
  exit 1
fi

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

gh run download "$run" -R "$repo" -n snapshots -D "$work/snapshots"

rm -rf "$dest"
mkdir -p "$dest"
cp -R "$work/snapshots/." "$dest/"

echo "References from run $run are in ${dest#"$root"/}:"
git -C "$root" status --short --untracked-files=all -- "$dest"
