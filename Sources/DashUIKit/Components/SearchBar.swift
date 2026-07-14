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

// MARK: - Public shell (iOS 14+)

@available(iOS 14, *)
public struct SearchBar: View {
    @Binding private var text: String
    private let placeholder: String

    public init(
        text: Binding<String>,
        placeholder: String? = nil
    ) {
        self._text = text
        self.placeholder = placeholder
            ?? NSLocalizedString("Search", bundle: .module, comment: "DashUIKit")
    }

    public var body: some View {
        if #available(iOS 15, *) {
            SearchBarFocused(text: $text, placeholder: placeholder)
        } else {
            SearchBarLegacy(text: $text, placeholder: placeholder)
        }
    }
}

// MARK: - iOS 15+ (focus-driven cancel button)

@available(iOS 15, *)
private struct SearchBarFocused: View {
    private enum Layout {
        static let fieldHeight: CGFloat = 40
        static let fieldCornerRadius: CGFloat = 14
        static let fieldHorizontalPadding: CGFloat = 14
        static let fieldSpacing: CGFloat = 10
        static let cancelHorizontalPadding: CGFloat = 12
        static let cancelVerticalPadding: CGFloat = 6
        static let animationDuration: TimeInterval = 0.25
    }

    @Binding var text: String
    let placeholder: String

    @FocusState private var isFocused: Bool
    @State private var isEditing: Bool = false

    var body: some View {
        HStack(spacing: 0) {
            HStack(spacing: Layout.fieldSpacing) {
                magnifyingGlass
                searchField
                clearButton
            }
            .padding(.horizontal, Layout.fieldHorizontalPadding)
            .frame(height: Layout.fieldHeight)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.dash.searchBackground)
            .clipShape(RoundedRectangle(cornerRadius: Layout.fieldCornerRadius, style: .continuous))

            if isEditing {
                cancelButton
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: Layout.animationDuration), value: isEditing)
        .onAppear {
            isEditing = isFocused
        }
        .onChange(of: isFocused) { focused in
            withAnimation(.easeInOut(duration: Layout.animationDuration)) {
                isEditing = focused
            }
        }
    }

    private var magnifyingGlass: some View {
        Image(dash: .custom("searchbar-magnifyingglass-icon", bundle: .dashUIKit))
            .resizable()
            .scaledToFit()
            .frame(maxHeight: 15)
    }

    @ViewBuilder
    private var clearButton: some View {
        if !text.isEmpty {
            Button(
                action: { text = "" },
                label: {
                    Image(dash: .custom("searchbar-xmark-icon", bundle: .dashUIKit))
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 15)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
            )
            .accessibilityLabel(Text(NSLocalizedString("Clear", bundle: .module, comment: "DashUIKit")))
        }
    }

    private var cancelButton: some View {
        Button(
            action: {
                text = ""
                withAnimation(.easeInOut(duration: Layout.animationDuration)) {
                    isEditing = false
                }
                isFocused = false
            },
            label: {
                Text(NSLocalizedString("Cancel", bundle: .module, comment: "DashUIKit"))
                    .font(Font.dash.footnote.weight(.semibold))
                    .padding(.horizontal, Layout.cancelHorizontalPadding)
                    .padding(.vertical, Layout.cancelVerticalPadding)
            }
        )
        .tint(Color.dash.primaryText as Color?)
    }

    @ViewBuilder
    private var searchField: some View {
        if #available(iOS 17.0, *) {
            TextField(
                text: $text,
                prompt: Text(placeholder)
                    .font(Font.dash.subhead)
                    .foregroundStyle(Color.dash.black1000Alpha30)
            ) {
                EmptyView()
            }
            .focused($isFocused)
            .tint(Color.dash.primaryText as Color?)
        } else {
            TextField(placeholder, text: $text)
                .focused($isFocused)
                .tint(Color.dash.primaryText as Color?)
                .foregroundColor(Color.dash.primaryText)
        }
    }
}

// MARK: - iOS 14 fallback (no focus state — static bar without cancel animation)

@available(iOS 14, *)
private struct SearchBarLegacy: View {
    private enum Layout {
        static let fieldHeight: CGFloat = 40
        static let fieldCornerRadius: CGFloat = 14
        static let fieldHorizontalPadding: CGFloat = 14
        static let fieldSpacing: CGFloat = 10
    }

    @Binding var text: String
    let placeholder: String

    var body: some View {
        HStack(spacing: Layout.fieldSpacing) {
            magnifyingGlass
            TextField(placeholder, text: $text)
                .accentColor(Color.dash.primaryText)
                .foregroundColor(Color.dash.primaryText)
            clearButton
        }
        .padding(.horizontal, Layout.fieldHorizontalPadding)
        .frame(height: Layout.fieldHeight)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.dash.searchBackground)
        .clipShape(RoundedRectangle(cornerRadius: Layout.fieldCornerRadius, style: .continuous))
    }

    private var magnifyingGlass: some View {
        Image(dash: .custom("searchbar-magnifyingglass-icon", bundle: .dashUIKit))
            .resizable()
            .scaledToFit()
            .frame(maxHeight: 15)
    }

    @ViewBuilder
    private var clearButton: some View {
        if !text.isEmpty {
            Button(
                action: { text = "" },
                label: {
                    Image(dash: .custom("searchbar-xmark-icon", bundle: .dashUIKit))
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 15)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
            )
            .accessibilityLabel(Text(NSLocalizedString("Clear", bundle: .module, comment: "DashUIKit")))
        }
    }
}

// MARK: - Preview

#if DEBUG

@available(iOS 17, macOS 14, *)
#Preview {
    @Previewable @State var text = ""
    SearchBar(text: $text)
        .padding()
}

#endif // DEBUG
#endif // canImport(UIKit)
