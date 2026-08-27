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

// MARK: - CheckmarkIcon

/// A code-drawn "✓" (selected) mark. Mirrors the source SVG (15×12 viewBox, the
/// polyline 1,5.85 → 5.48,10.7 → 14,1, round caps/joins). Scales cleanly to any
/// `size`, which sets the WIDTH — the height follows the source aspect ratio, so
/// the tick never squares off into something the design did not draw.
///
/// The default colour is `Color.dash.blue`, which is the `#008DE4` the SVG
/// strokes with; naming the token rather than the hex keeps it following the
/// palette.
public struct CheckmarkIcon: View {
    public var size: CGFloat = 15
    public var color: Color = Color.dash.blue
    public var lineWidth: CGFloat = 2

    /// A public struct gets no public memberwise initializer, so this one is
    /// written out to keep the call site unchanged for module-internal users
    /// and available to app code.
    public init(
        size: CGFloat = 15,
        color: Color = Color.dash.blue,
        lineWidth: CGFloat = 2
    ) {
        self.size = size
        self.color = color
        self.lineWidth = lineWidth
    }

    public var body: some View {
        CheckmarkShape()
            .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
            .frame(width: size, height: size * CheckmarkShape.aspectRatio)
    }
}

// MARK: - CheckmarkShape

/// The tick polyline, normalized from the 15×12 source viewBox so it keeps its
/// proportions at any size.
private struct CheckmarkShape: Shape {
    private static let viewBox = CGSize(width: 15, height: 12)

    /// Height per unit of width — `CheckmarkIcon` sizes by width.
    static let aspectRatio: CGFloat = viewBox.height / viewBox.width

    /// Start, elbow and end of the tick, in source-viewBox units.
    private static let points = [
        CGPoint(x: 1, y: 5.85),
        CGPoint(x: 5.48, y: 10.7),
        CGPoint(x: 14, y: 1),
    ]

    func path(in rect: CGRect) -> Path {
        let scaled = Self.points.map { point in
            CGPoint(
                x: rect.minX + rect.width * point.x / Self.viewBox.width,
                y: rect.minY + rect.height * point.y / Self.viewBox.height)
        }

        var path = Path()
        path.move(to: scaled[0])
        path.addLine(to: scaled[1])
        path.addLine(to: scaled[2])
        return path
    }
}

#if DEBUG

#Preview {
    VStack(spacing: 24) {
        CheckmarkIcon()
        CheckmarkIcon(size: 24, color: .white, lineWidth: 3)
            .padding(20)
            .background(Circle().fill(Color.dash.blue))
        CheckmarkIcon(size: 40, color: Color.dash.green, lineWidth: 4)
    }
    .padding()
}

#endif
