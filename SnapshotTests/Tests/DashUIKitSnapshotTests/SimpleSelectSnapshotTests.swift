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
final class SimpleSelectSnapshotTests: XCTestCase {

    /// A column of options with each one selected in turn: the selected card
    /// takes the blue border and fill. One option has no description.
    func testSelection() throws {
        let view = VStack(spacing: 24) {
            ForEach(0..<3, id: \.self) { selected in
                VStack(spacing: 10) {
                    SimpleSelect(
                        title: "Shielded balance",
                        description: "Keeps your username private",
                        isSelected: selected == 0
                    ) {}
                    SimpleSelect(
                        title: "Dash balance",
                        description: "Funds will be traceable to your username",
                        isSelected: selected == 1
                    ) {}
                    SimpleSelect(title: "No description", isSelected: selected == 2) {}
                }
            }
        }
        try assertComponentSnapshots(of: view, named: "selection")
    }

    /// A description that wraps onto several lines.
    func testLongDescription() throws {
        let view = SimpleSelect(
            title: "Dash balance",
            description: "Funds will be traceable to your username, and anyone who looks the username up can see the payment that created it",
            isSelected: true
        ) {}
        try assertComponentSnapshots(of: view, named: "long-description")
    }
}
#endif
