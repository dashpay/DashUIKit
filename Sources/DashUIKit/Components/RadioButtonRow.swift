//
//  Created by Andrei Ashikhmin
//  Copyright © 2025 Dash Core Group. All rights reserved.
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

/// A tappable row with a title, an optional subtitle, trailing text and leading icon, and a
/// radio or checkbox indicator.
///
/// Inside `.disabled(true)` the row takes the system's disabled look and ignores taps: for an
/// option the host shows but cannot offer yet. The indicator still shows `isSelected`, so a
/// disabled option is normally passed `isSelected: false`.
///
/// VoiceOver reads the row's texts and its `isSelected` trait, not the indicator image.
public struct RadioButtonRow: View {

    public enum Style {
        case radio
        case checkbox
    }

    private let title: String
    private let subtitle: String?
    private let trailingText: String?
    private let icon: DashIconSource?
    private let isSelected: Bool
    private let style: Style
    private let highlightsSelectedTitle: Bool
    private let action: () -> Void

    public init(
        title: String,
        subtitle: String? = nil,
        trailingText: String? = nil,
        icon: DashIconSource? = nil,
        isSelected: Bool,
        style: Style = .radio,
        action: @escaping () -> Void
    ) {
        self.init(
            title: title,
            subtitle: subtitle,
            trailingText: trailingText,
            icon: icon,
            isSelected: isSelected,
            style: style,
            highlightsSelectedTitle: false,
            action: action
        )
    }

    /// `highlightsSelectedTitle`: a selected `.radio` row draws its title in
    /// `Color.dash.blue`, as in a list of options where the chosen one stands out.
    /// A checkbox title keeps its colour.
    public init(
        title: String,
        subtitle: String? = nil,
        trailingText: String? = nil,
        icon: DashIconSource? = nil,
        isSelected: Bool,
        style: Style = .radio,
        highlightsSelectedTitle: Bool,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.trailingText = trailingText
        self.icon = icon
        self.isSelected = isSelected
        self.style = style
        self.highlightsSelectedTitle = highlightsSelectedTitle
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                if let icon = icon {
                    Image(dash: icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                }

                VStack(alignment: .leading, spacing: 0) {
                    Text(title)
                        .dashFont(.subheadMedium)
                        .foregroundStyle(titleColor)

                    if let subtitle = subtitle {
                        Text(subtitle)
                            .dashFont(.caption1)
                            .foregroundStyle(Color.dash.secondaryText)
                    }
                }

                Spacer()

                if let trailingText = trailingText {
                    Text(trailingText)
                        .dashFont(.subheadMedium)
                        .foregroundStyle(Color.dash.primaryText)
                }

                indicator
                    // The trait below carries the state; the image would read its asset name.
                    .accessibilityHidden(true)
            }
            .padding(.horizontal, 16)
            .frame(minHeight: subtitle != nil ? 60 : 54)
            // After the frame, so the whole row height takes the tap.
            .contentShape(Rectangle())
        }
        // The system plain style also gives a disabled row its faded look.
        .buttonStyle(PlainButtonStyle())
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var titleColor: Color {
        if highlightsSelectedTitle && isSelected && style == .radio { return Color.dash.blue }
        return Color.dash.primaryText
    }

    @ViewBuilder
    private var indicator: some View {
        switch style {
        case .radio:
            Circle()
                .stroke(isSelected ? Color.dash.blue : Color.dash.gray300.opacity(0.5), lineWidth: isSelected ? 6 : 2)
                .frame(width: isSelected ? 21 : 24, height: isSelected ? 21 : 24)
                .padding(.trailing, isSelected ? 2 : 0)
        case .checkbox:
            (isSelected ? DashIcon.Checkbox.checkmarkChecked : .checkmarkUnchecked).image
                .resizable()
                .frame(width: 24, height: 24)
        }
    }
}

#if DEBUG

#Preview("Styles and content", traits: .sizeThatFitsLayout) {
    VStack(spacing: 0) {
        RadioButtonRow(title: "Radio selected", isSelected: true) {}
        RadioButtonRow(title: "Radio unselected", isSelected: false) {}
        RadioButtonRow(title: "Checkbox selected", isSelected: true, style: .checkbox) {}
        RadioButtonRow(title: "Checkbox unselected", isSelected: false, style: .checkbox) {}
        RadioButtonRow(
            title: "With subtitle and trailing",
            subtitle: "Secondary text",
            trailingText: "-10%",
            isSelected: true
        ) {}
        RadioButtonRow(
            title: "With icon",
            icon: .system("star.fill"),
            isSelected: false
        ) {}
    }
}

#Preview("Long title", traits: .sizeThatFitsLayout) {
    VStack(spacing: 0) {
        RadioButtonRow(
            title: "A long option title that has to wrap onto a second line on a narrow phone",
            isSelected: true,
            highlightsSelectedTitle: true
        ) {}
        RadioButtonRow(
            title: "A long checkbox title that has to wrap onto a second line on a narrow phone",
            isSelected: true,
            style: .checkbox
        ) {}
    }
    .frame(width: 320)
}

private struct HighlightedAndDisabledRows: View {
    var body: some View {
        VStack(spacing: 0) {
            RadioButtonRow(title: "Radio selected, highlighted", isSelected: true, highlightsSelectedTitle: true) {}
            RadioButtonRow(title: "Radio unselected, highlighted", isSelected: false, highlightsSelectedTitle: true) {}
            RadioButtonRow(title: "Radio disabled", isSelected: false) {}
                .disabled(true)
            RadioButtonRow(title: "Checkbox disabled", subtitle: "Secondary text", isSelected: false, style: .checkbox) {}
                .disabled(true)
        }
        .background(Color.dash.primaryBackground)
    }
}

#Preview("Highlighted and disabled", traits: .sizeThatFitsLayout) {
    HighlightedAndDisabledRows()
}

#Preview("Highlighted and disabled, dark", traits: .sizeThatFitsLayout) {
    HighlightedAndDisabledRows()
        .preferredColorScheme(.dark)
}

#endif
