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
final class RadioButtonRowSnapshotTests: XCTestCase {

    /// Radio and checkbox, selected and not.
    func testStyles() throws {
        let view = VStack(spacing: 0) {
            RadioButtonRow(title: "Radio selected", isSelected: true) {}
            RadioButtonRow(title: "Radio unselected", isSelected: false) {}
            RadioButtonRow(title: "Checkbox selected", isSelected: true, style: .checkbox) {}
            RadioButtonRow(title: "Checkbox unselected", isSelected: false, style: .checkbox) {}
        }
        try assertComponentSnapshots(of: view, named: "styles")
    }

    /// A subtitle (the taller row) with trailing text, and a leading icon.
    func testContent() throws {
        let view = VStack(spacing: 0) {
            RadioButtonRow(
                title: "With subtitle and trailing",
                subtitle: "Secondary text",
                trailingText: "-10%",
                isSelected: true
            ) {}
            RadioButtonRow(title: "With icon", icon: .system("star.fill"), isSelected: false) {}
            RadioButtonRow(
                title: "Everything",
                subtitle: "Secondary text",
                trailingText: "0.5 DASH",
                icon: .system("star.fill"),
                isSelected: true,
                style: .checkbox
            ) {}
        }
        try assertComponentSnapshots(of: view, named: "content")
    }

    /// The highlighted title: blue on a selected radio; a checkbox keeps its colour.
    func testHighlightedTitle() throws {
        let view = VStack(spacing: 0) {
            RadioButtonRow(title: "Radio selected", isSelected: true, highlightsSelectedTitle: true) {}
            RadioButtonRow(title: "Radio unselected", isSelected: false, highlightsSelectedTitle: true) {}
            RadioButtonRow(title: "Checkbox selected", isSelected: true, style: .checkbox, highlightsSelectedTitle: true) {}
        }
        try assertComponentSnapshots(of: view, named: "highlighted-title")
    }

    /// Rows inside `.disabled(true)`: the system's disabled look.
    func testDisabled() throws {
        let view = VStack(spacing: 0) {
            RadioButtonRow(title: "Radio", subtitle: "Secondary text", trailingText: "-10%", isSelected: false) {}
            RadioButtonRow(title: "With icon", icon: .system("star.fill"), isSelected: false) {}
            RadioButtonRow(title: "Checkbox", isSelected: false, style: .checkbox) {}
        }
        .disabled(true)
        try assertComponentSnapshots(of: view, named: "disabled")
    }
}
#endif
