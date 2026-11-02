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
final class CheckmarkIconSnapshotTests: XCTestCase {

    /// The default size and colour, white on a disc with a heavier line, and
    /// large in another colour.
    func testVariants() throws {
        let view = HStack(spacing: 24) {
            CheckmarkIcon()
            CheckmarkIcon(size: 24, color: Color.dash.white, lineWidth: 3)
                .padding(20)
                .background(Circle().fill(Color.dash.blue))
            CheckmarkIcon(size: 40, color: Color.dash.green, lineWidth: 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        try assertComponentSnapshots(of: view, named: "variants")
    }
}
#endif
