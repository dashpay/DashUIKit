#!/usr/bin/env bash
# Prints the UDID of an available iPhone simulator on the newest iOS runtime the
# selected Xcode can run: runtime major.minor <= the iOS Simulator SDK version
# (a patch runtime such as 26.6.1 runs on the 26.6 SDK), and that has an iPhone.
set -euo pipefail

sdk=$(xcrun --sdk iphonesimulator --show-sdk-version)
runtimes=$(xcrun simctl list runtimes available -j)
devices=$(xcrun simctl list devices available -j)

udid=$(jq -rn --arg sdk "$sdk" --argjson runtimes "$runtimes" --argjson devices "$devices" '
  def mm: split(".") | map(tonumber) | .[0:2];
  [$runtimes.runtimes[]
    | select(.platform == "iOS" and (.version | mm) <= ($sdk | mm))
    | . as $rt
    | [$devices.devices[$rt.identifier][]? | select(.name | startswith("iPhone"))]
    | select(length > 0)
    | {version: ($rt.version | split(".") | map(tonumber)), runtime: $rt.identifier, udid: (last | .udid)}]
  | sort_by(.version) | last
  | if . == null then empty else "\(.udid) \(.runtime)" end')

if [ -z "$udid" ]; then
  echo "::error::No iOS runtime <= SDK ${sdk} with an available iPhone simulator" >&2
  xcrun simctl list devices available >&2
  exit 1
fi

echo "Using ${udid#* } ${udid%% *}" >&2
echo "${udid%% *}"
