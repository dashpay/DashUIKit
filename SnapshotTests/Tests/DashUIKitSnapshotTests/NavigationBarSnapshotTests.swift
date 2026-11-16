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
final class NavigationBarSnapshotTests: XCTestCase {

    private func title() -> some View {
        Text("Title")
            .dashFont(.subheadMedium)
            .foregroundColor(.dash.primaryText)
    }

    func testVariants() throws {
        let view = VStack(spacing: 12) {
            NavigationBar(leading: { NavigationBarElement.back.button {} })
            NavigationBar(
                leading: { NavigationBarElement.back.button {} },
                central: { title() },
                trailing: { NavigationBarElement.info.button {} }
            )
            NavigationBar(
                central: { title() },
                trailing: { NavigationBarElement.close.button {} }
            )
            NavigationBar(
                leading: { NavigationBarElement.back.button {} },
                trailing: { NavigationBarElement.plus.button {} }
            )
        }
        try assertComponentSnapshots(of: view, named: "variants")
    }

    private func longTitle() -> some View {
        Text("A title far too long to fit between the controls")
            .dashFont(.subheadMedium)
            .foregroundColor(.dash.primaryText)
    }

    /// A long title ends in an ellipsis clear of the wider side: with both
    /// sides, with a back button only, with two views in one slot (measured
    /// together), and with no sides, where it spans the full width.
    func testLongTitles() throws {
        let view = VStack(spacing: 12) {
            NavigationBar(
                leading: { NavigationBarElement.back.button {} },
                central: { longTitle() },
                trailing: { NavigationBarElement.info.button {} }
            )
            NavigationBar(
                leading: { NavigationBarElement.back.button {} },
                central: { longTitle() }
            )
            NavigationBar(
                leading: { NavigationBarElement.back.button {} },
                central: { longTitle() },
                trailing: {
                    NavigationBarCircleButton(.system("arrow.clockwise"), accessibilityLabel: Text("Refresh")) {}
                    NavigationBarCircleButton(.system("ellipsis"), accessibilityLabel: Text("More")) {}
                }
            )
            NavigationBar(central: { longTitle() })
        }
        try assertComponentSnapshots(of: view, named: "long-titles")
    }
}
#endif
