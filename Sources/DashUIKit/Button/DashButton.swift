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

@available(iOS 14, macOS 10.15, *)
public enum DashButtonSize: Sendable {
    case large, medium, small, extraSmall

    var gap: CGFloat {
        switch self {
        case .large: return 10
        case .medium: return 8
        case .small: return 6
        case .extraSmall: return 6
        }
    }

    var hPadding: CGFloat {
        switch self {
        case .large: return 20
        case .medium: return 16
        case .small: return 12
        case .extraSmall: return 8
        }
    }

    var vPadding: CGFloat {
        switch self {
        case .large: return 14
        case .medium: return 10
        case .small: return 6
        case .extraSmall: return 4
        }
    }

    var radius: CGFloat {
        switch self {
        case .large: return 16
        case .medium: return 14
        case .small: return 11
        case .extraSmall: return 9
        }
    }

    var fontSize: Font {
        switch self {
        case .large: return .system(size: 16)
        case .medium: return .system(size: 14)
        case .small: return .system(size: 13)
        case .extraSmall: return .system(size: 12)
        }
    }
}

@available(iOS 14, macOS 10.15, *)
public enum DashButtonStyle {
    case filledBlue, filledRed, strokeGray, tintedBlue, tintedGray, plainBlue, plainBlack, plainRed, filledWhiteBlue, tintedWhite, plainWhite

    func backgroundColor(isEnabled: Bool) -> Color {
        switch self {
        case .filledBlue:
            return isEnabled ? .dash.buttonFilledBlueBackground : .dash.buttonFilledBlueBackgroundDisabled
        case .filledRed:
            return isEnabled ? .dash.buttonFilledRedBackground : .dash.buttonFilledRedBackgroundDisabled
        case .strokeGray:
            return isEnabled ? .clear : .dash.buttonStrokeGrayBackgroundDisabled
        case .tintedBlue:
            return isEnabled ? .dash.buttonTintedBlueBackground : .dash.buttonTintedBlueBackgroundDisabled
        case .tintedGray:
            return isEnabled ? .dash.buttonTintedGrayBackground : .dash.buttonTintedGrayBackgroundDisabled
        case .plainBlue, .plainBlack, .plainRed, .plainWhite:
            return .clear
        case .filledWhiteBlue:
            return isEnabled ? .dash.buttonFilledWhiteBackground : .dash.buttonFilledWhiteBackgroundDisabled
        case .tintedWhite:
            return isEnabled ? .dash.buttonTintedWhiteBackground : .dash.buttonTintedWhiteBackgroundDisabled
        }
    }

    func foregroundColor(isEnabled: Bool) -> Color {
        switch self {
        case .filledBlue:
            return isEnabled ? .dash.buttonFilledBlueContent : .dash.buttonFilledBlueContentDisabled
        case .filledRed:
            return isEnabled ? .dash.buttonFilledRedContent : .dash.buttonFilledRedContentDisabled
        case .strokeGray:
            return isEnabled ? .dash.buttonStrokeGrayContent : .dash.buttonStrokeGrayContentDisabled
        case .tintedBlue:
            return isEnabled ? .dash.buttonTintedBlueContent : .dash.buttonTintedBlueContentDisabled
        case .tintedGray:
            return isEnabled ? .dash.buttonTintedGrayContent : .dash.buttonTintedGrayContentDisabled
        case .plainBlue:
            return isEnabled ? .dash.buttonPlainBlueContent : .dash.buttonPlainBlueContentDisabled
        case .plainBlack:
            return isEnabled ? .dash.buttonPlainBlackContent : .dash.buttonPlainBlackContentDisabled
        case .plainRed:
            return isEnabled ? .dash.buttonPlainRedContent : .dash.buttonPlainRedContentDisabled
        case .filledWhiteBlue:
            return isEnabled ? .dash.buttonFilledWhiteContent : .dash.buttonFilledWhiteContentDisabled
        case .tintedWhite:
            return isEnabled ? .dash.buttonTintedWhiteContent : .dash.buttonTintedWhiteContentDisabled
        case .plainWhite:
            return isEnabled ? .dash.buttonPlainWhiteContent : .dash.buttonPlainWhiteContentDisabled
        }
    }
}

@available(iOS 14, macOS 11, *)
public struct DashButton: View {

    public var text: String? = "Label"
    public var leadingIcon: DashIconSource? = nil
    public var trailingIcon: DashIconSource? = nil

    public var isEnabled: Bool = true
    public var isLoading: Bool = false
    public var fillsWidth: Bool = false

    public var size: DashButtonSize = .large
    public var style: DashButtonStyle = .filledBlue
    public var action: () -> Void = {}

    public init(
        text: String? = nil,
        leadingIcon: DashIconSource? = nil,
        trailingIcon: DashIconSource? = nil,
        isEnabled: Bool = true,
        isLoading: Bool = false,
        fillsWidth: Bool = false,
        size: DashButtonSize,
        style: DashButtonStyle,
        action: @escaping () -> Void = {}
    ) {
        self.text = text
        self.leadingIcon = leadingIcon
        self.trailingIcon = trailingIcon
        self.isEnabled = isEnabled
        self.isLoading = isLoading
        self.fillsWidth = fillsWidth
        self.size = size
        self.style = style
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            styledContent
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled || isLoading)
    }

    private var styledContent: some View {
        Group {
            if style == .strokeGray {
                content
                    .padding(.horizontal, size.hPadding)
                    .padding(.vertical, size.vPadding)
                    .foregroundColor(style.foregroundColor(isEnabled: isEnabled))
                    .background(style.backgroundColor(isEnabled: isEnabled))
                    .clipShape(RoundedRectangle(cornerRadius: size.radius, style: .continuous))
                    .frame(maxWidth: fillsWidth ? .infinity : nil)
                    .overlay(
                        RoundedRectangle(cornerRadius: size.radius)
                            .inset(by: 0.5)
                            .stroke(Color.dash.buttonStrokeGrayStroke, lineWidth: 1)
                    )
            } else {
                content
                    .padding(.horizontal, size.hPadding)
                    .padding(.vertical, size.vPadding)
                    .foregroundColor(style.foregroundColor(isEnabled: isEnabled))
                    .frame(maxWidth: fillsWidth ? .infinity : nil)
                    .background(style.backgroundColor(isEnabled: isEnabled))
                    .clipShape(RoundedRectangle(cornerRadius: size.radius, style: .continuous))
            }
        }

    }

    private var content: some View {
        HStack(spacing: size.gap) {
            if let icon = leadingIcon {
                Image(dash: icon)
            }

            if isLoading {
                ProgressView()
            } else if let text {
                Text(text)
                    .font(size.fontSize)
                    .fontWeight(.semibold)
            }

            if let icon = trailingIcon {
                Image(dash: icon)
            }
        }
    }
}

#if DEBUG

@available(iOS 17, macOS 14, *)
private let previewButtonSizes: [DashButtonSize] = [
    .large,
    .medium,
    .small,
    .extraSmall,
]

@available(iOS 17, macOS 14, *)
private extension DashButtonSize {
    var previewTitle: String {
        switch self {
        case .large: return "Large"
        case .medium: return "Medium"
        case .small: return "Small"
        case .extraSmall: return "Extra Small"
        }
    }
}

@available(iOS 17, macOS 14, *)
private extension DashButtonStyle {
    var previewTitle: String {
        switch self {
        case .filledBlue: return "Filled Blue"
        case .filledRed: return "Filled Red"
        case .strokeGray: return "Stroke Gray"
        case .tintedBlue: return "Tinted Blue"
        case .tintedGray: return "Tinted Gray"
        case .plainBlue: return "Plain Blue"
        case .plainBlack: return "Plain Black"
        case .plainRed: return "Plain Red"
        case .filledWhiteBlue: return "Filled White Blue"
        case .tintedWhite: return "Tinted White"
        case .plainWhite: return "Plain White"
        }
    }

    var previewBackgroundColor: Color {
        switch self {
        case .filledWhiteBlue, .tintedWhite, .plainWhite:
            return .dash.buttonFilledBlueBackground
        default:
            return .clear
        }
    }
}

@available(iOS 17, macOS 14, *)
private struct DashButtonStylePreview: View {
    let style: DashButtonStyle

    var body: some View {
        ScrollView(.horizontal) {
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Enabled")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    HStack(alignment: .top, spacing: 12) {
                        ForEach(Array(previewButtonSizes.enumerated()), id: \.offset) { _, size in
                            DashButton(
                                text: size.previewTitle,
                                isEnabled: true,
                                size: size,
                                style: style,
                                action: {}
                            )
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Disabled")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    HStack(alignment: .top, spacing: 12) {
                        ForEach(Array(previewButtonSizes.enumerated()), id: \.offset) { _, size in
                            DashButton(
                                text: size.previewTitle,
                                isEnabled: false,
                                size: size,
                                style: style,
                                action: {}
                            )
                        }
                    }
                }
            }
            .padding(24)
        }
        .background(style.previewBackgroundColor)
    }
}

@available(iOS 17, macOS 14, *)
#Preview("Example") {
    VStack {
        DashButton(
            text: "Withdraw funds",
            fillsWidth: true,
            size: .large,
            style: .filledBlue,
            action: {}
        )

        DashButton(
            text: "Withdraw funds",
            fillsWidth: true,
            size: .large,
            style: .strokeGray,
            action: {}
        )
    }
    .padding(.horizontal)
}

@available(iOS 17, macOS 14, *)
#Preview("Filled Blue") {
    DashButtonStylePreview(style: .filledBlue)
}

@available(iOS 17, macOS 14, *)
#Preview("Filled Red") {
    DashButtonStylePreview(style: .filledRed)
}

@available(iOS 17, macOS 14, *)
#Preview("Stroke Gray") {
    DashButtonStylePreview(style: .strokeGray)
}

@available(iOS 17, macOS 14, *)
#Preview("Tinted Blue") {
    DashButtonStylePreview(style: .tintedBlue)
}

@available(iOS 17, macOS 14, *)
#Preview("Tinted Gray") {
    DashButtonStylePreview(style: .tintedGray)
}

@available(iOS 17, macOS 14, *)
#Preview("Plain Blue") {
    DashButtonStylePreview(style: .plainBlue)
}

@available(iOS 17, macOS 14, *)
#Preview("Plain Black") {
    DashButtonStylePreview(style: .plainBlack)
}

@available(iOS 17, macOS 14, *)
#Preview("Plain Red") {
    DashButtonStylePreview(style: .plainRed)
}

@available(iOS 17, macOS 14, *)
#Preview("Filled White Blue") {
    DashButtonStylePreview(style: .filledWhiteBlue)
}

@available(iOS 17, macOS 14, *)
#Preview("Tinted White") {
    DashButtonStylePreview(style: .tintedWhite)
}

@available(iOS 17, macOS 14, *)
#Preview("Plain White") {
    DashButtonStylePreview(style: .plainWhite)
}

#endif
