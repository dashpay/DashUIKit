#!/usr/bin/env bash
# Selects /Applications/Xcode_<version>.app and prints the toolchain versions.
# Usage: select-xcode.sh <version>
set -euo pipefail

version=${1:?usage: select-xcode.sh <version>}
sudo xcode-select -s "/Applications/Xcode_${version}.app"
xcodebuild -version
swift --version
