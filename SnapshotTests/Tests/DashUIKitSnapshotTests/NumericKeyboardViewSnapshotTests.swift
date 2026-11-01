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
final class NumericKeyboardViewSnapshotTests: XCTestCase {

    private func keyboard(
        value: String = "12",
        showDecimalSeparator: Bool = true,
        actionEnabled: Bool = true,
        helperText: String? = "Help text"
    ) -> some View {
        NumericKeyboardView(
            value: .constant(value),
            showDecimalSeparator: showDecimalSeparator,
            locale: Locale(identifier: "en_US"),
            actionButtonText: "Continue",
            actionEnabled: actionEnabled,
            inProgress: false,
            helperText: helperText,
            actionHandler: {}
        )
    }

    func testHelpTextAndDecimalSeparator() throws {
        try assertComponentSnapshots(of: keyboard(), named: "help-decimal")
    }

    func testNoHelpTextNoDecimalSeparator() throws {
        try assertComponentSnapshots(
            of: keyboard(showDecimalSeparator: false, helperText: nil),
            named: "plain"
        )
    }

    func testLongHelpText() throws {
        try assertComponentSnapshots(
            of: keyboard(helperText: "The amount is converted at the current rate and may change slightly before the transfer is confirmed."),
            named: "long-help"
        )
    }

    func testActionDisabled() throws {
        try assertComponentSnapshots(of: keyboard(actionEnabled: false), named: "action-disabled")
    }
}
#endif
