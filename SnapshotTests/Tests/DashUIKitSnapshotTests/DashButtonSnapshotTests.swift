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
final class DashButtonSnapshotTests: XCTestCase {

    private static let sizes: [(DashButtonSize, String)] = [
        (.large, "Large"), (.medium, "Medium"), (.small, "Small"), (.extraSmall, "XS"),
    ]

    /// Every size, enabled and disabled, in one image per style.
    private func grid(_ style: DashButtonStyle) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach([true, false], id: \.self) { isEnabled in
                HStack(alignment: .top, spacing: 8) {
                    ForEach(Self.sizes, id: \.1) { size, title in
                        DashButton(text: title, isEnabled: isEnabled, size: size, style: style)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    func testFilledBlue() throws { try assertComponentSnapshots(of: grid(.filledBlue), named: "grid") }
    func testFilledRed() throws { try assertComponentSnapshots(of: grid(.filledRed), named: "grid") }
    func testStrokeGray() throws { try assertComponentSnapshots(of: grid(.strokeGray), named: "grid") }
    func testTintedBlue() throws { try assertComponentSnapshots(of: grid(.tintedBlue), named: "grid") }
    func testTintedGray() throws { try assertComponentSnapshots(of: grid(.tintedGray), named: "grid") }
    func testPlainBlue() throws { try assertComponentSnapshots(of: grid(.plainBlue), named: "grid") }
    func testPlainBlack() throws { try assertComponentSnapshots(of: grid(.plainBlack), named: "grid") }
    func testPlainRed() throws { try assertComponentSnapshots(of: grid(.plainRed), named: "grid") }

    // The white styles sit on a blue surface, as the previews show them.
    func testFilledWhiteBlue() throws {
        try assertComponentSnapshots(of: grid(.filledWhiteBlue), named: "grid", background: .dash.buttonFilledBlueBackground)
    }

    // Light and dark render the same pixels today, but every colour here has its own
    // dark variant in the catalog; the dark reference guards those.
    func testTintedWhite() throws {
        try assertComponentSnapshots(of: grid(.tintedWhite), named: "grid", background: .dash.buttonFilledBlueBackground)
    }

    func testPlainWhite() throws {
        try assertComponentSnapshots(of: grid(.plainWhite), named: "grid", background: .dash.buttonFilledBlueBackground)
    }

    func testIconsAndFullWidth() throws {
        let view = VStack(spacing: 12) {
            DashButton(text: "Withdraw funds", fillsWidth: true, size: .large, style: .filledBlue)
            DashButton(
                text: "Send",
                leadingIcon: .system("arrow.up"),
                trailingIcon: .system("chevron.right"),
                size: .medium,
                style: .tintedBlue
            )
            DashButton(leadingIcon: .system("plus"), size: .small, style: .strokeGray, accessibilityLabel: "Add")
        }
        try assertComponentSnapshots(of: view, named: "variants")
    }
}
#endif
