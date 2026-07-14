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
