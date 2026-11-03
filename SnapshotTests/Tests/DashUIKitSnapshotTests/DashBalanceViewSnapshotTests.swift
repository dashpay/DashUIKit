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
final class DashBalanceViewSnapshotTests: XCTestCase {

    /// With a fiat line and without one, on the secondary surface it sits on in
    /// a converter row.
    func testWithAndWithoutFiat() throws {
        let view = VStack(spacing: 16) {
            DashBalanceView(balance: "1.5", fiat: "$ 150.00")
            DashBalanceView(balance: "0", fiat: nil)
        }
        try assertComponentSnapshots(of: view, named: "fiat", background: .dash.secondaryBackground)
    }
}
#endif
