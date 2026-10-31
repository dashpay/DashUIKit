#!/usr/bin/env bash
# Prints the UDID of an available iPhone simulator on the newest iOS runtime the
# selected Xcode can run: runtime major.minor <= the iOS Simulator SDK version
# (a patch runtime such as 26.6.1 runs on the 26.6 SDK), and that has an iPhone.
# Usage: pick-simulator.sh [<device name>]  (an exact name, e.g. "iPhone 17"; default:
# any iPhone)
set -euo pipefail

name=${1:-}

sdk=$(xcrun --sdk iphonesimulator --show-sdk-version)

# Through files, not --argjson: the device list can outgrow the argument limit.
work=$(mktemp -d)
xcrun simctl list runtimes available -j > "$work/runtimes.json"
xcrun simctl list devices available -j > "$work/devices.json"

udid=$(jq -rn --arg sdk "$sdk" --arg name "$name" \
  --slurpfile runtimes "$work/runtimes.json" \
  --slurpfile devices "$work/devices.json" '
  def mm: split(".") | map(tonumber) | .[0:2];
  [$runtimes[0].runtimes[]
    | select(.platform == "iOS" and (.version | mm) <= ($sdk | mm))
    | . as $rt
    | [$devices[0].devices[$rt.identifier][]? | select(if $name == "" then (.name | startswith("iPhone")) else .name == $name end)]
    | select(length > 0)
    | {version: ($rt.version | split(".") | map(tonumber)), runtime: $rt.identifier, udid: (last | .udid)}]
  | sort_by(.version) | last
  | if . == null then empty else "\(.udid) \(.runtime)" end')
rm -rf "$work"

if [ -z "$udid" ]; then
  echo "::error::No iOS runtime <= SDK ${sdk} with an available ${name:-iPhone} simulator" >&2
  xcrun simctl list devices available >&2
  exit 1
fi

echo "Using ${udid#* } ${udid%% *}" >&2
echo "${udid%% *}"
