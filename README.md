# DashUIKit

A SwiftUI design-system library for Dash Core Group apps. It ships reusable UI
components, design tokens (colors and typography), illustrations, and a handful of
layout utilities — everything needed to assemble Dash product screens with a
consistent look.

Every component is **presentational and value-driven**: it owns no business logic,
networking, or persistence. You pass in formatted strings, flags, bindings, and
callbacks; the component renders and reports user intent back to you.

- **Platforms:** iOS 14+ (some features light up on 15 / 16 / 17 with graceful fallbacks)
- **Swift tools:** 6.3
- **Module:** `import DashUIKit`

## Installation

Swift Package Manager. Add the dependency to your `Package.swift`:

```swift
.package(url: "https://github.com/romchornyi/DashUIKit.git", branch: "main")
```

…or in Xcode: **File ▸ Add Package Dependencies…** and paste the repo URL.

Then `import DashUIKit` wherever you build views.

## Quick start

```swift
import SwiftUI
import DashUIKit

struct Example: View {
    @State private var amount = ""

    var body: some View {
        VStack(spacing: 16) {
            Text("Send")
                .dashFont(.title2)                 // DS typography + line height
                .foregroundColor(.dash.primaryText) // DS color token

            DashButton(
                text: "Continue",
                fillsWidth: true,
                size: .large,
                style: .filledBlue
            ) {
                // handle tap
            }
        }
        .padding()
        .background(Color.dash.primaryBackground)
    }
}
```

## Documentation

Per-component reference lives in [`docs/`](docs/README.md) — open the index to see
the full catalog (API, props, behavior, and usage snippets). Use it to check whether
a component already exists before building your own.

## Component catalog

| Component | What it is | Doc |
|---|---|---|
| `DashButton` | Themed button — 4 sizes × 11 styles, icons, loading, full-width | [Buttons & inputs](docs/buttons-and-inputs.md) |
| `DashSwitch` | DS-tinted toggle | [Buttons & inputs](docs/buttons-and-inputs.md) |
| `SearchBar` | Search field with animated cancel (iOS 15+) and iOS 14 fallback | [Buttons & inputs](docs/buttons-and-inputs.md) |
| `AddressFieldView` | Crypto-address text field with QR / clear and error state | [Buttons & inputs](docs/buttons-and-inputs.md) |
| `NumericKeyboardView` | Locale-aware on-screen number pad with action button | [Buttons & inputs](docs/buttons-and-inputs.md) |
| `EnterAmountView` | Amount-entry screen control — single & dual-swap modes | [Amount & currency](docs/amount-and-currency.md) |
| `SwapAmountView` | Animated primary/secondary amount display | [Amount & currency](docs/amount-and-currency.md) |
| `DashAmount` | Renders a duffs `Int64` as a formatted Dash amount + symbol | [Amount & currency](docs/amount-and-currency.md) |
| `DashBalanceView` | Trailing balance (Dash amount + fiat sub-line) | [Amount & currency](docs/amount-and-currency.md) |
| `DashPickerView` | Compact inline segmented option picker | [Amount & currency](docs/amount-and-currency.md) |
| `CurrencyOption` | Fiat / Dash / coin enum driving symbols & display names | [Amount & currency](docs/amount-and-currency.md) |
| `CoinSelector` | Coin row — icon, name/code, price or "halted" badge | [Lists & rows](docs/lists-and-rows.md) |
| `MenuItem` | Settings/menu row with flexible trailing accessory | [Lists & rows](docs/lists-and-rows.md) |
| `RadioButtonRow` | Selectable row — radio or checkbox style | [Lists & rows](docs/lists-and-rows.md) |
| `List1View` | Simple label ↔ value row | [Lists & rows](docs/lists-and-rows.md) |
| `NavigationBar` | Custom three-slot nav bar + `NavigationBarElement` buttons | [Navigation & containers](docs/navigation-and-containers.md) |
| `BottomSheet` | Sheet chrome (grabber + nav bar) with self-sizing support | [Navigation & containers](docs/navigation-and-containers.md) |
| `MenuViewModifier` | Card chrome — rounded background + shadow | [Navigation & containers](docs/navigation-and-containers.md) |
| `Toast` | Blurred toast — warning/info/error/success/copied/loading | [Feedback](docs/feedback.md) |
| `LoadingIllustration` / `LoadingSpinner` | iOS-style activity spinner | [Feedback](docs/feedback.md) |
| `SuccessIllustration` / `ErrorIllustration` | 90×90 status badges | [Feedback](docs/feedback.md) |
| `XmarkIcon` | Code-drawn close (✕) icon | [Feedback](docs/feedback.md) |
| Geometry helpers | `readingFrame`, `readingLocation`, `ScrollViewWithOnScrollChanged`, `scaleToFitWidth` | [Utilities](docs/utilities.md) |
| Foundation | `Color.dash.*`, `Font.dash.*`, `.dashFont`, `DashIconSource` | [Foundation](docs/foundation.md) |

## Project layout

```
Sources/DashUIKit/
  Button/            DashButton
  Components/        Components (EnterAmount/, Geometry/, Icons/, Illustrations/)
  Table List/        List1View
  ViewModifiers/     MenuViewModifier
  Foundation/        Color / Font / typography / Image / Bundle helpers
  Resources/         Media.xcassets (colors, icons, illustrations)
```

## License

MIT — see the per-file headers.
