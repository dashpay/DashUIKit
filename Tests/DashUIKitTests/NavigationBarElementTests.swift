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


import XCTest
@testable import DashUIKit

final class NavigationBarElementTests: XCTestCase {

    /// Hosts may still build an element from its raw value, so the raw value
    /// must stay the name of the imageset it draws.
    func testRawValueNamesTheDrawnImageset() {
        for element in NavigationBarElement.allCases {
            XCTAssertEqual(element.rawValue, element.asset.assetName, "\(element)")
        }
    }

    /// Host UI tests look the buttons up by these identifiers.
    func testAccessibilityIdentifiersAreTheDocumentedOnes() {
        XCTAssertEqual(NavigationBarElement.back.accessibilityIdentifier, "navigationbar-back")
        XCTAssertEqual(NavigationBarElement.close.accessibilityIdentifier, "navigationbar-close")
        XCTAssertEqual(NavigationBarElement.plus.accessibilityIdentifier, "navigationbar-plus")
        XCTAssertEqual(NavigationBarElement.info.accessibilityIdentifier, "navigationbar-info")
    }
}
