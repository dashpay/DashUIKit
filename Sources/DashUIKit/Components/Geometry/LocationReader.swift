//
//  Created by Roman Chornyi
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

// MARK: - LocationReader

/// Publishes the center point of whatever view it backs, resolved in `coordinateSpace`.
///
/// The point-sized sibling of ``FrameReader``: it collapses to a zero-sized probe and only
/// emits the midpoint, which is all most scroll/position effects need. Reach for it through
/// ``SwiftUI/View/readingLocation(coordinateSpace:onChange:)``.
@available(iOS 14, macOS 11, *)
struct LocationReader: View {

    private let coordinateSpace: CoordinateSpace
    private let report: (CGPoint) -> Void

    init(coordinateSpace: CoordinateSpace, onChange: @escaping (CGPoint) -> Void) {
        self.coordinateSpace = coordinateSpace
        self.report = onChange
    }

    var body: some View {
        GeometryReader { proxy in
            // Pinned to a 0×0 box, so the frame's midpoint collapses onto the probe's origin.
            let center = proxy.frame(in: coordinateSpace).center

            Color.clear
                .onAppear { report(center) }
                .onChange(of: center, perform: report)
        }
        .frame(width: 0, height: 0, alignment: .center)
    }
}

// MARK: - View sugar

@available(iOS 14, macOS 11, *)
extension View {

    /// Reports this view's center point — in `coordinateSpace` — on appear and on every change.
    /// Installed as a zero-sized, transparent background so it never affects layout.
    func readingLocation(
        coordinateSpace: CoordinateSpace = .global,
        onChange: @escaping (_ location: CGPoint) -> Void
    ) -> some View {
        background(LocationReader(coordinateSpace: coordinateSpace, onChange: onChange))
    }
}

// MARK: - Helpers

@available(iOS 14, macOS 11, *)
private extension CGRect {
    /// Geometric center of the rect.
    var center: CGPoint { CGPoint(x: midX, y: midY) }
}

// MARK: - Preview

#if DEBUG

@available(iOS 14, macOS 11, *)
struct LocationReader_Previews: PreviewProvider {

    private struct Demo: View {
        @State private var headerCenterY: CGFloat = 0

        var body: some View {
            ScrollView(.vertical) {
                VStack(spacing: 16) {
                    Text("Header")
                        .frame(maxWidth: .infinity)
                        .frame(height: 160)
                        .background(Color.green)
                        .cornerRadius(10)
                        .readingLocation(coordinateSpace: .named("demo")) { point in
                            headerCenterY = point.y
                        }

                    ForEach(0..<24) { index in
                        Color.green.opacity(0.4)
                            .frame(maxWidth: .infinity)
                            .frame(height: 160)
                            .cornerRadius(10)
                            .overlay(Text("\(index)"))
                    }
                }
                .padding()
            }
            .coordinateSpace(name: "demo")
            .overlay(Text(String(format: "header midY: %.1f", headerCenterY)).padding(), alignment: .top)
        }
    }

    static var previews: some View {
        Demo()
    }
}

#endif
