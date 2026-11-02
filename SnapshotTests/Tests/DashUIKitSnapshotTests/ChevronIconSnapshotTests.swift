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
import DashUIKit
import SwiftUI
import XCTest

@MainActor
final class ChevronIconSnapshotTests: XCTestCase {

    private static let directions: [ChevronIcon.Direction] = [.left, .right, .up, .down]

    /// The four directions at the default size and colour.
    func testDirections() throws {
        let view = HStack(spacing: 32) {
            ForEach(Self.directions, id: \.self) { direction in
                ChevronIcon(direction: direction)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        try assertComponentSnapshots(of: view, named: "directions")
    }

    /// Large, each on its own bounds, so the frame each direction reports is
    /// visible: left and right are tall, up and down are wide.
    func testMeasuredBounds() throws {
        let view = HStack(spacing: 24) {
            ForEach(Self.directions, id: \.self) { direction in
                ChevronIcon(direction: direction, size: 40, color: Color.dash.blue, lineWidth: 4)
                    .background(Color.dash.gray300Alpha20)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        try assertComponentSnapshots(of: view, named: "bounds")
    }
}
#endif
