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
final class CoinSelectorSnapshotTests: XCTestCase {

    private static var icon: some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(Color.dash.blue)
            .frame(width: 30, height: 30)
    }

    /// A price with a network, a halted coin (faded, with the badge), a coin
    /// with neither price nor network, and a name too long for its row.
    func testTrailingVariants() throws {
        let view = VStack(spacing: 0) {
            CoinSelector(name: "Rune", code: "RUNE", network: "Maya", trailing: .price("$0.40")) { Self.icon }
            CoinSelector(name: "Ethereum", code: "ETH", network: "NEAR", trailing: .price("$3,200.00")) { Self.icon }
            CoinSelector(name: "USD Coin", code: "USDC", network: "Multiple", trailing: .price("$1.00")) { Self.icon }
            CoinSelector(name: "Tether", code: "USDT", trailing: .halted) { Self.icon }
            CoinSelector(name: "Bitcoin", code: "BTC") { Self.icon }
            CoinSelector(
                name: "Wrapped Bitcoin bridged through a very long network name",
                code: "WBTC",
                network: "Ethereum",
                trailing: .price("$64,000.00")
            ) { Self.icon }
        }
        try assertComponentSnapshots(of: view, named: "trailing")
    }
}
#endif
