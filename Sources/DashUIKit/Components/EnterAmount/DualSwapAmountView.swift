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

// MARK: - DualSwapAmountView

/// Thin wrapper around `SwapAmountView`'s animated dual-swap mode.
///
/// `SwapAmountView` renders two persistent rows in a `ZStack`:
/// - **A row** always shows `primaryAmount` / `primaryCurrency`.
/// - **B row** always shows `secondaryAmount` / `secondaryCurrency` (+ optional chevron).
///
/// When `isPrimarySelected` flips, both rows animate their `scaleEffect` and `offset`
/// simultaneously, producing a continuous grow-rise / shrink-fall effect without any font swap
/// or view recreation. The content in each row never changes — only the visual position does.
///
/// Tapping anywhere in the container (except the chevron) fires `onSwap`.
@available(iOS 14, macOS 11, *)
internal struct DualSwapAmountView: View {
    let primaryAmount: String
    let secondaryAmount: String
    let primaryCurrency: CurrencyOption
    let secondaryCurrency: CurrencyOption
    /// When `true`, primary amount occupies the large/top slot; when `false`, secondary does.
    let isPrimarySelected: Bool
    let isCurrencySelectorHidden: Bool
    let onSwap: () -> Void
    let onSelectCurrency: () -> Void
    let onPaste: (() -> Void)?

    var body: some View {
        SwapAmountView(
            amount: primaryAmount,
            symbol: primaryCurrency.symbol,
            secondaryText: secondaryAmount,
            showDashLogo: primaryCurrency == .dash,
            showCurrencyButton: false,
            onPaste: nil,
            secondarySymbol: secondaryCurrency.symbol,
            showSecondaryDashLogo: secondaryCurrency == .dash,
            showSecondaryCurrencyButton: !isCurrencySelectorHidden,
            onSecondaryCurrencyTap: onSelectCurrency,
            swapAnimationKey: isPrimarySelected
        )
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture { onSwap() }
        .dashPasteContextMenu(onPaste: onPaste)
    }
}

// MARK: - DualInputTypeSwitcher (internal)

/// Trailing vertical list of currency-code buttons; the selected entry is highlighted.
/// Fixed width matches `DualSwapLayout.sideColumnWidth` so it occupies its side column exactly.
@available(iOS 14, macOS 11, *)
internal struct DualInputTypeSwitcher: View {
    let codes: [String]
    let selected: String
    let onSelect: (String) -> Void

    var body: some View {
        VStack(spacing: DualSwapLayout.switcherItemSpacing) {
            ForEach(codes, id: \.self) { code in
                Button {
                    onSelect(code)
                } label: {
                    Text(code)
                        .font(Font.dash.caption2)
                        .foregroundColor(
                            code == selected
                                ? Color.dash.primaryText
                                : Color.dash.primaryText.opacity(0.8)
                        )
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .padding(.horizontal, DualSwapLayout.switcherHPadding)
                        .padding(.vertical, DualSwapLayout.switcherVPadding)
                        .frame(minHeight: DualSwapLayout.switcherItemHeight)
                        .background(
                            RoundedRectangle(cornerRadius: DualSwapLayout.switcherCornerRadius, style: .continuous)
                                .fill(code == selected ? Color.dash.black1000Alpha5 : Color.clear)
                        )
                }
                .buttonStyle(.plain)
                .disabled(code == selected)
            }
        }
        .frame(width: DualSwapLayout.sideColumnWidth, alignment: .trailing)
    }
}

// MARK: - Layout constants

/// Side-column widths and switcher styling.
/// Swap animation constants live in `SwapAnimLayout` (inside `SwapAmountView.swift`).
// Internal so EnterAmountView.dualSwapLayout can read sideColumnWidth.
enum DualSwapLayout {
    static let sideColumnWidth: CGFloat = 44

    static let switcherItemSpacing: CGFloat = 4
    static let switcherItemHeight: CGFloat = 24
    static let switcherCornerRadius: CGFloat = 7
    static let switcherHPadding: CGFloat = 6
    static let switcherVPadding: CGFloat = 3
}
