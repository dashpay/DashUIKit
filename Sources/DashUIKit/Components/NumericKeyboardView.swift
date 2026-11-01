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

import Foundation
import SwiftUI

/// The keypad's input rules, shared by the on-screen buttons and by hosts that
/// route a physical keyboard into the same value.
///
/// `NumericKeyboardView` renders buttons and installs no text responder, so a
/// host that wants hardware-keyboard support has to supply its own responder.
/// It must not reimplement the rules while doing so: `applyKeyPress` owns the
/// locale-sensitive parts (which separator is decimal, which is grouping and
/// therefore dropped, single decimal separator, delete), and
/// `key(forTyped:locale:)` translates a typed character into the key the
/// on-screen keypad would have sent.
public enum NumericKeyboardLocaleSupport {
    public static func decimalSeparator(for locale: Locale) -> String {
        locale.decimalSeparator ?? "."
    }

    /// The key the delete button sends; a host's Backspace handling passes this
    /// to `applyKeyPress`.
    public static var deleteKey: String { Layout.deleteKey }

    static func rows(showDecimalSeparator: Bool, locale: Locale) -> [[String]] {
        let lastRow: [String]
        if showDecimalSeparator {
            lastRow = [decimalSeparator(for: locale), Layout.zeroKey, Layout.deleteKey]
        } else {
            lastRow = [Layout.emptyKey, Layout.zeroKey, Layout.deleteKey]
        }

        return [
            ["1", "2", "3"],
            ["4", "5", "6"],
            ["7", "8", "9"],
            lastRow,
        ]
    }

    /// Translates a character typed on a physical keyboard into the key the
    /// on-screen keypad would have sent, or `nil` when the keypad has no such
    /// key. Feed the result to `applyKeyPress`.
    ///
    /// A hardware decimal key stands for whatever this locale's decimal
    /// separator is — a German layout emits "," and a US layout ".". The one
    /// character deliberately passed through unchanged is the locale's
    /// grouping separator, because dropping it is `applyKeyPress`'s rule to
    /// apply, not this method's to duplicate.
    public static func key(forTyped character: Character, locale: Locale) -> String? {
        if let digit = character.wholeNumberValue, (0 ... 9).contains(digit) {
            return String(digit)
        }

        guard character == "." || character == "," else { return nil }

        let typed = String(character)
        let groupingSeparator = locale.groupingSeparator ?? ","
        let decimalSeparator = decimalSeparator(for: locale)

        if typed == groupingSeparator, groupingSeparator != decimalSeparator {
            return typed
        }
        return decimalSeparator
    }

    public static func applyKeyPress(
        value: String,
        key: String,
        showDecimalSeparator: Bool,
        locale: Locale
    ) -> String {
        if key == Layout.deleteKey {
            var updatedValue = value
            if !updatedValue.isEmpty {
                updatedValue.removeLast()
            }
            return updatedValue
        }

        let decimalSeparator = decimalSeparator(for: locale)
        let groupingSeparator = locale.groupingSeparator ?? ","

        if !groupingSeparator.isEmpty, key == groupingSeparator, groupingSeparator != decimalSeparator {
            return value
        }

        if key == decimalSeparator {
            if showDecimalSeparator && !value.contains(decimalSeparator) {
                return value + decimalSeparator
            }
            return value
        }

        guard !key.isEmpty else { return value }
        return value + key
    }

    enum Layout {
        static let zeroKey = "0"
        static let emptyKey = ""
        static let deleteKey = "⌫"
    }
}

// MARK: - NumericKeyboardView

public struct NumericKeyboardView: View {

    private enum Layout {
        /// The panel takes the full width and is rounded at the top; its content
        /// is inset by these paddings. The bottom one sits above the bottom
        /// safe area, which the background runs on through.
        static let panelHorizontalPadding: CGFloat = 20
        static let panelVerticalPadding: CGFloat = 20
        static let panelCornerRadius: CGFloat = 32
        static let rootSpacing: CGFloat = 20
        /// No gap between rows: the 50 pt keys are the rows' whole height, so
        /// a tap anywhere in a column lands on a key.
        static let keyRowSpacing: CGFloat = 0
        static let keyColumnSpacing: CGFloat = 5
        static let keyHeight: CGFloat = 50
        static let actionButtonHorizontalPadding: CGFloat = 20
        /// Draws the `delete.left` glyph about 18.5 × 15.9 pt, its size in the design.
        static let deleteSymbolSize: CGFloat = 17.5
        static let disabledOpacity: CGFloat = 0.5
        static let enabledOpacity: CGFloat = 1.0

        static let deleteSymbol = "delete.left"
    }

    @Binding private var value: String
    private let showDecimalSeparator: Bool
    public var locale: Locale = .autoupdatingCurrent
    private let actionButtonText: String
    private let actionEnabled: Bool
    private let inProgress: Bool
    private let helperText: String?
    private let actionHandler: () -> Void

    public init(
        value: Binding<String>,
        showDecimalSeparator: Bool,
        locale: Locale = .autoupdatingCurrent,
        actionButtonText: String,
        actionEnabled: Bool,
        inProgress: Bool,
        helperText: String? = nil,
        actionHandler: @escaping () -> Void
    ) {
        self._value = value
        self.showDecimalSeparator = showDecimalSeparator
        self.locale = locale
        self.actionButtonText = actionButtonText
        self.actionEnabled = actionEnabled
        self.inProgress = inProgress
        self.helperText = helperText
        self.actionHandler = actionHandler
    }

    private var rows: [[String]] {
        NumericKeyboardLocaleSupport.rows(showDecimalSeparator: showDecimalSeparator, locale: locale)
    }

    public var body: some View {
        VStack(spacing: Layout.rootSpacing) {
            helperTextRow(helperText)
            keyboardRowsView
            actionButtonView
        }
        .padding(.horizontal, Layout.panelHorizontalPadding)
        .padding(.vertical, Layout.panelVerticalPadding)
        .frame(maxWidth: .infinity)
        // Rounded at the top only, and run down into the bottom safe area.
        //
        // `.continuous` because the circular default kinks visibly where the
        // arc meets the top edge at this radius.
        .background {
            UnevenRoundedRectangle(
                topLeadingRadius: Layout.panelCornerRadius,
                topTrailingRadius: Layout.panelCornerRadius,
                style: .continuous
            )
            .fill(Color.dash.secondaryBackground)
            .ignoresSafeArea(edges: .bottom)
        }
    }

    private var keyboardRowsView: some View {
        VStack(spacing: Layout.keyRowSpacing) {
            ForEach(rows, id: \.self) { row in
                keyboardRowView(row)
                    .opacity(inProgress ? Layout.disabledOpacity : Layout.enabledOpacity)
            }
        }
    }

    private func keyboardRowView(_ row: [String]) -> some View {
        HStack(spacing: Layout.keyColumnSpacing) {
            ForEach(row, id: \.self) { key in
                keyButtonView(key)
            }
        }
    }

    @ViewBuilder
    private func keyButtonView(_ key: String) -> some View {
        if key == NumericKeyboardLocaleSupport.Layout.emptyKey {
            // The bottom-left slot without a decimal separator: holds the
            // grid's shape, and is neither a key nor a VoiceOver stop.
            keyCell(Color.clear)
                .accessibilityHidden(true)
        } else {
            keyButton(key)
        }
    }

    private func keyButton(_ key: String) -> some View {
        Button {
            handleKeyPress(key)
        } label: {
            keyCell(keyContentView(key))
                // The whole key is the target, not only its glyph.
                .contentShape(Rectangle())
        }
        .disabled(inProgress)
    }

    /// One slot of the grid: an equal share of the row's width, one key tall.
    private func keyCell(_ content: some View) -> some View {
        content
            .frame(maxWidth: .infinity)
            .frame(height: Layout.keyHeight)
    }

    @ViewBuilder
    private func keyContentView(_ key: String) -> some View {
        if key == NumericKeyboardLocaleSupport.Layout.deleteKey {
            Image(dash: .system(Layout.deleteSymbol))
                .font(.system(size: Layout.deleteSymbolSize))
                .foregroundStyle(Color.dash.primaryText)
        } else {
            Text(key)
                .dashFont(.title3Medium)
                .foregroundStyle(Color.dash.primaryText)
        }
    }

    private var actionButtonView: some View {
        DashButton(
            text: actionButtonText,
            isEnabled: !value.isEmpty && actionEnabled,
            isLoading: inProgress,
            fillsWidth: true,
            size: .large,
            style: .filledBlue,
            action: actionHandler
        )
        .padding(.horizontal, Layout.actionButtonHorizontalPadding)
    }

    @ViewBuilder
    private func helperTextRow(_ text: String?) -> some View {
        if let text, !text.isEmpty {
            Text(text)
                .dashFont(.footnote)
                .foregroundStyle(Color.dash.secondaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        } else {
            EmptyView()
        }
    }

    private func handleKeyPress(_ key: String) {
        value = NumericKeyboardLocaleSupport.applyKeyPress(
            value: value,
            key: key,
            showDecimalSeparator: showDecimalSeparator,
            locale: locale
        )
    }
}

#if DEBUG

private let longHelperText = "The amount is converted at the current rate and may change slightly before the transfer is confirmed."

private struct NumericKeyboardPreview: View {
    private let showDecimalSeparator: Bool
    private let actionEnabled: Bool
    private let inProgress: Bool
    private let helperText: String?

    @State private var value: String

    init(
        initialValue: String = "12",
        showDecimalSeparator: Bool = true,
        actionEnabled: Bool = true,
        inProgress: Bool = false,
        helperText: String? = "Help text"
    ) {
        _value = State(initialValue: initialValue)
        self.showDecimalSeparator = showDecimalSeparator
        self.actionEnabled = actionEnabled
        self.inProgress = inProgress
        self.helperText = helperText
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            Text(value.isEmpty ? " " : value)
                .dashFont(.title1)
                .foregroundStyle(Color.dash.primaryText)
            Spacer()
            NumericKeyboardView(
                value: $value,
                showDecimalSeparator: showDecimalSeparator,
                locale: Locale(identifier: "uk_UA"),
                actionButtonText: "Continue",
                actionEnabled: actionEnabled,
                inProgress: inProgress,
                helperText: helperText,
                actionHandler: {}
            )
        }
        .background(Color.dash.primaryBackground)
    }
}

#Preview("Help text, decimal") {
    NumericKeyboardPreview()
}

#Preview("Help text, decimal, dark") {
    NumericKeyboardPreview()
        .preferredColorScheme(.dark)
}

#Preview("No help text, no decimal") {
    NumericKeyboardPreview(showDecimalSeparator: false, helperText: nil)
}

#Preview("No help text, no decimal, dark") {
    NumericKeyboardPreview(showDecimalSeparator: false, helperText: nil)
        .preferredColorScheme(.dark)
}

#Preview("In progress") {
    NumericKeyboardPreview(inProgress: true)
}

#Preview("In progress, dark") {
    NumericKeyboardPreview(inProgress: true)
        .preferredColorScheme(.dark)
}

#Preview("Long help text") {
    NumericKeyboardPreview(helperText: longHelperText)
}

#Preview("Long help text, dark") {
    NumericKeyboardPreview(helperText: longHelperText)
        .preferredColorScheme(.dark)
}

#Preview("Action disabled") {
    NumericKeyboardPreview(actionEnabled: false)
}

#Preview("Action disabled, dark") {
    NumericKeyboardPreview(actionEnabled: false)
        .preferredColorScheme(.dark)
}

#Preview("Empty value") {
    NumericKeyboardPreview(initialValue: "")
}

#Preview("Empty value, dark") {
    NumericKeyboardPreview(initialValue: "")
        .preferredColorScheme(.dark)
}

#endif
