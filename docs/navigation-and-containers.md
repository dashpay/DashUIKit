# Navigation & containers

Structural chrome — nav bars, bottom sheets, and card styling.

---

## NavigationBar

File `Components/NavigationBar.swift`

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

File `Components/TopIntro/TopIntroView.swift`

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

File `Components/BottomSheet/BottomSheet.swift`

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
  (`.large` / `.medium` / `.height`). Wraps content in a `NavigationView`.
- **`fillsHeight: false`** — natural height; pair with `.selfSizingSheet(…)` so the sheet
  snaps to its content.

`isDismissalEnabled` says whether the sheet may dismiss **itself**: it blocks the
interactive swipe and the close button's default `dismiss()`. The binding is dynamic, so a
host can lock the sheet while signing or broadcasting and restore it afterward — and
because the flag is passed to the modifier rather than switching between two view trees,
flipping it leaves the content, and every piece of `@State` inside it, untouched.

It does not silence `onClose`. A host that took the close action over keeps it, which is
how "the swipe is blocked, but closing asks for confirmation" is expressed:

```swift
BottomSheet(
    title: "Edit note",
    showBackButton: $showBack,
    isDismissalEnabled: .constant(false),   // swipe is blocked
    onClose: { showsDiscardAlert = true }   // …the button still reaches the host
) { … }
```

The close button goes inert on its own when a tap would do nothing — dismissal disabled and
no `onClose` — and `isCloseButtonEnabled: false` takes it away outright. An inert button is
visibly dimmed and exposes the disabled accessibility trait. Use `showsCloseButton: false`
when the sheet should have no close affordance at all.

Swipe blocking uses `interactiveDismissDisabled`.

`onClose` covers the **close button only**: an interactive swipe dismisses the sheet
without calling it. A host that has to hear about every dismissal should also pass
`onDismiss:` to the presenting `.sheet`.

All of these options preserve the existing behavior when omitted.

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
        cornerRadius: 24          // below iOS 26; iOS 26+ keeps system corners
    ) {
        MyContent()
    }
}
```

`.selfSizingSheet(…)` (a `View` extension) measures the wrapped content directly via a
`GeometryReader` and drives `presentationDetents([.height(measured)])`. The measured
content must have a finite intrinsic height (no
greedy `Spacer`/`maxHeight: .infinity`), or the measurement is wrong.
`BottomSheetHeightPreferenceKey` is exposed for advanced cases.

`background` fills the sheet **and** its presentation. The measured height excludes the
home-indicator inset that `presentationDetents([.height])` adds back, so that strip lies
outside the sheet's own stack — without the presentation fill it shows the system
background as a pale band along the bottom edge, whatever the content is styled with.

## SheetFeature

File `Components/BottomSheet/SheetFeature.swift` · public

One "here is what this gives you" line for a `BottomSheet`: an icon beside a name and a
sentence. Stack several to describe what a feature unlocks.

```swift
SheetFeature(
    title: "Identity",
    description: "Register a username and be paid by name instead of an address.",
    icon: .custom("feature-identity", bundle: .dashUIKit),
    iconColor: Color.dash.purple)                            // omit to keep the asset's own colours

SheetFeature(title: "Custom", description: "…") {            // or any view in the slot
    Circle().fill(Color.dash.blueAlpha10)
}
```

The icon slot is a `ViewBuilder`, not a `DashIconSource`, because the leading mark is not
always an image — a badge or a coloured container belongs there too. It is framed to 40×40
so a column of features stays aligned whatever each row puts in it. The convenience initializer takes an optional `iconColor`: given one, the asset is drawn
as a template in that colour; omitted, it renders as authored — the only way an icon with
more than one colour keeps them, since a template flattens everything to a single tint.

---

## MenuViewModifier

File `ViewModifiers/MenuViewModifier.swift`

Card chrome: inner padding, a rounded (radius 20, continuous) `secondaryBackground` fill,
and a soft DS shadow. Use it to wrap grouped content (e.g. a stack of `MenuItem`s) into a
floating card.

```swift
VStack(spacing: 0) { /* rows */ }
    .modifier(MenuViewModifier(shadowRadius: 10, innerPadding: 6))
```

The shadow uses `Color.dash.shadow`, which is adaptive (subtle on light, `.clear` on dark).
