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

    // MARK: - detents

    func testNothingToSizeToOffersMedium() {
        XCTAssertEqual(SelfSizingSheetHeight.detent(for: 0), .medium)
        XCTAssertEqual(SelfSizingSheetHeight.detents(current: 0, outgoing: []), [.medium])
    }

    func testAtRestOnlyTheCurrentHeightIsOffered() {
        XCTAssertEqual(SelfSizingSheetHeight.detent(for: 320), .height(320))
        XCTAssertEqual(SelfSizingSheetHeight.detents(current: 320, outgoing: []), [.height(320)])
    }

    func testAnAnimatedChangeOffersTheOutgoingHeightToo() {
        XCTAssertEqual(
            SelfSizingSheetHeight.detents(current: 600, outgoing: [320]),
            [.height(600), .height(320)])
    }

    func testEveryHeightLeftInOneTurnIsOffered() {
        XCTAssertEqual(
            SelfSizingSheetHeight.detents(current: 700, outgoing: [320, 600]),
            [.height(700), .height(600), .height(320)])
    }

    func testAnOutgoingHeightEqualToTheCurrentOneAddsNothing() {
        XCTAssertEqual(SelfSizingSheetHeight.detents(current: 320, outgoing: [320]), [.height(320)])
    }

    func testAZeroOutgoingHeightIsNotOffered() {
        XCTAssertEqual(SelfSizingSheetHeight.detents(current: 320, outgoing: [0]), [.height(320)])
    }

    // MARK: - animates

    /// Whether a measurement change from `old` to `new` under a cap of `cap` is animated.
    private func animates(
        from old: CGFloat,
        to new: CGFloat,
        cap: CGFloat = 800,
        reduceMotion: Bool = false
    ) -> Bool {
        SelfSizingSheetHeight.animates(reduceMotion: reduceMotion, from: old, to: new, maxHeight: cap)
    }

    func testFirstMeasurementIsNotAnimated() {
        XCTAssertFalse(animates(from: 0, to: 400))
    }

    func testLaterChangeIsAnimated() {
        XCTAssertTrue(animates(from: 200, to: 400))
        XCTAssertTrue(animates(from: 400, to: 200))
    }

    func testReduceMotionIsNotAnimated() {
        XCTAssertFalse(animates(from: 200, to: 400, reduceMotion: true))
    }

    func testChangeAboveTheCapIsNotAnimated() {
        XCTAssertFalse(animates(from: 900, to: 1000))
    }

    func testGrowingAcrossTheCapIsAnimated() {
        XCTAssertTrue(animates(from: 400, to: 1000))
    }

    func testShrinkingAcrossTheCapIsAnimated() {
        XCTAssertTrue(animates(from: 1000, to: 400))
    }

    func testReachingExactlyTheCapIsAnimated() {
        XCTAssertTrue(animates(from: 400, to: 800))
    }

    func testMovingFromAboveTheCapToExactlyTheCapIsNotAnimated() {
        XCTAssertFalse(animates(from: 1000, to: 800))
    }

    func testBothHeightsAreJudgedAtTheCurrentCap() {
        // 1000 → 1100 stays above a cap of 600: the detent does not move.
        XCTAssertFalse(animates(from: 1000, to: 1100, cap: 600))
        // Under a cap of 1200 the same change moves the detent.
        XCTAssertTrue(animates(from: 1000, to: 1100, cap: 1200))
    }

    // MARK: - overloads

    /// Checked at compile time: a call without `animatesHeightChanges` keeps resolving to the
    /// overload without it, and one with it, `false` included, to the overload that takes it,
    /// with no ambiguity between the two.
    @MainActor
    func testCallsResolveWithAndWithoutAnimatesHeightChanges() {
        _ = Text("").selfSizingSheet()
        _ = Text("").selfSizingSheet(
            fallback: 240, maxHeightFraction: 0.9, background: .dash.secondaryBackground, cornerRadius: 24)
        _ = Text("").selfSizingSheet(animatesHeightChanges: true)
        _ = Text("").selfSizingSheet(animatesHeightChanges: false)
        _ = BottomSheet.selfSizing(showBackButton: .constant(false)) { Text("") }
        _ = BottomSheet.selfSizing(showBackButton: .constant(false), cornerRadius: 24) { Text("") }
        _ = BottomSheet.selfSizing(showBackButton: .constant(false), animatesHeightChanges: true) { Text("") }
        _ = BottomSheet.selfSizing(showBackButton: .constant(false), animatesHeightChanges: false) { Text("") }
    }
}
