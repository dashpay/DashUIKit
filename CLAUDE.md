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
the only consumer. Everything SwiftUI shipped up to iOS 18 — `@FocusState`,
`presentationDetents`, `presentationBackground`, the `#Preview` macro, `.isToggle` — is
available unconditionally, so components carry no `@available` annotation and no fallback
branch for it.

When writing or changing code:

- **Do not** add `@available(iOS …)` for anything at or below the floor; the package
  declares it once. An API newer than the floor is gated in the body with
  `if #available(...)` / `#unavailable(...)` plus a path that works below it, and the
  declaration stays unannotated — `selfSizingSheet` does this for the iOS 26 corner
  styling (`#unavailable(iOS 26.0)`).
- Raising the floor again is a package-level decision, not a per-component one. It is
  declared twice: `SnapshotTests/Package.swift` repeats it and must move with it. If a
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
  Table List/        List1View (label/value row), List8View (label/value row, optional avatar)
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
  Inside the library a bundled icon is a `DashIcon` case (`DashIcon.Toast.info.source`,
  `.image`), never a name built at runtime: CI rejects a lookup in `.dashUIKit` /
  `.module` whose name is not one literal, and a lookup in the host bundle (`.main`,
  `nil`, `.none`). It is a text scan: the call shapes it cannot follow (a bundle in a
  variable, `.custom(name)` with no bundle and no `dash:` / `icon:` label, …) are listed
  in the script header.
- **Availability:** don't annotate. The floor is declared in `Package.swift`; gate an API
  that needs something *newer* than it with `if #available(...)` in the body.
- **UIKit-only files** are wrapped in `#if canImport(UIKit)` (e.g. `SearchBar`, `Toast`,
  `AddressFieldView`, `DashSwitch`).
- **Localization:** user-facing strings use `NSLocalizedString(_, bundle: .module, comment:)`.
- **PR screenshots:** a PR that changes anything under `Sources/` or a package manifest
  (`Package.swift`, `Package@swift-*.swift`) shows Before / After screenshots (light and
  dark) in its description, as files dragged in (uploaded to GitHub) or embedded repository
  images pinned to a full commit SHA, or ticks "No visual change" and says why.
  CI (`Before / After screenshots`) enforces it.
- Components are **stateless/value-driven** — state (`@Binding`) and callbacks live with the
  host. Don't add view models or persistence here.
- CI enforces the mechanical ones with `.github/scripts/conventions.sh`: `DashIcon` ↔
  imagesets, `Color.dash` tokens ↔ colorsets, literal asset names and their bundle, no
  computed names in the package bundle, no colors built from components (`Color(red:…)`,
  hex), `NSLocalizedString` / `String(localized:)` with the package bundle, no
  `@available` at or below the floor.
  It does not check system colors (`Color.red`) or `Text("…")` keys. Run it from the repo
  root before pushing.

## Build / preview

- This is a plain SwiftPM library — `swift build` compiles it; there is no app target.
- Develop visually with Xcode SwiftUI **#Previews** (open a file, use the canvas).

## Snapshot tests

- Light and dark reference images of the main components live in the separate package
  `SnapshotTests/` (swift-snapshot-testing stays out of the library's manifest). See
  [`docs/snapshot-tests.md`](docs/snapshot-tests.md).
- The references are rendered by the `Snapshot tests (iOS Simulator)` CI job and compared only
  on its simulator runtime; elsewhere the tests are skipped. **Don't commit references recorded on
  your own simulator.**
- To update them after a deliberate visual change: push, let the snapshot job fail, then run
  `.github/scripts/fetch-snapshots.sh` from the repo root, review the images, commit.
- A new component state that matters visually gets a snapshot test in
  `SnapshotTests/Tests/DashUIKitSnapshotTests/<Component>SnapshotTests.swift`, as well as its preview.

## Component catalog

Full per-component reference (API, props, behavior, usage) lives in **`docs/`**. Start at
[`docs/README.md`](docs/README.md) — it indexes every component so you can check whether a
given UI element already exists before building a new one. The public surface is also
summarized in [`README.md`](README.md).
