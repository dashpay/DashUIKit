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

/// Both styles of `EnterAmountView`; `CurrencyOption` is the value it shows. A
/// fiat option's symbol comes from `Locale.current`: "$" for USD in the
/// reference locale.
@MainActor
final class EnterAmountViewSnapshotTests: XCTestCase {

    private static let options: [CurrencyOption] = [.fiat("USD"), .dash, .coin("BTC")]

    /// The single style with each kind of option selected: Dash shows the
    /// logo, fiat its symbol and the currency chevron, a coin its code. With
    /// and without the Max button, and with the selected option hidden from
    /// the picker.
    func testSingle() throws {
        let view = VStack(spacing: 16) {
            EnterAmountView(value: .constant("12.5"), selectedCurrency: .constant(.dash), options: Self.options)
                .frame(height: 110)
            EnterAmountView(
                value: .constant("100"),
                selectedCurrency: .constant(.fiat("USD")),
                options: Self.options,
                onMax: {},
                onCurrencyTap: {}
            )
            .frame(height: 110)
            EnterAmountView(
                value: .constant(""),
                selectedCurrency: .constant(.coin("BTC")),
                options: Self.options,
                onMax: {},
                hidesSelectedOption: true
            )
            .frame(height: 110)
        }
        try assertComponentSnapshots(of: view, named: "single", background: .dash.secondaryBackground)
    }

    /// The dual-swap style at rest, never toggled, so the swap animation does
    /// not run: Dash in the large slot with the Max button and the switcher,
    /// fiat in the large slot with the currency chevron, the chevron hidden,
    /// and an error message in place of the secondary amount.
    func testDualSwap() throws {
        let view = VStack(spacing: 24) {
            EnterAmountView(
                primaryAmount: "1.23456",
                secondaryAmount: "150.00",
                primaryCurrency: .dash,
                secondaryCurrency: .fiat("USD"),
                isPrimarySelected: true,
                currencyCodes: ["DASH", "USD"],
                selectedCurrencyCode: "DASH",
                onMax: {}
            )
            EnterAmountView(
                primaryAmount: "1.5",
                secondaryAmount: "142.50",
                primaryCurrency: .dash,
                secondaryCurrency: .fiat("EUR"),
                isPrimarySelected: false,
                onCurrencyTap: {}
            )
            EnterAmountView(
                primaryAmount: "0.00012345",
                secondaryAmount: "0.01",
                primaryCurrency: .dash,
                secondaryCurrency: .fiat("USD"),
                isPrimarySelected: true,
                isCurrencySelectorHidden: true
            )
            EnterAmountView(
                primaryAmount: "250",
                secondaryAmount: "",
                primaryCurrency: .dash,
                secondaryCurrency: .fiat("USD"),
                isPrimarySelected: true,
                errorMessage: "Insufficient balance"
            )
        }
        try assertComponentSnapshots(of: view, named: "dual-swap", background: .dash.secondaryBackground)
    }

    /// A value too long for its column scales the whole amount down as one
    /// unit: in the single style, between the Max button and the picker, and in
    /// the dual-swap style, where the large row is wider than its column.
    func testLongAmounts() throws {
        let view = VStack(spacing: 24) {
            EnterAmountView(
                value: .constant("99999.99999999"),
                selectedCurrency: .constant(.dash),
                options: Self.options,
                onMax: {}
            )
            .frame(height: 110)
            EnterAmountView(
                primaryAmount: "12345678901234.5678",
                secondaryAmount: "1,234,567,890,123.45",
                primaryCurrency: .dash,
                secondaryCurrency: .fiat("USD"),
                isPrimarySelected: true
            )
        }
        try assertComponentSnapshots(of: view, named: "long-amounts", background: .dash.secondaryBackground)
    }
}
#endif
