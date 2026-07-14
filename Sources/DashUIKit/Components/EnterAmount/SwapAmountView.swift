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
#if canImport(UIKit)
import UIKit
#endif

// MARK: - SwapAmountView

@available(iOS 14, macOS 11, *)
public struct SwapAmountView: View {

    // MARK: Primary row props

    public let amount: String
    public var symbol: String? = nil
    public var secondaryText: String? = nil
    public var topText: String? = nil
    public var bottomText: String? = nil
    public var showDashLogo: Bool = false
    public var showCurrencyButton: Bool = false
    public var onCurrencyTap: (() -> Void)? = nil
    public var onPaste: (() -> Void)? = nil

    // MARK: Secondary row props (only used in animated dual-swap mode)

    /// Currency symbol for the B row (secondary logical value). Nil = no symbol.
    public var secondarySymbol: String? = nil
    /// Show the Dash logo on the B row.
    public var showSecondaryDashLogo: Bool = false
    /// Show a currency-select chevron beside the B row's amount.
    public var showSecondaryCurrencyButton: Bool = false
    /// Action fired when the secondary-row chevron is tapped.
    public var onSecondaryCurrencyTap: (() -> Void)? = nil
    /// When non-nil, enables the animated dual-swap ZStack layout and acts as the animation key.
    /// `true` = A row (amount) is the large/top slot; `false` = B row (secondaryText) is.
    /// Nil = static single-amount layout (`.single` usage).
    public var swapAnimationKey: Bool? = nil

    // MARK: Init

    public init(
        amount: String,
        symbol: String? = nil,
        secondaryText: String? = nil,
        topText: String? = nil,
        bottomText: String? = nil,
        showDashLogo: Bool = false,
        showCurrencyButton: Bool = false,
        onCurrencyTap: (() -> Void)? = nil,
        onPaste: (() -> Void)? = nil,
        secondarySymbol: String? = nil,
        showSecondaryDashLogo: Bool = false,
        showSecondaryCurrencyButton: Bool = false,
        onSecondaryCurrencyTap: (() -> Void)? = nil,
        swapAnimationKey: Bool? = nil
    ) {
        self.amount = amount
        self.symbol = symbol
        self.secondaryText = secondaryText
        self.topText = topText
        self.bottomText = bottomText
        self.showDashLogo = showDashLogo
        self.showCurrencyButton = showCurrencyButton
        self.onCurrencyTap = onCurrencyTap
        self.onPaste = onPaste
        self.secondarySymbol = secondarySymbol
        self.showSecondaryDashLogo = showSecondaryDashLogo
        self.showSecondaryCurrencyButton = showSecondaryCurrencyButton
        self.onSecondaryCurrencyTap = onSecondaryCurrencyTap
        self.swapAnimationKey = swapAnimationKey
    }

    // MARK: Body

    public var body: some View {
        content
    }

    private var content: some View {
        VStack(spacing: 2) {
            if let top = topText {
                Text(top)
                    .font(Font.dash.caption1)
                    .foregroundColor(Color.dash.tertiaryText)
            }

            if let animKey = swapAnimationKey {
                animatedBody(isPrimaryLarge: animKey)
            } else {
                staticBody
            }

            if let bottom = bottomText {
                Text(bottom)
                    .font(Font.dash.caption1)
                    .foregroundColor(Color.dash.tertiaryText)
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: Static layout (unchanged from original — drives .single)

    private var staticBody: some View {
        VStack(spacing: 0) {
            primaryRow

            if let secondary = secondaryText {
                Text(secondary)
                    .font(Font.dash.subhead)
                    .foregroundColor(Color.dash.tertiaryText)
            }
        }
    }

    // MARK: Animated dual-swap layout

    /// Thin forwarder — instantiates `AnimatedSwapLayout` which owns the two-phase animation state.
    /// Phase 1 (scale + opacity) runs in place; phase 2 (offset glide) follows after `scalePhase`.
    @ViewBuilder
    private func animatedBody(isPrimaryLarge: Bool) -> some View {
        AnimatedSwapLayout(
            amount: amount,
            symbol: symbol,
            secondaryText: secondaryText,
            showDashLogo: showDashLogo,
            showCurrencyButton: showCurrencyButton,
            onCurrencyTap: onCurrencyTap,
            onPaste: onPaste,
            secondarySymbol: secondarySymbol,
            showSecondaryDashLogo: showSecondaryDashLogo,
            showSecondaryCurrencyButton: showSecondaryCurrencyButton,
            onSecondaryCurrencyTap: onSecondaryCurrencyTap,
            isPrimaryLarge: isPrimaryLarge
        )
    }

    // MARK: Rows

    private var primaryRow: some View {
        // Amount (symbol + number + logo) and the currency chevron scale down together as ONE
        // centered unit, so the chevron stays right next to the amount instead of being pushed to
        // the far edge (scaleToFitWidth fills the width, so it must wrap the whole group, not just
        // the amount). Renders full-size when it fits; shrinks uniformly when it doesn't.
        HStack(spacing: 6) {
            amountView(font: Font.dash.largeTitle, dashSize: .init(width: 19, height: 16))
                .foregroundColor(Color.dash.primaryText)

            if showCurrencyButton {
                Button {
                    onCurrencyTap?()
                } label: {
                    Image(dash: .custom("chevron-down-currency-select", bundle: .dashUIKit))
                        .frame(width: 10, height: 5)
                }
                .buttonStyle(.plain)
            }
        }
        .scaleToFitWidth()
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .dashPasteContextMenu(onPaste: onPaste)
    }

    // MARK: Amount content views

    private func amountView(font: Font, dashSize: CGSize? = nil) -> some View {
        HStack(spacing: 4) {
            if let sym = symbol, !sym.isEmpty {
                Text(sym)
                    .font(font)
            }

            Text(displayAmount)
                .font(font)

            if showDashLogo {
                Image(dash: .custom("enter-amount-dash", bundle: .dashUIKit))
                    .resizable()
                    .scaledToFit()
                    .frame(width: dashSize?.width, height: dashSize?.height)
            }
        }
    }

    private func secondaryAmountView(font: Font, dashSize: CGSize? = nil) -> some View {
        HStack(spacing: 4) {
            if let sym = secondarySymbol, !sym.isEmpty {
                Text(sym)
                    .font(font)
            }

            Text(displaySecondary)
                .font(font)

            if showSecondaryDashLogo {
                Image(dash: .custom("enter-amount-dash", bundle: .dashUIKit))
                    .resizable()
                    .scaledToFit()
                    .frame(width: dashSize?.width, height: dashSize?.height)
            }
        }
    }

    // MARK: Display normalisers

    /// The numeric string as shown to the user. Pure display transform:
    /// - empty → "0"
    /// - bare-decimal input gets a leading zero: ".34" → "0.34", "." → "0." (same for ",")
    /// Does NOT trim, reformat, or cap precision — that happens upstream in `sanitize`.
    private var displayAmount: String {
        guard !amount.isEmpty else { return "0" }
        if let first = amount.first, first == "." || first == "," {
            return "0" + amount
        }
        return amount
    }

    private var displaySecondary: String {
        guard let s = secondaryText, !s.isEmpty else { return "0" }
        if let first = s.first, first == "." || first == "," { return "0" + s }
        return s
    }
}

// MARK: - AnimatedSwapLayout

/// Stateful sub-view combining font switching with `scaleEffect` for the dual-swap animation.
///
/// **How it works:**
/// When `isPrimaryLarge` flips, the animation runs in two phases:
///
/// 1. **Font snap** (`fontPrimary`): both rows instantly switch to their target font
///    (largeTitle bold ↔ subhead regular) and foreground color. Because the font size jumps
///    at the boundary, each row's `scaleEffect` is immediately set to the **compensating**
///    value — the ratio that makes the new font appear the same visual size as the old one
///    (e.g. if A row just switched from largeTitle→subhead, set scaleA = 34/15 so subhead×2.267
///    still looks 34pt). On the NEXT run loop, `scaleEffect` is animated to 1.0, producing a
///    smooth grow/shrink with correct font weight throughout.
///
/// 2. **Offset glide** (`offsetPrimary`): after `scalePhase` has elapsed, rows slide to their
///    new vertical positions.
///
/// Result: correct bold weight in the large slot, correct regular weight in the small slot,
/// smooth size transition via `scaleEffect` bridging the font snap.
@available(iOS 14, macOS 11, *)
private struct AnimatedSwapLayout: View {

    // MARK: Content props

    let amount: String
    let symbol: String?
    let secondaryText: String?
    let showDashLogo: Bool
    let showCurrencyButton: Bool
    let onCurrencyTap: (() -> Void)?
    let onPaste: (() -> Void)?
    let secondarySymbol: String?
    let showSecondaryDashLogo: Bool
    let showSecondaryCurrencyButton: Bool
    let onSecondaryCurrencyTap: (() -> Void)?
    let isPrimaryLarge: Bool

    // MARK: Phase state

    /// Drives font (largeTitle↔subhead) and foreground color. Snaps instantly — no animation.
    @State private var fontPrimary: Bool
    /// Per-row `scaleEffect` values. Set to compensating ratio on font snap, then animated to 1.0.
    @State private var scaleA: CGFloat = 1.0
    @State private var scaleB: CGFloat = 1.0
    /// Controls `.offset`. Animated after `scalePhase` delay in phase 2.
    @State private var offsetPrimary: Bool

    // MARK: Timing

    static let scalePhase: Double = 0.18
    static let offsetPhase: Double = 0.2

    // MARK: Init

    init(
        amount: String,
        symbol: String?,
        secondaryText: String?,
        showDashLogo: Bool,
        showCurrencyButton: Bool,
        onCurrencyTap: (() -> Void)?,
        onPaste: (() -> Void)?,
        secondarySymbol: String?,
        showSecondaryDashLogo: Bool,
        showSecondaryCurrencyButton: Bool,
        onSecondaryCurrencyTap: (() -> Void)?,
        isPrimaryLarge: Bool
    ) {
        self.amount = amount
        self.symbol = symbol
        self.secondaryText = secondaryText
        self.showDashLogo = showDashLogo
        self.showCurrencyButton = showCurrencyButton
        self.onCurrencyTap = onCurrencyTap
        self.onPaste = onPaste
        self.secondarySymbol = secondarySymbol
        self.showSecondaryDashLogo = showSecondaryDashLogo
        self.showSecondaryCurrencyButton = showSecondaryCurrencyButton
        self.onSecondaryCurrencyTap = onSecondaryCurrencyTap
        self.isPrimaryLarge = isPrimaryLarge
        _fontPrimary = State(initialValue: isPrimaryLarge)
        _offsetPrimary = State(initialValue: isPrimaryLarge)
    }

    // MARK: Body

    var body: some View {
        // Font and dash-logo size both come from fontPrimary (snaps at animation boundary).
        let aFont: Font = fontPrimary ? Font.dash.largeTitle : Font.dash.subhead
        let bFont: Font = fontPrimary ? Font.dash.subhead : Font.dash.largeTitle
        let dashSize = fontPrimary ? CGSize(width: 19, height: 16) : CGSize(width: 10, height: 8)
        let chevronSize = fontPrimary ? CGSize(width: 5, height: 2.5) : CGSize(width: 10, height: 5)
        let iconForegroundColor: Color = fontPrimary ? Color.dash.primaryText : Color.dash.tertiaryText

        ZStack(alignment: .center) {
            // A row — always carries the primary logical value
            rowContent(
                font: aFont,
                displayText: displayAmount,
                showLogo: showDashLogo,
                dashSize: dashSize
            )
            .foregroundColor(iconForegroundColor)
            .scaleToFitWidth()
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
            .dashPasteContextMenu(onPaste: onPaste)
            .scaleEffect(scaleA, anchor: .center)
            .offset(y: offsetPrimary ? SwapAnimLayout.primaryOffset : SwapAnimLayout.secondaryOffset)

            // B row — always carries the secondary logical value; shows optional chevron
            HStack(spacing: 6) {
                rowContent(
                    font: bFont,
                    displayText: displaySecondary,
                    symbol: secondarySymbol,
                    showLogo: showSecondaryDashLogo,
                    dashSize: dashSize
                )

                if showSecondaryCurrencyButton {
                    Button { onSecondaryCurrencyTap?() } label: {
                        Image(dash: .custom("chevron-down-currency-select", bundle: .dashUIKit))
                            .resizable()
                            .scaledToFit()
                            .frame(width: chevronSize.width, height: chevronSize.height)
                    }
                    .buttonStyle(.plain)
                }
            }
            .foregroundColor(fontPrimary ? Color.dash.tertiaryText : Color.dash.primaryText)
            .scaleToFitWidth()
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
            .dashPasteContextMenu(onPaste: onPaste)
            .scaleEffect(scaleB, anchor: .center)
            .offset(y: offsetPrimary ? SwapAnimLayout.secondaryOffset : SwapAnimLayout.primaryOffset)
        }
        .frame(height: SwapAnimLayout.containerHeight)
        .frame(maxWidth: .infinity)
        .onChange(of: isPrimaryLarge) { newValue in
            // Step 1: font/color snaps to target (no animation — font is not animatable)
            fontPrimary = newValue

            // Step 2: immediately set compensating scaleEffect so visual size appears unchanged
            // despite the font size jump. newValue=true means A just grew (subhead→largeTitle):
            //   A comp = subhead/largeTitle = secondaryScale (largeTitle × 0.441 ≈ subhead visual)
            //   B comp = largeTitle/subhead  = primaryScale  (subhead  × 2.267 ≈ largeTitle visual)
            // newValue=false means A just shrank (largeTitle→subhead): ratios are reversed.
            scaleA = newValue ? SwapAnimLayout.secondaryScale : SwapAnimLayout.primaryScale
            scaleB = newValue ? SwapAnimLayout.primaryScale   : SwapAnimLayout.secondaryScale

            // Step 3 (next run loop): animate scaleEffect to natural size 1.0.
            // Deferring to the next run loop lets SwiftUI render the compensating scale first,
            // so the animation truly starts from the compensating value.
            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: Self.scalePhase)) {
                    scaleA = 1.0
                    scaleB = 1.0
                }
            }

            // Phase 2: offset glide after the scale phase completes
            DispatchQueue.main.asyncAfter(deadline: .now() + Self.scalePhase) {
                withAnimation(.easeInOut(duration: Self.offsetPhase)) {
                    offsetPrimary = newValue
                }
            }
        }
    }

    // MARK: Row content helper

    private func rowContent(
        font: Font,
        displayText: String,
        symbol: String? = nil,
        showLogo: Bool,
        dashSize: CGSize
    ) -> some View {
        HStack(spacing: 4) {
            if let sym = symbol, !sym.isEmpty {
                Text(sym).font(font)
            }
            Text(displayText).font(font)
            if showLogo {
                Image(dash: .custom("enter-amount-dash", bundle: .dashUIKit))
                    .resizable()
                    .scaledToFit()
                    .frame(width: dashSize.width, height: dashSize.height)
            }
        }
    }

    private var displayAmount: String {
        guard !amount.isEmpty else { return "0" }
        if let first = amount.first, first == "." || first == "," { return "0" + amount }
        return amount
    }

    private var displaySecondary: String {
        guard let s = secondaryText, !s.isEmpty else { return "0" }
        if let first = s.first, first == "." || first == "," { return "0" + s }
        return s
    }
}

// MARK: - Paste Context Menu

@available(iOS 14, macOS 11, *)
extension View {
    /// Long-press to paste. Intentionally uses an `onLongPressGesture` and NOT `.contextMenu`:
    /// `.contextMenu` adds a `_UIReparentingView` to the host's view hierarchy, which is
    /// unsupported when the SwiftUI content is embedded in a `UIHostingController` (as Send /
    /// Specify are) and silently breaks the gesture. The long-press pastes only when the
    /// clipboard actually has a string.
    @ViewBuilder
    func dashPasteContextMenu(onPaste: (() -> Void)?) -> some View {
        if let onPaste {
            #if canImport(UIKit)
            self.simultaneousGesture(
                LongPressGesture(minimumDuration: 0.4).onEnded { _ in
                    onPaste()
                }
            )
            #else
            self
            #endif
        } else {
            self
        }
    }
}

// MARK: - Swap animation layout constants

// Internal so DualSwapAmountView can read them if needed; private would hide from the module.
@available(iOS 14, macOS 11, *)
enum SwapAnimLayout {
    // Slot heights (reference: SendAmountAmountsStack)
    static let primaryHeight: CGFloat = 41
    static let slotSpacing: CGFloat = 0
    static let secondaryHeight: CGFloat = 20
    // Fixed container height prevents layout jumps during animation
    static let containerHeight: CGFloat = primaryHeight + slotSpacing + secondaryHeight  // 70

    // Scale factors between the two base fonts (largeTitle bold 34pt ↔ subhead regular 15pt).
    // A row uses largeTitle as base; B row uses subhead as base.
    // secondaryScale shrinks largeTitle to appear subhead-sized in the small slot.
    // primaryScale grows subhead to appear largeTitle-sized in the large slot.
    static let secondaryScale: CGFloat = 15.0 / 34.0  // ≈ 0.441
    static let primaryScale: CGFloat = 34.0 / 15.0    // ≈ 2.267
    static let secondaryOpacity: CGFloat = 0.67

    // Offsets from ZStack center (= containerHeight / 2 = 35).
    // Primary anchor centre:   primaryHeight / 2 = 21  →  offset = 21 − 35 = −14
    // Secondary anchor centre: primaryHeight + slotSpacing + secondaryHeight / 2 = 60  →  offset = 60 − 35 = +25
    static let primaryOffset: CGFloat = -(containerHeight / 2 - primaryHeight / 2)
    static let secondaryOffset: CGFloat = primaryHeight + slotSpacing + secondaryHeight / 2 - containerHeight / 2
}

// MARK: - Previews

#if DEBUG

@available(iOS 17, macOS 14, *)
#Preview("Normal amounts") {
    VStack(spacing: 20) {
        SwapAmountView(
            amount: "1.5",
            secondaryText: "$ 150.00",
            topText: "Enter amount",
            showDashLogo: true
        )
        SwapAmountView(
            amount: "100",
            symbol: "$",
            secondaryText: "Ð 1.0",
            showCurrencyButton: true
        )
    }
    .padding(20)
}

@available(iOS 17, macOS 14, *)
#Preview("Edge cases — scaling") {
    VStack(spacing: 20) {
        SwapAmountView(
            amount: "99999.99999999",
            topText: "Dash — very long",
            showDashLogo: true
        )
        SwapAmountView(
            amount: "123456.78",
            symbol: "$",
            topText: "Fiat — long with button",
            showCurrencyButton: true
        )
        SwapAmountView(
            amount: "0.00012345",
            symbol: "BTC",
            topText: "Crypto — small value"
        )
    }
    .padding(20)
}

@available(iOS 17, macOS 14, *)
#Preview("Edge cases — precision") {
    VStack(spacing: 20) {
        SwapAmountView(
            amount: "0.13",
            symbol: "$",
            topText: "Fiat 0.13 (max 2 dp)",
            showCurrencyButton: true
        )
        SwapAmountView(
            amount: "1",
            topText: "Normalized from 01 → 1",
            showDashLogo: true
        )
        SwapAmountView(
            amount: "0.",
            symbol: "$",
            topText: "In-progress: 0.",
            showCurrencyButton: true
        )
    }
    .padding(20)
}

@available(iOS 17, macOS 14, *)
#Preview("Leading zero — bare decimal") {
    VStack(spacing: 20) {
        SwapAmountView(
            amount: ".34",
            topText: "Bare decimal: .34 → 0.34",
            showDashLogo: true
        )
        SwapAmountView(
            amount: ".",
            symbol: "$",
            topText: "In-progress: . → 0.",
            showCurrencyButton: true
        )
    }
    .padding(20)
}

@available(iOS 17, macOS 14, *)
#Preview("Animated dual-swap (interactive)") {
    VStack {
        SwapAmountView(
            amount: "1.5",
            secondaryText: "$ 150.00",
            topText: "Enter amount",
            showDashLogo: true
        )

        SwapAmountAnimatedPreview()
            .background(Color.dash.secondaryBackground)
            .padding(20)
    }
}

@available(iOS 17, macOS 14, *)
private struct SwapAmountAnimatedPreview: View {
    @State private var isPrimarySelected = true

    var body: some View {
        VStack(spacing: 16) {
            Text(isPrimarySelected ? "Dash is primary (large)" : "Fiat is primary (large)")
                .font(Font.dash.caption1)
                .foregroundColor(Color.dash.tertiaryText)

            SwapAmountView(
                amount: "1.23456",
                symbol: nil,
                secondaryText: "150.00",
                topText: "Enter amount",
                showDashLogo: true,
                secondarySymbol: "$",
                showSecondaryCurrencyButton: true,
                onSecondaryCurrencyTap: {},
                swapAnimationKey: isPrimarySelected
            )
            .contentShape(Rectangle())
            .onTapGesture { isPrimarySelected.toggle() }

            Button("Tap to swap") { isPrimarySelected.toggle() }
                .font(Font.dash.footnote)
                .foregroundColor(Color.dash.blue)
        }
    }
}

#endif
