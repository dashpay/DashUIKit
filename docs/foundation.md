# Foundation

Design tokens and primitives shared by every component. Files live in
`Sources/DashUIKit/Foundation/`.

---

## Colors

`Color+DashUI.swift` — file `Foundation/Color+DashUI.swift`

All theme colors are exposed through the `Color.dash` namespace (`DashColors` enum). Each
property maps to a **named color set in the asset catalog** (`Media.xcassets/Colors/…`),
so light/dark variants come from the assets — never hardcode hex.

```swift
Text("Hi")
    .foregroundColor(.dash.primaryText)
    .background(Color.dash.secondaryBackground)
```

Token groups (see the source for the full list):

- **Text:** `primaryText`, `secondaryText`, `tertiaryText`, `whiteText`, `blueText`,
  `successText`, `errorText`
- **Background:** `primaryBackground`, `secondaryBackground`, `tertiaryBackground`,
  `blueBackground`
- **Buttons:** `buttonFilledBlue…`, `buttonFilledRed…`, `buttonTintedBlue/Gray/White…`,
  `buttonStrokeGray…`, `buttonPlainBlue/Black/Red/White…`, `buttonFilledWhite…`
  (each has `…Background`, `…BackgroundDisabled`, `…Content`, `…ContentDisabled` where
  applicable). These back `DashButtonStyle`.
- **Component-specific:** `grabberFill`, `searchBackground`/`searchIcon`/…,
  `segmentControl…`, `select…`, `stepper…`, `switchTrackFillOn/Off…`, `textFieldCryptoAddress…`,
  `toastBackground`/`toastText`, `toolbar…`, `topIntro…`, `bottomNavBackground`,
  `navBackButton`, `backgroundOverlay`, `listGiftCardNumberBackground`, `badgeBackground…`,
  `statusBarElements`, `shortcutBarBackground`
- **Raw tokens:** `blue` (+ `blueAlpha5…90`), `black`/`black1000Alpha5…90`/`black800/900`,
  `gray50…500` (+ alpha variants), `green`/`greenAlpha10`, `red`/`redAlpha5/10`,
  `white`/`whiteAlpha5…90`, `orange`, `yellow`, `lightBlue`, `purple`, `topper`, `uphold`
- **`shadow`** — a code-defined adaptive color (subtle on light, `.clear` on dark);
  used by `MenuViewModifier`.

Adding a color: add the color set to the catalog, then add a matching
`static var … { dashAsset("AssetName") }` line. Do not introduce inline `Color(hex:)`.

---

## Typography

Files `Foundation/DashTextStyle.swift`, `Font+DashUI.swift`, `LineHeight+DashUI.swift`.

Two layers:

- **`Font.dash.*`** (`DashFonts`) — plain `Font` tokens (size + weight only).
- **`DashTextStyle`** — pairs a font token with its **design line height**. Apply both at
  once with the `.dashFont(_:)` view modifier.

```swift
Text(body).dashFont(.subhead)        // font (15 regular) + line height 20
Text(label).font(Font.dash.footnote) // just the font, when line height doesn't matter
```

Available styles (size / weight / line height), each present as both `Font.dash.X` and
`DashTextStyle.X`:

| Style | Size | Weight | Line height |
|---|---|---|---|
| `largeTitle` | 34 | bold | 41 |
| `title1` | 28 | bold | 34 |
| `title2` | 22 | bold | 28 |
| `title3` | 20 | bold | 25 |
| `title3Medium` | 20 | medium | 25 |
| `headline` | 17 | bold | 22 |
| `body` | 17 | regular | 22 |
| `callout` | 16 | regular | 21 |
| `calloutMedium` | 16 | semibold | 21 |
| `subhead` | 15 | regular | 20 |
| `subheadMedium` | 15 | medium | 20 |
| `footnote` | 13 | regular | 18 |
| `footnoteMedium` | 13 | medium | 18 |
| `caption1` | 12 | regular | 16 |
| `caption1Medium` | 12 | medium | 16 |
| `caption2` | 11 | regular | 13 |

`.dashLineHeight(size:lineHeight:)` (in `LineHeight+DashUI.swift`) is the lower-level
modifier `.dashFont` uses — it adds the leading that fixed-size system fonts otherwise
lack, keeping single lines vertically centered. Use `.dashFont` in normal code.

---

## Icons

File `Foundation/Image+DashUI.swift`.

`DashIconSource` abstracts where an icon comes from; render any source with `Image(dash:)`,
then apply your own `.resizable()`, sizing, and color.

```swift
public enum DashIconSource {
    case system(_ name: String)                       // SF Symbol
    case custom(_ name: String, bundle: Bundle? = nil) // asset-catalog image
    case uiImage(_ image: UIImage)                     // runtime UIImage
}

Image(dash: .system("info.circle"))
Image(dash: .custom("menu-send", bundle: .dashUIKit))
    .resizable().scaledToFit().frame(width: 30, height: 30)
```

Many components accept a `DashIconSource?` directly (`DashButton.leadingIcon`,
`MenuItem.leadingIcon`, `RadioButtonRow.icon`, …).

Bundled custom assets (under `Media.xcassets/Icons & Illustrations/`) include nav icons
(`navigationbar-back/close/plus/info`), search icons, currency glyphs
(`icon_dash_currency`, `enter-amount-dash`, `chevron-down-currency-select`), checkbox
icons, text-field icons (`text-field-qr`, `text-field-clear`), menu icons
(`menu-send/receive`, `support`, …), and illustrations (`illustration-dash-dex`,
`illustration-xmark`, `checkmark`, `crowdnode.warning`).

---

## Bundle

File `Foundation/BundleToken.swift`.

`Bundle.dashUIKit` is a convenience alias for `Bundle.module`, used when loading custom
assets from the package bundle (`Image(dash: .custom(name, bundle: .dashUIKit))`).
