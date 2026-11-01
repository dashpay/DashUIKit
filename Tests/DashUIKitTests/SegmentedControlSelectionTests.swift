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

    /// Three 100 pt segments, option 0 on the left.
    private let leftToRight = [
        CGRect(x: 0, y: 0, width: 100, height: 32),
        CGRect(x: 100, y: 0, width: 100, height: 32),
        CGRect(x: 200, y: 0, width: 100, height: 32),
    ]

    /// The same row mirrored: option 0 on the right, as an `HStack` lays it out
    /// right to left.
    private let rightToLeft = [
        CGRect(x: 200, y: 0, width: 100, height: 32),
        CGRect(x: 100, y: 0, width: 100, height: 32),
        CGRect(x: 0, y: 0, width: 100, height: 32),
    ]

    func testTouchSelectsTheSegmentUnderIt() {
        XCTAssertEqual(SegmentedControlSelection.segmentIndex(at: 10, in: leftToRight), 0)
        XCTAssertEqual(SegmentedControlSelection.segmentIndex(at: 100, in: leftToRight), 1)
        XCTAssertEqual(SegmentedControlSelection.segmentIndex(at: 299, in: leftToRight), 2)
    }

    func testTouchFollowsAMirroredRow() {
        XCTAssertEqual(SegmentedControlSelection.segmentIndex(at: 10, in: rightToLeft), 2)
        XCTAssertEqual(SegmentedControlSelection.segmentIndex(at: 150, in: rightToLeft), 1)
        XCTAssertEqual(SegmentedControlSelection.segmentIndex(at: 299, in: rightToLeft), 0)
    }

    /// A drag that leaves the track keeps the segment at the end it left by.
    func testTouchPastEitherEndSelectsTheEndSegment() {
        XCTAssertEqual(SegmentedControlSelection.segmentIndex(at: -40, in: leftToRight), 0)
        XCTAssertEqual(SegmentedControlSelection.segmentIndex(at: 340, in: leftToRight), 2)
        XCTAssertEqual(SegmentedControlSelection.segmentIndex(at: -40, in: rightToLeft), 2)
        XCTAssertEqual(SegmentedControlSelection.segmentIndex(at: 340, in: rightToLeft), 0)
    }

    func testNoSegmentsSelectNothing() {
        XCTAssertNil(SegmentedControlSelection.segmentIndex(at: 10, in: []))
    }
}
