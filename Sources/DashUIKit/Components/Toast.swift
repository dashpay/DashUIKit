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

#if canImport(UIKit)
import SwiftUI
import UIKit

// MARK: - BackgroundBlurView

struct BackgroundBlurView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

// MARK: - ToastStyle

public enum ToastStyle {
    case warning, info, error, success, copied, loading, noInternet

    /// The leading icon; `nil` for `loading`, which draws `LoadingSpinner`.
    var icon: DashIcon.Toast? {
        switch self {
        case .warning: return .warning
        case .info:    return .info
        case .error:   return .error
        case .success: return .success
        case .copied:  return .copied
        case .loading: return nil
        case .noInternet: return .noWifi
        }
    }
}

// MARK: - Toast

public struct Toast: View {

    private let style: ToastStyle
    private let message: String
    private let accessibilityLabel: Text
    private let action: (title: String, handler: () -> Void)?
    private let onDismiss: (() -> Void)?

    public init(
        style: ToastStyle,
        message: String,
        onDismiss: (() -> Void)? = nil
    ) {
        self.init(style: style, message: message, accessibilityLabel: Text(message), onDismiss: onDismiss)
    }

    /// `action` adds a small button before the close button ("Try again"); its
    /// `title` is shown as given, so the host localizes it.
    public init(
        style: ToastStyle,
        message: String,
        action: (title: String, handler: () -> Void),
        onDismiss: (() -> Void)? = nil
    ) {
        self.init(
            style: style,
            message: message,
            accessibilityLabel: Text(message),
            action: action,
            onDismiss: onDismiss
        )
    }

    /// `accessibilityLabel` is what VoiceOver reads instead of `message`, for a
    /// host that wants the style spoken too ("Error, payment failed"). It is a
    /// `Text`, so the host localizes it as it would a `Button` title. It replaces
    /// the message's label, so pass a new one with every new message. The icon
    /// itself is never read.
    public init(
        style: ToastStyle,
        message: String,
        accessibilityLabel: Text,
        onDismiss: (() -> Void)? = nil
    ) {
        self.style = style
        self.message = message
        self.accessibilityLabel = accessibilityLabel
        self.action = nil
        self.onDismiss = onDismiss
    }

    /// The `accessibilityLabel` initializer with an action button; see the two above.
    public init(
        style: ToastStyle,
        message: String,
        accessibilityLabel: Text,
        action: (title: String, handler: () -> Void),
        onDismiss: (() -> Void)? = nil
    ) {
        self.style = style
        self.message = message
        self.accessibilityLabel = accessibilityLabel
        self.action = action
        self.onDismiss = onDismiss
    }

    public var body: some View {
        HStack(alignment: .top, spacing: 8) {
            HStack(alignment: .top, spacing: 0) {
                // Otherwise VoiceOver reads the asset name ("toast-warning, image").
                leadingIcon
                    .frame(width: 24, height: 24)
                    .accessibilityHidden(true)

                Text(message)
                    .dashFont(.footnoteMedium)
                    .foregroundStyle(Color.dash.toastText)
                    .padding(.vertical, 3)
                    .padding(.leading, 8)
                    .accessibilityLabel(accessibilityLabel)
            }
            .padding(.trailing, 8)

            if action != nil || onDismiss != nil {
                Spacer(minLength: 10)

                HStack(alignment: .top, spacing: 8) {
                    if let action {
                        Button(action: action.handler) {
                            Text(action.title)
                                .dashFont(.caption1Medium)
                                .foregroundStyle(Color.dash.toastText)
                                .lineLimit(1)
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                                        .fill(Color.dash.whiteAlpha10)
                                )
                        }
                        .buttonStyle(.plain)
                        // A long message wraps; the button keeps its size.
                        .fixedSize()
                    }

                    if let onDismiss {
                        Button(action: onDismiss) {
                            XmarkIcon(color: Color.dash.toastText)
                                .padding(8)
                                .background(Circle().fill(Color.dash.whiteAlpha10))
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(Text(NSLocalizedString("Close", bundle: .module, comment: "DashUIKit")))
                    }
                }
            }
        }
        .padding(.leading, 12)
        .padding(.trailing, 8)
        .padding(.vertical, 8)
        .background(
            ZStack {
                BackgroundBlurView()
                Color.dash.toastBackground
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .contentShape(Rectangle())
    }

    @ViewBuilder
    private var leadingIcon: some View {
        if let icon = style.icon {
            icon.image
                .resizable()
                .scaledToFit()
                .frame(width: 16, height: 16)
        } else {
            // Reuse the design-system spinner (12 spokes at graduated opacity).
            // LoadingSpinner applies its own per-spoke opacity on top of toastText.
            LoadingSpinner(size: 16, color: Color.dash.toastText)
        }
    }
}

// MARK: - Preview

#if DEBUG

#Preview {
    VStack(spacing: 12) {
        Toast(style: .warning, message: "Some coins are not available", onDismiss: {})
        Toast(style: .info, message: "Heads up", onDismiss: {})
        Toast(style: .error, message: "Something went wrong", onDismiss: {})
        Toast(style: .error, message: "Payment failed", accessibilityLabel: Text("Error, payment failed"), onDismiss: {})
        Toast(style: .success, message: "Done", onDismiss: {})
        Toast(style: .copied, message: "Copied to clipboard")
        Toast(style: .loading, message: "Loading…")
        Toast(style: .noInternet, message: "No internet connection")
    }
    .padding()
    .background(Color.dash.blue)
}

#Preview("Action") {
    VStack(spacing: 12) {
        Toast(style: .error, message: "Couldn't refresh.", action: (title: "Try again", handler: {}))
        Toast(style: .error, message: "Couldn't refresh.", action: (title: "Try again", handler: {}), onDismiss: {})
        Toast(
            style: .warning,
            message: "Couldn't read your vote history. Voting is paused until it loads.",
            action: (title: "Try again", handler: {}),
            onDismiss: {}
        )
    }
    .padding()
    .background(Color.dash.blue)
}

#endif
#endif // canImport(UIKit)
