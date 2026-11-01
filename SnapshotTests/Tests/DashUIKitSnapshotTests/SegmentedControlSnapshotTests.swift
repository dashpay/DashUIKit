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
final class SegmentedControlSnapshotTests: XCTestCase {

    private let days = ["Day", "Week", "Month"]
    private let directions = ["Receive", "Internal", "Send"]

    private func icon(_ option: String, _ isSelected: Bool) -> DashIconSource {
        switch option {
        case "Receive":
            return (isSelected ? DashIcon.SegmentedControl.receive : .receiveDisabled).source
        case "Send":
            return (isSelected ? DashIcon.SegmentedControl.send : .sendDisabled).source
        default:
            return (isSelected ? DashIcon.SegmentedControl.transfer : .transferDisabled).source
        }
    }

    /// Two and three text segments, each selection position.
    func testText() throws {
        let view = VStack(spacing: 16) {
            SegmentedControl(options: ["Single", "Multiple"], selection: .constant("Multiple"))
            ForEach(days, id: \.self) { selected in
                SegmentedControl(options: days, selection: .constant(selected))
            }
        }
        try assertComponentSnapshots(of: view, named: "text")
    }

    /// Artwork over the label, each selection position: the selected segment
    /// shows the coloured artwork, the others the grey one.
    func testIcon() throws {
        let view = VStack(spacing: 16) {
            ForEach(directions, id: \.self) { selected in
                SegmentedControl(options: directions, selection: .constant(selected), label: { $0 }, icon: icon)
            }
        }
        try assertComponentSnapshots(of: view, named: "icon")
    }

    /// Offered more height than it needs, the icon variant keeps its own.
    func testIconInATallContainer() throws {
        let view = SegmentedControl(options: directions, selection: .constant("Receive"), label: { $0 }, icon: icon)
            .frame(height: 160, alignment: .top)
        try assertComponentSnapshots(of: view, named: "icon-tall-container")
    }

    /// Mirrored: the first option is on the right, under the pill.
    func testRightToLeft() throws {
        let view = VStack(spacing: 16) {
            SegmentedControl(options: days, selection: .constant("Day"))
            SegmentedControl(options: directions, selection: .constant("Receive"), label: { $0 }, icon: icon)
        }
        .environment(\.layoutDirection, .rightToLeft)
        try assertComponentSnapshots(of: view, named: "right-to-left")
    }

    /// A selection that is none of the options draws no pill.
    func testNoMatchingSelection() throws {
        let view = SegmentedControl(options: days, selection: .constant("Year"))
        try assertComponentSnapshots(of: view, named: "no-matching-selection")
    }
}
#endif
