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
final class AddressFieldViewSnapshotTests: XCTestCase {

    private static let address = "bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh"

    /// Empty: with the scan glyph, without a scan handler (no trailing glyph),
    /// and with the Paste button. Every field here is unfocused: focus needs a
    /// key window, which a render without a host app does not have, so the
    /// focused ring is not pinned.
    func testEmpty() throws {
        let view = VStack(spacing: 20) {
            AddressFieldView(
                text: .constant(""),
                label: "Destination address",
                placeholder: "BTC address",
                hasError: false,
                onScanQR: {}
            )
            AddressFieldView(
                text: .constant(""),
                label: "Username",
                placeholder: "Enter a username",
                hasError: false
            )
            AddressFieldView(
                text: .constant(""),
                label: "Destination address",
                placeholder: "BTC address",
                hasError: false,
                onScanQR: {},
                onPaste: {}
            )
        }
        try assertComponentSnapshots(of: view, named: "empty")
    }

    /// Filled and unfocused: an address that wraps to two lines (the trailing
    /// control keeps its space but is hidden), text longer than two lines cut
    /// to two, and a value with no clear button (its tap area collapses).
    func testFilled() throws {
        let view = VStack(spacing: 20) {
            AddressFieldView(
                text: .constant(Self.address),
                label: "Destination address",
                placeholder: "BTC address",
                hasError: false,
                onScanQR: {}
            )
            AddressFieldView(
                text: .constant("\(Self.address)\n\(Self.address)"),
                label: "Destination address",
                placeholder: "BTC address",
                hasError: false,
                onScanQR: {}
            )
            AddressFieldView(
                text: .constant("satoshi"),
                label: "Username",
                placeholder: "Enter a username",
                hasError: false,
                showsClearButton: false
            )
        }
        try assertComponentSnapshots(of: view, named: "filled")
    }

    /// An error: the red fill and ring, the clear button, the message below.
    func testError() throws {
        let view = AddressFieldView(
            text: .constant("invalid-address"),
            label: "Destination address",
            placeholder: "BTC address",
            hasError: true,
            errorText: "Error text",
            onScanQR: {}
        )
        try assertComponentSnapshots(of: view, named: "error")
    }

    /// Disabled: no trailing control, the text not editable.
    func testDisabled() throws {
        let view = AddressFieldView(
            text: .constant(Self.address),
            label: "Destination address",
            placeholder: "BTC address",
            hasError: false,
            isDisabled: true,
            onScanQR: {}
        )
        try assertComponentSnapshots(of: view, named: "disabled")
    }

    /// A host's badge on the label row, opposite the label.
    func testLabelAccessory() throws {
        let view = AddressFieldView(
            text: .constant("yV1D1ivvSUyKPJnbFmzSTVh1MyZ3JbeVkY"),
            label: "Address",
            placeholder: "Dash address",
            hasError: false
        ) {
            HStack(spacing: 4) {
                DashIcon.Common.iconDashCurrency.image
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 10, height: 10)
                Text("Transparent address")
                    .dashFont(.caption2)
            }
            .foregroundStyle(Color.dash.blueText)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Color.dash.blueAlpha10)
            .clipShape(Capsule())
        }
        try assertComponentSnapshots(of: view, named: "label-accessory")
    }
}
#endif
