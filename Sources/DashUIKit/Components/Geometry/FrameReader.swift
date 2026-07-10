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

// MARK: - FrameReader

/// Publishes the live frame of whatever view it backs, resolved in `coordinateSpace`.
///
/// It paints nothing: a transparent, greedy overlay that forwards the resolved `CGRect`
/// once on first layout and again on every subsequent change. Attach it through
/// ``SwiftUI/View/readingFrame(coordinateSpace:onChange:)`` rather than building it directly.
@available(iOS 14, macOS 11, *)
struct FrameReader: View {

    private let coordinateSpace: CoordinateSpace
    private let report: (CGRect) -> Void

    init(coordinateSpace: CoordinateSpace, onChange: @escaping (CGRect) -> Void) {
        self.coordinateSpace = coordinateSpace
        self.report = onChange
    }

    var body: some View {
        GeometryReader { proxy in
            // Resolve once per layout pass and reuse for both the initial emit and the diff.
            let frame = proxy.frame(in: coordinateSpace)

            Color.clear
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onAppear { report(frame) }
                .onChange(of: frame, perform: report)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - View sugar

@available(iOS 14, macOS 11, *)
public extension View {

    /// Reports this view's frame — in `coordinateSpace` — as it appears and whenever it moves
    /// or resizes. Installed as a transparent background so it never affects layout.
    func readingFrame(
        coordinateSpace: CoordinateSpace = .global,
        onChange: @escaping (_ frame: CGRect) -> Void
    ) -> some View {
        background(FrameReader(coordinateSpace: coordinateSpace, onChange: onChange))
    }
}

// MARK: - Preview

#if DEBUG

@available(iOS 14, macOS 11, *)
struct FrameReader_Previews: PreviewProvider {

    private struct Demo: View {
        @State private var topY: CGFloat = 0

        var body: some View {
            ScrollView(.vertical) {
                VStack(spacing: 16) {
                    ForEach(0..<24) { index in
                        Color.green
                            .frame(maxWidth: .infinity)
                            .frame(height: 160)
                            .cornerRadius(10)
                            .overlay(Text("\(index)"))
                            // Track only the first tile's position within the named space.
                            .readingFrame(coordinateSpace: .named("demo")) { frame in
                                if index == 0 { topY = frame.minY }
                            }
                    }
                }
                .padding()
            }
            .coordinateSpace(name: "demo")
            .overlay(Text(String(format: "minY: %.1f", topY)).padding(), alignment: .top)
        }
    }

    static var previews: some View {
        Demo()
    }
}

#endif
