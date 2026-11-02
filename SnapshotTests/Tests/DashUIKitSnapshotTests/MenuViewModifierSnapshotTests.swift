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
final class MenuViewModifierSnapshotTests: XCTestCase {

    /// The card chrome around a column of rows: the default inner padding and
    /// shadow, then a wider padding and a larger shadow. The shadow is drawn in
    /// the image, so each card keeps room around it.
    func testCard() throws {
        let rows = VStack(spacing: 0) {
            List1View(label: "Amount", value: "1.5 DASH")
            List1View(label: "Network fee", value: "0.0001 DASH")
        }
        let view = VStack(spacing: 32) {
            rows.modifier(MenuViewModifier())
            rows.modifier(MenuViewModifier(shadowRadius: 20, innerPadding: 12))
        }
        .padding(24)
        try assertComponentSnapshots(of: view, named: "card")
    }
}
#endif
