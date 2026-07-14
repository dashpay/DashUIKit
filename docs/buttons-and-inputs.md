# Buttons & inputs

Interactive controls for tapping and text/number entry.

---

## DashButton

File `Button/DashButton.swift` · `@available(iOS 14, macOS 11, *)`

The design-system button. Supports leading/trailing icons, a loading spinner,
optional full-width fill, four sizes, and eleven styles.

```swift
DashButton(
    text: "Withdraw funds",
    leadingIcon: nil,            // DashIconSource?
    trailingIcon: nil,           // DashIconSource?
    isEnabled: true,
    isLoading: false,            // shows ProgressView instead of label, disables tap
    fillsWidth: false,           // true → frame(maxWidth: .infinity)
    size: .large,
    style: .filledBlue,
    action: { /* tap */ }
)
```

**`DashButtonSize`** — `.large` · `.medium` · `.small` · `.extraSmall`. Drives padding,
corner radius, icon gap, and font size (16 / 14 / 13 / 12 pt).

**`DashButtonStyle`** — colors resolve from `Color.dash.button…` tokens (enabled +
disabled variants):

- Filled: `.filledBlue`, `.filledRed`, `.filledWhiteBlue`
- Tinted: `.tintedBlue`, `.tintedGray`, `.tintedWhite`
- Stroke: `.strokeGray` (transparent fill + 1pt border)
- Plain (no background): `.plainBlue`, `.plainBlack`, `.plainRed`, `.plainWhite`

Notes: `isLoading` both shows a `ProgressView` and disables the button. The `…White` /
`filledWhiteBlue` styles are intended for use on a blue background.

---

## DashSwitch

File `Components/DashSwitch.swift` · `@available(iOS 14, *)` · **UIKit only**
(`#if canImport(UIKit)`)

A thin wrapper over `Toggle` tinted with the DS "on" track color
(`switchTrackFillOn`). Labels hidden.

```swift
@State private var isOn = true
DashSwitch(isOn: $isOn)
```

> A fully custom `DashToggleStyle` (using the thumb/off-track tokens) is noted as a TODO
> in the source for when pixel-exact fidelity is required.

---

## SearchBar

File `Components/SearchBar.swift` · `@available(iOS 14, *)` · **UIKit only**

Rounded search field with magnifying-glass icon and inline clear (✕) button.

```swift
@State private var query = ""
SearchBar(text: $query, placeholder: "Search coins")   // placeholder optional
```

Behavior:

- **iOS 15+** (`SearchBarFocused`): uses `@FocusState`; an animated **Cancel** button
  slides in while editing (clears text + resigns focus on tap).
- **iOS 14** (`SearchBarLegacy`): static bar without the focus-driven cancel animation.

Default placeholder is the localized "Search". Background uses `Color.dash.searchBackground`.

---

## AddressFieldView

File `Components/AddressFieldView.swift` · `@available(iOS 15, macOS 12, *)` · **UIKit only**

A labeled crypto-address input with a trailing action button (scan-QR when empty, clear
when filled), error styling, and a multi-line read-out state. iOS 17+ uses a vertical
axis field (1–3 lines); older iOS uses a single-line field.

```swift
@State private var address = ""
AddressFieldView(
    text: $address,
    label: "Destination address",
    placeholder: "BTC address",
    hasError: false,
    errorText: nil,            // shown in red below when non-nil
    isDisabled: false,
    onScanQR: { /* open scanner */ }
)
```

State-driven styling:

- **Focused:** clear background + gray border.
- **Error:** red-tinted background, `errorText` shown beneath.
- **Blurred + filled (no error):** clean read-out — the trailing action button is hidden
  but kept in the layout (opacity 0, non-interactive) so the field width/wrapping doesn't
  shift between focused/unfocused.
- **Disabled:** field non-editable, action button omitted.

---

## NumericKeyboardView

File `Components/NumericKeyboardView.swift` · `@available(iOS 14, macOS 11, *)`

A custom on-screen numeric pad (1–9, 0, decimal separator, delete) plus a primary
`DashButton` action and optional helper text. **Locale-aware**: the decimal separator and
grouping-separator handling come from the supplied `Locale`.

```swift
@State private var value = ""
NumericKeyboardView(
    value: $value,
    showDecimalSeparator: true,                 // false → bottom-left key is blank
    locale: .autoupdatingCurrent,               // drives separator + key filtering
    actionButtonText: "Verify",
    actionEnabled: true,                         // combined with value non-empty
    inProgress: false,                           // dims keys + shows button spinner
    helperText: nil,
    actionHandler: { /* submit value */ }
)
```

Key-press logic lives in `NumericKeyboardLocaleSupport` (internal, unit-testable):
appends digits, inserts at most one decimal separator (only when `showDecimalSeparator`),
ignores the grouping separator, and `⌫` removes the last character. The action button is
enabled only when `value` is non-empty **and** `actionEnabled` is true.
