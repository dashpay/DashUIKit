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
final class List1ViewSnapshotTests: XCTestCase {

    /// The default texts, a typical row, and a value long enough to wrap, which
    /// stays right-aligned against the label.
    func testRows() throws {
        let view = VStack(spacing: 0) {
            List1View()
            List1View(label: "Network fee", value: "0.0001 DASH")
            List1View(
                label: "Address",
                value: "XqK7pMn2rV9wL4tYeB8dN3cF6hJsA1uZ XqK7pMn2rV9wL4tYeB8dN3cF6hJsA1uZ"
            )
        }
        try assertComponentSnapshots(of: view, named: "rows")
    }
}
#endif
