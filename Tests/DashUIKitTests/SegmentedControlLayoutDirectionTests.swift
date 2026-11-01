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

/// Lays out a row the way the control measures its segments, in a window, and
/// checks that a point inside a segment's measured frame hits that segment in
/// both layout directions.
@MainActor
final class SegmentedControlLayoutDirectionTests: XCTestCase {

    private final class Recorder {
        var frames: [Int: CGRect] = [:]
    }

    private struct Row: View {
        let recorder: Recorder

        var body: some View {
            HStack(spacing: 0) {
                ForEach(0..<3, id: \.self) { index in
                    Color.clear
                        .frame(maxWidth: .infinity)
                        .frame(height: 32)
                        .segmentedControlFrame { recorder.frames[index] = $0 }
                }
            }
            .padding(4)
            .coordinateSpace(.named(SegmentedControlSelection.space))
        }
    }

    private var window: UIWindow?

    override func tearDown() async throws {
        window?.isHidden = true
        window = nil
        try await super.tearDown()
    }

    private func measure(_ direction: LayoutDirection) async throws -> [CGRect] {
        let recorder = Recorder()
        let controller = UIHostingController(
            rootView: Row(recorder: recorder).environment(\.layoutDirection, direction))
        controller.safeAreaRegions = []
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 308, height: 100))
        window.rootViewController = controller
        window.makeKeyAndVisible()
        self.window = window
        for _ in 0..<100 where recorder.frames.count < 3 {
            try await Task.sleep(for: .milliseconds(50))
        }
        window.isHidden = true
        return (0..<3).compactMap { recorder.frames[$0] }
    }

    func testFirstOptionIsHitWhereItIsDrawn() async throws {
        for direction in [LayoutDirection.leftToRight, .rightToLeft] {
            let frames = try await measure(direction)
            XCTAssertEqual(frames.count, 3, "\(direction)")
            guard frames.count == 3 else { continue }

            // The first option is drawn at the leading edge.
            if direction == .rightToLeft {
                XCTAssertGreaterThan(frames[0].minX, frames[2].minX)
            } else {
                XCTAssertLessThan(frames[0].minX, frames[2].minX)
            }
            for index in 0..<3 {
                XCTAssertEqual(
                    SegmentedControlSelection.segmentIndex(at: frames[index].midX, in: frames), index,
                    "\(direction) segment \(index)")
            }
        }
    }
}
#endif
