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

@MainActor
final class ModalDialogTests: XCTestCase {

    /// The secondary action sits above the primary one, as in the design, and
    /// each button runs its own action.
    func testTheSecondaryButtonComesFirstAndEachRunsItsOwnAction() {
        var ran: [String] = []
        let dialog = ModalDialog(
            heading: "Keys left on your identity",
            paragraphs: ["One.", "Two."],
            primaryAction: .init(title: "Turn them off", role: .destructive) { ran.append("primary") },
            secondaryAction: .init(title: "Leave them") { ran.append("secondary") })

        XCTAssertEqual(dialog.buttons.map(\.title), ["Leave them", "Turn them off"])
        XCTAssertEqual(dialog.buttons.map(\.style), [.tintedGray, .tintedRed])
        dialog.buttons.forEach { $0.handler() }
        XCTAssertEqual(ran, ["secondary", "primary"])
    }

    func testOneButtonIsThePrimaryAction() {
        var ran = false
        let dialog = ModalDialog(heading: "Success", paragraphs: [], primaryAction: .init(title: "OK") { ran = true })

        XCTAssertEqual(dialog.buttons.map(\.title), ["OK"])
        XCTAssertEqual(dialog.buttons.map(\.style), [.tintedGray])
        dialog.buttons[0].handler()
        XCTAssertTrue(ran)
    }

    /// Paragraphs render in the order given, each its own block; none is dropped
    /// or merged.
    func testParagraphsKeepTheirOrder() {
        let paragraphs = ["First.", "Second.", "Third."]
        let dialog = ModalDialog(heading: "Success", paragraphs: paragraphs, primaryAction: .init(title: "OK") {})

        XCTAssertEqual(dialog.paragraphs, paragraphs)
    }
}
