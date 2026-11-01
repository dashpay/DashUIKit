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

import CoreGraphics
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

    // MARK: Touch to segment

    private func index(at x: CGFloat, rightToLeft: Bool = false) -> Int? {
        SegmentedControlSelection.segmentIndex(at: x, width: 300, count: 3, rightToLeft: rightToLeft)
    }

    func testTouchSelectsTheSegmentUnderIt() {
        XCTAssertEqual(index(at: 10), 0)
        XCTAssertEqual(index(at: 100), 1)
        XCTAssertEqual(index(at: 299), 2)
    }

    /// Right to left the first option is on the right, and touch coordinates
    /// still run from the left edge.
    func testTouchFollowsAMirroredRow() {
        XCTAssertEqual(index(at: 10, rightToLeft: true), 2)
        XCTAssertEqual(index(at: 150, rightToLeft: true), 1)
        XCTAssertEqual(index(at: 299, rightToLeft: true), 0)
    }

    /// A drag that leaves the track keeps the segment at the end it left by.
    func testTouchPastEitherEndSelectsTheEndSegment() {
        XCTAssertEqual(index(at: -40), 0)
        XCTAssertEqual(index(at: 340), 2)
        XCTAssertEqual(index(at: -40, rightToLeft: true), 2)
        XCTAssertEqual(index(at: 340, rightToLeft: true), 0)
    }

    func testNothingToSelectBeforeLayoutOrWithoutOptions() {
        XCTAssertNil(SegmentedControlSelection.segmentIndex(at: 10, width: 0, count: 3, rightToLeft: false))
        XCTAssertNil(SegmentedControlSelection.segmentIndex(at: 10, width: 300, count: 0, rightToLeft: false))
    }
}
