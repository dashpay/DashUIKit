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
final class SystemMessageViewSnapshotTests: XCTestCase {

    /// The defaults (warning icon, grey surface) with a subtitle that wraps,
    /// and a title alone.
    func testDefault() throws {
        let view = VStack(spacing: 16) {
            SystemMessageView(
                title: "You have a balance on CrowdNode",
                subtitle: "These funds should be withdrawn from CrowdNode. You can transfer these funds to this wallet or via your online account on some other device."
            )
            SystemMessageView(title: "Syncing with the network")
        }
        try assertComponentSnapshots(of: view, named: "default")
    }

    /// A custom icon and surface, two pill buttons and the close button.
    func testButtonsAndClose() throws {
        let view = SystemMessageView(
            title: "Address Expired",
            subtitle: "The receiving address has expired. Generate a new one or extend the expiry.",
            icon: .system("clock.badge.exclamationmark"),
            backgroundColor: Color.dash.blueAlpha5,
            buttonName: "Renew",
            onAction: {},
            secondaryButtonName: "Extend",
            onSecondaryAction: {},
            onClose: {}
        )
        try assertComponentSnapshots(of: view, named: "buttons-close")
    }

    /// A link-style primary action sits against the text, tighter than a pill;
    /// with a link style and only the secondary pill, the pill keeps its place.
    /// A button without an action is not drawn.
    func testLinkAction() throws {
        let view = VStack(spacing: 16) {
            SystemMessageView(
                title: "Your username is pending",
                subtitle: "Voting ends in a few days.",
                buttonName: "Learn more",
                onAction: {},
                buttonStyle: .plainBlue
            )
            SystemMessageView(
                title: "Your username is pending",
                subtitle: "Voting ends in a few days.",
                secondaryButtonName: "Details",
                onSecondaryAction: {},
                buttonStyle: .plainBlue
            )
            SystemMessageView(
                title: "No action handler",
                buttonName: "Hidden",
                onClose: {}
            )
        }
        try assertComponentSnapshots(of: view, named: "link-action")
    }
}
#endif
