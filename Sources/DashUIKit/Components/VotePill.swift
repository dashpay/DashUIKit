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

// MARK: - VotePill

/// A compact vote button: a count next to a thumb, or a chevron that expands a
/// group of requests.
///
/// ```swift
/// VotePill(kind: .block, count: 3, isSelected: true) { vote(.lock) }
/// VotePill(kind: .approve, count: 0, status: isSending ? .busy : .enabled) { vote(.approve) }
/// VotePill(kind: .expand(isExpanded: false)) { isExpanded.toggle() }
/// ```
///
/// The pill is value-driven. The host says whether the user's own vote is on it
/// (`isSelected`, the filled look) and, separately, whether it can be tapped
/// (`status`). The two combine: a vote in flight or a closed vote keeps showing
/// whose vote it is. `.busy` and `.disabled` ignore taps, so a vote cannot be
/// sent twice.
///
/// VoiceOver reads one button. The default label names the action ("Block",
/// "Approve", "Show requests") and the value is the count, plus "Sending" while
/// `.busy`. A host that can say more (the username, a localized plural) passes
/// `accessibilityLabel` and `accessibilityValue`; its value is read as given, so
/// a busy host value says "sending" in the host's own words.
public struct VotePill: View {

    /// What the pill does.
    public enum Kind: Hashable, Sendable {
        /// A vote against the request: red, thumb down.
        case block
        /// A vote for the request: blue, thumb up.
        case approve
        /// Shows or hides the requests grouped under one name: gray chevron, no count.
        case expand(isExpanded: Bool)
    }

    /// Whether the pill reacts to taps.
    public enum Status: Hashable, Sendable {
        /// Tappable.
        case enabled
        /// A vote is being sent: a spinner replaces the icon, taps are ignored.
        case busy
        /// Not available: the pill's look at 40% opacity, taps are ignored.
        case disabled
    }

    let kind: Kind
    let count: Int
    let isSelected: Bool
    let status: Status
    let accessibilityLabel: String?
    let accessibilityValue: String?
    let action: () -> Void

    @Environment(\.locale) private var locale
    /// `false` when an ancestor is `.disabled`. Read here, above the pill's own
    /// `.disabled`, so it reflects the ancestor only. The pill's button style
    /// draws no disabled look, so the fade has to follow this too.
    @Environment(\.isEnabled) private var isEnabled

    /// `isSelected` draws the filled look (the user's own vote). It has no effect
    /// on an `.expand` pill.
    public init(
        kind: Kind,
        count: Int = 0,
        isSelected: Bool = false,
        status: Status = .enabled,
        accessibilityLabel: String? = nil,
        accessibilityValue: String? = nil,
        action: @escaping () -> Void
    ) {
        self.kind = kind
        self.count = count
        self.isSelected = isSelected
        self.status = status
        self.accessibilityLabel = accessibilityLabel
        self.accessibilityValue = accessibilityValue
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            pill
                // The design draws a 40 pt pill and its rows are laid out
                // around 40 pt. The tap area reaches 2 pt past each edge
                // (44 pt) without taking layout space.
                .padding(.vertical, 2)
                .contentShape(Rectangle())
                .padding(.vertical, -2)
        }
        // Its own style: the system plain style dims a disabled label on top
        // of the pill's own fade, and would grey out the busy spinner.
        .buttonStyle(VotePillButtonStyle())
        .disabled(!statusAllowsTaps)
        .accessibilityLabel(Text(resolvedAccessibilityLabel))
        .accessibilityValue(Text(resolvedAccessibilityValue))
        .accessibilityAddTraits(showsSelected ? .isSelected : [])
    }

    private var pill: some View {
        HStack(spacing: 6) {
            if showsCount {
                Text(Self.displayCount(count, locale: locale))
                    .dashFont(.subheadMedium)
                    .monospacedDigit()
                    .lineLimit(1)
                    .fixedSize()
            }
            icon
        }
        .foregroundStyle(contentColor)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .frame(minWidth: 70, minHeight: 40)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .opacity(Self.isFaded(status: status, environmentEnabled: isEnabled) ? Self.disabledOpacity : 1)
    }

    @ViewBuilder
    private var icon: some View {
        if status == .busy {
            ProgressView()
                .controlSize(.small)
                .tint(contentColor)
                .frame(width: 16.13, height: 14)
        } else {
            switch kind {
            case .approve:
                thumb
                    // The thumb sits 2 pt above centre in the design.
                    .offset(y: -2)
            case .block:
                thumb
                    // The design has no thumb-down glyph: it turns the thumb-up
                    // over, and the turned glyph sits 1 pt below centre.
                    .rotationEffect(.degrees(180))
                    .offset(y: 1)
            case .expand(let isExpanded):
                ChevronIcon(
                    direction: isExpanded ? .up : .down,
                    size: 11,
                    color: contentColor,
                    lineWidth: 2
                )
            }
        }
    }

    private var thumb: some View {
        DashIcon.Voting.thumbUp.image
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(width: 16.13, height: 14)
    }

    // MARK: Appearance

    private var showsCount: Bool {
        if case .expand = kind { return false }
        return true
    }

    /// Whether the pill's own status lets it take taps: a busy one must not
    /// send the same vote twice, a disabled one cannot vote at all. A disabled
    /// ancestor blocks taps on top of this, as for any SwiftUI control.
    var statusAllowsTaps: Bool { status == .enabled }

    /// A disabled pill keeps its own colours at this opacity. The tinted-disabled
    /// button tokens lose the count against the dark background.
    static let disabledOpacity: Double = 0.4

    /// Faded when the pill is disabled, or when an ancestor disabled it — the
    /// pill's button style replaces the system dimming, so it fades itself. A
    /// busy pill fades with a disabled ancestor too, so a frozen row reads as
    /// frozen; on its own it keeps its look, its spinner saying why.
    static func isFaded(status: Status, environmentEnabled: Bool) -> Bool {
        status == .disabled || !environmentEnabled
    }

    /// The filled look: `isSelected` on a vote kind.
    var showsSelected: Bool {
        if case .expand = kind { return false }
        return isSelected
    }

    private var backgroundColor: Color {
        switch kind {
        case .block: return showsSelected ? Color.dash.red : Color.dash.redAlpha5
        case .approve: return showsSelected ? Color.dash.blue : Color.dash.blueAlpha5
        case .expand: return Color.dash.gray300Alpha10
        }
    }

    private var contentColor: Color {
        switch kind {
        case .block: return showsSelected ? Color.dash.whiteText : Color.dash.errorText
        case .approve: return showsSelected ? Color.dash.whiteText : Color.dash.blueText
        case .expand: return Color.dash.gray300
        }
    }

    // MARK: Accessibility

    var resolvedAccessibilityLabel: String {
        if let accessibilityLabel { return accessibilityLabel }
        switch kind {
        case .block:
            return NSLocalizedString("Block", bundle: .module, comment: "DashUIKit")
        case .approve:
            return NSLocalizedString("Approve", bundle: .module, comment: "DashUIKit")
        case .expand(let isExpanded):
            return isExpanded
                ? NSLocalizedString("Hide requests", bundle: .module, comment: "DashUIKit")
                : NSLocalizedString("Show requests", bundle: .module, comment: "DashUIKit")
        }
    }

    var resolvedAccessibilityValue: String { accessibilityValue(locale: locale) }

    /// A host value is read as given: the host knows the status and speaks its
    /// own language, so it says "sending" itself. DashUIKit ships no
    /// translations, and an English word appended to a translated value would
    /// mix languages. The default value is the count, plus "Sending" ("Loading"
    /// for an expand pill) while `.busy`.
    func accessibilityValue(locale: Locale) -> String {
        if let accessibilityValue { return accessibilityValue }
        guard status == .busy else {
            return showsCount ? max(count, 0).formatted(.number.locale(locale)) : ""
        }
        guard showsCount else {
            return NSLocalizedString("Loading", bundle: .module, comment: "DashUIKit")
        }
        return max(count, 0).formatted(.number.locale(locale)) + ", "
            + NSLocalizedString("Sending", bundle: .module, comment: "DashUIKit")
    }

    /// The count as drawn: negative counts show as 0, and four digits and more
    /// collapse to "999+" so the pill grows only a few points past its 70 pt
    /// minimum. VoiceOver still reads the exact number.
    static func displayCount(_ count: Int, locale: Locale) -> String {
        // The view's locale digits (Arabic, Devanagari, …); the cap never needs
        // grouping. The capped form is a left-to-right isolate, so the "+"
        // stays after the digits in right-to-left text.
        let style = IntegerFormatStyle<Int>.number.locale(locale)
        guard count > 999 else { return max(count, 0).formatted(style) }
        return "\u{2066}" + 999.formatted(style) + "+\u{2069}"
    }
}

/// Press feedback only. The pill draws its own disabled look, so the system's
/// disabled dimming is not wanted here.
private struct VotePillButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

// MARK: - Previews

#if DEBUG

private struct VotePillPreviewGrid: View {
    private let rows: [(String, Bool, VotePill.Status)] = [
        ("idle", false, .enabled), ("selected", true, .enabled),
        ("busy", false, .busy), ("busy, mine", true, .busy),
        ("disabled", false, .disabled), ("disabled, mine", true, .disabled),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(rows, id: \.0) { name, isSelected, status in
                HStack(spacing: 10) {
                    Text(name)
                        .dashFont(.caption1)
                        .foregroundStyle(Color.dash.tertiaryText)
                        .frame(width: 60, alignment: .leading)
                    VotePill(kind: .block, count: 1, isSelected: isSelected, status: status) {}
                    VotePill(kind: .approve, count: 12, isSelected: isSelected, status: status) {}
                    VotePill(kind: .expand(isExpanded: false), status: status) {}
                    VotePill(kind: .expand(isExpanded: true), status: status) {}
                }
            }
            HStack(spacing: 10) {
                Text("large")
                    .dashFont(.caption1)
                    .foregroundStyle(Color.dash.tertiaryText)
                    .frame(width: 60, alignment: .leading)
                VotePill(kind: .block, count: 999) {}
                VotePill(kind: .approve, count: 12_345) {}
            }
        }
        .padding(20)
        .background(Color.dash.secondaryBackground)
    }
}

/// The row from Figma `3830:20728`: what the pill sits in.
private struct VotePillPreviewRow: View {
    var body: some View {
        HStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 0) {
                Text(verbatim: "mikedoe")
                    .dashFont(.subheadMedium)
                    .foregroundStyle(Color.dash.primaryText)
                Text(verbatim: "Link included")
                    .dashFont(.footnote)
                    .foregroundStyle(Color.dash.tertiaryText)
            }
            .padding(.leading, 4)
            .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 10) {
                VotePill(kind: .block, count: 0) {}
                VotePill(kind: .approve, count: 1, isSelected: true) {}
            }
        }
        .padding(.leading, 10)
        .padding(.vertical, 8)
        .modifier(MenuViewModifier(shadowRadius: 20))
        .padding(20)
        .background(Color.dash.primaryBackground)
    }
}

#Preview("States") {
    VotePillPreviewGrid()
}

#Preview("States, dark") {
    VotePillPreviewGrid()
        .preferredColorScheme(.dark)
}

#Preview("In a row") {
    VotePillPreviewRow()
}

#Preview("In a row, dark") {
    VotePillPreviewRow()
        .preferredColorScheme(.dark)
}

#Preview("Accessibility XXL") {
    VotePillPreviewGrid()
        .dynamicTypeSize(.accessibility3)
}

#Preview("Inside a disabled ancestor") {
    VotePillPreviewGrid()
        .disabled(true)
}

#Preview("Right to left") {
    VotePillPreviewRow()
        .environment(\.layoutDirection, .rightToLeft)
}

#endif
