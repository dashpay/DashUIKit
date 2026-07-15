# Lists & rows

Row components for building lists, menus, and selection screens. None of them draw their
own dividers or backgrounds — compose them in your own `VStack`/`List` and add separators
as needed.

---

## CoinSelector

File `Components/CoinSelector.swift` · `@available(iOS 14, macOS 11, *)`

A coin/asset row: leading icon (your view), name + code stacked, and a flexible trailing
slot — a price/network readout or a "halted" badge. Generic over the icon view.

```swift
CoinSelector(
    name: "Rune",
    code: "RUNE",
    network: "Maya",                 // optional second trailing line
    trailing: .price("$0.40")        // CoinSelectorTrailing?
) {
    Image("rune-icon").resizable().frame(width: 30, height: 30)   // @ViewBuilder icon
}
```

**`CoinSelectorTrailing`**:

- `.price(String)` — price line; if `network` is set it appears beneath it.
- `.halted` — renders a localized **"halted"** badge and dims the whole row to 50% opacity.

Name truncates with `…` on overflow. The row sets `contentShape(.rect)` so the whole area
is tappable when you wrap it in a `Button`.

---

## MenuItem

File `Components/MenuItem.swift` · `@available(iOS 14, macOS 11, *)`

A settings/menu row: optional leading icon, title with optional inline info icon, optional
help text, and a flexible trailing **accessory**.

```swift
MenuItem(
    leadingIcon: .custom("menu-send", bundle: .dashUIKit),  // DashIconSource?
    title: "Network fee",
    helpText: "Estimated cost for this transaction",
    infoIcon: .system("info.circle"),
    accessory: .text("0.0001 DASH")
)
```

**`MenuItemAccessory`** — the trailing look (extend this enum rather than overriding
per-call fonts/colors, to keep rows consistent):

- `.none`
- `.toggle(isOn: Binding<Bool>)` — a `Toggle`
- `.text(String)`
- `.button(DashButton)` — embed a `DashButton`
- `.balance(dash: Int64, sign: DashAmountSign = .negativeOnly, fiat: String? = nil)` —
  a `DashAmount` (duffs) with an optional pre-formatted fiat sub-line. The fiat line is
  hidden for zero / `.max` / `.min` amounts. The library only renders the fiat string you
  pass — it does no conversion.

---

## ConverterCard

File `Components/ConverterCard/ConverterCard.swift` · `@available(iOS 14, macOS 11, *)`

A two-row source/destination card with a seam-centered arrow badge. Each row is wrapped
in shared card chrome; passing `onSwap` makes the badge tappable and rotates the arrow,
omitting it leaves a static down arrow.

```swift
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
        dashBalance: 123_456_789,
        fiat: "$120.00",
        showsBalance: false
    ),
    onSwap: { /* swap rows */ }
)
```

### ConverterCardItem

Display data for one row in `ConverterCard`. Use the plain fields for icon/title/subtitle/
balance/fiat, or override the leading/trailing content with `iconView` / `trailingView`.
`subtitleLineLimit` controls wrapping; `showsBalance` hides the trailing amount when
`false`.

### ConverterCardRow

Internal helper that applies the shared rounded card chrome and reports its height. It is
not intended for direct use.

### ConverterArrowBadge

Internal seam badge: static `arrow-down` without swapping, or tappable
`diagonal-up-down` when `onSwap` is supplied. It is also an internal helper.

---

## TransactionView

File `Components/Transaction/TransactionView.swift` · `@available(iOS 14, macOS 11, *)`

A transaction row with a leading icon, optional status badge, title/time/detail text, and
a trailing Dash amount plus optional fiat line. Pass `action` to make the whole row
tappable; omit it for a static row.

```swift
TransactionView(
    icon: .system("arrow.down.circle.fill"),
    title: "Received",
    subtitle: "8:34 AM",
    details: "Processing",
    dashAmount: 6_791_000,
    amountSign: .always,
    fiat: "$ 1.87",
    action: { /* open details */ }
)
```

The amount is a raw duff value (`Int64`, 10⁸ per Dash) rendered via `DashAmount`.

---

## RadioButtonRow

File `Components/RadioButtonRow.swift` · `@available(iOS 14, macOS 11, *)`

A tappable selectable row with title, optional subtitle, optional trailing text, optional
leading icon, and a selection indicator in one of two styles.

```swift
RadioButtonRow(
    title: "Standard fee",
    subtitle: "Secondary text",      // optional
    trailingText: "-10%",            // optional
    icon: .system("star.fill"),      // optional DashIconSource
    isSelected: true,
    style: .radio,                   // .radio (default) or .checkbox
    action: { /* select */ }
)
```

**`Style`** — `.radio` (a ring that thickens/fills blue when selected) or `.checkbox`
(uses the bundled `icon_checkbox_square[_checked]` assets). Row min-height is 60 with a
subtitle, otherwise 54; the whole row is the tap target.

---

## List1View

File `Table List/List1View.swift` · `@available(iOS 14, macOS 11, *)`

The simplest row: a tertiary-colored **label** on the left and a primary-colored **value**
on the right (value is right-aligned and can wrap). Useful for detail / summary lists.

```swift
List1View(label: "Network", value: "Dash")
```
