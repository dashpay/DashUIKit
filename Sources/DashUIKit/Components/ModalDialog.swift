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

/// A dialog card: an optional icon, a heading, any number of paragraphs and
/// one or two actions stacked full width. The host presents it (over a dim,
/// centred); the card only lays itself out. Text longer than the screen
/// scrolls inside the card, and the buttons stay visible.
public struct ModalDialog: View {

    public enum Icon: Sendable {
        /// The yellow warning tile.
        case warning
    }

    /// One button of the dialog.
    public struct Action {
        public enum Role: Sendable {
            case regular
            /// Ends something the user cannot simply get back: drawn in red.
            case destructive
        }

        public let title: String
        public let role: Role
        public let handler: () -> Void

        public init(title: String, role: Role = .regular, handler: @escaping () -> Void) {
            self.title = title
            self.role = role
            self.handler = handler
        }
    }

    /// A button as drawn, top to bottom.
    struct Button {
        let title: String
        let style: DashButtonStyle
        let handler: () -> Void
    }

    public let icon: Icon?
    public let heading: String
    public let paragraphs: [String]
    public let primaryAction: Action
    public let secondaryAction: Action?

    public init(
        icon: Icon? = nil,
        heading: String,
        paragraphs: [String],
        primaryAction: Action,
        secondaryAction: Action? = nil
    ) {
        self.icon = icon
        self.heading = heading
        self.paragraphs = paragraphs
        self.primaryAction = primaryAction
        self.secondaryAction = secondaryAction
    }

    /// The secondary action above the primary one.
    var buttons: [Button] {
        [secondaryAction, primaryAction].compactMap { action in
            action.map { action in
                Button(
                    title: action.title,
                    style: action.role == .destructive ? .tintedRed : .tintedGray,
                    handler: action.handler)
            }
        }
    }

    public var body: some View {
        VStack(spacing: 30) {
            ViewThatFits(in: .vertical) {
                topContent
                ScrollView {
                    topContent
                }
                .scrollBounceBehavior(.basedOnSize)
            }
            VStack(spacing: 20) {
                ForEach(Array(buttons.enumerated()), id: \.offset) { _, button in
                    DashButton(text: button.title, fillsWidth: true, size: .medium, style: button.style, action: button.handler)
                }
            }
        }
        .padding(.top, 30)
        .padding([.horizontal, .bottom], 20)
        .frame(maxWidth: 330)
        .background(Color.dash.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
    }

    private var topContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            if let icon {
                iconImage(icon)
                    .accessibilityHidden(true)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(heading)
                    .dashFont(.headline)
                    .accessibilityAddTraits(.isHeader)
                ForEach(Array(paragraphs.enumerated()), id: \.offset) { index, paragraph in
                    Text(paragraph)
                        .dashFont(.subhead)
                        // A blank line between paragraphs, as the text reads.
                        .padding(.top, index == 0 ? 0 : DashTextStyle.subhead.lineHeight)
                }
            }
            .foregroundStyle(Color.dash.primaryText)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 10)
    }

    private func iconImage(_ icon: Icon) -> some View {
        switch icon {
        case .warning:
            DashIcon.Illustrations.dialogueWarning.image
                .resizable()
                .frame(width: 46, height: 46)
        }
    }
}

#if DEBUG

private let questionText = "Disconnected. Keys this wallet did not record giving are still on your identity (2): keys of this app from another device or from before a restore, or DashPay profile keys no connection holds. Turn them off too?"
private let notCheckedText = "Disconnected. This wallet could not tell yet which app holds some keys on your identity (1). Open Connections again later to see them."
private let notAttributableText = "Some keys on your identity (1) may belong to another app of the same developer, so this wallet left them on. Each one shows on its own row in Connections; disconnect it there if you no longer need it."
private let leftText = "Disconnected. Some keys of this app are still on your identity (1). Disconnect it again to turn them off."

private func dimmed(_ dialog: ModalDialog) -> some View {
    ZStack {
        Color.black.opacity(0.4).ignoresSafeArea()
        dialog.padding(.horizontal, 20)
    }
}

#Preview("One button") {
    dimmed(ModalDialog(icon: .warning, heading: "Success", paragraphs: [notCheckedText], primaryAction: .init(title: "OK") {}))
}

#Preview("Two buttons") {
    dimmed(ModalDialog(
        icon: .warning, heading: "Keys left on your identity", paragraphs: [questionText],
        primaryAction: .init(title: "Turn them off", role: .destructive) {},
        secondaryAction: .init(title: "Leave them") {}))
}

#Preview("Long text") {
    dimmed(ModalDialog(
        icon: .warning, heading: "Success",
        paragraphs: [notCheckedText, notAttributableText, leftText, questionText, notAttributableText],
        primaryAction: .init(title: "OK") {}))
}

#Preview("No icon, no paragraphs") {
    dimmed(ModalDialog(heading: "Disconnected", paragraphs: [], primaryAction: .init(title: "OK") {}))
}

#Preview("Dark") {
    dimmed(ModalDialog(
        icon: .warning, heading: "Keys left on your identity", paragraphs: [questionText, notAttributableText],
        primaryAction: .init(title: "Turn them off", role: .destructive) {},
        secondaryAction: .init(title: "Leave them") {}))
        .preferredColorScheme(.dark)
}

#endif
