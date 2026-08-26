# Navigation & containers

Structural chrome — nav bars, bottom sheets, and card styling.

---

## NavigationBar

File `Components/NavigationBar.swift` · `@available(iOS 14, macOS 11, *)`

A custom three-slot top bar: **leading**, **central**, **trailing**, each a
`@ViewBuilder`. The leading/trailing pair is laid out in an `HStack` with a `Spacer`
between; the central content is overlaid centered (so a long title stays centered
regardless of side content). Min height 64.

```swift
NavigationBar(
    leading: { NavigationBarElement.back.button { dismiss() } },
    central: {
        Text("Title")
            .dashFont(.subheadMedium)
            .foregroundColor(.dash.primaryText)
    },
    trailing: { NavigationBarElement.info.button { showInfo() } }
)
```

Convenience initializers let you omit any slot (e.g. only `leading`, or `central` +
`trailing`) via `EmptyView` specializations.

**`NavigationBarElement`** — bundled icon buttons backed by the nav assets:
`.back`, `.close`, `.plus`, `.info`. Each provides:

- `.icon` — the resizable `Image`.
- `.button(action:)` — a 44×44 tappable button with a press animation
  (scale 0.88 + opacity 0.7).

---

## TopIntroView

File `Components/TopIntro/TopIntroView.swift` · `@available(iOS 14, macOS 11, *)`

A lightweight top-of-screen intro block: title plus up to two description lines, laid
out as a leading-aligned text stack with extra trailing padding so it breathes beside
actions or safe areas.

```swift
TopIntroView(
    title: "Confirm details",
    mainDescription: "Review the amount before continuing.",
    secondaryDescription: "You can always go back and edit it."
)
```

Use it for screen headers that sit above the main content rather than inside a nav bar.

---

## BottomSheet

File `Components/BottomSheet.swift` · `@available(iOS 14, macOS 11, *)`

Sheet chrome to put **inside** a SwiftUI `.sheet { }`: a grabber, a `NavigationBar` header
(optional back button + title + close), and your content. Two height modes.

```swift
.sheet(isPresented: $isPresented) {
    BottomSheet(
        title: "Details",
        showBackButton: $showBack,            // Binding<Bool>
        onBackButtonPressed: { /* pop */ },
        isDismissalEnabled: $canDismiss,       // close + swipe; true by default
        showsCloseButton: true,                // true by default
        onClose: { /* custom close action */ },
        fillsHeight: true,                    // greedy: fills the sheet
        background: .dash.primaryBackground   // fill behind grabber, header and content
    ) {
        MyContent()
    }
}
```

- **`fillsHeight: true`** (default) — content fills the sheet; pair with an explicit detent
  on **iOS 16+** (`.large` / `.medium` / `.height`). Wraps content in a `NavigationView`.
- **`fillsHeight: false`** — natural height; pair with `.selfSizingSheet(…)` so the sheet
  snaps to its content.

`isDismissalEnabled` controls the close button and interactive swipe dismissal together.
The binding is dynamic, so a host can disable both while signing or broadcasting and
restore them afterward. The close button becomes visibly disabled and exposes the disabled
accessibility trait. Interactive-dismiss blocking uses the system API on **iOS 15+** /
**macOS 12+**; older supported systems retain the close-button protection.

Set `showsCloseButton: false` when the sheet has no close affordance. Pass `onClose` to
override the default presentation dismissal; the callback is then responsible for actually
dismissing the sheet. All three options preserve the existing behavior when omitted.

### Self-sizing

Prefer the `BottomSheet.selfSizing(…)` factory, which guarantees `fillsHeight: false` and
the modifier are applied together:

```swift
.sheet(isPresented: $isPresented) {
    BottomSheet.selfSizing(
        title: "Quick action",
        showBackButton: .constant(false),
        fallback: 240,            // height before first measurement (avoids .medium flash)
        maxHeightFraction: 0.95,  // cap at 95% of window height (clip taller → use ScrollView)
        background: .dash.secondaryBackground, // also fills the home-indicator strip
        cornerRadius: 24          // iOS 16.4..<26; iOS 26+ keeps system corners
    ) {
        MyContent()
    }
}
```

`.selfSizingSheet(…)` (a `View` extension) measures the wrapped content directly via a
`GeometryReader` and drives `presentationDetents([.height(measured)])`. **iOS 16+** only;
a **no-op below iOS 16**. The measured content must have a finite intrinsic height (no
greedy `Spacer`/`maxHeight: .infinity`), or the measurement is wrong.
`BottomSheetHeightPreferenceKey` is exposed for advanced cases.

`background` fills the sheet **and** its presentation. The measured height excludes the
home-indicator inset that `presentationDetents([.height])` adds back, so that strip lies
outside the sheet's own stack — without the presentation fill it shows the system
background as a pale band along the bottom edge, whatever the content is styled with.

---

## MenuViewModifier

File `ViewModifiers/MenuViewModifier.swift` · `@available(iOS 14, macOS 11, *)`

Card chrome: inner padding, a rounded (radius 20, continuous) `secondaryBackground` fill,
and a soft DS shadow. Use it to wrap grouped content (e.g. a stack of `MenuItem`s) into a
floating card.

```swift
VStack(spacing: 0) { /* rows */ }
    .modifier(MenuViewModifier(shadowRadius: 10, innerPadding: 6))
```

The shadow uses `Color.dash.shadow`, which is adaptive (subtle on light, `.clear` on dark).
