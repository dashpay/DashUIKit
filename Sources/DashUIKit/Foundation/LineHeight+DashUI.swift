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
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

@available(iOS 14, macOS 10.15, *)
public extension View {
    /// Applies a design line height to text rendered with a fixed-size system font.
    ///
    /// `Font.system(size:)` renders with the typeface's *natural* line height, which is
    /// smaller than the Dynamic Type / Figma line height documented for each
    /// `Font.dash.*` token (e.g. footnote is 13pt but the spec line height is 18pt).
    /// This modifier adds the missing leading:
    /// - `lineSpacing` opens the gap between wrapped lines, and
    /// - vertical padding gives single lines the same extra height and keeps the text
    ///   vertically centered, matching the design.
    ///
    /// - Parameters:
    ///   - size: the font point size (the same value as the `Font.dash.*` token).
    ///   - lineHeight: the target line height from the design spec.
    func dashLineHeight(size: CGFloat, lineHeight: CGFloat) -> some View {
        let natural = Self.naturalLineHeight(forSize: size)
        let delta = max(lineHeight - natural, 0)
        return self
            .lineSpacing(delta)
            .padding(.vertical, delta / 2)
    }

    /// Natural line height of the system font at `size`. For SF this is independent of
    /// weight, so only the size is needed.
    private static func naturalLineHeight(forSize size: CGFloat) -> CGFloat {
        #if canImport(UIKit)
        return UIFont.systemFont(ofSize: size).lineHeight
        #elseif canImport(AppKit)
        return NSFont.systemFont(ofSize: size).ascender - NSFont.systemFont(ofSize: size).descender
        #else
        return size * 1.2
        #endif
    }
}

#if DEBUG

@available(iOS 17, macOS 14, *)
#Preview("Footnote line height") {
    let sample = "Back up your wallet to keep your funds safe and recover it on a new device."

    return VStack(alignment: .leading, spacing: 24) {
        VStack(alignment: .leading, spacing: 4) {
            Text("Default (.system natural ≈ 15.5pt)")
                .font(Font.dash.caption2)
                .foregroundColor(Color.dash.secondaryText)
            Text(sample)
                .font(Font.dash.footnote)
                .foregroundColor(Color.dash.primaryText)
                .background(Color.dash.blueAlpha10)
        }

        VStack(alignment: .leading, spacing: 4) {
            Text("dashLineHeight(size: 13, lineHeight: 18)")
                .font(Font.dash.caption2)
                .foregroundColor(Color.dash.secondaryText)
            Text(sample)
                .font(Font.dash.footnote)
                .foregroundColor(Color.dash.primaryText)
                .dashLineHeight(size: 13, lineHeight: 18)
                .background(Color.dash.blueAlpha10)
        }
    }
    .padding()
}

#endif
