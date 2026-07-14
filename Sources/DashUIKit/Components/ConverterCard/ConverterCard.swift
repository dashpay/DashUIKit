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

// MARK: - ConverterCard

/// A two-row card (source → destination) with an arrow badge centered on the seam between the
/// rows. Each row is a `MenuItem` wrapped in rounded card chrome.
///
/// Pass `onSwap` to show a tappable `diagonal-up-down` button; omit it (or pass `nil`) for a
/// static `arrow-down` indicator when the card is non-swappable.
@available(iOS 14, macOS 11, *)
public struct ConverterCard: View {

    private enum Layout {
        static let cardSpacing: CGFloat = 5
    }

    private let fromItem: ConverterCardItem
    private let toItem: ConverterCardItem
    private let onSwap: (() -> Void)?

    @State private var topRowHeight: CGFloat = 74

    public init(
        fromItem: ConverterCardItem,
        toItem: ConverterCardItem,
        onSwap: (() -> Void)? = nil
    ) {
        self.fromItem = fromItem
        self.toItem = toItem
        self.onSwap = onSwap
    }

    private var orderedItems: [ConverterCardItem] { [fromItem, toItem] }

    public var body: some View {
        VStack(spacing: Layout.cardSpacing) {
            ForEach(Array(orderedItems.enumerated()), id: \.element.id) { index, item in
                ConverterCardRow(slot: index == 0 ? .top : .bottom) {
                    row(item: item)
                }
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.82), value: fromItem.id)
        .overlay(
            ConverterArrowBadge(onSwap: onSwap)
                // Anchor the badge's CENTER to the overlay's .top point, so the offset below
                // places the badge centre exactly on the seam — independent of the badge's height.
                .alignmentGuide(VerticalAlignment.top) { $0[VerticalAlignment.center] }
                .offset(y: seamY),
            alignment: .top
        )
        .onPreferenceChange(ConverterRowHeightKey.self) { heights in
            if let h = heights[.top], h > 0 { topRowHeight = h }
        }
    }

    /// Centre of the gap between the two rows. Depends only on the top row height and the stack
    /// spacing — never on the bottom row — so it stays correct when the rows differ in height.
    private var seamY: CGFloat { topRowHeight + Layout.cardSpacing / 2 }

    /// Row layout mirrors `MenuItem` (icon 30pt, 10pt padding) but stays flexible enough for a
    /// custom icon/trailing view and a multi-line subtitle.
    private func row(item: ConverterCardItem) -> some View {
        HStack(spacing: 10) {
            leading(item)

            VStack(alignment: .leading, spacing: 1) {
                Text(item.title)
                    .dashFont(.subheadMedium)
                    .foregroundColor(Color.dash.primaryText)

                if let subtitle = item.subtitle {
                    Text(subtitle)
                        .dashFont(.footnote)
                        .foregroundColor(Color.dash.secondaryText)
                        .lineLimit(item.subtitleLineLimit)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.leading, 6)

            Spacer(minLength: 8)

            trailing(item)
        }
        .padding(10)
    }

    @ViewBuilder
    private func leading(_ item: ConverterCardItem) -> some View {
        if let iconView = item.iconView {
            iconView.frame(width: 30, height: 30)
        } else if let icon = item.icon {
            Image(dash: icon)
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
        }
    }

    @ViewBuilder
    private func trailing(_ item: ConverterCardItem) -> some View {
        if let trailingView = item.trailingView {
            trailingView
        } else if item.showsBalance {
            VStack(alignment: .trailing, spacing: 1) {
                DashAmount(amount: item.dashBalance, sign: .none)
                    .foregroundColor(Color.dash.primaryText)

                if item.dashBalance != 0, let fiat = item.fiat {
                    Text(fiat)
                        .dashFont(.footnote)
                        .foregroundColor(Color.dash.secondaryText)
                }
            }
        }
    }
}

#if DEBUG
@available(iOS 14, macOS 11, *)
struct ConverterCard_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ConverterCard(
                fromItem: ConverterCardItem(
                    icon: .system("bitcoinsign.circle.fill"),
                    title: "Coinbase",
                    subtitle: "Dash Wallet",
                    dashBalance: 420_000_000,
                    fiat: "$410.00"
                ),
                toItem: ConverterCardItem(
                    icon: .system("d.circle.fill"),
                    title: "Dash",
                    subtitle: "Dash Wallet",
                    dashBalance: 123_456_789,
                    fiat: "$120.00",
                    showsBalance: false
                ),
                onSwap: {}
            )
            .previewDisplayName("Swappable")

            ConverterCard(
                fromItem: ConverterCardItem(
                    icon: .system("d.circle.fill"),
                    title: "Dash",
                    dashBalance: 500_000_000,
                    fiat: "$490.00"
                ),
                toItem: ConverterCardItem(
                    icon: .system("arrow.right.circle.fill"),
                    title: "Destination",
                    showsBalance: false
                )
            )
            .previewDisplayName("Static (no swap)")

            // Unequal rows — badge must stay on the seam when the bottom row is taller.
            ConverterCard(
                fromItem: ConverterCardItem(
                    icon: .system("bitcoinsign.circle.fill"),
                    title: "Coinbase",
                    dashBalance: 420_000_000,
                    fiat: "$410.00"
                ),
                toItem: ConverterCardItem(
                    icon: .system("d.circle.fill"),
                    title: "Dash",
                    subtitle: "XqK7pMn2rV9wL4tYeB8dN3cF6hJsA1uZ — long address wraps and makes this row taller than the top row",
                    subtitleLineLimit: nil,
                    showsBalance: false
                ),
                onSwap: {}
            )
            .previewDisplayName("Unequal rows (tall bottom)")
        }
        .padding()
        .background(Color.dash.primaryBackground)
    }
}

@available(iOS 14, macOS 11, *)
struct SwapPreview: View {
    @State private var swapped = false

    var coinbase: ConverterCardItem {
        ConverterCardItem(id: "coinbase", icon: .system("bitcoinsign.circle.fill"),
                          title: "Coinbase", dashBalance: 131_715_000, fiat: "$0.04")
    }
    var dash: ConverterCardItem {
        ConverterCardItem(id: "dash", icon: .system("d.circle.fill"),
                          title: "Dash", subtitle: "Dash Wallet",
                          dashBalance: 17_351_000, fiat: "$6.04")
    }

    var body: some View {
        ConverterCard(
            fromItem: swapped ? dash : coinbase,
            toItem: swapped ? coinbase : dash,
            onSwap: { swapped.toggle() }
        )
        .padding()
        .background(Color.dash.primaryBackground)
    }
}

@available(iOS 17, macOS 14, *)
#Preview("Swap animation") { SwapPreview() }
#endif
