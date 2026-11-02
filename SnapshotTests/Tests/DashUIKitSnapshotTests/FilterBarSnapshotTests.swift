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
final class FilterBarSnapshotTests: XCTestCase {

    func testPlain() throws {
        try assertComponentSnapshots(of: FilterBar(value: "New to old") {}, named: "plain")
    }

    /// A value wider than the caption column is cut at the tail on one line.
    func testLongValue() throws {
        let bar = FilterBar(value: "I have not voted · Only duplicates · Only requests with links") {}
        try assertComponentSnapshots(of: bar, named: "long-value")
    }

    /// A toast in place of the caption. The blur behind the toast is not in the
    /// image (see `ToastSnapshotTests`).
    func testReplacement() throws {
        let bar = FilterBar(
            value: "New to old",
            replacement: Toast(style: .success, message: "Voted johndoe username")
        ) {}
        try assertComponentSnapshots(of: bar, named: "replacement")
    }
}
#endif
