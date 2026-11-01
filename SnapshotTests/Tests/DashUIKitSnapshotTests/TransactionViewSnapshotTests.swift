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
final class TransactionViewSnapshotTests: XCTestCase {

    func testRows() throws {
        let view = VStack(spacing: 0) {
            TransactionView(
                icon: .system("arrow.down.circle.fill"),
                title: "Received",
                subtitle: "8:34 AM",
                dashAmount: 6_791_000,
                amountSign: .always,
                fiat: "$ 1.87"
            )
            TransactionView(
                icon: .system("arrow.up.circle.fill"),
                secondaryIcon: .system("clock.fill"),
                title: "Sent",
                subtitle: "8:34 AM",
                details: "Processing",
                dashAmount: -1_250_000,
                fiat: "$ 0.34"
            )
            TransactionView(
                icon: .system("circle.grid.2x2.fill"),
                topText: "3 transactions",
                title: "Mixing Transactions",
                subtitle: "8:34 AM",
                dashAmount: 50_000_000,
                amountSign: .none
            )
            TransactionView(
                icon: .system("arrow.forward.circle.fill"),
                title: "Internal Transfer",
                subtitle: "8:34 AM",
                dashAmount: 200_000_000,
                amountSign: .none,
                amountAccessorySystemImage: "arrow.triangle.2.circlepath",
                fiat: "$ 55.00"
            )
            TransactionView(
                icon: DashIcon.Transaction.mining.source,
                title: "Reward",
                subtitle: "8:34 AM",
                dashAmount: 250_000_000,
                amountSign: .always,
                fiat: "$ 68.75",
                trailingStatusText: "Locked"
            )
        }
        try assertComponentSnapshots(of: view, named: "rows")
    }
}
#endif
