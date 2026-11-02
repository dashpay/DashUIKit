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
final class SwapAmountViewSnapshotTests: XCTestCase {

    /// The static layout: the top and bottom captions, a secondary line, the
    /// currency chevron, a coin code as the symbol, and the display transforms
    /// of an empty and a bare-decimal amount.
    ///
    /// Each view sits in a slot of fixed height, as `EnterAmountView` gives it:
    /// the amount row learns its height from a measurement that lands after the
    /// first layout pass, so a height taken from the content alone is the one
    /// before it, and the render would be cut off.
    func testStatic() throws {
        let view = VStack(spacing: 20) {
            SwapAmountView(amount: "1.5", secondaryText: "$ 150.00", topText: "Enter amount", showDashLogo: true)
                .frame(height: 100)
            SwapAmountView(amount: "100", symbol: "$", secondaryText: "Ð 1.0", showCurrencyButton: true)
                .frame(height: 80)
            SwapAmountView(amount: "0.13", symbol: "$", bottomText: "Fiat, with button", showCurrencyButton: true)
                .frame(height: 80)
            SwapAmountView(amount: "0.00012345", symbol: "BTC", topText: "Crypto, small value")
                .frame(height: 80)
            HStack {
                SwapAmountView(amount: "", showDashLogo: true)
                SwapAmountView(amount: ".34", showDashLogo: true)
                SwapAmountView(amount: ",", symbol: "$")
            }
            .frame(height: 60)
        }
        try assertComponentSnapshots(of: view, named: "static")
    }

    /// Amounts wider than the 370 pt slot: the symbol, the figure, the logo and
    /// the chevron scale down together as one unit, the chevron staying next
    /// to the figure. Fixed slots, for the reason `testStatic` gives.
    func testScalesToFit() throws {
        let view = VStack(spacing: 20) {
            SwapAmountView(amount: "1234567890123456789012.34", topText: "Dash, wider than the slot", showDashLogo: true)
                .frame(height: 80)
            SwapAmountView(
                amount: "12345678901234567890.12",
                symbol: "$",
                topText: "Fiat, wider than the slot, with button",
                showCurrencyButton: true
            )
            .frame(height: 80)
        }
        try assertComponentSnapshots(of: view, named: "scales-to-fit")
    }

    /// The dual-swap layout at rest, each row in the large slot. Only a change
    /// of the key after the first render animates.
    func testAnimatedLayoutAtRest() throws {
        let view = VStack(spacing: 20) {
            ForEach([true, false], id: \.self) { isPrimaryLarge in
                SwapAmountView(
                    amount: "1.23456",
                    secondaryText: "150.00",
                    topText: "Enter amount",
                    showDashLogo: true,
                    secondarySymbol: "$",
                    showSecondaryCurrencyButton: true,
                    swapAnimationKey: isPrimaryLarge
                )
            }
        }
        try assertComponentSnapshots(of: view, named: "animated-at-rest", background: .dash.secondaryBackground)
    }

    /// In the dual-swap layout an error message takes the secondary row's place,
    /// at the secondary size, and drops the chevron.
    func testSecondaryError() throws {
        let view = SwapAmountView(
            amount: "250",
            secondaryText: "37.50",
            showDashLogo: true,
            secondarySymbol: "$",
            showSecondaryCurrencyButton: true,
            secondaryErrorMessage: "Insufficient balance",
            swapAnimationKey: true
        )
        try assertComponentSnapshots(of: view, named: "secondary-error", background: .dash.secondaryBackground)
    }
}
#endif
