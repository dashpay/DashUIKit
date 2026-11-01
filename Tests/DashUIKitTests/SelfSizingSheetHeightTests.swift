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

import SwiftUI
import XCTest
@testable import DashUIKit

final class SelfSizingSheetHeightTests: XCTestCase {

    // MARK: - resolved

    func testFallbackIsUsedBeforeTheFirstMeasurement() {
        XCTAssertEqual(SelfSizingSheetHeight.resolved(measured: 0, fallback: 240, maxHeight: 800), 240)
    }

    func testMeasurementReplacesTheFallback() {
        XCTAssertEqual(SelfSizingSheetHeight.resolved(measured: 320, fallback: 240, maxHeight: 800), 320)
    }

    func testHeightIsCappedAtTheMaximum() {
        XCTAssertEqual(SelfSizingSheetHeight.resolved(measured: 1200, fallback: 240, maxHeight: 800), 800)
        XCTAssertEqual(
            SelfSizingSheetHeight.resolved(measured: 0, fallback: .greatestFiniteMagnitude, maxHeight: 800),
            800)
    }

    func testNoMeasurementAndNoFallbackResolvesToZero() {
        XCTAssertEqual(SelfSizingSheetHeight.resolved(measured: 0, fallback: 0, maxHeight: 800), 0)
    }

    // MARK: - animation

    /// The animation for a measurement change from `old` (applied at `oldCap`) to `new` at `newCap`.
    private func animation(
        _ requested: Animation?,
        from old: CGFloat,
        to new: CGFloat,
        oldCap: CGFloat = 800,
        newCap: CGFloat = 800
    ) -> Animation? {
        let applied = old > 0
            ? SelfSizingSheetHeight.resolved(measured: old, fallback: 0, maxHeight: oldCap)
            : 0
        let next = SelfSizingSheetHeight.resolved(measured: new, fallback: 0, maxHeight: newCap)
        return SelfSizingSheetHeight.animation(for: requested, from: applied, to: next)
    }

    func testDefaultPathTakesNoAnimation() {
        XCTAssertNil(animation(nil, from: 200, to: 400))
    }

    func testFirstMeasurementIsNotAnimated() {
        XCTAssertNil(animation(.easeInOut, from: 0, to: 400))
    }

    func testLaterChangeTakesTheRequestedAnimation() {
        XCTAssertEqual(animation(.easeInOut, from: 200, to: 400), .easeInOut)
        XCTAssertEqual(animation(.easeInOut, from: 400, to: 200), .easeInOut)
    }

    func testChangeAboveTheCapIsNotAnimated() {
        XCTAssertNil(animation(.easeInOut, from: 900, to: 1000))
    }

    func testGrowingAcrossTheCapIsAnimated() {
        XCTAssertEqual(animation(.easeInOut, from: 400, to: 1000), .easeInOut)
    }

    func testShrinkingAcrossTheCapIsAnimated() {
        XCTAssertEqual(animation(.easeInOut, from: 1000, to: 400), .easeInOut)
    }

    func testReachingExactlyTheCapIsAnimated() {
        XCTAssertEqual(animation(.easeInOut, from: 400, to: 800), .easeInOut)
    }

    func testMovingFromAboveTheCapToExactlyTheCapIsNotAnimated() {
        XCTAssertNil(animation(.easeInOut, from: 1000, to: 800))
    }

    func testEqualCappedHeightsFromBelowAreNotAnimated() {
        XCTAssertNil(SelfSizingSheetHeight.animation(for: .easeInOut, from: 400, to: 400))
    }

    func testChangeIsComparedAgainstTheCapItWasAppliedAt() {
        // Applied at 800 under the old cap; after a rotation the cap is 600, so the detent moves.
        XCTAssertEqual(animation(.easeInOut, from: 1000, to: 1100, oldCap: 800, newCap: 600), .easeInOut)
        // Applied at 600 under the old cap; under the new cap of 1200 the 900 is shown in full.
        XCTAssertEqual(animation(.easeInOut, from: 1000, to: 900, oldCap: 600, newCap: 1200), .easeInOut)
        // Applied at 600 under the cap of 600; after rotation to 900, 600 measured stays at 600.
        XCTAssertNil(animation(.easeInOut, from: 700, to: 600, oldCap: 600, newCap: 900))
    }

    // MARK: - overloads

    /// Checked at compile time: a call without `animation` keeps resolving to the overload
    /// without it, and one with it, `nil` included, to the overload that takes it, with no
    /// ambiguity between the two.
    @MainActor
    func testCallsResolveWithAndWithoutAnimation() {
        _ = Text("").selfSizingSheet()
        _ = Text("").selfSizingSheet(
            fallback: 240, maxHeightFraction: 0.9, background: .dash.secondaryBackground, cornerRadius: 24)
        _ = Text("").selfSizingSheet(animation: .easeInOut)
        _ = Text("").selfSizingSheet(animation: nil)
        _ = BottomSheet.selfSizing(showBackButton: .constant(false)) { Text("") }
        _ = BottomSheet.selfSizing(showBackButton: .constant(false), cornerRadius: 24) { Text("") }
        _ = BottomSheet.selfSizing(showBackButton: .constant(false), animation: .easeInOut) { Text("") }
        _ = BottomSheet.selfSizing(showBackButton: .constant(false), animation: nil) { Text("") }
    }
}
