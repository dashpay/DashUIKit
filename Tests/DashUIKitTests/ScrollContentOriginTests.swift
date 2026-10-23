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

/// Geometry values below are what `onScrollGeometryChange` delivered on an iOS simulator for
/// the named situations; the expected origin is `.zero` at rest, negative towards the content
/// end and positive past the start.
final class ScrollContentOriginTests: XCTestCase {

    private func geometry(offset: CGPoint, insets: EdgeInsets = EdgeInsets()) -> ScrollGeometry {
        ScrollGeometry(
            contentOffset: offset,
            contentSize: CGSize(width: 2400, height: 2400),
            contentInsets: insets,
            containerSize: CGSize(width: 360, height: 600)
        )
    }

    private func origin(_ offset: CGPoint, _ insets: EdgeInsets = EdgeInsets(), _ direction: LayoutDirection = .leftToRight) -> CGPoint {
        scrollContentOrigin(of: geometry(offset: offset, insets: insets), layoutDirection: direction)
    }

    // MARK: - Vertical

    func testTopInsetReadsZeroAtRest() {
        XCTAssertEqual(origin(CGPoint(x: 0, y: -112), EdgeInsets(top: 112, leading: 0, bottom: 0, trailing: 0)).y, 0)
    }

    func testScrollingDownIsNegativeAndPullingPastTheTopIsPositive() {
        let insets = EdgeInsets(top: 112, leading: 0, bottom: 0, trailing: 0)
        XCTAssertEqual(origin(CGPoint(x: 0, y: 8), insets).y, -120)
        XCTAssertEqual(origin(CGPoint(x: 0, y: -152), insets).y, 40)
    }

    // MARK: - Horizontal, left to right

    func testLeadingInsetReadsZeroAtRest() {
        XCTAssertEqual(origin(CGPoint(x: -30, y: 0), EdgeInsets(top: 0, leading: 30, bottom: 0, trailing: 0)).x, 0)
    }

    func testTrailingInsetDoesNotMoveTheRestPosition() {
        let insets = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 40)
        XCTAssertEqual(origin(.zero, insets).x, 0)
        XCTAssertEqual(origin(CGPoint(x: 40, y: 0), insets).x, -40)
        XCTAssertEqual(origin(CGPoint(x: -30, y: 0), insets).x, 30)
    }

    // MARK: - Horizontal, right to left

    func testRightToLeftStartInsetReadsZeroAtRest() {
        let insets = EdgeInsets(top: 0, leading: 40, bottom: 0, trailing: 0)
        XCTAssertEqual(origin(.zero, insets, .rightToLeft).x, 0)
        XCTAssertEqual(origin(CGPoint(x: 40, y: 0), insets, .rightToLeft).x, -40)
        XCTAssertEqual(origin(CGPoint(x: -30, y: 0), insets, .rightToLeft).x, 30)
    }

    func testRightToLeftEndInsetIsSubtractedFromTheOffset() {
        let insets = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 30)
        XCTAssertEqual(origin(CGPoint(x: 30, y: 0), insets, .rightToLeft).x, 0)
        XCTAssertEqual(origin(CGPoint(x: 70, y: 0), insets, .rightToLeft).x, -40)
        XCTAssertEqual(origin(CGPoint(x: -90, y: 0), insets, .rightToLeft).x, 120)
    }

    func testRightToLeftMarginsOnBothSides() {
        let insets = EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
        XCTAssertEqual(origin(CGPoint(x: 20, y: 0), insets, .rightToLeft).x, 0)
        XCTAssertEqual(origin(CGPoint(x: 60, y: 0), insets, .rightToLeft).x, -40)
        XCTAssertEqual(origin(CGPoint(x: -10, y: 0), insets, .rightToLeft).x, 30)
    }
}
