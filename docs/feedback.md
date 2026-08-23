# Feedback

Status, progress, and notification visuals.

---

## Toast

File `Components/Toast.swift` · `@available(iOS 14, macOS 11, *)` · **UIKit only**
(`#if canImport(UIKit)`)

A blurred, rounded toast: leading status icon, message, and an optional dismiss (✕)
button. Background is a `systemUltraThinMaterialDark` blur under `Color.dash.toastBackground`.

```swift
Toast(
    style: .success,
    message: "Done",
    onDismiss: { /* hide */ }   // nil → no dismiss button
)
```

**`ToastStyle`** — `.warning` · `.info` · `.error` · `.success` · `.copied` · `.loading`
· `.noInternet`. Each maps to an icon asset under
`Media.xcassets/Icons & Illustrations/Toast/` (`toast-warning`, `toast-info`, …,
`toast-no-wifi`). `.loading` instead renders the DS `LoadingSpinner`.

> ⚠️ The toast icon assets are placeholders to be supplied. Until the imagesets exist the
> icon slot renders empty for the non-loading styles — that's expected, not a bug. See the
> note at the top of `Toast.swift` for the exact asset names.

This is just the toast *view* — presentation/animation/auto-dismiss timing is the host's
responsibility (e.g. overlay it and drive visibility yourself).

---

## SystemMessageView

File `Components/SystemMessageView.swift` · `@available(iOS 14, macOS 11, *)`

An icon-led system banner with optional subtitle, up to two action buttons, and an
optional close button. The default icon is the bundled `warning_triangle` asset, and the
default background is a lightly tinted DS gray.

```swift
SystemMessageView(
    title: "Address expired",
    subtitle: "Generate a new receiving address.",
    buttonName: "Renew",
    onAction: { /* handle action */ },
    onClose: { /* dismiss */ }
)
```

The action buttons are regular `DashButton`s, so use the host to decide whether to show
one or two of them.

---

## LoadingIllustration / LoadingSpinner

File `Components/Illustrations/LoadingIllustration.swift` · `@available(iOS 14, macOS 11, *)`

`LoadingSpinner` is an iOS-style activity indicator built from `spokeCount` capsules in a
ring. The spokes are static; a bright "head" steps clockwise while the others fade
(comet-tail opacity), crossfading between steps — mirroring `UIActivityIndicatorView`.

```swift
LoadingSpinner(size: 24, color: .gray, spokeCount: 12, duration: 1)
```

`LoadingIllustration` wraps the spinner centered in a fixed square frame (defaults match
the Maya design: a 61.73 spinner in a 90×90 frame).

```swift
LoadingIllustration()                                   // 61.73 spinner, DS blue, 90×90
LoadingIllustration(size: 32, color: .red, containerSize: 64)
```

Defaults: `size: 61.73`, `color: LoadingSpinner.defaultColor` (DS blue), `containerSize: 90`.

---

## SuccessIllustration / ErrorIllustration

Files `Components/Illustrations/SuccessIllustration.swift`,
`Components/Illustrations/ErrorIllustration.swift` · `@available(iOS 14, macOS 11, *)`

90×90 circular status badges — a green circle with a checkmark, and a red circle with an
✕ (both from bundled assets). No parameters.

```swift
SuccessIllustration()
ErrorIllustration()
```

---

## InfoRoundIcon

File `Components/Icons/InfoRoundIcon.swift` · `@available(iOS 14, macOS 11, *)` · public

A code-drawn round "i" — a filled disc with a white glyph — for the "there is more to say
about this" affordance. Geometry is normalized from a 19×19 SVG, so stem and dot keep
their weight and position at any `size`.

```swift
InfoRoundIcon()                                             // 19pt, Blue disc
InfoRoundIcon(size: 20, color: Color.dash.gray300Alpha70)   // muted, beside a menu title
```

The disc reads `Color.dash.blue` by default and the glyph `Color.dash.white`, so both
follow the palette instead of a baked-in hex. `MenuItem` renders it for
`MenuItemInfo.round`.

---

## XmarkIcon

File `Components/Icons/XmarkIcon.swift` · `@available(iOS 14, macOS 11, *)` · public

A code-drawn "✕" close icon (a `Shape` with two round-capped diagonals, mirroring a 9×9
SVG), so it scales cleanly to any size without an asset. Used by `Toast`'s dismiss button.

```swift
XmarkIcon(size: 24, color: .white, lineWidth: 2)
```

> Prefer this over the bundled `navigationbar-close` asset when the close control
> is drawn at a non-standard size or needs to take the surrounding tint: being a
> `Shape`, it stays crisp at any `size` and honours `color` / `lineWidth`. The
> asset remains the right choice where the navigation bar's exact artwork is
> wanted.

---

## CheckmarkIcon

File `Components/Icons/CheckmarkIcon.swift` · `@available(iOS 14, macOS 11, *)` · public

A code-drawn "✓" selection mark (a `Shape` stroking the polyline of a 15×12 SVG, round
caps and joins). Backs `MenuItemAccessory.selection`.

```swift
CheckmarkIcon(size: 24, color: .white, lineWidth: 3)
```

> `size` sets the **width**; the height follows the source aspect ratio (12/15), unlike
> `XmarkIcon`, whose artwork is square. The default colour is `Color.dash.blue` — the
> token the source SVG's `#008DE4` corresponds to — so the mark follows the palette
> rather than a frozen hex.

---

## ChevronIcon

File `Components/Icons/ChevronIcon.swift` · `@available(iOS 14, macOS 11, *)` · public

A code-drawn chevron, in any of the four directions (a `Shape` stroking the polyline of a
7×12 SVG, round caps and joins). `ConverterCard` puts one on every row that carries an
`onTap`, so a row that opens a picker reads as one at rest.

```swift
ChevronIcon()                                    // points right, 12pt tall
ChevronIcon(direction: .down, size: 16)
ChevronIcon(direction: .left, color: Color.dash.blue, lineWidth: 2)
```

| Property | Default | Notes |
| --- | --- | --- |
| `direction` | `.right` | `.right` / `.left` / `.up` / `.down` |
| `size` | `12` | The **long** side — height for left/right, width for up/down |
| `color` | `Color.dash.gray300Alpha90` | The palette entry for the source SVG's `#B0B6BC` at 90% |
| `lineWidth` | `1.6` | Source stroke width |

> Only the `.right` chevron is drawn; the rest are that glyph rotated, so all four share one
> geometry and one line weight. The frame swaps axes with the rotation, so a `.up` / `.down`
> chevron measures wider than tall and lays out without a gap beside it.

