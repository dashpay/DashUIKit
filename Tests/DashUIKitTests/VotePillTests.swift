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

@MainActor
final class VotePillTests: XCTestCase {

    func testDisplayCountClampsAndCaps() {
        XCTAssertEqual(VotePill.displayCount(-3, locale: en), "0")
        XCTAssertEqual(VotePill.displayCount(0, locale: en), "0")
        XCTAssertEqual(VotePill.displayCount(999, locale: en), "999")
        XCTAssertEqual(VotePill.displayCount(1_000, locale: en), "\u{2066}999+\u{2069}")
    }

    func testDisplayCountUsesTheGivenLocaleDigits() {
        XCTAssertEqual(VotePill.displayCount(12, locale: Locale(identifier: "ar_EG")), "١٢")
    }

    /// VoiceOver reads the exact count, never the capped or negative drawing.
    func testValueIsTheExactCount() {
        XCTAssertEqual(pill(.approve, count: 12_345).accessibilityValue(locale: en), "12,345")
        XCTAssertEqual(pill(.block, count: -1).accessibilityValue(locale: en), "0")
    }

    func testBusyDefaultValueSaysSendingOrLoading() {
        XCTAssertEqual(pill(.approve, count: 3, status: .busy).accessibilityValue(locale: en), "3, Sending")
        XCTAssertEqual(pill(.expand(isExpanded: false), status: .busy).accessibilityValue(locale: en), "Loading")
    }

    /// A host value is read as given, busy or not: no English word is appended
    /// to a translated value.
    func testHostValueAndLabelWin() {
        let custom = VotePill(
            kind: .block, count: 3, status: .busy,
            accessibilityLabel: "Block johndoe", accessibilityValue: "3 votes", action: {})
        XCTAssertEqual(custom.resolvedAccessibilityLabel, "Block johndoe")
        XCTAssertEqual(custom.accessibilityValue(locale: en), "3 votes")
    }

    func testExpandHasNoSelectedLook() {
        XCTAssertTrue(pill(.approve, isSelected: true).showsSelected)
        XCTAssertTrue(pill(.block, isSelected: true, status: .disabled).showsSelected)
        XCTAssertFalse(pill(.expand(isExpanded: true), isSelected: true).showsSelected)
    }

    private let en = Locale(identifier: "en_US")

    private func pill(
        _ kind: VotePill.Kind, count: Int = 0, isSelected: Bool = false, status: VotePill.Status = .enabled
    ) -> VotePill {
        VotePill(kind: kind, count: count, isSelected: isSelected, status: status, action: {})
    }
}
