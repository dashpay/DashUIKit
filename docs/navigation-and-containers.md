# Navigation & containers

Structural chrome — nav bars, bottom sheets, and card styling.

---

## NavigationBar

File `Components/NavigationBar.swift`

A custom three-slot top bar: **leading**, **central**, **trailing**, each a
`@ViewBuilder`. The leading/trailing pair is laid out in an `HStack` with a `Spacer`
between; the central content is overlaid centered (so a long title stays centered
regardless of side content). Min height 74.

```swift
NavigationBar(
    leading: { NavigationBarElement.back.button { dismiss() } },
    central: {
        Text("Title")
            .dashFont(.subheadMedium)
            .foregroundStyle(Color.dash.primaryText)
    },
    trailing: { NavigationBarElement.info.button { showInfo() } }
)
```

Convenience initializers let you omit any slot (e.g. only `leading`, or `central` +
`trailing`) via `EmptyView` specializations.

**`NavigationBarElement`** — bundled icon buttons backed by the nav assets:
`.back`, `.close`, `.plus`, `.info`. Each provides:

- `.icon` — the element as drawn. `.back`, `.close` and `.plus` are a vector glyph
  (`Color.dash.toolbarRoundContent`) centred in a 34×34 circle with a 1.5pt
  `Color.dash.toolbarRoundBorder` stroke, so both adapt to light/dark mode.
  `.info` is a self-contained 24×24 icon.
- `.button(action:)` — the icon as a button. The touch area is 44pt tall and at least 44pt wide
  for hit testing, while the element keeps its hug width in layout (so a circle stays on the
  bar's 20pt inset). Press animation: scale 0.88 + opacity 0.7; dimmed to 0.35 opacity while
  `.disabled(true)`. VoiceOver reads its label ("Back", "Close", "Add", "Info"); UI tests find it
  by its accessibility identifier (`navigationbar-back`, `navigationbar-close`,
  `navigationbar-plus`, `navigationbar-info`), which does not change with the language:
  `app.buttons["navigationbar-back"]` in XCUITest, `id: "navigationbar-back"` in Maestro (its
  `text:` selector matches the label). An identifier set on an ancestor that is not an
  accessibility container (a host's header `HStack`, the `NavigationBar`) can replace the button's;
  add `.accessibilityElement(children: .contain)` to that ancestor. The bare `.icon` carries no
  identifier.
  `BottomSheet`'s header back and close buttons are these buttons, so they carry the same
  identifiers. `NavigationBarCircleButton` and `NavigationBarCircleMenu` carry none: give
  them your own with `.accessibilityIdentifier(_:)`.

### Custom circle actions

For a bar action with no bundled element, use the same token circle with your own icon. All
three take a `DashIconSource`: an SF Symbol (`.system`) is set in `Font.dash.subheadMedium`;
a `.custom` / `.uiImage` asset renders at its own size, so draw it for a 34pt circle.
`accessibilityLabel` is a `Text`, so `Text("Refresh")` is looked up in the host's string table
like a SwiftUI `Button` title (`Text(verbatim:)` for an already-localized string).

File `Components/NavigationBarCircleButton.swift` — **`NavigationBarCircleButton(_:accessibilityLabel:action:)`**,
a bar button with the same touch area, press animation and disabled dimming as
`NavigationBarElement.button(action:)`:

```swift
NavigationBarCircleButton(.system("arrow.clockwise"), accessibilityLabel: Text("Refresh"), action: reload)
    .disabled(isReloading)
```

Each element's hit area is widened to at least 44pt beyond its 34pt circle (5pt per side), so
put adjacent bar buttons **at least 10pt apart** (`HStack(spacing: 10)`) or the hit areas
overlap and a tap between them goes to the later one.

File `Components/NavigationBarCircleMenu.swift` — **`NavigationBarCircleMenu(_:accessibilityLabel:content:)`**,
a `Menu` with the circle as its label (e.g. a ⋯ overflow). It uses the bar's button style, so its press
animation and disabled dimming match the circle buttons:

```swift
NavigationBarCircleMenu(.system("ellipsis"), accessibilityLabel: Text("More")) {
    Button("Select") { startSelecting() }
}
```

File `Components/NavigationBarCircleIcon.swift` — **`NavigationBarCircleIcon(_:)`**, the circle on its
own (34×34, 1.5pt `toolbarRoundBorder` stroke, `toolbarRoundContent` tint, the whole circle
hit-testable). `.back` / `.close` / `.plus` draw through it; reach for it only to build
something the two above don't cover.

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
        cornerRadius: 24,         // below iOS 26; iOS 26+ keeps system corners
        animation: .easeInOut     // optional: animate height changes after the first
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

Both `BottomSheet.selfSizing(…)` and `.selfSizingSheet(…)` have an overload that takes
`animation:`, for content that switches in place between views of different heights — a
preset list and a keypad or a calendar. With it, a change of the measured height after the
first one is applied inside `withAnimation(animation)` (exceptions below): the
content changes first, and the detent follows it in an animation instead of jumping once
the new content is measured.

- The sheet itself resizes with the system sheet animation; the given animation applies to
  the SwiftUI side of the change (the measured height), so its curve may not show on the
  sheet's edge.
- The first measurement replaces `fallback` (or `.medium` when there is none) without
  `animation`.
- While the detent catches up, the content stays at the top edge of the sheet, whether it
  grew or shrank. Content taller than the cap is clipped at the bottom.
- With Reduce Motion on, the sheet leaves `animation` out; the content is still held at
  the top edge.
- A change that leaves the capped detent where it is (both heights above the
  `maxHeightFraction` cap) is not animated.
- Limit: if the content reports a provisional height while the sheet is being presented
  and then the settled one, the second step counts as a change and can animate.

Without `animation` (or with `nil`) the sheet adds no animation to a height change; a
transaction the host is already animating in still applies.

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
    icon: DashIcon.Features.identity.source,
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

The shadow uses `Color.dash.shadow`, the `Shadow` colorset (subtle on light, clear on dark).
