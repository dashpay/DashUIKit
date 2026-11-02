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
import SwiftUI
import UIKit
import XCTest
@testable import DashUIKit

/// The snapshot helper pins every view to its ideal height, so a bar that
/// stretches in a real container would still look right there. These measure
/// the bar offered a whole screen, as a safe-area inset or a stack offers it.
@MainActor
final class FilterBarLayoutTests: XCTestCase {

    private let screen = CGSize(width: 402, height: 800)

    func testKeepsItsHeightWhenOfferedTheScreen() {
        XCTAssertEqual(height(of: FilterBar(value: "New to old") {}), 54, accuracy: 0.5)
    }

    func testKeepsItsHeightWithAReplacement() {
        let bar = FilterBar(
            value: "New to old",
            replacement: Toast(style: .success, message: "Voted johndoe username")) {}
        XCTAssertEqual(height(of: bar), 54, accuracy: 0.5)
    }

    /// A message far wider than the centre column stays on one line, so the
    /// bar does not grow when it shows.
    func testKeepsItsHeightWithALongReplacement() {
        let bar = FilterBar(
            value: "New to old",
            replacement: Toast(
                style: .success,
                message: "Voted averyveryverylongusername_2026 username on every request")) {}
        XCTAssertEqual(height(of: bar), 54, accuracy: 0.5)
    }

    /// A custom replacement taller than the row is cut, not grown into.
    func testKeepsItsHeightWithATallCustomReplacement() {
        let tall = VStack {
            Text(verbatim: "First line")
            Text(verbatim: "Second line")
            Text(verbatim: "Third line")
        }
        XCTAssertEqual(height(of: FilterBar(value: "New to old", replacement: tall) {}), 54, accuracy: 0.5)
    }

    private func height(of view: some View) -> CGFloat {
        UIHostingController(rootView: view).sizeThatFits(in: screen).height
    }
}

#endif
