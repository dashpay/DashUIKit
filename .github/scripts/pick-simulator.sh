#!/usr/bin/env bash
# Prints the UDID of an available iPhone simulator on the newest iOS runtime the
# selected Xcode can run (runtime version <= the iOS Simulator SDK version).
set -euo pipefail

sdk=$(xcrun --sdk iphonesimulator --show-sdk-version)

runtime=$(xcrun simctl list runtimes available -j | jq -r --arg sdk "$sdk" '
  def v: split(".") | map(tonumber);
  [.runtimes[] | select(.platform == "iOS" and (.version | v) <= ($sdk | v))]
  | sort_by(.version | v) | last | .identifier // empty')

if [ -z "$runtime" ]; then
  echo "::error::No iOS simulator runtime <= SDK ${sdk} on this machine" >&2
  xcrun simctl list runtimes >&2
  exit 1
fi

udid=$(xcrun simctl list devices available -j | jq -r --arg rt "$runtime" '
  [.devices[$rt][]? | select(.name | startswith("iPhone"))] | last | .udid // empty')

if [ -z "$udid" ]; then
  echo "::error::No available iPhone simulator for ${runtime}" >&2
  xcrun simctl list devices available >&2
  exit 1
fi

echo "Using ${runtime} ${udid}" >&2
echo "$udid"
