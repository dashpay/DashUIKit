//
//  Copyright © 2026 Dash Core Group. All rights reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  https://opensource.org/licenses/MIT
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#if canImport(UIKit)
import DashUIKit
import SnapshotTesting
import SwiftUI
import UIKit
import XCTest

/// The environment the references in `__Snapshots__` are rendered in: the
/// `Snapshot tests (iOS Simulator)` CI job. Text, SF Symbols and layout render
/// differently on another iOS release or locale, so the references are only
/// compared there (see docs/snapshot-tests.md).
enum ReferenceEnvironment {
    /// The CI simulator runtime: its version and build. A runtime update with the
    /// same version number can still render differently.
    static let iOS = "26.5 (23F77)"
    /// Amounts are formatted with `Locale.current`; this is 1234.5 in the
    /// reference locale's separators.
    static let number = "1,234.5"

    static var current: (iOS: String, number: String) {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = .current
        // "Version 26.5 (Build 23F77)" → "26.5 (23F77)"
        let os = ProcessInfo.processInfo.operatingSystemVersionString
            .replacingOccurrences(of: "Version ", with: "")
            .replacingOccurrences(of: "Build ", with: "")
        return (os, formatter.string(from: 1234.5) ?? "")
    }

    struct Mismatch: Error, CustomStringConvertible {
        let description: String
    }

    /// Throws `XCTSkip` outside the reference environment, or an error that
    /// fails the test when `SNAPSHOT_REQUIRE_REFERENCE_ENVIRONMENT=1` (CI).
    /// `SNAPSHOT_FORCE=1` compares anyway.
    static func check() throws {
        let environment = ProcessInfo.processInfo.environment
        if environment["SNAPSHOT_FORCE"] == "1" { return }

        let current = current
        if current.iOS == iOS, current.number == number { return }

        let message = """
            References are rendered on iOS \(iOS) with numbers as "\(number)"; this is iOS \
            \(current.iOS) with "\(current.number)". Set SNAPSHOT_FORCE=1 to compare anyway, \
            or update ReferenceEnvironment and re-record (docs/snapshot-tests.md).
            """
        if environment["SNAPSHOT_REQUIRE_REFERENCE_ENVIRONMENT"] == "1" {
            throw Mismatch(description: message)
        }
        throw XCTSkip(message)
    }
}

enum SnapshotLayout {
    /// The iPhone 17 Pro width in points, rendered at its 3× scale.
    static let width: CGFloat = 402
    static let scale: CGFloat = 3
    static let padding: CGFloat = 16
}

/// Asserts `view` against its light and its dark reference, rendered at
/// `SnapshotLayout.width` on `background`, with `SnapshotLayout.padding` around it.
///
/// `precision: 1` checks every pixel; `perceptualPrecision: 0.98` lets a pixel
/// differ by a colour distance (ΔE) of at most 2, which absorbs anti-aliasing noise
/// and nothing a reader would see.
@MainActor
func assertComponentSnapshots(
    of view: some View,
    named name: String,
    background: Color = Color.dash.primaryBackground,
    fileID: StaticString = #fileID,
    filePath: StaticString = #filePath,
    testName: String = #function,
    line: UInt = #line,
    column: UInt = #column
) throws {
    try ReferenceEnvironment.check()

    for style in [UIUserInterfaceStyle.light, .dark] {
        let traits = UITraitCollection { traits in
            traits.userInterfaceStyle = style
            traits.displayScale = SnapshotLayout.scale
        }
        let framed = view
            .padding(SnapshotLayout.padding)
            .frame(width: SnapshotLayout.width)
            .background(background)
            .environment(\.colorScheme, style == .dark ? .dark : .light)

        assertSnapshot(
            of: framed,
            as: .image(precision: 1, perceptualPrecision: 0.98, layout: .sizeThatFits, traits: traits),
            named: "\(name)-\(style == .dark ? "dark" : "light")",
            fileID: fileID,
            file: filePath,
            testName: testName,
            line: line,
            column: column
        )
    }
}
#endif
