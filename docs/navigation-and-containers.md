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
        fillsHeight: true                     // greedy: fills the sheet
    ) {
        MyContent()
    }
}
```

- **`fillsHeight: true`** (default) — content fills the sheet; pair with an explicit detent
  (`.large` / `.medium` / `.height`). Wraps content in a `NavigationView`.
- **`fillsHeight: false`** — natural height; pair with `.selfSizingSheet(…)` so the sheet
  snaps to its content.

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
