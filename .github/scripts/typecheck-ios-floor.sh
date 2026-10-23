#!/usr/bin/env bash
# Type-checks the library at the iOS floor declared in Package.swift.
#
# xcodebuild raises the deployment target to the SDK's own minimum (iOS 15 on
# current Xcodes), so an API newer than the package's floor can build cleanly
# there. swiftc accepts the real floor for a type-check, so run it directly.
#
# The flags mirror what SwiftPM passes for this manifest. Package.swift shapes
# they do not model fail here loudly instead of checking the wrong thing.
# Xcode-generated asset symbols (ColorResource, ImageResource) do not exist here;
# the library resolves assets by name (Color.dash, DashIcon), not through them.
set -euo pipefail

scripts=$(cd "$(dirname "$0")" && pwd)

if ! head -n 1 Package.swift | grep -qE 'swift-tools-version: ?6'; then
  echo "::error::typecheck-ios-floor.sh passes -swift-version 6; Package.swift is not on tools version 6" >&2
  exit 1
fi
for extra in Package@swift-*.swift; do
  if [ -e "$extra" ]; then
    echo "::error::${extra} is not read by typecheck-ios-floor.sh or ios-floor.sh; update them" >&2
    exit 1
  fi
done

manifest_body=$(grep -vE '^[[:space:]]*//' Package.swift)
for construct in '.package(' 'swiftSettings' 'swiftLanguageModes' 'exclude:' 'path:' ' sources:'; do
  if grep -qF -- "$construct" <<< "$manifest_body"; then
    echo "::error::Package.swift uses '${construct# }', which typecheck-ios-floor.sh does not model; update the script" >&2
    exit 1
  fi
done
targets=$(grep -cE '\.target\(' <<< "$manifest_body" || true)
if [ "$targets" -ne 1 ]; then
  echo "::error::typecheck-ios-floor.sh expects one library target in Package.swift, found ${targets}" >&2
  exit 1
fi

floor=$("$scripts/ios-floor.sh" Package.swift)

sources=()
while IFS= read -r -d '' file; do
  sources+=("$file")
done < <(find Sources/DashUIKit -name '*.swift' -print0)
if [ "${#sources[@]}" -eq 0 ]; then
  echo "::error::No Swift sources found under Sources/DashUIKit" >&2
  exit 1
fi

# Only the DEBUG, simulator branch is checked; code that exists only elsewhere is not.
if grep -nE '#if[[:space:]]*!DEBUG|targetEnvironment' "${sources[@]}"; then
  echo "::error::Release-only or device-only branches are not covered by typecheck-ios-floor.sh; extend it" >&2
  exit 1
fi

# SwiftPM generates Bundle.module for the resource bundle; swiftc alone does not.
# No EXIT trap for cleanup: on bash 3.2 it turns an unbound-variable abort into exit 0.
stub_dir=$(mktemp -d)
stub="$stub_dir/BundleModule.swift"
printf 'import Foundation\nextension Foundation.Bundle { static let module = Bundle.main }\n' > "$stub"

# DEBUG on: the previews are type-checked too, and no source has a release-only branch.
echo "Type-checking ${#sources[@]} files for iOS ${floor}"
status=0
xcrun --sdk iphonesimulator swiftc -typecheck \
  -swift-version 6 \
  -target "arm64-apple-ios${floor}-simulator" \
  -module-name DashUIKit \
  -package-name DashUIKit \
  -parse-as-library \
  -DSWIFT_PACKAGE \
  -DSWIFT_MODULE_RESOURCE_BUNDLE_AVAILABLE \
  -DDEBUG \
  "$stub" "${sources[@]}" || status=$?

rm -rf "$stub_dir"
exit "$status"
