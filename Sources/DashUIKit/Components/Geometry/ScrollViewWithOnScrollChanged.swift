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

/// A drop-in `ScrollView` that reports its content offset as the user scrolls — useful for
/// collapsing headers, scroll-driven shadows, parallax, etc., without depending on iOS 17's
/// `onScrollGeometryChange`.
///
/// The trick: a zero-sized ``LocationReader`` rides at the very top of the content inside a
/// private named coordinate space. As the content slides, the probe's position within that
/// space is exactly the scroll offset, which is forwarded through `onScrollChanged`.
@available(iOS 14, macOS 11, *)
public struct ScrollViewWithOnScrollChanged<Content: View>: View {

    private let axes: Axis.Set
    private let showsIndicators: Bool
    private let content: Content
    private let report: (CGPoint) -> Void

    /// A per-instance coordinate-space name, so stacked scroll views never read each other's probe.
    @State private var spaceName = UUID().uuidString

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
            offsetProbe
            content
        }
        .coordinateSpace(name: spaceName)
    }

    /// Top-of-content marker whose location within `spaceName` mirrors the scroll offset.
    private var offsetProbe: some View {
        LocationReader(coordinateSpace: .named(spaceName), onChange: report)
    }
}

// MARK: - Preview

#if DEBUG

@available(iOS 14, macOS 11, *)
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
            .overlay(Text(String(format: "offset.y: %.1f", offsetY)).padding(), alignment: .top)
        }
    }

    static var previews: some View {
        Demo()
    }
}

#endif
