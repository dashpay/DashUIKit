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

## XmarkIcon

File `Components/Icons/XmarkIcon.swift` · `@available(iOS 14, macOS 11, *)` · internal

A code-drawn "✕" close icon (a `Shape` with two round-capped diagonals, mirroring a 9×9
SVG), so it scales cleanly to any size without an asset. Used by `Toast`'s dismiss button.

```swift
XmarkIcon(size: 24, color: .white, lineWidth: 2)
```

> Internal to the module (not part of the public API) — reach for the bundled
> `navigationbar-close` asset or an SF Symbol from app code.
