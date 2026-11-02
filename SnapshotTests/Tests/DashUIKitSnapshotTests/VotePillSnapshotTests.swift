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
import SwiftUI
import XCTest

@MainActor
final class VotePillSnapshotTests: XCTestCase {

    /// Every kind in every status, unselected and selected, one row each. The
    /// busy spinner is drawn from the layer tree without running its animation,
    /// so its frame is stable.
    func testKindsAndStates() throws {
        let rows: [(Bool, VotePill.Status)] = [
            (false, .enabled), (true, .enabled),
            (false, .busy), (true, .busy),
            (false, .disabled), (true, .disabled),
        ]
        let view = VStack(alignment: .leading, spacing: 12) {
            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                HStack(spacing: 10) {
                    VotePill(kind: .block, count: 1, isSelected: row.0, status: row.1) {}
                    VotePill(kind: .approve, count: 12, isSelected: row.0, status: row.1) {}
                    VotePill(kind: .expand(isExpanded: false), status: row.1) {}
                    VotePill(kind: .expand(isExpanded: true), status: row.1) {}
                }
            }
        }
        try assertComponentSnapshots(of: view, named: "states", background: .dash.secondaryBackground)
    }

    /// Counts that need the most room: three digits fill the 70 pt pill, four and
    /// more collapse to "999+", a few points wider.
    func testLargeCounts() throws {
        let view = VStack(spacing: 12) {
            HStack(spacing: 10) {
                VotePill(kind: .block, count: 999) {}
                VotePill(kind: .approve, count: 12_345, isSelected: true) {}
            }
            // Arabic digits, right to left: the "+" stays after the digits.
            HStack(spacing: 10) {
                VotePill(kind: .block, count: 999) {}
                VotePill(kind: .approve, count: 12_345, isSelected: true) {}
            }
            .environment(\.locale, Locale(identifier: "ar_EG"))
            .environment(\.layoutDirection, .rightToLeft)
        }
        try assertComponentSnapshots(of: view, named: "large-counts", background: .dash.secondaryBackground)
    }
}
#endif
