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
final class CriteriaSnapshotTests: XCTestCase {

    /// Every state, one row each: the pending ring, the checking spinner, the
    /// met, failed, blocking (red text) and warning discs. The spinner is drawn
    /// from the layer tree without running its animation, so its frame is stable.
    func testEveryState() throws {
        let view = Criteria([
            Criterion(text: "Pending: not evaluated yet", state: .pending),
            Criterion(text: "Checking: a query is in flight", state: .checking),
            Criterion(text: "Met: the rule is satisfied", state: .met),
            Criterion(text: "Failed: the rule is not satisfied", state: .failed),
            Criterion(text: "Blocking: this is why Continue is disabled", state: .blocking),
            Criterion(text: "Warning: satisfied, but read this", state: .warning),
        ])
        try assertComponentSnapshots(of: view, named: "states", background: .dash.secondaryBackground)
    }

    /// Text that wraps in a narrow block: the mark stays on the first line.
    func testWrapping() throws {
        let view = Criteria([
            Criterion(
                text: "This username would also require voting, try adding a digit between 2 and 9",
                state: .blocking),
            Criterion(text: "Username available", state: .met),
        ])
        .frame(width: 260)
        .frame(maxWidth: .infinity, alignment: .leading)
        try assertComponentSnapshots(of: view, named: "wrapping", background: .dash.secondaryBackground)
    }

    /// The icon slot next to a standard disc, and a wider row spacing.
    func testIconSlotAndSpacing() throws {
        let view = Criteria([
            Criterion(text: "Standard disc", state: .met),
            Criterion(text: "The design system's icon slot", icon: .system("bolt.circle.fill")),
        ], spacing: 20)
        try assertComponentSnapshots(of: view, named: "icon-slot", background: .dash.secondaryBackground)
    }
}
#endif
