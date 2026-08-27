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

import XCTest
@testable import DashUIKit

final class BottomSheetDismissalActionTests: XCTestCase {
    func testDisabledDismissalDoesNotInvokeAnyAction() {
        var didClose = false
        var didDismiss = false

        BottomSheetDismissalAction.perform(
            isEnabled: false,
            onClose: { didClose = true },
            dismiss: { didDismiss = true }
        )

        XCTAssertFalse(didClose)
        XCTAssertFalse(didDismiss)
    }

    func testCustomCloseActionOverridesDefaultDismissal() {
        var didClose = false
        var didDismiss = false

        BottomSheetDismissalAction.perform(
            isEnabled: true,
            onClose: { didClose = true },
            dismiss: { didDismiss = true }
        )

        XCTAssertTrue(didClose)
        XCTAssertFalse(didDismiss)
    }

    func testDefaultCloseActionDismissesPresentation() {
        var didDismiss = false

        BottomSheetDismissalAction.perform(
            isEnabled: true,
            onClose: nil,
            dismiss: { didDismiss = true }
        )

        XCTAssertTrue(didDismiss)
    }
}
