# Amount & currency

The amount-entry suite (`Components/EnterAmount/`) plus standalone amount renderers.
These power Send / Convert / DashDEX-style screens.

---

## EnterAmountView

File `Components/EnterAmount/EnterAmountView.swift` · `@available(iOS 14, macOS 11, *)`

The top-level amount-entry control. Two layouts selected by **`EnterAmountStyle`**:

- **`.single`** (default) — Max button + `SwapAmountView` + `DashPickerView` currency list.
- **`.dualSwap`** — two amounts (e.g. Dash + fiat) stacked; tapping animates them swapping
  the large/small slots. Optional Max button and a trailing input-type switcher.

Each layout has its own initializer (the `.single` init keeps existing call sites
source-compatible).

### Single

```swift
@State private var value = "12.5"
@State private var currency: CurrencyOption = .dash

EnterAmountView(
    value: $value,
    selectedCurrency: $currency,
    options: [.fiat("USD"), .dash, .coin("BTC")],
    onMax: { /* fill max */ },
    onCurrencyTap: { /* e.g. open fiat picker */ },
    onPaste: { /* paste from clipboard */ }
)
```

### Dual-swap

```swift
EnterAmountView(
    primaryAmount: "1.23456",        // host-formatted (e.g. Dash)
    secondaryAmount: "$ 150.00",     // host-formatted (e.g. fiat)
    primaryCurrency: .dash,
    secondaryCurrency: .fiat("USD"),
    isPrimarySelected: true,         // true → primary in large slot
    isCurrencySelectorHidden: false, // hides the chevron next to secondary
    currencyCodes: ["DASH", "USD"],  // non-nil → trailing vertical switcher
    selectedCurrencyCode: "DASH",
    onMax: { },                      // nil → no Max button (amount stays centered)
    onSwap: { /* toggle isPrimarySelected */ },
    onCurrencyTap: { },
    onPaste: { },
    onSelectInputType: { code in /* user picked a code */ }
)
```

The dual-swap layout uses three columns — leading (Max or spacer), centered animated
amount stack, trailing (switcher or spacer) — with equal fixed side widths so the amount
stays truly centered regardless of which controls are present. All amounts are **strings
the host formats**; the component never does currency math.

---

## SwapAmountView

File `Components/EnterAmount/SwapAmountView.swift` · `@available(iOS 14, macOS 11, *)`

The amount display used inside `EnterAmountView`. Renders a large amount (optional
currency symbol + number + Dash logo) with optional top/bottom helper text and an optional
secondary line. Public, so it can be used standalone.

```swift
SwapAmountView(
    amount: "1.5",
    symbol: nil,                  // e.g. "$" for fiat; nil for Dash
    secondaryText: "$ 150.00",
    topText: "Enter amount",
    bottomText: nil,
    showDashLogo: true,
    showCurrencyButton: false,    // chevron beside the amount → onCurrencyTap
    onCurrencyTap: nil,
    onPaste: nil                  // long-press to paste
)
```

Two modes:

- **Static** (`swapAnimationKey == nil`): single amount + optional secondary line. Drives
  the `.single` style.
- **Animated dual-swap** (`swapAnimationKey: Bool`): a `ZStack` of two persistent rows (A =
  primary, B = secondary). When the key flips, both rows animate `scaleEffect` + `offset`
  together for a continuous grow-rise / shrink-fall, with the font snapping to the target
  weight and a compensating scale bridging the jump. `DualSwapAmountView` (internal) is the
  thin wrapper `EnterAmountView` uses; tapping the container fires `onSwap`.

Display normalization: empty → `"0"`; a bare-decimal input gets a leading zero
(`.34` → `0.34`). It does **not** reformat or cap precision — that's the host's job.

`scaleToFitWidth` keeps the whole amount group on one line, shrinking uniformly when long
(see [Utilities](utilities.md#scaletofitwidth)).

The `.dashPasteContextMenu(onPaste:)` helper (in this file) wires long-press-to-paste via
`onLongPressGesture` — deliberately **not** `.contextMenu`, which breaks inside a
`UIHostingController`.

---

## DashAmount

File `Components/DashAmount.swift` · `@available(iOS 14, macOS 11, *)`

Renders a **duffs `Int64`** (1 DASH = 100,000,000 duffs) as a localized decimal amount
followed by the Dash currency glyph. Display-only.

```swift
DashAmount(
    amount: 6_791_000,        // duffs
    fontSize: 15,
    weight: .medium,
    dashSymbolFactor: 1,      // glyph size = fontSize × factor
    sign: .negativeOnly
)
```

**`DashAmountSign`** — `.none` (never show a sign) · `.negativeOnly` (minus only;
default) · `.always` (`+`/`-`). Zero never shows a sign in any mode.

Sentinels: `amount == .max` or `.min` renders the localized **"Not available"** string
(used for unknown/pending balances). Formatting: up to 5 fraction digits, grouping
separators, current locale.

---

## DashBalanceView

File `Components/EnterAmount/DashBalanceView.swift` · `@available(iOS 14, macOS 11, *)`

Trailing balance block: a **symbol-free, pre-formatted** Dash amount string + Dash glyph,
with an optional fiat sub-line beneath. Unlike `DashAmount`, it takes already-formatted
strings (from a view model), not duffs.

```swift
DashBalanceView(balance: "1.5", fiat: "$ 150.00")  // fiat nil → hide sub-line
```

---

## DashPickerView

File `Components/EnterAmount/DashPickerView.swift` · `@available(iOS 14, macOS 11, *)`

A compact vertical inline picker over any `Hashable` option; the selected row gets a
subtle highlighted background. Generic and reusable.

```swift
@State private var selected: CurrencyOption = .dash
DashPickerView(
    options: [.fiat("USD"), .dash, .coin("BTC")],
    title: { $0.displayName },     // (Option) -> String
    selected: $selected
)
```

In `.single` `EnterAmountView` this is the currency list on the trailing side.

---

## CurrencyOption

File `Components/EnterAmount/CurrencyOption.swift` · public `Hashable` enum

Models the three input kinds the amount controls understand:

```swift
public enum CurrencyOption: Hashable {
    case fiat(String)   // currency code, e.g. "USD"
    case dash
    case coin(String)   // coin code, e.g. "BTC"
}
```

Helpers: `isFiat`, `isCoinInput`, `displayName` (`"DASH"` / the code), and `symbol`
(fiat → locale currency symbol via the internal `DashCurrencySymbol`; dash → `nil`, shown
as a logo instead; coin → the code). Convenience values like `.dash` / `.fiat("USD")` are
used as defaults in `EnterAmountView`.
