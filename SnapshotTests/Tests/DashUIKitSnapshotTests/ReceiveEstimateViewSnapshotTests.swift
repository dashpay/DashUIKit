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
final class ReceiveEstimateViewSnapshotTests: XCTestCase {

    /// Loading (the spinner, drawn from the layer tree without running its
    /// animation), an error that wins over an amount, an approximate amount,
    /// an exact one, one with fiat, and a hidden one between two dividers that
    /// takes no space.
    func testStates() throws {
        let view = VStack(spacing: 24) {
            ReceiveEstimateView(isVisible: true, title: "Receive amount", amount: nil, isLoading: true)
            ReceiveEstimateView(
                isVisible: true,
                title: "Receive amount",
                amount: "0.0123 BTC",
                errorMessage: "Insufficient balance"
            )
            ReceiveEstimateView(isVisible: true, title: "Receive amount", amount: "0.0123 BTC")
            ReceiveEstimateView(isVisible: true, title: "You will receive", amount: "0.5 DASH", approximate: false)
            ReceiveEstimateView(isVisible: true, title: "You will receive", amount: "22 DASH", fiat: "$6.04")
            VStack(spacing: 0) {
                Divider()
                ReceiveEstimateView(isVisible: false, title: "Receive amount", amount: "0.0123 BTC")
                Divider()
            }
        }
        try assertComponentSnapshots(of: view, named: "states")
    }
}
#endif
