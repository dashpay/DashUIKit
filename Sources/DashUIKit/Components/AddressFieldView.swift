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

/// Outside the view, not nested in it: `AddressFieldView` is generic over its
/// accessory, and a generic type cannot hold static stored properties.
private enum Layout {
    static let hSpacing: CGFloat = 20
    static let lPadding: CGFloat = 20
    static let tPadding: CGFloat = 10
    static let iconSize: CGFloat = 17
    static let cornerRadius: CGFloat = 16
    static let actionTapArea: CGFloat = 40
    /// Width of the focus / error ring, drawn hard-edged outside the field —
    /// Figma's `shadow: 0 0 0 3px`, which is a 3pt spread with no blur and no
    /// offset.
    static let ringWidth: CGFloat = 3
}

@available(iOS 15, macOS 12, *)
public struct AddressFieldView<Accessory: View>: View {

    @Binding private var text: String
    private let label: String
    private let placeholder: String
    private let hasError: Bool
    private let errorText: String?
    private var isDisabled: Bool
    private var onScanQR: (() -> Void)?
    private var onPaste: (() -> Void)?
    /// Trailing content on the label row — a badge naming what the entered
    /// address turned out to be, say. Sits opposite `label`, so it is for
    /// something that describes the field rather than acts on it; the
    /// controls that act live inside the field itself.
    private let accessory: Accessory
    /// Lets the host raise and dismiss the keyboard — focus on appear, blur
    /// before presenting a sheet. The field still owns its `@FocusState`; this
    /// mirrors it in both directions so the host does not need one. `nil` means
    /// the field is the only one deciding, which is what every existing caller
    /// does.
    private var isFocused: Binding<Bool>?
    /// Whether the trailing ✕ is offered once there is text. A long address
    /// needs it; a short field the user can clear by hand does not, and there
    /// it is only one more thing to hit by accident.
    private let showsClearButton: Bool
    /// The content has passed whatever the host validates it against, so the
    /// field stops asking for attention: the focus ring is dropped. An error
    /// still overrides it — a name can be well-formed and still refused.
    private let isAccepted: Bool

    @FocusState private var isTextFieldFocused: Bool

    public init(
        text: Binding<String>,
        label: String,
        placeholder: String,
        hasError: Bool,
        errorText: String? = nil,
        isDisabled: Bool = false,
        onScanQR: (() -> Void)? = nil,
        onPaste: (() -> Void)? = nil,
        isFocused: Binding<Bool>? = nil,
        showsClearButton: Bool = true,
        isAccepted: Bool = false,
        @ViewBuilder accessory: () -> Accessory
    ) {
        self._text = text
        self.label = label
        self.placeholder = placeholder
        self.hasError = hasError
        self.errorText = errorText
        self.isDisabled = isDisabled
        self.onScanQR = onScanQR
        self.onPaste = onPaste
        self.isFocused = isFocused
        self.showsClearButton = showsClearButton
        self.isAccepted = isAccepted
        self.accessory = accessory()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Text(label)
                    .dashFont(.footnote)
                    .foregroundStyle(Color.dash.gray500)

                Spacer(minLength: 0)

                accessory
            }
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
            // Not `.shadow`: with no blur and no offset a shadow lands exactly
            // under the field and is never seen, and in the focused state the
            // background is clear, so what little showed would be cast by the
            // text rather than by the field's outline. A stroke on the outward
            // inset is the ring the design draws.
            .overlay(
                RoundedRectangle(cornerRadius: Layout.cornerRadius + Layout.ringWidth / 2, style: .continuous)
                    .inset(by: -Layout.ringWidth / 2)
                    .stroke(ringColor, lineWidth: Layout.ringWidth)
            )

            if let errorText {
                Text(errorText)
                    .dashFont(.footnote)
                    .foregroundStyle(Color.dash.errorText)
            }
        }
        .onAppear {
            // A host that wants the keyboard up on entry sets its flag before
            // this field exists, so the mirror below never fires for it.
            if isFocused?.wrappedValue == true { isTextFieldFocused = true }
        }
        .onChange(of: isTextFieldFocused) { focused in
            if isFocused?.wrappedValue != focused { isFocused?.wrappedValue = focused }
        }
        .onChange(of: isFocused?.wrappedValue) { requested in
            guard let requested, requested != isTextFieldFocused else { return }
            isTextFieldFocused = requested
        }
    }

}

@available(iOS 15, macOS 12, *)
public extension AddressFieldView where Accessory == EmptyView {
    /// No label accessory — the original shape, unchanged for callers that
    /// have nothing to put there.
    init(
        text: Binding<String>,
        label: String,
        placeholder: String,
        hasError: Bool,
        errorText: String? = nil,
        isDisabled: Bool = false,
        onScanQR: (() -> Void)? = nil,
        onPaste: (() -> Void)? = nil,
        isFocused: Binding<Bool>? = nil,
        showsClearButton: Bool = true,
        isAccepted: Bool = false
    ) {
        self.init(
            text: text,
            label: label,
            placeholder: placeholder,
            hasError: hasError,
            errorText: errorText,
            isDisabled: isDisabled,
            onScanQR: onScanQR,
            onPaste: onPaste,
            isFocused: isFocused,
            showsClearButton: showsClearButton,
            isAccepted: isAccepted,
            accessory: { EmptyView() })
    }
}

@available(iOS 15, macOS 12, *)
extension AddressFieldView {
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
                // A prompt must stay a `Text`; `dashFont` returns `some View`, and a
                // line height cannot be applied to `Text` anyway.
                prompt: Text(placeholder)
                    .font(Font.dash.subhead)
                    .foregroundStyle(Color.dash.black1000Alpha30),
                axis: .vertical
            )
            .lineLimit(1...2)
            .dashFont(.subhead)
            .textInputAutocapitalization(.never)
            .disableAutocorrection(true)
            .foregroundStyle(Color.dash.primaryText)
            .tint(Color.dash.primaryText)
            .focused($isTextFieldFocused)
            .disabled(isDisabled)
        } else {
            TextField(placeholder, text: $text)
                .dashFont(.subhead)
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
                // Only when there is somewhere for the tap to go. A field for
                // something that has no QR form — a username, say — passes no
                // handler, and drawing the glyph anyway offered a control that
                // did nothing.
                if let onScanQR {
                    Button(action: onScanQR) {
                        DashIcon.Other.textFieldQR.image
                            .resizable()
                            .scaledToFit()
                            .frame(width: Layout.iconSize, height: Layout.iconSize)
                    }
                    .accessibilityLabel(NSLocalizedString("Scan QR code", bundle: .module, comment: "DashUIKit"))
                }
            } else if showsClearButton {
                Button(action: { text = "" }) {
                    DashIcon.Other.textFieldClear.image
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(Color.dash.primaryText)
                        .frame(width: 11, height: 11)
                }
                .accessibilityLabel(NSLocalizedString("Clear address", bundle: .module, comment: "DashUIKit"))
            }
        }
        // The tap area is reserved rather than sized to whichever control is
        // showing, so the field's width does not shift as the user types. A
        // field that can never show either control reserves nothing.
        .frame(
            width: hasTrailingControl ? Layout.actionTapArea : 0,
            height: Layout.actionTapArea)
        .contentShape(Rectangle())
    }

    /// Whether any trailing control can appear in this field's configuration.
    private var hasTrailingControl: Bool {
        onScanQR != nil || showsClearButton
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

    /// The ring around the field, as the design system draws it: red while
    /// something is wrong, blue while the user is working in the field, and
    /// nothing once the content has been accepted — at that point the field
    /// has no more to say and a glow would keep drawing the eye to a question
    /// already answered.
    private var ringColor: Color {
        if hasError { return Color.dash.redAlpha20 }
        if isFocusedState, !isAccepted { return Color.dash.blueAlpha20 }
        return .clear
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
#Preview("Empty, no scan handler") {
    // Nothing to scan — a username, a label, a note. No trailing glyph is
    // drawn, where before an inert QR button was.
    AddressFieldView(
        text: .constant(""),
        label: "Username",
        placeholder: "Enter a username",
        hasError: false, errorText: nil
    )
    .padding()
}

@available(iOS 17, macOS 14, *)
#Preview("Accepted — no ring, no clear button") {
    AddressFieldView(
        text: .constant("satoshi"),
        label: "Username",
        placeholder: "Enter a username",
        hasError: false, errorText: nil,
        showsClearButton: false,
        isAccepted: true
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

@available(iOS 17, macOS 14, *)
#Preview("Label accessory") {
    AddressFieldView(
        text: .constant("yV1D1ivvSUyKPJnbFmzSTVh1MyZ3JbeVkY"),
        label: "Address",
        placeholder: "Dash address",
        hasError: false
    ) {
        // What the host puts here is its own: a badge naming the kind of
        // address that was entered, decided by the host's own decoder.
        HStack(spacing: 4) {
            DashIcon.Common.iconDashCurrency.image
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 10, height: 10)
            Text("Transparent address")
                .dashFont(.caption2)
        }
        .foregroundStyle(Color.dash.blueText)
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(Color.dash.blueAlpha10)
        .clipShape(Capsule())
    }
    .padding()
    .background(Color.dash.primaryBackground)
}

#endif
#endif // canImport(UIKit)
