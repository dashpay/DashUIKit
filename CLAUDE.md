# DashUIKit context

SwiftUI design-system library for Dash Core Group apps. Pure UI components, design
tokens (colors / typography), and small layout utilities. No business logic, no
networking — every component is dumb and driven entirely by the values and closures
the host passes in.

- Swift tools: **6.3**
- Single library target **`DashUIKit`** (`import DashUIKit`)
- Assets live in `Sources/DashUIKit/Resources/Media.xcassets` and are reached via
  `Bundle.module` / `Bundle.dashUIKit`.

## ⚠️ Hard constraint: must support iOS 14

**This library must remain available on iOS 14.** The package deployment target is
`iOS(.v14)` (see `Package.swift`) and this is non-negotiable — every public component
must be usable from an iOS 14 host.

When writing or changing code:

- Annotate public API with `@available(iOS 14, macOS 11, *)` (or `macOS 10.15` for
  Foundation-level token types). **Do not** make a component's *minimum* availability
  higher than iOS 14.
- If you need a SwiftUI API introduced after iOS 14 (e.g. `@FocusState` 15,
  `presentationDetents` 16, `#Preview` macro 17), **gate it with `if #available(...)`
  and provide an iOS 14 fallback path** — never raise the whole component's floor.
  See `SearchBar` (15+ focus path + 14 legacy path), `BottomSheet` / `selfSizingSheet`
  (16+ detents, no-op below), and `AddressFieldView` (17 axis field + older fallback).
- It is fine for `#Preview`-only code to require iOS 17 — previews are `#if DEBUG` and
  never ship — but the component itself must still build and run on iOS 14.

## Where things are

```
Sources/DashUIKit/
  Button/            DashButton (+ DashButtonSize / DashButtonStyle)
  Components/        Most components (one type per file)
    EnterAmount/     Amount-entry suite (EnterAmountView, SwapAmountView, …)
    Geometry/        Layout readers + scale-to-fit helpers
    Icons/           Code-drawn icons (XmarkIcon)
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
