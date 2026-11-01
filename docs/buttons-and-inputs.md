# Buttons & inputs

Interactive controls for tapping and text/number entry.

---

## DashButton

File `Button/DashButton.swift`

The design-system button. Supports leading/trailing icons, a loading spinner,
optional full-width fill, four sizes, and twelve styles.

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
- Tinted: `.tintedBlue`, `.tintedRed`, `.tintedGray`, `.tintedWhite`
- Stroke: `.strokeGray` (transparent fill + 1pt border)
- Plain (no background): `.plainBlue`, `.plainBlack`, `.plainRed`, `.plainWhite`

Notes: `isLoading` both shows a `ProgressView` and disables the button. The `…White` /
`filledWhiteBlue` styles are intended for use on a blue background.

---

## DashSwitch

File `Components/DashSwitch.swift` · **UIKit only**
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

## SwitchView

File `Components/Switch/SwitchView.swift`

The design system's switch: the DS track and thumb drawn in SwiftUI, on iOS and macOS.
`MenuItem`'s `.toggle` accessory uses it. It takes its enabled state from the environment,
so `.disabled(true)` dims it and stops the tap. Use it where the DS switch is drawn;
`DashSwitch` is the system switch with the DS tint, UIKit only.

```swift
@State private var isOn = false
SwitchView(isOn: $isOn)
    .accessibilityLabel("Advanced mode")   // optional, see below
```

To assistive technologies and UI tests it is a native switch-style `Toggle` with a hidden
label: the same traits, the same state value, which VoiceOver speaks in the user's
language, dimmed when disabled, and a double-tap flips `isOn`. Its own label is empty:
name it with `.accessibilityLabel(_:)`, or put it in a row that combines its children
(`.accessibilityElement(children: .combine)`), which then reads the row's text as the
label and the switch's state as the value. On iOS, UI tests read the state as the value
`"1"` / `"0"`, as for any `Toggle`.

---

## SearchBar

File `Components/SearchBar.swift` · **UIKit only**

Rounded search field with magnifying-glass icon and inline clear (✕) button.

```swift
@State private var query = ""
SearchBar(text: $query, placeholder: "Search coins")   // placeholder optional
```

Behavior:

- An animated **Cancel** button slides in while the field has focus (clears text + resigns
  focus on tap).
- Focus is internal (`@FocusState`): a host can neither read nor set it.
- Typed text is `.subhead` in `Color.dash.primaryText`, the same size as the placeholder.
  Like every `Font.dash` token it is a fixed size and does not scale with Dynamic Type.

Default placeholder is the localized "Search". Background uses `Color.dash.searchBackground`.

---

## AddressFieldView

File `Components/AddressFieldView.swift` · **UIKit only**

A labeled crypto-address input with a trailing action button (scan-QR when empty, clear
when filled), error styling, and a multi-line read-out state. Uses a vertical
axis field (1–2 lines).

Also the general-purpose text input: its three parts — label, field, help text — are the
design system's `Input` component, so it is what any labeled field is built from, not
only an address one. The scan-QR button appears **only when `onScanQR` is given**; a
field for something with no QR form (a username, a note) passes no handler and gets no
trailing glyph while empty.

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

- **Ring** (3pt, hard-edged, outside the field — Figma's `0 0 0 3px`):
  `redAlpha20` while `hasError`, `blueAlpha20` while
  focused, and none once `isAccepted` — the field stops asking for attention when the
  content has passed whatever the host validates it against. An error still overrides it.
- **Focused:** clear background + gray border.
- **Error:** red-tinted background, `errorText` shown beneath.
- **Blurred + filled (no error):** clean read-out — the trailing action button is hidden
  but kept in the layout (opacity 0, non-interactive) so the field width/wrapping doesn't
  shift between focused/unfocused.
- **Disabled:** field non-editable, action button omitted.

`showsClearButton: false` drops the trailing ✕ for a field short enough to clear by hand;
with no `onScanQR` either, no trailing space is reserved at all.

---

## Criteria

File `Components/Criteria.swift`

A block of requirements with their status — the check-list under a username or password
field. One mark per row says whether that rule is met.

```swift
Criteria([
    Criterion(text: "Between 3 and 23 characters", state: .met),
    Criterion(text: "Letters, numbers and hyphens only", state: .failed),
    Criterion(text: "You need to have more 0.25 Dash to create this username", state: .blocking),
    Criterion(text: "Username available", state: .checking),
])
```

`init(_ items: [Criterion], spacing: CGFloat = 10)` — `spacing` is the gap between rows.

### States

| `CriterionState` | Mark | Text |
|---|---|---|
| `.pending` | empty ring, `gray300Alpha50` | primary |
| `.checking` | circular spinner in the mark's box | primary |
| `.met` | green disc, white tick | primary |
| `.failed` | red disc, white cross | primary |
| `.blocking` | red disc, white cross | `errorText` |
| `.warning` | yellow disc, white exclamation | primary |

`.failed` and `.blocking` draw the same mark: the difference is whether the rule is the
reason the user cannot continue, which is what colours the text.

A rule that should not be shown is simply left out of the array — there is no "hidden"
state, matching the design system, which has no mark for one.

### Icon slot

The design system models this row as an icon slot plus text, so a row can carry artwork
of its own instead of a standard disc. It is rendered in the same 19pt box, untinted:

```swift
Criterion(text: "Listed in the marketplace", icon: .custom("tag.badge", bundle: .main))
```

### Geometry

Fixed by the design system, not by the caller: 6pt between mark and text; the mark is
19pt centred in a 26pt box, which sets the row height; the text is `.dashFont(.footnote)`
with 4pt of vertical padding, and wraps rather than truncates.

The `met` tick and the `warning` exclamation are drawn in this file rather than reusing
`CheckmarkIcon`: that icon comes from a different source SVG whose polyline is about a
tenth flatter than this one. The `failed` cross does reuse `XmarkIcon`, whose shape is
identical once scaled.

> The design system draws three icons for this row — default, cross and tick. `.warning`
> has no artwork yet and is drawn here to match the others' weight; swap it for the real
> asset when it lands.

---

## SimpleSelect

File `Components/SimpleSelect.swift`

One option in a short list the user picks from: a title, an optional line saying what picking
it means, and a card that carries the selection itself. The card *is* the control — there is no
trailing radio or checkmark — so the description sits inside the hit target.

```swift
VStack(spacing: 20) {
    SimpleSelect(
        title: "Shielded balance",
        description: "Keeps your username private",
        isSelected: selection == .shielded,
        action: { selection = .shielded })
    SimpleSelect(
        title: "Dash balance",
        description: "Funds will be traceable to your username",
        isSelected: selection == .core,
        action: { selection = .core })
}
```

`init(title: String, description: String? = nil, isSelected: Bool, action: @escaping () -> Void)`
— stateless: the host owns the selection and passes `isSelected` for each option.

| State | Border | Fill |
|---|---|---|
| selected | `blue`, 1.5pt | `blueAlpha5` |
| unselected | `gray300Alpha30`, 1.5pt | none |

The card takes the full width it is offered (options are compared in a column), has a 16pt
corner radius and 20 × 12pt padding; the title is `.subheadMedium`, the description `.footnote`
in `secondaryText`. The whole card is tappable, including an unselected card with no fill.
VoiceOver reads it as a button, with the selected trait on the chosen option.

For a row with an icon, a trailing value or an explicit radio/checkbox mark, use
[`RadioButtonRow`](lists-and-rows.md#radiobuttonrow).

---

## SegmentedControl

File `Components/SegmentedControl.swift`

A row of mutually exclusive options on a grey track, with a white pill under the selected one.
Tap a segment or drag across the track; the pill springs to the new segment.

```swift
SegmentedControl(options: ["Active", "Disconnected", "Expired"], selection: $filter)

SegmentedControl(
    options: Direction.allCases,
    selection: $direction,
    label: { $0.title },
    icon: { option, isSelected in option.icon(isSelected: isSelected).source })
```

- `init(options: [T], selection: Binding<T>, label: @escaping (T) -> String, icon: ((T, Bool) -> DashIconSource)? = nil)`
- `init(options: [String], selection: Binding<String>)` — the options are their own labels.

`icon` gets the option and whether it is selected, so a segment can switch between two
artworks (`DashIcon.SegmentedControl.receive` / `.receiveDisabled`) rather than tint one.

The text-only control is 40pt tall; with icons it sizes to its content (17pt artwork over
the label). Neither grows when its container offers more height. Labels are `.footnoteMedium`
in `segmentControlContSelected` / `segmentControlContNotSelected`. Track
`segmentControlBackgroundGroup`, 20pt corners, 4pt inset; pill `segmentControlBackground` with
16pt corners and the `shadow` token. VoiceOver reads one button per segment, with the selected
trait on the chosen one.

The first option equal to `selection` is the selected segment; a selection that matches no
option selects none and draws no pill. Options are expected to be distinct. In a right-to-left
layout the row mirrors, and the pill and drag-to-select follow it.

---

## NumericKeyboardView

File `Components/NumericKeyboardView.swift`

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

Key-press logic lives in `NumericKeyboardLocaleSupport` (public, unit-testable):
appends digits, inserts at most one decimal separator (only when `showDecimalSeparator`),
ignores the grouping separator, and `⌫` removes the last character. The action button is
enabled only when `value` is non-empty **and** `actionEnabled` is true.

### Hardware keyboards

The pad is made of buttons and installs no text responder, so a physical keyboard reaches
it only if the host adds one. Route those keystrokes through the same rules rather than
reimplementing them — a second copy is how `1,000` typed in `en_US` turns into `1.000`:

```swift
// In the host's `UIKeyInput` responder.
override func insertText(_ text: String) {
    for character in text {
        guard let key = NumericKeyboardLocaleSupport.key(forTyped: character, locale: locale) else { continue }
        value = NumericKeyboardLocaleSupport.applyKeyPress(
            value: value, key: key, showDecimalSeparator: true, locale: locale
        )
    }
}

override func deleteBackward() {
    value = NumericKeyboardLocaleSupport.applyKeyPress(
        value: value, key: NumericKeyboardLocaleSupport.deleteKey, showDecimalSeparator: true, locale: locale
    )
}
```

`key(forTyped:locale:)` returns `nil` for characters the pad has no key for. A typed `.` or
`,` maps to the locale's decimal separator, except when it *is* the locale's grouping
separator — that one is passed through so `applyKeyPress` drops it, exactly as a tapped key
would be.
