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
final class MenuItemSnapshotTests: XCTestCase {

    func testTextRows() throws {
        let view = VStack(spacing: 0) {
            MenuItem(title: "Notifications")
            MenuItem(title: "Recovery phrase", helpText: "Back up your wallet to keep your funds safe")
            MenuItem(
                title: "Network fee",
                helpText: "Estimated cost for this transaction",
                info: .round(color: Color.dash.gray300Alpha70),
                accessory: .text("0.0001 DASH")
            )
        }
        try assertComponentSnapshots(of: view, named: "text")
    }

    func testControlAccessories() throws {
        let view = VStack(spacing: 0) {
            MenuItem(title: "Enable biometrics", accessory: .toggle(isOn: .constant(true)))
            MenuItem(title: "Withdraw", accessory: .button(DashButton(text: "Withdraw", size: .small, style: .tintedBlue)))
            MenuItem(
                leadingIcon: DashIcon.Menu.dashLogoSquare.source,
                title: "Transparent",
                accessory: .selection(isSelected: true)
            )
            MenuItem(
                leadingIcon: DashIcon.Features.platform.source,
                title: "Platform",
                accessory: .selection(isSelected: false)
            )
        }
        try assertComponentSnapshots(of: view, named: "controls")
    }

    func testBalances() throws {
        let view = VStack(spacing: 0) {
            MenuItem(title: "Staking balance", accessory: .balance(dash: 6_791_000, fiat: "$1.23"))
            MenuItem(title: "Outgoing", accessory: .balance(dash: -6_791_000, fiat: "$1.23"))
            MenuItem(title: "Received", accessory: .balance(dash: 6_791_000, sign: .always, fiat: "$1.23"))
            MenuItem(title: "Available", accessory: .balance(dash: 0))
            MenuItem(title: "Pending", accessory: .balance(dash: .max))
        }
        try assertComponentSnapshots(of: view, named: "balances")
    }

    func testEnabledAndDisabled() throws {
        let view = VStack(spacing: 0) {
            MenuItem(
                leadingIcon: DashIcon.Menu.receive.source,
                title: "Buy Dash",
                helpText: "From any crypto to your Dash Wallet"
            )
            MenuItem(
                leadingIcon: DashIcon.Menu.receive.source,
                isEnabled: false,
                disabledLeadingIcon: DashIcon.Menu.receiveDisabled.source,
                title: "Buy Dash",
                helpText: "From any crypto to your Dash Wallet"
            )
        }
        try assertComponentSnapshots(of: view, named: "states")
    }
}
#endif
