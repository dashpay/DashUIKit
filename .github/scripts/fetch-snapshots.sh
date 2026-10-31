#!/usr/bin/env bash
# Replaces the local snapshot references with the ones CI rendered for the checked-out
# commit. The `Snapshot tests (iOS Simulator)` job re-records every missing or changed
# reference, fails, and uploads the whole set as the artifact `snapshots`; this script
# downloads it into SnapshotTests/Tests/DashUIKitSnapshotTests/__Snapshots__.
# Review the result with `git diff`, then commit and push.
#
# Usage: fetch-snapshots.sh [<run-id>]
#   Without a run id: the newest finished, not cancelled CI run of HEAD, which must be
#   pushed, in an open PR (CI runs on pull requests and on master).
#   A run id must be a run of HEAD too.
# The references show the committed code of HEAD, so the working tree must have no
# uncommitted changes to tracked files, and none at all in __Snapshots__.
# Env: REPO (default dashpay/DashUIKit). Needs gh, logged in.
set -euo pipefail

repo=${REPO:-dashpay/DashUIKit}
root=$(git rev-parse --show-toplevel)
dest="$root/SnapshotTests/Tests/DashUIKitSnapshotTests/__Snapshots__"

if [ $# -gt 1 ]; then
  echo "usage: fetch-snapshots.sh [<run-id>]" >&2
  exit 2
fi

# Package.resolved is left out: a local Xcode rewrites it, and it does not change
# what CI rendered.
changes=$( (git -C "$root" status --porcelain --untracked-files=no -- . \
    ':!SnapshotTests/Package.resolved'
  git -C "$root" status --porcelain --untracked-files=all -- SnapshotTests/Tests) | sort -u)
if [ -n "$changes" ]; then
  echo "Uncommitted changes; the fetched references would show HEAD, not this tree." >&2
  echo "Commit or discard them first:" >&2
  echo "$changes" >&2
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
  runs=$(gh run list -R "$repo" --workflow ci.yml --commit "$sha" --limit 20 \
    --json databaseId,status,conclusion \
    --jq '.[] | "\(.databaseId) \(.status) \(.conclusion // "-" | if . == "" then "-" else . end)"')
  if [ -z "$runs" ]; then
    echo "No CI run for ${sha:0:7} in $repo. Push it to a branch with an open PR and wait" >&2
    echo "for CI." >&2
    exit 1
  fi
  # Newest first: skip runs that are still going or were cancelled.
  run=
  while read -r id state result; do
    if [ "$state" = completed ] && [ "$result" != cancelled ]; then
      run=$id status=$state
      break
    fi
    echo "Skipping run $id ($state${result:+, $result})." >&2
  done <<< "$runs"
  if [ -z "$run" ]; then
    echo "No finished CI run of ${sha:0:7} yet; run this again when one has finished." >&2
    exit 1
  fi
fi
if [ "$status" != completed ]; then
  echo "CI run $run for ${sha:0:7} is $status; run this again when it has finished:" >&2
  echo "  gh run watch $run -R $repo" >&2
  exit 1
fi

# Jobs of the run's latest attempt. A passing re-run of a failed attempt keeps the
# failed attempt's artifact; it must not be installed.
job=$(gh run view "$run" -R "$repo" --json jobs \
  --jq '.jobs[] | select(.name == "Snapshot tests (iOS Simulator)")
    | "\(.conclusion // "" | if . == "" then "unfinished" else . end)|\(.startedAt)"')
IFS='|' read -r conclusion started <<< "$job"
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

# Downloaded first, then swapped in, so a failed download leaves the references as they
# were. At the repo root (ignored by git), outside the test target, on the same disk.
work=$(mktemp -d "$root/.fetch-snapshots.XXXXXX")
trap 'rm -rf "$work"' EXIT

gh run download "$run" -R "$repo" -n snapshots -D "$work/snapshots"

rm -rf "$dest"
mv "$work/snapshots" "$dest"

echo "References from run $run are in ${dest#"$root"/}:"
git -C "$root" status --short --untracked-files=all -- "$dest"
