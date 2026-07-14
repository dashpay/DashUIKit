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

// MARK: - TransactionView

/// Transaction row: a leading icon (with an optional status badge in the bottom-trailing corner),
/// a title / time / optional detail line, and a trailing Dash amount (+ optional fiat). Pass
/// `action` to make the whole row a tappable button; omit it for a static row.
///
/// The amount is a raw duff value (`Int64`, 10⁸ per Dash) rendered via `DashAmount`, mirroring
/// `ConverterCardItem.dashBalance`. Icons are `DashIconSource` (asset in the DashUIKit bundle, an
/// SF Symbol, or a runtime `UIImage`); pass `iconView` for a custom / remotely-loaded main icon.
@available(iOS 14, macOS 11, *)
public struct TransactionView: View {

    private enum Layout {
        static let rowSpacing: CGFloat = 16
        static let iconSize: CGFloat = 30
        static let iconCornerRadius: CGFloat = 12
        static let badgeSize: CGFloat = 14
        static let badgeRing: CGFloat = 2
        static let vPadding: CGFloat = 12
        static let hPadding: CGFloat = 10
    }

    // Leading
    /// Static leading icon. Ignored when `iconView` is non-nil.
    public var icon: DashIconSource?
    /// Custom leading view (e.g. a remotely-loaded coin icon). Takes precedence over `icon`.
    public var iconView: AnyView?
    /// Small status badge pinned to the icon's bottom-trailing corner (e.g. processing / locked).
    public var secondaryIcon: DashIconSource?

    // Central
    /// Optional header above the title, e.g. a grouped-set count like "3 transactions".
    public var topText: String?
    public var title: String
    /// Secondary line, typically the time ("8:34 AM").
    public var subtitle: String?
    /// Optional extra state/detail line shown next to the subtitle.
    public var details: String?

    // Trailing
    /// Dash amount in duffs (10⁸ per Dash). Negative = outgoing.
    public var dashAmount: Int64
    public var amountSign: DashAmountSign
    public var fiat: String?
    /// Short status shown immediately before the amount, e.g. "Locked" for a coinbase reward that
    /// has not matured yet. Rendered in the warning tone, since it qualifies the amount.
    public var trailingStatusText: String?

    /// When set, the whole row is a plain-styled button. `nil` renders a non-interactive row.
    public var action: (() -> Void)?

    public init(
        icon: DashIconSource? = nil,
        iconView: AnyView? = nil,
        secondaryIcon: DashIconSource? = nil,
        topText: String? = nil,
        title: String,
        subtitle: String? = nil,
        details: String? = nil,
        dashAmount: Int64 = 0,
        amountSign: DashAmountSign = .negativeOnly,
        fiat: String? = nil,
        trailingStatusText: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.iconView = iconView
        self.secondaryIcon = secondaryIcon
        self.topText = topText
        self.title = title
        self.subtitle = subtitle
        self.details = details
        self.dashAmount = dashAmount
        self.amountSign = amountSign
        self.fiat = fiat
        self.trailingStatusText = trailingStatusText
        self.action = action
    }

    public var body: some View {
        if let action {
            Button(action: action) { content }
                .buttonStyle(.plain)
        } else {
            content
        }
    }

    private var content: some View {
        HStack(spacing: Layout.rowSpacing) {
            iconWrap
            infoWrap
        }
        .padding(.vertical, Layout.vPadding)
        .padding(.horizontal, Layout.hPadding)
        .contentShape(Rectangle())
    }

    // MARK: - Icon

    private var iconWrap: some View {
        // `.overlay(_:alignment:)` (iOS 13) rather than `.overlay(alignment:content:)` (iOS 15),
        // so the component stays usable at the iOS 14 deployment target.
        mainIcon
            .frame(width: Layout.iconSize, height: Layout.iconSize)
            .clipShape(RoundedRectangle(cornerRadius: Layout.iconCornerRadius, style: .continuous))
            .overlay(
                secondaryBadge
                    .offset(x: 3,y: 3),
                alignment: .bottomTrailing
            )
    }

    @ViewBuilder
    private var secondaryBadge: some View {
        if let secondaryIcon {
            Image(dash: secondaryIcon)
                .resizable()
                .scaledToFit()
                .frame(width: Layout.badgeSize, height: Layout.badgeSize)
                .padding(Layout.badgeRing)
                .background(Circle().fill(Color.dash.secondaryBackground))
                // Nudge the badge to sit on the icon's corner.
                .offset(x: Layout.badgeRing, y: Layout.badgeRing)
        }
    }

    @ViewBuilder
    private var mainIcon: some View {
        if let iconView {
            iconView
        } else if let icon {
            Image(dash: icon)
                .resizable()
                .scaledToFit()
        } else {
            Color.clear
        }
    }

    // MARK: - Info

    private var infoWrap: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let topText {
                Text(topText)
                    .dashFont(.footnote)
                    .foregroundColor(Color.dash.secondaryText)
            }

            HStack(alignment: .center, spacing: 8) {
                VStack(alignment: .leading, spacing: 1) {
                    Text(title)
                        .dashFont(.footnoteMedium)
                        .foregroundColor(Color.dash.primaryText)

                    HStack(spacing: 8) {
                        if let subtitle {
                            Text(subtitle)
                                .dashFont(.footnote)
                                .foregroundColor(Color.dash.secondaryText)
                        }

                        // Badge
                        if let details {
                            HStack(spacing: 2) {
                                Text(details)
                                    .dashFont(.caption1Medium)
                                    .foregroundColor(Color.dash.blueText)
                            }
                            .padding(.horizontal, 4)
                            .background(Color.dash.blueAlpha10)
                            .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                trailingAmount
            }
        }
    }

    private var trailingAmount: some View {
        VStack(alignment: .trailing, spacing: 1) {
            HStack(spacing: 4) {
                if let trailingStatusText {
                    Text(trailingStatusText)
                        .dashFont(.caption1Medium)
                        .foregroundColor(Color.dash.orange)
                }

                DashAmount(amount: dashAmount, sign: amountSign)
                    .foregroundColor(Color.dash.primaryText)
            }

            if let fiat {
                Text(fiat)
                    .dashFont(.footnote)
                    .foregroundColor(Color.dash.secondaryText)
            }
        }
    }
}

// MARK: - Previews

#if DEBUG

@available(iOS 17, macOS 14, *)
#Preview("Received") {
    TransactionView(
        icon: .system("arrow.down.circle.fill"),
        title: "Received",
        subtitle: "8:34 AM",
        dashAmount: 6_791_000,
        amountSign: .always,
        fiat: "$ 1.87"
    )
    .padding(.horizontal)
    .background(Color.dash.primaryBackground)
}

@available(iOS 17, macOS 14, *)
#Preview("Sent + badge") {
    TransactionView(
        icon: .system("arrow.up.circle.fill"),
        secondaryIcon: .system("clock.fill"),
        title: "Sent",
        subtitle: "8:34 AM",
        details: "Processing",
        dashAmount: -1_250_000,
        amountSign: .negativeOnly,
        fiat: "$ 0.34"
    )
    .padding(.horizontal)
    .background(Color.dash.primaryBackground)
}

@available(iOS 17, macOS 14, *)
#Preview("Grouped set") {
    TransactionView(
        icon: .system("circle.grid.2x2.fill"),
        topText: "3 transactions",
        title: "Mixing Transactions",
        subtitle: "8:34 AM",
        dashAmount: 50_000_000,
        amountSign: .none
    )
    .padding(.horizontal)
    .background(Color.dash.primaryBackground)
}

@available(iOS 17, macOS 14, *)
#Preview("Locked reward") {
    TransactionView(
        icon: .custom("transaction-mining"),
        title: "Reward",
        subtitle: "8:34 AM",
        dashAmount: 250_000_000,
        amountSign: .always,
        fiat: "$ 68.75",
        trailingStatusText: "Locked"
    )
    .padding(.horizontal)
    .background(Color.dash.primaryBackground)
}

#endif
