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
final class NavigationBarCircleIconSnapshotTests: XCTestCase {

    /// Two bundled glyphs (back, close) drawn at their own size, and two SF
    /// Symbols set in the component's font, each in the bordered 34 pt circle.
    func testIcons() throws {
        let view = HStack(spacing: 10) {
            NavigationBarCircleIcon(DashIcon.NavigationBar.back.source)
            NavigationBarCircleIcon(DashIcon.NavigationBar.close.source)
            NavigationBarCircleIcon(.system("arrow.clockwise"))
            NavigationBarCircleIcon(.system("ellipsis"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        try assertComponentSnapshots(of: view, named: "icons")
    }
}
#endif
