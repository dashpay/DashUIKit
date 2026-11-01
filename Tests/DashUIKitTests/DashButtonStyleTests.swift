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

final class DashButtonStyleTests: XCTestCase {

    /// `.tintedRed` draws its own fill in both states, so the whole button is
    /// hit-testable, not only the title (a `.clear` background is not).
    func testTintedRedHasAFilledBackgroundInBothStates() {
        XCTAssertEqual(DashButtonStyle.tintedRed.backgroundColor(isEnabled: true), .dash.buttonTintedRedBackground)
        XCTAssertEqual(DashButtonStyle.tintedRed.backgroundColor(isEnabled: false), .dash.buttonTintedRedBackgroundDisabled)
        XCTAssertEqual(DashButtonStyle.tintedRed.foregroundColor(isEnabled: true), .dash.buttonTintedRedContent)
        XCTAssertEqual(DashButtonStyle.tintedRed.foregroundColor(isEnabled: false), .dash.buttonTintedRedContentDisabled)
    }

    /// Each tinted-red colorset resolves in light and dark, with a non-zero alpha.
    func testTintedRedColorsetsResolveInLightAndDark() {
        let expected: [(name: String, rgba: (UInt8, UInt8, UInt8, CGFloat))] = [
            ("ButtonTintedRedBackground", (0xEA, 0x39, 0x43, 0.05)),
            ("ButtonTintedRedBackgroundDisabled", (0x0A, 0x0B, 0x0D, 0.05)),
            ("ButtonTintedRedContent", (0xEA, 0x39, 0x43, 1.0)),
            ("ButtonTintedRedContentDisabled", (0x0A, 0x0B, 0x0D, 0.4)),
        ]
        for style in [UIUserInterfaceStyle.light, .dark] {
            let traits = UITraitCollection(userInterfaceStyle: style)
            for (name, rgba) in expected {
                guard let color = UIColor(named: name, in: .dashUIKit, compatibleWith: traits) else {
                    XCTFail("\(name) is missing from the package bundle")
                    continue
                }
                var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
                XCTAssertTrue(color.getRed(&r, green: &g, blue: &b, alpha: &a), name)
                XCTAssertEqual(r * 255, CGFloat(rgba.0), accuracy: 0.5, "\(name) red, \(style.rawValue)")
                XCTAssertEqual(g * 255, CGFloat(rgba.1), accuracy: 0.5, "\(name) green, \(style.rawValue)")
                XCTAssertEqual(b * 255, CGFloat(rgba.2), accuracy: 0.5, "\(name) blue, \(style.rawValue)")
                XCTAssertEqual(a, rgba.3, accuracy: 0.001, "\(name) alpha, \(style.rawValue)")
                XCTAssertGreaterThan(a, 0, "\(name) must not be clear")
            }
        }
    }
}
#endif
