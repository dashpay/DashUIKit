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
final class BottomSheetSnapshotTests: XCTestCase {

    /// The sheet's own chrome (grabber, back button, title, close button) at its
    /// natural height, outside a presentation.
    func testNaturalHeightWithHeader() throws {
        let view = BottomSheet(
            title: "Bottom Sheet",
            showBackButton: .constant(true),
            fillsHeight: false
        ) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Natural height content")
                    .dashFont(.calloutMedium)
                    .foregroundColor(.dash.primaryText)
                Text("The sheet snaps to its content.")
                    .dashFont(.body)
                    .foregroundColor(.dash.secondaryText)
            }
            .padding()
        }
        try assertComponentSnapshots(of: view, named: "header")
    }

    func testCloseButtonDisabled() throws {
        let view = BottomSheet(
            title: "Confirm",
            showBackButton: .constant(false),
            isDismissalEnabled: .constant(false),
            isCloseButtonEnabled: false,
            fillsHeight: false
        ) {
            Text("Dismissal is blocked while this runs.")
                .dashFont(.body)
                .foregroundColor(.dash.secondaryText)
                .padding()
        }
        try assertComponentSnapshots(of: view, named: "close-disabled")
    }

    func testSheetFeatureList() throws {
        let view = VStack(alignment: .leading, spacing: 16) {
            SheetFeature(
                title: "Identity",
                description: "Register a username and be paid by name instead of an address.",
                icon: DashIcon.Features.identity.source
            )
            SheetFeature(
                title: "Platform",
                description: "Store contacts and profile data on Dash Platform.",
                icon: DashIcon.Features.platform.source
            )
            SheetFeature(
                title: "Shield",
                description: "Move funds into shielded balances that stay off the public ledger.",
                icon: DashIcon.Features.shield.source
            )
        }
        try assertComponentSnapshots(of: view, named: "features")
    }
}
#endif
