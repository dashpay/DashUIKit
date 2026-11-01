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

final class SegmentedControlSelectionTests: XCTestCase {

    // MARK: Selected segment

    func testSelectedIndexIsTheMatchingOption() {
        XCTAssertEqual(SegmentedControlSelection.selectedIndex(of: "Week", in: ["Day", "Week", "Month"]), 1)
    }

    /// A selection that is none of the options selects no segment, so no pill
    /// is drawn under an option that is not announced as selected.
    func testSelectionOutsideTheOptionsSelectsNothing() {
        XCTAssertNil(SegmentedControlSelection.selectedIndex(of: "Year", in: ["Day", "Week", "Month"]))
        XCTAssertNil(SegmentedControlSelection.selectedIndex(of: "Day", in: [String]()))
    }

    func testRepeatedOptionSelectsItsFirstCopy() {
        XCTAssertEqual(SegmentedControlSelection.selectedIndex(of: "Day", in: ["Week", "Day", "Day"]), 1)
    }
}
