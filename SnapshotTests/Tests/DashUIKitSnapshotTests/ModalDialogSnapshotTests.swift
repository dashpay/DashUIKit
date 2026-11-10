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
import DashUIKit
import SwiftUI
import XCTest

@MainActor
final class ModalDialogSnapshotTests: XCTestCase {

    /// One full-width button under a paragraph.
    func testOneButton() throws {
        let view = ModalDialog(
            icon: .warning, heading: "Success",
            paragraphs: ["Disconnected. This wallet could not tell yet which app holds some keys on your identity (1). Open Connections again later to see them."],
            primaryAction: .init(title: "OK") {})
        try assertComponentSnapshots(of: view, named: "one-button")
    }

    /// The secondary action above a destructive primary one.
    func testTwoButtons() throws {
        let view = ModalDialog(
            icon: .warning, heading: "Keys left on your identity",
            paragraphs: ["Disconnected. Keys this wallet did not record giving are still on your identity (2): keys of this app from another device or from before a restore, or DashPay profile keys no connection holds. Turn them off too?"],
            primaryAction: .init(title: "Turn them off", role: .destructive) {},
            secondaryAction: .init(title: "Leave them") {})
        try assertComponentSnapshots(of: view, named: "two-buttons")
    }

    /// Several paragraphs, a blank line between them; and a heading with no
    /// icon and no paragraph.
    func testParagraphsAndBare() throws {
        let view = VStack(spacing: 16) {
            ModalDialog(
                icon: .warning, heading: "Success",
                paragraphs: [
                    "Disconnected. This wallet could not tell yet which app holds some keys on your identity (1). Open Connections again later to see them.",
                    "Some keys on your identity (1) may belong to another app of the same developer, so this wallet left them on. Each one shows on its own row in Connections; disconnect it there if you no longer need it.",
                    "Disconnected. Some keys of this app are still on your identity (1). Disconnect it again to turn them off.",
                ],
                primaryAction: .init(title: "OK") {})
            ModalDialog(heading: "Disconnected", paragraphs: [], primaryAction: .init(title: "OK") {})
        }
        try assertComponentSnapshots(of: view, named: "paragraphs-bare")
    }
}
#endif
