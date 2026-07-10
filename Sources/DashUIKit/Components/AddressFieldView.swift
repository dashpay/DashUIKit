//
//  Created by Dash Core Group. All rights reserved.
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

@available(iOS 15, macOS 12, *)
public struct AddressFieldView: View {

    private enum Layout {
        static let hSpacing: CGFloat = 20
        static let lPadding: CGFloat = 20
        static let tPadding: CGFloat = 10
        static let iconSize: CGFloat = 17
        static let cornerRadius: CGFloat = 16
        static let actionTapArea: CGFloat = 40
    }

    @Binding private var text: String
    private let label: String
    private let placeholder: String
    private let hasError: Bool
    private let errorText: String?
    private var isDisabled: Bool
    private var onScanQR: (() -> Void)?
    private var onPaste: (() -> Void)?

    @FocusState private var isTextFieldFocused: Bool

    public init(
        text: Binding<String>,
        label: String,
        placeholder: String,
        hasError: Bool,
        errorText: String? = nil,
        isDisabled: Bool = false,
        onScanQR: (() -> Void)? = nil,
        onPaste: (() -> Void)? = nil
    ) {
        self._text = text
        self.label = label
        self.placeholder = placeholder
        self.hasError = hasError
        self.errorText = errorText
        self.isDisabled = isDisabled
        self.onScanQR = onScanQR
        self.onPaste = onPaste
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(label)
                .dashFont(.footnote)
                .foregroundStyle(Color.dash.gray500)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(alignment: .center, spacing: Layout.hSpacing) {
                textField
                    .padding(.vertical, 15)

                if !isDisabled {
                    // In the blurred-filled state (text present, unfocused, no error) the trailing
                    // icon stays in the layout so the field width — and the address text wrapping —
                    // doesn't shift between focused and unfocused. Per design it's just hidden:
                    // opacity 0 and non-interactive, but the space is reserved.
                    HStack(spacing: 8) {
                        if showsPasteButton { pasteButton }
                        actionButton
                            .opacity(isBlurredFilledState ? 0 : 1)
                            .allowsHitTesting(!isBlurredFilledState)
                    }
                }
            }
            .padding(.leading, Layout.lPadding)
            .padding(.trailing, Layout.tPadding)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: Layout.cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Layout.cornerRadius)
                    .stroke(borderColor, lineWidth: borderWidth)
            )

            if let errorText {
                Text(errorText)
                    .dashFont(.footnote)
                    .foregroundStyle(Color.dash.errorText)
            }
        }
    }

    // MARK: - Subviews

    private var showsPasteButton: Bool {
        text.isEmpty && !isDisabled && onPaste != nil
    }

    private var pasteButton: some View {
        DashButton(
            text: NSLocalizedString("Paste", bundle: .module, comment: "DashUIKit"),
            size: .medium,
            style: .plainBlue,
            action: { onPaste?() }
        )
    }

    @ViewBuilder private var textField: some View {
        if #available(iOS 17.0, *) {
            TextField(
                "",
                text: $text,
                prompt: Text(placeholder)
                    .font(Font.dash.subhead)
                    .foregroundStyle(Color.dash.black1000Alpha30),
                axis: .vertical
            )
            .lineLimit(1...2)
            .font(Font.dash.subhead)
            .textInputAutocapitalization(.never)
            .disableAutocorrection(true)
            .foregroundStyle(Color.dash.primaryText)
            .tint(Color.dash.primaryText)
            .focused($isTextFieldFocused)
            .disabled(isDisabled)
        } else {
            TextField(placeholder, text: $text)
                .font(Font.dash.subhead)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .foregroundStyle(Color.dash.primaryText)
                .tint(Color.dash.primaryText)
                .focused($isTextFieldFocused)
                .disabled(isDisabled)
        }
    }

    private var actionButton: some View {
        Group {
            if text.isEmpty {
                Button(action: { onScanQR?() }) {
                    Image(dash: .custom("text-field-qr", bundle: .dashUIKit))
                        .resizable()
                        .scaledToFit()
                        .frame(width: Layout.iconSize, height: Layout.iconSize)
                }
                .accessibilityLabel(NSLocalizedString("Scan QR code", bundle: .module, comment: "DashUIKit"))
            } else {
                Button(action: { text = "" }) {
                    Image(dash: .custom("text-field-clear", bundle: .dashUIKit))
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(Color.dash.primaryText)
                        .frame(width: 11, height: 11)
                }
                .accessibilityLabel(NSLocalizedString("Clear address", bundle: .module, comment: "DashUIKit"))
            }
        }
        .frame(width: Layout.actionTapArea, height: Layout.actionTapArea)
        .contentShape(Rectangle())
    }

    // MARK: - Styling

    private var backgroundColor: Color {
        if isFocusedState { return .clear }
        if hasError { return Color.dash.redAlpha5 }
        return Color.dash.gray300Alpha10
    }

    private var borderColor: Color {
        isFocusedState ? Color.dash.gray300Alpha40 : .clear
    }

    private var borderWidth: CGFloat {
        isFocusedState ? 1 : 0
    }

    private var isFocusedState: Bool {
        isTextFieldFocused && !isDisabled
    }

    private var isFilledState: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isFocusedState
    }

    /// Field is unfocused ("tapped outside"), has text, and has no error — a clean read-out state
    /// with no editing affordance (the trailing action button is suppressed).
    private var isBlurredFilledState: Bool {
        isFilledState && !hasError && !isDisabled
    }
}

#if DEBUG

@available(iOS 17, macOS 14, *)
#Preview("Empty") {
    AddressFieldView(
        text: .constant(""),
        label: "Destination address",
        placeholder: "BTC address",
        hasError: false, errorText: nil,
        onScanQR: {}
    )
    .padding()
}

@available(iOS 17, macOS 14, *)
#Preview("Empty with Paste button") {
    AddressFieldView(
        text: .constant(""),
        label: "Destination address",
        placeholder: "BTC address",
        hasError: false, errorText: nil,
        onScanQR: {},
        onPaste: {}
    )
    .padding()
}

@available(iOS 17, macOS 14, *)
#Preview("With Text") {
    AddressFieldView(
        text: .constant("bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh"),
        label: "Destination address",
        placeholder: "BTC address",
        hasError: false, errorText: nil,
        onScanQR: {}
    )
    .padding()
}

@available(iOS 17, macOS 14, *)
#Preview("Multiline") {
    AddressFieldView(
        text: .constant("bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh\nbc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh"),
        label: "Destination address",
        placeholder: "BTC address",
        hasError: false, errorText: nil,
        onScanQR: {}
    )
    .padding()
}

@available(iOS 17, macOS 14, *)
#Preview("Error") {
    AddressFieldView(
        text: .constant("invalid-address"),
        label: "Destination address",
        placeholder: "BTC address",
        hasError: true, errorText: "Error text",
        onScanQR: {}
    )
    .padding()
}

@available(iOS 17, macOS 14, *)
#Preview("Filled") {
    AddressFieldView(
        text: .constant("bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh"),
        label: "Destination address",
        placeholder: "BTC address",
        hasError: false, errorText: nil,
        onScanQR: {}
    )
    .padding()
}

@available(iOS 17, macOS 14, *)
#Preview("Blurred + filled (no action button)") {
    AddressFieldView(
        text: .constant("bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh"),
        label: "Destination address",
        placeholder: "BTC address",
        hasError: false, errorText: nil,
        onScanQR: {}
    )
    .padding()
}

#endif
#endif // canImport(UIKit)
