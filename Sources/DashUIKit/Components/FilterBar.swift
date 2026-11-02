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

// MARK: - FilterBar

/// The bottom bar of a filtered list: a round filter button and a centred
/// "Filtered by / <value>" caption. Tapping the button or the caption calls
/// `action`. VoiceOver reads the bar as one button, "Filters", whose value is the
/// caption.
///
/// ```swift
/// List { … }
///     .safeAreaInset(edge: .bottom) {
///         FilterBar(value: "New to old") { showFilters = true }
///     }
/// ```
///
/// The bar adds no space for the home indicator: placed in
/// `.safeAreaInset(edge: .bottom)`, the system inset provides it.
///
/// `replacement` takes the place of the caption while it is non-nil, for
/// example a `Toast` confirming an action, so the two never overlap. It gets the
/// caption's 44 pt row and is clipped to it; its text gets a one-line default
/// (shrunk a little, then cut at the tail), so keep it short, with what
/// matters first. Showing and hiding it fades. To fade one replacement into
/// the next, give each its own `.id` and change it inside `withAnimation`:
///
/// ```swift
/// FilterBar(value: sortName,
///           replacement: toast.map { Toast(style: .success, message: $0.message).id($0.id) }) {
///     showFilters = true
/// }
/// ```
public struct FilterBar<Replacement: View>: View {

    let value: String
    let title: String?
    let filterAccessibilityLabel: String?
    let action: () -> Void
    let replacement: Replacement?

    /// `value` names the active sort or filter and should not be empty. `title`
    /// replaces the "Filtered by" line, for a host that localizes its strings.
    public init(
        value: String,
        title: String? = nil,
        filterAccessibilityLabel: String? = nil,
        replacement: Replacement?,
        action: @escaping () -> Void
    ) {
        self.value = value
        self.title = title
        self.filterAccessibilityLabel = filterAccessibilityLabel
        self.action = action
        self.replacement = replacement
    }

    private var hasReplacement: Bool { replacement != nil }

    /// The row every column shares: the filter button's tap target and the
    /// centre column the caption or replacement lives in.
    static var rowHeight: CGFloat { 44 }

    public var body: some View {
        HStack(spacing: 14) {
            Button(action: action) {
                filterCircle
                    // 40 pt column, 44 pt tall tap target around the 30 pt circle.
                    .frame(width: 40, height: Self.rowHeight)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text(filterAccessibilityLabel
                ?? NSLocalizedString("Filters", bundle: .module, comment: "DashUIKit")))
            // Title and value as two phrases, so the host's own title keeps its
            // word order in any language.
            .accessibilityValue(Text(captionTitle + ", " + value))

            // The centre column: the caption, or the replacement in its place.
            // Both are centred on the bar, between two 40 pt columns.
            ZStack {
                if let replacement {
                    replacement
                        // One line, so a toast's message fits the row: it
                        // shrinks a little before it is cut.
                        .lineLimit(1)
                        // 13 pt shrinks to 11 pt at most, the smallest legible size.
                        .minimumScaleFactor(0.85)
                        .transition(.opacity)
                } else {
                    Button(action: action) {
                        caption
                            // The whole centre column, not just the text, answers taps.
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    // The filter button already speaks for the bar.
                    .accessibilityHidden(true)
                    .transition(.opacity)
                }
            }
            // The row's 44 pt whatever is in it, so a replacement taller than
            // the caption cannot grow the bar and shift the list above it.
            .frame(maxWidth: .infinity)
            .frame(height: Self.rowHeight)
            .clipped()
            // Clipping hides the overflow; this keeps it from taking taps too.
            .contentShape(Rectangle())
            .animation(.easeInOut(duration: 0.2), value: hasReplacement)

            Color.clear
                .frame(width: 40)
        }
        // The bar keeps its own height in any container (a safe-area inset or a
        // stack offers more), and only takes the width.
        .fixedSize(horizontal: false, vertical: true)
        .padding(.horizontal, 20)
        // 7 + 44 + 3: the design's 50 pt row (8 + 34 caption + 8) under a 4 pt
        // top edge, while the button gets a 44 pt target.
        .padding(.top, 7)
        .padding(.bottom, 3)
        .frame(maxWidth: .infinity)
        .background(Color.dash.secondaryBackground)
    }

    private var filterCircle: some View {
        DashIcon.Common.filterS.image
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(width: 13, height: 13)
            .foregroundStyle(Color.dash.buttonFilledBlueContent)
            .frame(width: 30, height: 30)
            .background(Circle().fill(Color.dash.buttonFilledBlueBackground))
    }

    private var caption: some View {
        VStack(spacing: 0) {
            Text(captionTitle)
                .dashFont(.caption1)
                .foregroundStyle(Color.dash.tertiaryText)
                .lineLimit(1)
                .truncationMode(.tail)
            Text(value)
                .dashFont(.caption1)
                .foregroundStyle(Color.dash.primaryText)
                .lineLimit(1)
                .truncationMode(.tail)
        }
        .multilineTextAlignment(.center)
    }

    private var captionTitle: String {
        title ?? NSLocalizedString("Filtered by", bundle: .module, comment: "DashUIKit")
    }
}

public extension FilterBar where Replacement == EmptyView {
    init(
        value: String,
        title: String? = nil,
        filterAccessibilityLabel: String? = nil,
        action: @escaping () -> Void
    ) {
        self.init(
            value: value,
            title: title,
            filterAccessibilityLabel: filterAccessibilityLabel,
            replacement: nil,
            action: action
        )
    }
}

// MARK: - Previews

#if DEBUG

private struct FilterBarPreview<Replacement: View>: View {
    let bar: FilterBar<Replacement>

    var body: some View {
        VStack(spacing: 0) {
            Color.dash.primaryBackground
            bar
        }
        .frame(height: 160)
    }
}

#Preview("Plain") {
    FilterBarPreview(bar: FilterBar(value: "New to old") {})
}

#Preview("Plain, dark") {
    FilterBarPreview(bar: FilterBar(value: "New to old") {})
        .preferredColorScheme(.dark)
}

#Preview("Long value") {
    FilterBarPreview(bar: FilterBar(
        value: "I have not voted · Only duplicates · Only requests with links") {})
}

#if canImport(UIKit)
#Preview("With a toast") {
    FilterBarPreview(bar: FilterBar(
        value: "New to old",
        replacement: Toast(style: .success, message: "Voted johndoe username")) {})
}

#Preview("With a long toast") {
    FilterBarPreview(bar: FilterBar(
        value: "New to old",
        replacement: Toast(
            style: .success,
            message: "Voted averyveryverylongusername_2026 username on every request")) {})
}

#Preview("With a toast, dark") {
    FilterBarPreview(bar: FilterBar(
        value: "New to old",
        replacement: Toast(style: .success, message: "Voted johndoe username")) {})
    .preferredColorScheme(.dark)
}
#endif

#endif
