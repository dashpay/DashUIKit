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

// MARK: - ChevronIcon

/// A code-drawn chevron, in any of the four directions.
///
/// Mirrors the source SVG (7×12 viewBox, the polyline 0.8,10.8 → 5.8,5.8 →
/// 0.8,0.8, 1.6 stroke, round caps/joins) — that is the `.right` chevron, and
/// the other three are the same glyph rotated, so all four keep one geometry
/// and one line weight.
///
/// `size` sets the LONG side; the short one follows the source aspect ratio, so
/// a chevron never squashes into something the design did not draw. A `.up` /
/// `.down` chevron is therefore wider than it is tall, which is what rotating
/// the drawn one gives you.
///
/// The default colour is `Color.dash.gray300Alpha90` — the palette entry for
/// the `#B0B6BC` at 90% the SVG strokes with.
@available(iOS 14, macOS 11, *)
public struct ChevronIcon: View {

    /// Where the chevron points.
    public enum Direction {
        case right
        case left
        case up
        case down

        /// Rotation applied to the drawn `.right` chevron.
        var angle: Angle {
            switch self {
            case .right: return .degrees(0)
            case .down: return .degrees(90)
            case .left: return .degrees(180)
            case .up: return .degrees(270)
            }
        }

        /// True when the rotation exchanges the glyph's width and height.
        var isVertical: Bool {
            switch self {
            case .up, .down: return true
            case .left, .right: return false
            }
        }
    }

    public var direction: Direction = .right
    /// The chevron's long side — its height when pointing left/right, its
    /// width when pointing up/down.
    public var size: CGFloat = 12
    public var color: Color = Color.dash.gray300Alpha90
    public var lineWidth: CGFloat = 1.6

    /// A public struct gets no public memberwise initializer, so this one is
    /// written out to keep the call site unchanged for module-internal users
    /// and available to app code.
    public init(
        direction: Direction = .right,
        size: CGFloat = 12,
        color: Color = Color.dash.gray300Alpha90,
        lineWidth: CGFloat = 1.6
    ) {
        self.direction = direction
        self.size = size
        self.color = color
        self.lineWidth = lineWidth
    }

    public var body: some View {
        ChevronShape()
            .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
            // Drawn at the `.right` orientation, then rotated. The outer frame
            // swaps the axes for the vertical directions so the rotated glyph
            // reports the space it actually occupies — a `.down` chevron that
            // still measured 7×12 would leave a gap beside it and clip above.
            .frame(width: size * ChevronShape.aspectRatio, height: size)
            .rotationEffect(direction.angle)
            .frame(
                width: direction.isVertical ? size : size * ChevronShape.aspectRatio,
                height: direction.isVertical ? size * ChevronShape.aspectRatio : size)
    }
}

// MARK: - ChevronShape

/// The chevron polyline, normalized from the 7×12 source viewBox so it keeps
/// its proportions at any size. Points right; `ChevronIcon` rotates it.
@available(iOS 14, macOS 11, *)
private struct ChevronShape: Shape {
    private static let viewBox = CGSize(width: 7, height: 12)

    /// Width per unit of height — `ChevronIcon` sizes by the long side, which
    /// for the drawn orientation is the height.
    static let aspectRatio: CGFloat = viewBox.width / viewBox.height

    /// Top, point and bottom of the chevron, in source-viewBox units.
    private static let points = [
        CGPoint(x: 0.8, y: 0.8),
        CGPoint(x: 5.8, y: 5.8),
        CGPoint(x: 0.8, y: 10.8),
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

@available(iOS 17, macOS 14, *)
#Preview("Four directions") {
    HStack(spacing: 32) {
        ChevronIcon(direction: .left)
        ChevronIcon(direction: .right)
        ChevronIcon(direction: .up)
        ChevronIcon(direction: .down)
    }
    .padding()
    .background(Color.dash.primaryBackground)
}

/// Each one drawn on its own bounds, so the frame the rotation reports is
/// visible: left/right are tall, up/down are wide.
@available(iOS 17, macOS 14, *)
#Preview("Measured bounds") {
    HStack(spacing: 24) {
        ForEach([ChevronIcon.Direction.left, .right, .up, .down], id: \.angle.degrees) { direction in
            ChevronIcon(direction: direction, size: 40, color: Color.dash.blue, lineWidth: 4)
                .background(Color.dash.gray300Alpha20)
        }
    }
    .padding()
    .background(Color.dash.primaryBackground)
}

@available(iOS 17, macOS 14, *)
#Preview("Dark") {
    HStack(spacing: 32) {
        ChevronIcon(direction: .left)
        ChevronIcon(direction: .right)
        ChevronIcon(direction: .up)
        ChevronIcon(direction: .down)
    }
    .padding()
    .background(Color.dash.primaryBackground)
    .preferredColorScheme(.dark)
}

#endif
