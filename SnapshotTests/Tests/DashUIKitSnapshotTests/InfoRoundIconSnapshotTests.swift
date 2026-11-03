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
final class InfoRoundIconSnapshotTests: XCTestCase {

    /// Four sizes in the default colours, then recoloured disc and glyph.
    func testSizesAndColours() throws {
        let view = HStack(alignment: .center, spacing: 12) {
            InfoRoundIcon(size: 14)
            InfoRoundIcon()
            InfoRoundIcon(size: 28)
            InfoRoundIcon(size: 44)
            InfoRoundIcon(size: 32, color: Color.dash.gray300)
            InfoRoundIcon(size: 32, color: Color.dash.orange, glyphColor: Color.dash.black)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        try assertComponentSnapshots(of: view, named: "sizes-colours")
    }
}
#endif
