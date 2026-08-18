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

// MARK: - InfoRoundIcon

/// A filled disc carrying a white "i" — the affordance for "there is more to
/// say about this".
///
/// Drawn rather than shipped as an asset, for the same reason `XmarkIcon` is:
/// it stays crisp at any size, and the disc takes the `Blue` token instead of
/// baking `#008DE4` into a PDF that would then miss a palette change.
@available(iOS 14, macOS 11, *)
public struct InfoRoundIcon: View {
    public var size: CGFloat = 19
    public var color: Color = Color.dash.blue
    public var glyphColor: Color = Color.white

    /// A public struct gets no public memberwise initializer, so this one is
    /// written out to keep the call site available to app code.
    public init(
        size: CGFloat = 19,
        color: Color = Color.dash.blue,
        glyphColor: Color = Color.white
    ) {
        self.size = size
        self.color = color
        self.glyphColor = glyphColor
    }

    public var body: some View {
        ZStack {
            Circle()
                .fill(color)
            InfoGlyphShape()
                .stroke(
                    glyphColor,
                    style: StrokeStyle(
                        lineWidth: size * Self.strokeRatio,
                        lineCap: .round,
                        lineJoin: .round))
        }
        .frame(width: size, height: size)
    }

    /// 1.6 of the 19-unit source viewBox.
    private static let strokeRatio: CGFloat = 1.6 / 19
}

// MARK: - InfoGlyphShape

/// The "i": a stem below the middle and a dot above it. Both are normalized
/// from the 19-unit source viewBox so the glyph keeps its proportions at any
/// size.
///
/// The dot is a 0.01-long segment rather than a circle — with a round cap that
/// renders as a dot of exactly the stem's weight, which is how the source
/// draws it and what keeps the two visually matched at every size.
@available(iOS 14, macOS 11, *)
private struct InfoGlyphShape: Shape {
    private let centerXRatio: CGFloat = 9.2998 / 19
    private let stemTopRatio: CGFloat = 9.30005 / 19
    private let stemBottomRatio: CGFloat = 12.6056 / 19
    private let dotTopRatio: CGFloat = 5.99451 / 19
    private let dotBottomRatio: CGFloat = 6.00451 / 19

    func path(in rect: CGRect) -> Path {
        let x = rect.minX + rect.width * centerXRatio

        var path = Path()
        path.move(to: CGPoint(x: x, y: rect.minY + rect.height * stemTopRatio))
        path.addLine(to: CGPoint(x: x, y: rect.minY + rect.height * stemBottomRatio))
        path.move(to: CGPoint(x: x, y: rect.minY + rect.height * dotTopRatio))
        path.addLine(to: CGPoint(x: x, y: rect.minY + rect.height * dotBottomRatio))
        return path
    }
}

#if DEBUG

@available(iOS 17, macOS 14, *)
#Preview("Sizes") {
    HStack(alignment: .center, spacing: 12) {
        InfoRoundIcon(size: 14)
        InfoRoundIcon()
        InfoRoundIcon(size: 28)
        InfoRoundIcon(size: 44)
    }
    .padding()
}

@available(iOS 17, macOS 14, *)
#Preview("Recoloured") {
    HStack(spacing: 12) {
        InfoRoundIcon(size: 32, color: Color.dash.gray300)
        InfoRoundIcon(size: 32, color: Color.dash.orange)
    }
    .padding()
    .background(Color.dash.primaryBackground)
}

#endif
