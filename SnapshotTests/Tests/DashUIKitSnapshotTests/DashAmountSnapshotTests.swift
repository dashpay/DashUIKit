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
final class DashAmountSnapshotTests: XCTestCase {

    /// A positive, a negative and a zero amount in each sign mode, one column
    /// per mode. Amounts are formatted with `Locale.current`, which the
    /// reference environment pins.
    func testSigns() throws {
        let signs: [DashAmountSign] = [.none, .negativeOnly, .always]
        let view = HStack(alignment: .top, spacing: 24) {
            ForEach(signs, id: \.self) { sign in
                VStack(alignment: .trailing, spacing: 8) {
                    DashAmount(amount: 6_791_000, fontSize: 15, sign: sign)
                    DashAmount(amount: -6_791_000, fontSize: 15, sign: sign)
                    DashAmount(amount: 0, fontSize: 15, sign: sign)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        try assertComponentSnapshots(of: view, named: "signs")
    }

    /// Size, weight and symbol factor; grouping and the fraction digit limit
    /// (five by default, rounding a few hundred duffs to zero, eight on
    /// request); and "Not available" for the sentinel values.
    func testFormatting() throws {
        let view = VStack(alignment: .leading, spacing: 8) {
            DashAmount(amount: 123_456_789_000, fontSize: 28, weight: .bold, dashSymbolFactor: 0.7)
            DashAmount(amount: 123_456_789)
            DashAmount(amount: 345)
            DashAmount(amount: 345, maximumFractionDigits: 8)
            DashAmount(amount: .max, fontSize: 15)
            DashAmount(amount: .min, fontSize: 15)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        try assertComponentSnapshots(of: view, named: "formatting")
    }
}
#endif
