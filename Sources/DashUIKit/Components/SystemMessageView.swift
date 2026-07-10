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

@available(iOS 14, macOS 11, *)
public struct SystemMessageView: View {

    public let title: String
    public let subtitle: String?
    public let icon: DashIconSource
    public let backgroundColor: Color
    public let buttonName: String?
    public let onAction: (() -> Void)?
    public let secondaryButtonName: String?
    public let onSecondaryAction: (() -> Void)?
    public let onClose: (() -> Void)?
    public init(
        title: String,
        subtitle: String? = nil,
        icon: DashIconSource = .custom("warning_triangle", bundle: .dashUIKit),
        backgroundColor: Color = Color.dash.gray300Alpha10,
        buttonName: String? = nil,
        onAction: (() -> Void)? = nil,
        secondaryButtonName: String? = nil,
        onSecondaryAction: (() -> Void)? = nil,
        onClose: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.backgroundColor = backgroundColor
        self.buttonName = buttonName
        self.onAction = onAction
        self.secondaryButtonName = secondaryButtonName
        self.onSecondaryAction = onSecondaryAction
        self.onClose = onClose
    }

    public var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(dash: icon)
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)

            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(title)
                        .dashFont(.subhead)
                        .foregroundColor(Color.dash.primaryText)

                    if let subtitle {
                        Text(subtitle)
                            .dashFont(.subhead)
                            .foregroundColor(Color.dash.secondaryText)
                            .multilineTextAlignment(.leading)
                    }
                }

                if buttonName != nil || secondaryButtonName != nil {
                    HStack(spacing: 10) {
                        if let buttonName, let onAction {
                            DashUIKit.DashButton(
                                text: buttonName,
                                size: .small,
                                style: .filledBlue,
                                action: onAction
                            )
                        }
                        if let secondaryButtonName, let onSecondaryAction {
                            DashUIKit.DashButton(
                                text: secondaryButtonName,
                                size: .small,
                                style: .tintedBlue,
                                action: onSecondaryAction
                            )
                        }
                    }
                    .padding(.bottom, 14)
                }
            }
            .padding(.vertical, 5)
            .frame(maxWidth: .infinity, alignment: .topLeading)

            if onClose != nil {
                Button(action: { onClose?() }) {
                    XmarkIcon(size: 9, color: Color.dash.primaryText)
                        .frame(width: 24, height: 24)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel(NSLocalizedString("Close", bundle: .module, comment: "DashUIKit"))
            }
        }
        .padding(10)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

// MARK: - Preview

#if DEBUG

@available(iOS 17, macOS 14, *)
#Preview("Default (back-compat)") {
    SystemMessageView(
        title: "You have a balance on CrowdNode",
        subtitle: "These funds should be withdrawn from CrowdNode. You can transfer these funds to this wallet or via your online account on some other device."
    )
    .padding()
}

@available(iOS 17, macOS 14, *)
#Preview("Custom icon + background + two buttons + close") {
    SystemMessageView(
        title: "Address Expired",
        subtitle: "The receiving address has expired. Generate a new one or extend the expiry.",
        icon: .system("clock.badge.exclamationmark"),
        backgroundColor: Color.dash.blueAlpha5,
        buttonName: "Renew",
        onAction: {},
        secondaryButtonName: "Extend",
        onSecondaryAction: {},
        onClose: {}
    )
    .padding()
}

#endif // DEBUG
