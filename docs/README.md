# DashUIKit — component catalog

This is the searchable reference for everything DashUIKit ships. Before building a new
UI element, scan this index to see whether it already exists.

All components are **presentational and value-driven** — you pass strings/flags/bindings
and callbacks; they render and report intent. They require `import DashUIKit` and target
**iOS 14+** (newer SwiftUI features are gated with fallbacks).

## Pages

- **[Foundation](foundation.md)** — design tokens: colors (`Color.dash.*`), typography
  (`Font.dash.*`, `.dashFont`, `DashTextStyle`), icons (`DashIconSource`, `Image(dash:)`),
  bundle access.
- **[Buttons & inputs](buttons-and-inputs.md)** — `DashButton`, `DashSwitch`, `SearchBar`,
  `AddressFieldView`, `NumericKeyboardView`.
- **[Amount & currency](amount-and-currency.md)** — `EnterAmountView`, `SwapAmountView`,
  `ReceiveEstimateView`, `DashAmount`, `DashBalanceView`, `DashPickerView`,
  `CurrencyOption`.
- **[Lists & rows](lists-and-rows.md)** — `CoinSelector`, `MenuItem`,
  `ConverterCard`, `TransactionView`, `RadioButtonRow`, `List1View`.
- **[Navigation & containers](navigation-and-containers.md)** — `NavigationBar`,
  `NavigationBarElement`, `TopIntroView`, `BottomSheet`, `MenuViewModifier`.
- **[Feedback](feedback.md)** — `Toast`, `SystemMessageView`,
  `LoadingIllustration` / `LoadingSpinner`, `SuccessIllustration`, `ErrorIllustration`,
  `XmarkIcon`.
- **[Utilities](utilities.md)** — geometry readers (`readingFrame`, `readingLocation`),
  `ScrollViewWithOnScrollChanged`, `scaleToFitWidth`.

## Alphabetical index

| Symbol | Page |
|---|---|
| `AddressFieldView` | [Buttons & inputs](buttons-and-inputs.md#addressfieldview) |
| `BottomSheet` | [Navigation & containers](navigation-and-containers.md#bottomsheet) |
| `Bundle.dashUIKit` | [Foundation](foundation.md#bundle) |
| `CoinSelector` | [Lists & rows](lists-and-rows.md#coinselector) |
| `Color.dash.*` (`DashColors`) | [Foundation](foundation.md#colors) |
| `ConverterArrowBadge` | [Lists & rows](lists-and-rows.md#converterarrowbadge) |
| `ConverterCard` | [Lists & rows](lists-and-rows.md#convertercard) |
| `ConverterCardItem` | [Lists & rows](lists-and-rows.md#convertercarditem) |
| `ConverterCardRow` | [Lists & rows](lists-and-rows.md#convertercardrow) |
| `CurrencyOption` | [Amount & currency](amount-and-currency.md#currencyoption) |
| `DashAmount` | [Amount & currency](amount-and-currency.md#dashamount) |
| `DashBalanceView` | [Amount & currency](amount-and-currency.md#dashbalanceview) |
| `DashButton` (`DashButtonSize`, `DashButtonStyle`) | [Buttons & inputs](buttons-and-inputs.md#dashbutton) |
| `DashIconSource` / `Image(dash:)` | [Foundation](foundation.md#icons) |
| `DashPickerView` | [Amount & currency](amount-and-currency.md#dashpickerview) |
| `DashSwitch` | [Buttons & inputs](buttons-and-inputs.md#dashswitch) |
| `DashTextStyle` / `.dashFont` / `Font.dash.*` | [Foundation](foundation.md#typography) |
| `EnterAmountView` (`EnterAmountStyle`) | [Amount & currency](amount-and-currency.md#enteramountview) |
| `ErrorIllustration` | [Feedback](feedback.md#successillustration--errorillustration) |
| `List1View` | [Lists & rows](lists-and-rows.md#list1view) |
| `LoadingIllustration` / `LoadingSpinner` | [Feedback](feedback.md#loadingillustration--loadingspinner) |
| `MenuItem` (`MenuItemAccessory`) | [Lists & rows](lists-and-rows.md#menuitem) |
| `MenuViewModifier` | [Navigation & containers](navigation-and-containers.md#menuviewmodifier) |
| `NavigationBar` / `NavigationBarElement` | [Navigation & containers](navigation-and-containers.md#navigationbar) |
| `NumericKeyboardView` | [Buttons & inputs](buttons-and-inputs.md#numerickeyboardview) |
| `RadioButtonRow` | [Lists & rows](lists-and-rows.md#radiobuttonrow) |
| `readingFrame` / `readingLocation` | [Utilities](utilities.md#frame--location-readers) |
| `ReceiveEstimateView` | [Amount & currency](amount-and-currency.md#receiveestimateview) |
| `ScrollViewWithOnScrollChanged` | [Utilities](utilities.md#scrollviewwithonscrollchanged) |
| `scaleToFitWidth` | [Utilities](utilities.md#scaletofitwidth) |
| `SearchBar` | [Buttons & inputs](buttons-and-inputs.md#searchbar) |
| `SuccessIllustration` | [Feedback](feedback.md#successillustration--errorillustration) |
| `SwapAmountView` | [Amount & currency](amount-and-currency.md#swapamountview) |
| `SystemMessageView` | [Feedback](feedback.md#systemmessageview) |
| `Toast` (`ToastStyle`) | [Feedback](feedback.md#toast) |
| `TopIntroView` | [Navigation & containers](navigation-and-containers.md#topintroview) |
| `TransactionView` | [Lists & rows](lists-and-rows.md#transactionview) |
| `XmarkIcon` | [Feedback](feedback.md#xmarkicon) |
