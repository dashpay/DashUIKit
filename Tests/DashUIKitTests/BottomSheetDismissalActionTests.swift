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
