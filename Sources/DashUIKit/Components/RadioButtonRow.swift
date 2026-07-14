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

@available(iOS 14, macOS 11, *)
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
        self.title = title
        self.subtitle = subtitle
        self.trailingText = trailingText
        self.icon = icon
        self.isSelected = isSelected
        self.style = style
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
                        .foregroundColor(Color.dash.primaryText)

                    if let subtitle = subtitle {
                        Text(subtitle)
                            .dashFont(.caption1)
                            .foregroundColor(Color.dash.secondaryText)
                    }
                }

                Spacer()

                if let trailingText = trailingText {
                    Text(trailingText)
                        .dashFont(.subheadMedium)
                        .foregroundColor(Color.dash.primaryText)
                }

                switch style {
                case .radio:
                    Circle()
                        .stroke(isSelected ? Color.dash.blue : Color.dash.gray300.opacity(0.5), lineWidth: isSelected ? 6 : 2)
                        .frame(width: isSelected ? 21 : 24, height: isSelected ? 21 : 24)
                        .padding(.trailing, isSelected ? 2 : 0)
                case .checkbox:
                    Image(dash: .custom(isSelected ? "icon_checkbox_square_checked" : "icon_checkbox_square", bundle: .dashUIKit))
                        .resizable()
                        .frame(width: 24, height: 24)
                }
            }
            .padding(.horizontal, 16)
            .contentShape(Rectangle())
            .frame(minHeight: subtitle != nil ? 60 : 54)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#if DEBUG

@available(iOS 14, macOS 11, *)
struct RadioButtonRow_Previews: PreviewProvider {
    static var previews: some View {
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
        .previewLayout(.sizeThatFits)
    }
}

#endif
