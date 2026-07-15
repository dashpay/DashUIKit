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

/// A text style that bundles a `Font.dash.*` token with its documented design line
/// height, so both are applied together via `.dashFont(_:)`.
///
/// `Font` alone cannot carry a line height (leading is applied by view modifiers, not
/// the font), so this pairs the font metrics with the spec line height.
@available(iOS 14, macOS 10.15, *)
public struct DashTextStyle: Sendable {
    public let size: CGFloat
    public let weight: Font.Weight
    public let lineHeight: CGFloat

    public init(size: CGFloat, weight: Font.Weight, lineHeight: CGFloat) {
        self.size = size
        self.weight = weight
        self.lineHeight = lineHeight
    }

    /// The plain `Font` for this style (no line height applied).
    public var font: Font { .system(size: size, weight: weight) }
}

// MARK: - Tokens (mirror `DashFonts`, with the documented line heights)

@available(iOS 14, macOS 10.15, *)
public extension DashTextStyle {
    static let largeTitle = DashTextStyle(size: 34, weight: .bold, lineHeight: 41)
    static let title1 = DashTextStyle(size: 28, weight: .bold, lineHeight: 34)
    static let title2 = DashTextStyle(size: 22, weight: .bold, lineHeight: 28)
    static let title3 = DashTextStyle(size: 20, weight: .bold, lineHeight: 25)
    static let title3Medium = DashTextStyle(size: 20, weight: .medium, lineHeight: 25)
    static let headline = DashTextStyle(size: 17, weight: .bold, lineHeight: 22)
    static let body = DashTextStyle(size: 17, weight: .regular, lineHeight: 22)
    static let callout = DashTextStyle(size: 16, weight: .regular, lineHeight: 21)
    static let calloutMedium = DashTextStyle(size: 16, weight: .semibold, lineHeight: 21)
    static let subhead = DashTextStyle(size: 15, weight: .regular, lineHeight: 20)
    static let subheadMedium = DashTextStyle(size: 15, weight: .medium, lineHeight: 20)
    static let footnote = DashTextStyle(size: 13, weight: .regular, lineHeight: 18)
    static let footnoteMedium = DashTextStyle(size: 13, weight: .medium, lineHeight: 18)
    static let caption1 = DashTextStyle(size: 12, weight: .regular, lineHeight: 16)
    static let caption1Medium = DashTextStyle(size: 12, weight: .medium, lineHeight: 16)
    static let caption2 = DashTextStyle(size: 11, weight: .regular, lineHeight: 13)
}

// MARK: - Convenience accessor (`Font.dash.style.footnote`)

@available(iOS 14, macOS 10.15, *)
public extension Font {
    /// Namespace for Dash text *styles* (font + line height), e.g. `Font.dashStyle.footnote`.
    static var dashStyle: DashTextStyle.Type { DashTextStyle.self }
}

// MARK: - View modifier

@available(iOS 14, macOS 10.15, *)
public extension View {
    /// Applies a Dash text style: sets the font **and** its documented line height in
    /// one call.
    ///
    /// ```swift
    /// Text(helpText).dashFont(.footnote)   // .system(size: 13) + line height 18
    /// ```
    func dashFont(_ style: DashTextStyle) -> some View {
        self
            .font(style.font)
            .dashLineHeight(size: style.size, lineHeight: style.lineHeight)
    }
}

#if DEBUG

@available(iOS 17, macOS 14, *)
#Preview("dashFont") {
    let sample = "Back up your wallet to keep your funds safe and recover it on a new device."

    return VStack(alignment: .leading, spacing: 24) {
        Text(sample)
            .font(Font.dash.footnote)            // plain font, natural line height
            .foregroundColor(Color.dash.primaryText)
            .background(Color.dash.blueAlpha10)

        Text(sample)
            .dashFont(.footnote)                 // font + line height 18, automatic
            .foregroundColor(Color.dash.primaryText)
            .background(Color.dash.blueAlpha10)
    }
    .padding()
}

#endif
