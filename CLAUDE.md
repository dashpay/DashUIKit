# DashUIKit context

SwiftUI design-system library for Dash Core Group apps. Pure UI components, design
tokens (colors / typography), and small layout utilities. No business logic, no
networking — every component is dumb and driven entirely by the values and closures
the host passes in.

- Swift tools: **6.3**
- Single library target **`DashUIKit`** (`import DashUIKit`)
- Assets live in `Sources/DashUIKit/Resources/Media.xcassets` and are reached via
  `Bundle.module` / `Bundle.dashUIKit`.

## Deployment target: iOS 18

The package targets **iOS 18 / macOS 15** (see `Package.swift`), matching dashwallet-ios,
the only consumer. Everything SwiftUI shipped up to iOS 17 — `@FocusState`,
`presentationDetents`, `presentationBackground`, the `#Preview` macro, `.isToggle` — is
available unconditionally, so components carry no `@available` annotation and no fallback
branch for it.

When writing or changing code:

- **Do not** add `@available(iOS …)` for anything at or below the floor; the package
  declares it once. Annotate only what genuinely needs a *higher* version than the
  floor, and then gate it with `if #available(...)` plus a path that works below it —
  `selfSizingSheet` does this for the iOS 26 corner styling (`#unavailable(iOS 26.0)`).
- Raising the floor again is a package-level decision, not a per-component one. If a
  component cannot work at the declared floor, say so in review rather than annotating
  around it.

## Where things are

```text
Sources/DashUIKit/
  Button/            DashButton (+ DashButtonSize / DashButtonStyle)
  Components/        Most components (one type per file)
    EnterAmount/     Amount-entry suite (EnterAmountView, SwapAmountView, …)
    Geometry/        Layout readers + scale-to-fit helpers
    Icons/           Code-drawn icons (XmarkIcon, CheckmarkIcon, ChevronIcon, InfoRoundIcon)
    Illustrations/   Loading / success / error illustrations
  Table List/        List1View (label/value row)
  ViewModifiers/     MenuViewModifier (card chrome)
  Foundation/        Color / Font / DashTextStyle / Image / line-height / Bundle
  Resources/         Media.xcassets (colors, icons, illustrations)
```

## Conventions (match these when adding code)

- **One public type per file**, named after the file. Heavy `#Preview` / `PreviewProvider`
  coverage under `#if DEBUG` is expected — add previews for every state.
- **Theming is asset-driven.** Never hardcode a `Color(...)`/hex. Use `Color.dash.<token>`
  (see `Foundation/Color+DashUI.swift`) — each maps to a named color set in the asset
  catalog with light/dark variants. Add a new token there, not inline.
- **Typography:** use `.dashFont(.subhead)` (sets font **and** design line height together)
  or `Font.dash.subhead` when you only need the font. Tokens defined in `DashTextStyle.swift`.
- **Icons:** pass a `DashIconSource` (`.system` / `.custom(name, bundle:)` / `.uiImage`) and
  render with `Image(dash: source)`. Custom assets resolve from `.dashUIKit`/`.module`.
- **Availability:** annotate public API with `@available(iOS 14, macOS 11, *)` (or higher only
  when a newer SwiftUI feature requires it, with an iOS 14 fallback path — see `SearchBar`,
  `BottomSheet`).
- **UIKit-only files** are wrapped in `#if canImport(UIKit)` (e.g. `SearchBar`, `Toast`,
  `AddressFieldView`, `DashSwitch`).
- **Localization:** user-facing strings use `NSLocalizedString(_, bundle: .module, comment:)`.
- Components are **stateless/value-driven** — state (`@Binding`) and callbacks live with the
  host. Don't add view models or persistence here.

## Build / preview

- This is a plain SwiftPM library — `swift build` compiles it; there is no app target.
- Develop visually with Xcode SwiftUI **#Previews** (open a file, use the canvas). Previews
  require iOS 17 for the `#Preview` macro; older `PreviewProvider` previews work back further.

## Component catalog

Full per-component reference (API, props, behavior, usage) lives in **`docs/`**. Start at
[`docs/README.md`](docs/README.md) — it indexes every component so you can check whether a
given UI element already exists before building a new one. The public surface is also
summarized in [`README.md`](README.md).
