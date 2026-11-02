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
final class ConverterCardSnapshotTests: XCTestCase {

    /// Swappable: the diagonal swap badge on the seam, a balance with fiat on
    /// the top row, no balance on the bottom one. The badge's rotation is state
    /// that only a tap changes, so it is at rest here.
    func testSwappable() throws {
        let view = ConverterCard(
            fromItem: ConverterCardItem(
                icon: .system("bitcoinsign.circle.fill"),
                title: "Coinbase",
                subtitle: "Dash Wallet",
                dashBalance: 420_000_000,
                fiat: "$410.00"
            ),
            toItem: ConverterCardItem(
                icon: .system("d.circle.fill"),
                title: "Dash",
                subtitle: "Dash Wallet",
                dashBalance: 123_456_789,
                fiat: "$120.00",
                showsBalance: false
            ),
            onSwap: {}
        )
        try assertComponentSnapshots(of: view, named: "swappable")
    }

    /// Not swappable: the static arrow-down badge.
    func testStatic() throws {
        let view = ConverterCard(
            fromItem: ConverterCardItem(
                icon: .system("d.circle.fill"),
                title: "Dash",
                dashBalance: 500_000_000,
                fiat: "$490.00"
            ),
            toItem: ConverterCardItem(
                icon: .system("arrow.right.circle.fill"),
                title: "Destination",
                showsBalance: false
            )
        )
        try assertComponentSnapshots(of: view, named: "static")
    }

    /// A row with a tap action grows the trailing chevron; the other stays
    /// without one. A zero balance hides the fiat line.
    func testTappableRow() throws {
        let view = ConverterCard(
            fromItem: ConverterCardItem(
                icon: .system("d.circle.fill"),
                title: "Tap to pick a source",
                subtitle: "From",
                dashBalance: 245_000_000,
                onTap: {}
            ),
            toItem: ConverterCardItem(
                icon: .system("person.crop.circle.fill"),
                title: "Identity",
                subtitle: "To",
                dashBalance: 0,
                fiat: "$0.00"
            )
        )
        try assertComponentSnapshots(of: view, named: "tappable-row")
    }

    /// A bottom row taller than the top one: the badge stays on the seam,
    /// which is measured from the top row alone.
    func testUnequalRows() throws {
        let view = ConverterCard(
            fromItem: ConverterCardItem(
                icon: .system("bitcoinsign.circle.fill"),
                title: "Coinbase",
                dashBalance: 420_000_000,
                fiat: "$410.00"
            ),
            toItem: ConverterCardItem(
                icon: .system("d.circle.fill"),
                title: "Dash",
                subtitle: "XqK7pMn2rV9wL4tYeB8dN3cF6hJsA1uZ, a long address that wraps and makes this row taller",
                subtitleLineLimit: nil,
                showsBalance: false
            ),
            onSwap: {}
        )
        try assertComponentSnapshots(of: view, named: "unequal-rows")
    }

    /// A top row taller than the 74 pt the card assumes before it has measured
    /// one: the badge sits on the seam only once the measured height is used.
    func testTallTopRow() throws {
        let view = ConverterCard(
            fromItem: ConverterCardItem(
                icon: .system("d.circle.fill"),
                title: "Dash",
                subtitle: "XqK7pMn2rV9wL4tYeB8dN3cF6hJsA1uZ, a long address that wraps and makes this row taller",
                subtitleLineLimit: nil,
                showsBalance: false
            ),
            toItem: ConverterCardItem(
                icon: .system("bitcoinsign.circle.fill"),
                title: "Coinbase",
                dashBalance: 420_000_000,
                fiat: "$410.00"
            ),
            onSwap: {}
        )
        try assertComponentSnapshots(of: view, named: "tall-top-row")
    }

    /// Custom leading and trailing views take the place of the icon and the
    /// built-in balance.
    func testCustomViews() throws {
        let view = ConverterCard(
            fromItem: ConverterCardItem(
                iconView: AnyView(Circle().fill(Color.dash.orange)),
                title: "Bitcoin",
                subtitle: "BTC",
                trailingView: AnyView(DashBalanceView(balance: "1.5", fiat: "$ 150.00"))
            ),
            toItem: ConverterCardItem(
                icon: .system("d.circle.fill"),
                title: "Dash",
                showsBalance: false
            )
        )
        try assertComponentSnapshots(of: view, named: "custom-views")
    }
}
#endif
