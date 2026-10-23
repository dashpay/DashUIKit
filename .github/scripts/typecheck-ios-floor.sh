#!/usr/bin/env bash
# Type-checks the library at the iOS floor declared in Package.swift.
#
# xcodebuild clamps the deployment target to the SDK's own minimum (iOS 15 on
# Xcode 27), so an iOS 15-only API inside an iOS 14 component builds cleanly
# there. swiftc accepts the real floor for a type-check, so run it directly,
# once as Release and once with DEBUG to cover the previews.
set -euo pipefail

floor=$(grep -oE '\.iOS\(\.v[0-9]+' Package.swift | grep -oE '[0-9]+$' || true)
if [ -z "$floor" ]; then
  echo "::error::Could not read the iOS deployment target from Package.swift"
  exit 1
fi

# SwiftPM generates Bundle.module for the resource bundle; swiftc alone does not.
stub_dir=$(mktemp -d)
stub="$stub_dir/BundleModule.swift"
printf 'import Foundation\nextension Foundation.Bundle { static let module = Bundle.main }\n' > "$stub"
trap 'rm -rf "$stub_dir"' EXIT

sources=()
while IFS= read -r -d '' file; do
  sources+=("$file")
done < <(find Sources/DashUIKit -name '*.swift' -print0)

for config in Release Debug; do
  defines=()
  if [ "$config" = Debug ]; then
    defines=(-DDEBUG)
  fi
  echo "Type-checking ${#sources[@]} files for iOS ${floor} (${config})"
  xcrun --sdk iphonesimulator swiftc -typecheck \
    -swift-version 6 \
    -target "arm64-apple-ios${floor}.0-simulator" \
    -module-name DashUIKit \
    "${defines[@]+"${defines[@]}"}" \
    "$stub" "${sources[@]}"
done
