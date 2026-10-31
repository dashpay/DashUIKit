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

// MARK: - ScrollViewWithOnScrollChanged

/// A drop-in `ScrollView` that reports where its content's origin sits as the user scrolls —
/// useful for collapsing headers, scroll-driven shadows, parallax, etc.
///
/// The reported point is the content origin relative to the visible start edges, inside every
/// content inset (safe area, `safeAreaPadding`, `contentMargins`): `.zero` at rest, negative once
/// the content has scrolled towards its end, and positive while it is pulled past the start.
/// It is read from `onScrollGeometryChange`, and sent again when the content reappears.
public struct ScrollViewWithOnScrollChanged<Content: View>: View {

    private let axes: Axis.Set
    private let showsIndicators: Bool
    private let content: Content
    private let report: (CGPoint) -> Void

    @Environment(\.layoutDirection) private var layoutDirection
    /// Remembers the last origin so it can be sent again when the content
    /// reappears. A reference, so scroll frames do not write view state.
    @State private var replay = Replay()

    public init(
        _ axes: Axis.Set = .vertical,
        showsIndicators: Bool = false,
        @ViewBuilder content: () -> Content,
        onScrollChanged: @escaping (_ origin: CGPoint) -> Void
    ) {
        self.axes = axes
        self.showsIndicators = showsIndicators
        self.content = content()
        self.report = onScrollChanged
    }

    public var body: some View {
        ScrollView(axes, showsIndicators: showsIndicators) {
            // Keeps the content one default stack spacing from the start edge,
            // where hosts lay out against it. Deleting it moves their content
            // towards the start by that spacing.
            Color.clear.frame(width: 0, height: 0)
            content
        }
        .onScrollGeometryChange(for: CGPoint.self) { geometry in
            scrollContentOrigin(of: geometry, layoutDirection: layoutDirection)
        } action: { _, origin in
            replay.last = origin
            report(origin)
        }
        .onAppear {
            // The first appearance is covered by the geometry change itself.
            if replay.hasAppeared, let last = replay.last { report(last) }
            replay.hasAppeared = true
        }
    }

    private final class Replay {
        var last: CGPoint?
        var hasAppeared = false
    }
}

/// Where the content's origin sits relative to the visible start edges, inside the insets.
///
/// Right-to-left layouts differ in how `ScrollGeometry` reports the horizontal axis: at rest
/// `contentOffset.x` equals the trailing inset, the leading inset does not move it, and the
/// offset grows as the content scrolls towards its end.
func scrollContentOrigin(of geometry: ScrollGeometry, layoutDirection: LayoutDirection) -> CGPoint {
    // Written as subtractions from zero, so the rest position is +0, never -0.
    let x = layoutDirection == .rightToLeft
        ? geometry.contentInsets.trailing - geometry.contentOffset.x
        : 0 - geometry.contentOffset.x - geometry.contentInsets.leading
    return CGPoint(x: x, y: 0 - geometry.contentOffset.y - geometry.contentInsets.top)
}

// MARK: - Preview

#if DEBUG

struct ScrollViewWithOnScrollChanged_Previews: PreviewProvider {

    private struct Demo: View {
        @State private var offsetY: CGFloat = 0

        var body: some View {
            ScrollViewWithOnScrollChanged {
                VStack(spacing: 16) {
                    ForEach(0..<24) { index in
                        Color.red.opacity(0.4)
                            .frame(maxWidth: .infinity)
                            .frame(height: 160)
                            .cornerRadius(10)
                            .overlay(Text("Row \(index)"))
                    }
                }
                .padding()
            } onScrollChanged: { origin in
                offsetY = origin.y
            }
            .overlay(alignment: .top) { Text(String(format: "offset.y: %.1f", offsetY)).padding() }
        }
    }

    private struct HorizontalDemo: View {
        @State private var offsetX: CGFloat = 0

        var body: some View {
            ScrollViewWithOnScrollChanged(.horizontal) {
                HStack(spacing: 16) {
                    ForEach(0..<24) { index in
                        Color.blue.opacity(0.4)
                            .frame(width: 120, height: 120)
                            .overlay { Text("Col \(index)") }
                    }
                }
                .padding()
            } onScrollChanged: { origin in
                offsetX = origin.x
            }
            .overlay(alignment: .bottom) { Text(String(format: "offset.x: %.1f", offsetX)).padding() }
        }
    }

    static var previews: some View {
        Demo()
            .previewDisplayName("Vertical")
        Demo()
            .contentMargins(.top, 40)
            .previewDisplayName("Vertical, top margin")
        HorizontalDemo()
            .previewDisplayName("Horizontal")
        HorizontalDemo()
            .environment(\.layoutDirection, .rightToLeft)
            .previewDisplayName("Horizontal, right-to-left")
    }
}

#endif
