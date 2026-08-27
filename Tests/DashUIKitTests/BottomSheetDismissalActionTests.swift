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

    // MARK: - perform

    func testDisabledDismissalDoesNotDismissTheSheetItself() {
        var didDismiss = false

        BottomSheetDismissalAction.perform(
            isDismissalEnabled: false,
            onClose: nil,
            dismiss: { didDismiss = true }
        )

        XCTAssertFalse(didDismiss)
    }

    /// Blocking dismissal takes away the sheet's own `dismiss()`, not the host's action:
    /// this is the "swipe is blocked, closing asks for confirmation" configuration.
    func testCustomCloseActionStillRunsWhileDismissalIsDisabled() {
        var didClose = false
        var didDismiss = false

        BottomSheetDismissalAction.perform(
            isDismissalEnabled: false,
            onClose: { didClose = true },
            dismiss: { didDismiss = true }
        )

        XCTAssertTrue(didClose)
        XCTAssertFalse(didDismiss)
    }

    func testCustomCloseActionOverridesDefaultDismissal() {
        var didClose = false
        var didDismiss = false

        BottomSheetDismissalAction.perform(
            isDismissalEnabled: true,
            onClose: { didClose = true },
            dismiss: { didDismiss = true }
        )

        XCTAssertTrue(didClose)
        XCTAssertFalse(didDismiss)
    }

    func testDefaultCloseActionDismissesPresentation() {
        var didDismiss = false

        BottomSheetDismissalAction.perform(
            isDismissalEnabled: true,
            onClose: nil,
            dismiss: { didDismiss = true }
        )

        XCTAssertTrue(didDismiss)
    }

    // MARK: - isCloseButtonActive

    func testCloseButtonIsActiveWhileDismissalIsEnabled() {
        XCTAssertTrue(BottomSheetDismissalAction.isCloseButtonActive(
            isCloseButtonEnabled: true,
            isDismissalEnabled: true,
            hasCustomCloseAction: false))
    }

    /// Nothing left for a tap to do: the sheet may not dismiss itself and no host
    /// action was supplied, so the button goes inert rather than lying about it.
    func testCloseButtonIsInertWhenDismissalIsDisabledAndNoCustomAction() {
        XCTAssertFalse(BottomSheetDismissalAction.isCloseButtonActive(
            isCloseButtonEnabled: true,
            isDismissalEnabled: false,
            hasCustomCloseAction: false))
    }

    func testCloseButtonStaysActiveForACustomActionWhileDismissalIsDisabled() {
        XCTAssertTrue(BottomSheetDismissalAction.isCloseButtonActive(
            isCloseButtonEnabled: true,
            isDismissalEnabled: false,
            hasCustomCloseAction: true))
    }

    func testCloseButtonIsInertWhenDisabledOutright() {
        XCTAssertFalse(BottomSheetDismissalAction.isCloseButtonActive(
            isCloseButtonEnabled: false,
            isDismissalEnabled: true,
            hasCustomCloseAction: true))
    }
}
