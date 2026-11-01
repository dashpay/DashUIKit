import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

public struct BottomSheet<Content: View>: View {
    @Environment(\.dismiss) private var dismiss

    public var title: String = ""
    @Binding public var showBackButton: Bool
    public var onBackButtonPressed: (() -> Void)? = nil
    /// Whether the sheet may dismiss itself: blocks the interactive swipe, and blocks the
    /// close button's default `dismiss()`. It does not silence `onClose` — a host that took
    /// the close action over stays in charge of it, which is what makes "block the swipe but
    /// ask before closing" expressible. Use `isCloseButtonEnabled` to disable the button too.
    @Binding public var isDismissalEnabled: Bool
    public var showsCloseButton: Bool = true
    /// Whether the close button accepts taps. It also goes inert on its own when it would have
    /// nothing left to do — dismissal disabled and no `onClose` to run.
    public var isCloseButtonEnabled: Bool = true
    /// Overrides the close button's action; the callback is then responsible for dismissing the
    /// sheet. It covers the **button only** — an interactive swipe dismisses the sheet without
    /// calling it, so a host that needs to hear about every dismissal should also pass
    /// `onDismiss:` to the presenting `.sheet`.
    public var onClose: (() -> Void)? = nil
    /// `true` (default) — greedy: content fills the sheet (use with an explicit detent or a
    /// `.large`/`.medium` detent). `false` — natural height: pair with `.selfSizingSheet()` so
    /// the sheet snaps to its content. Prefer `BottomSheet.selfSizing(...)` as the entry point
    /// when natural sizing is needed — it guarantees `fillsHeight: false` and the modifier are
    /// always applied together.
    ///
    /// Either way the content sits directly in the sheet, with no navigation container around
    /// it. A host that moves between screens inside the sheet keeps the route in its own state
    /// and drives the back button with `showBackButton` / `onBackButtonPressed`.
    public var fillsHeight: Bool = true
    /// Fill behind the whole sheet — grabber, header and content alike — running
    /// under the home indicator. `BottomSheet` does not set the presentation
    /// background; `BottomSheet.selfSizing(...)` passes this colour to
    /// `selfSizingSheet`, which does, so the inset its height detent adds below
    /// the content matches.
    public var background: Color = .dash.primaryBackground
    @ViewBuilder public var content: () -> Content

    public init(
        title: String = "",
        showBackButton: Binding<Bool>,
        onBackButtonPressed: (() -> Void)? = nil,
        isDismissalEnabled: Binding<Bool> = .constant(true),
        showsCloseButton: Bool = true,
        isCloseButtonEnabled: Bool = true,
        onClose: (() -> Void)? = nil,
        fillsHeight: Bool = true,
        background: Color = .dash.primaryBackground,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self._showBackButton = showBackButton
        self.onBackButtonPressed = onBackButtonPressed
        self._isDismissalEnabled = isDismissalEnabled
        self.showsCloseButton = showsCloseButton
        self.isCloseButtonEnabled = isCloseButtonEnabled
        self.onClose = onClose
        self.fillsHeight = fillsHeight
        self.background = background
        self.content = content
    }

    public var body: some View {
        let sheet = VStack(spacing: 0) {
            grabber
                .frame(maxWidth: .infinity, minHeight: 18, maxHeight: 18, alignment: .center)

            if hasHeaderContent {
                header
            }

            content()
                .frame(maxWidth: .infinity, maxHeight: fillsHeight ? .infinity : nil)
        }
        // The shape-style overload, which `.background(Color)` resolves to: the fill
        // runs under the safe areas the sheet keeps, so a `fillsHeight` sheet's
        // home-indicator strip matches the content.
        .background(background, ignoresSafeAreaEdges: .all)

        // One view for both modes and both dismissal states, with the flags passed as
        // values: an if/else would be `_ConditionalContent`, which rebuilds the sheet
        // and drops host state when a host flips `fillsHeight` or `isDismissalEnabled`.
        //
        // A `fillsHeight` sheet keeps its safe areas: the content stops above the home
        // indicator, and keyboard avoidance stays on, so a text field near the bottom
        // is lifted above the keyboard.
        //
        // A natural-height sheet publishes its height for `.selfSizingSheet()`. The
        // bottom safe area is not ignored, so the measured height excludes the
        // home-indicator inset — `.presentationDetents([.height])` adds that inset
        // itself. `.fixedSize(vertical:)` is critical there: it makes the sheet report
        // its *ideal* height independent of the height the sheet currently offers.
        // Without it the measurement is coupled to the detent (detent <- measured <-
        // offered height <- detent), so it ping-pongs by ~the safe-area inset and the
        // presenting view (HomeView) jitters up/down.
        sheet
            .fixedSize(horizontal: false, vertical: !fillsHeight)
            .background {
                if !fillsHeight {
                    GeometryReader { proxy in
                        Color.clear.preference(
                            key: BottomSheetHeightPreferenceKey.self,
                            value: proxy.size.height
                        )
                    }
                }
            }
            .interactiveDismissDisabled(!isDismissalEnabled)
    }

    private var grabber: some View {
        Rectangle()
            .foregroundColor(.clear)
            .frame(width: 36, height: 5)
            .background(Color.dash.grabberFill)
            .cornerRadius(5)
    }

    private var isCloseButtonActive: Bool {
        BottomSheetDismissalAction.isCloseButtonActive(
            isCloseButtonEnabled: isCloseButtonEnabled,
            isDismissalEnabled: isDismissalEnabled,
            hasCustomCloseAction: onClose != nil)
    }

    /// A header with no title, no back button and no close button is 74pt of
    /// nothing: it pushes the content down, and on a self-sizing sheet that
    /// blank strip becomes part of the sheet's own measured height. Collapse
    /// it rather than reserve it. Any one of the three brings it back, and the
    /// binding means a sheet can gain the header mid-flight.
    private var hasHeaderContent: Bool {
        !title.isEmpty || showBackButton || showsCloseButton
    }

    private var header: some View {
        NavigationBar(
            leading: {
                if showBackButton {
                    NavigationBarElement.back.button { onBackButtonPressed?() }
                }
            },
            central: {
                Text(title)
                    .dashFont(.subheadMedium)
                    .foregroundColor(.dash.primaryText)
            },
            trailing: {
                if showsCloseButton {
                    NavigationBarElement.close.button {
                        BottomSheetDismissalAction.perform(
                            isDismissalEnabled: isDismissalEnabled,
                            onClose: onClose,
                            dismiss: { dismiss() }
                        )
                    }
                    .disabled(!isCloseButtonActive)
                }
            }
        )
    }
}

public struct BottomSheetHeightPreferenceKey: PreferenceKey {
    public static let defaultValue: CGFloat = 0

    public static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

public extension BottomSheet {
    /// Self-sizing bottom sheet: builds with `fillsHeight: false` and applies
    /// `.selfSizingSheet(...)` so the two can't be mismatched. Drop the result
    /// directly into a `.sheet { }`.
    static func selfSizing(
        title: String = "",
        showBackButton: Binding<Bool>,
        onBackButtonPressed: (() -> Void)? = nil,
        isDismissalEnabled: Binding<Bool> = .constant(true),
        showsCloseButton: Bool = true,
        isCloseButtonEnabled: Bool = true,
        onClose: (() -> Void)? = nil,
        fallback: CGFloat = 0,
        maxHeightFraction: CGFloat = 0.95,
        background: Color = .dash.primaryBackground,
        cornerRadius: CGFloat? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        BottomSheet(
            title: title,
            showBackButton: showBackButton,
            onBackButtonPressed: onBackButtonPressed,
            isDismissalEnabled: isDismissalEnabled,
            showsCloseButton: showsCloseButton,
            isCloseButtonEnabled: isCloseButtonEnabled,
            onClose: onClose,
            fillsHeight: false,
            background: background,
            content: content
        )
        .selfSizingSheet(
            fallback: fallback,
            maxHeightFraction: maxHeightFraction,
            background: background,
            cornerRadius: cornerRadius)
    }
}

enum BottomSheetDismissalAction {
    /// The button is live while it still has something to do. Blocking dismissal only
    /// takes away what the sheet itself owns — the `dismiss()` it would call — so a host
    /// that supplied `onClose` keeps its action, and a sheet can block the swipe while
    /// still answering the close button with a confirmation. `isCloseButtonEnabled`
    /// remains the way to take the button away outright.
    static func isCloseButtonActive(
        isCloseButtonEnabled: Bool,
        isDismissalEnabled: Bool,
        hasCustomCloseAction: Bool
    ) -> Bool {
        isCloseButtonEnabled && (isDismissalEnabled || hasCustomCloseAction)
    }

    static func perform(isDismissalEnabled: Bool, onClose: (() -> Void)?, dismiss: () -> Void) {
        if let onClose {
            onClose()
        } else if isDismissalEnabled {
            dismiss()
        }
    }
}

public extension View {
    /// Sizes a `BottomSheet` (built with `fillsHeight: false`) to its content's natural height —
    /// no hardcoded `.height(...)` needed.
    ///
    /// The content is measured directly (via a `GeometryReader` background), so it does not rely
    /// on any published preference — it self-sizes whatever finite-height view it wraps. The
    /// measured view must have a finite intrinsic height (no greedy `Spacer` / `maxHeight: .infinity`),
    /// otherwise it expands to fill the offered space and the measurement is wrong — see
    /// `BottomSheet(fillsHeight: false)`.
    ///
    /// - Parameters:
    ///   - fallback: Height used before the first measurement (avoids a `.medium` flash).
    ///   - maxHeightFraction: Caps the sheet at this fraction of the window height; taller content
    ///     is clipped, so wrap it in a `ScrollView`.
    ///   - background: Fill for the sheet and its presentation, so the bottom
    ///     safe-area strip matches the content. This modifier cannot see the
    ///     colour the wrapped `BottomSheet` was built with, so a custom one has
    ///     to be passed here too — or use `BottomSheet.selfSizing(...)`, which
    ///     forwards a single `background` to both.
    ///   - cornerRadius: Optional corner radius applied via `presentationCornerRadius`
    ///     below iOS 26 (iOS 26+ keeps the system corner styling).
    @ViewBuilder
    func selfSizingSheet(
        fallback: CGFloat = 0,
        maxHeightFraction: CGFloat = 0.95,
        background: Color = .dash.primaryBackground,
        cornerRadius: CGFloat? = nil
    ) -> some View {
        let modified = modifier(SelfSizingSheetModifier(fallback: fallback, maxHeightFraction: maxHeightFraction))
        #if os(iOS)
        // The background is filled whatever the corner radius: the measured
        // height excludes the home-indicator inset that
        // `.presentationDetents([.height])` adds back, so that strip sits
        // outside the sheet's own `VStack` and shows the system background
        // unless this fills it.
        if #unavailable(iOS 26.0), let cornerRadius {
            modified
                .presentationCornerRadius(cornerRadius)
                .presentationBackground(background)
        } else {
            // iOS 26+ keeps the system corner styling.
            modified
                .presentationBackground(background)
        }
        #else
        // `presentationCornerRadius` is iOS-only; the presentation background
        // is not, so the parameter is not silently ignored off iOS.
        modified.presentationBackground(background)
        #endif
    }
}

private struct SelfSizingSheetModifier: ViewModifier {
    let fallback: CGFloat
    let maxHeightFraction: CGFloat
    @State private var measured: CGFloat = 0

    func body(content: Content) -> some View {
        // Measure the wrapped content directly — reliable on first layout (`onAppear`) and on
        // changes, without depending on a published preference.
        content
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .onAppear { update(proxy.size.height) }
                        .onChange(of: proxy.size.height) { _, newHeight in update(newHeight) }
                }
            )
            .presentationDetents(detents)
            .presentationDragIndicator(.hidden)
    }

    private var detents: Set<PresentationDetent> {
        let resolved = min(measured > 0 ? measured : fallback, maxSheetHeight)
        // Before the first measurement (and when no fallback is provided) use .medium so the
        // sheet is never given an invalid 0-height detent.
        return resolved > 0 ? [.height(resolved)] : [.medium]
    }

    private func update(_ newHeight: CGFloat) {
        guard newHeight > 0, newHeight != measured else { return }
        measured = newHeight
    }

    private var maxSheetHeight: CGFloat {
        #if canImport(UIKit)
        let windowHeight = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }?
            .keyWindow?.bounds.height
        let height = windowHeight ?? UIScreen.main.bounds.height
        return height * maxHeightFraction
        #else
        return .greatestFiniteMagnitude
        #endif
    }
}

#if DEBUG

#Preview("BottomSheet Filled Height") {
    BottomSheet(
        title: "Bottom Sheet",
        showBackButton: .constant(true)
    ) {
        VStack(alignment: .leading, spacing: 16) {
            Text("Greedy content")
                .dashFont(.calloutMedium)
                .foregroundColor(.dash.primaryText)

            Text("Fills the available sheet height.")
                .dashFont(.body)
                .foregroundColor(.dash.secondaryText)
        }
        .padding()
    }
}

#Preview("BottomSheet Text Field") {
    @Previewable @State var amount = ""

    BottomSheet(
        title: "Bottom Sheet",
        showBackButton: .constant(false)
    ) {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(1...20, id: \.self) { row in
                        Text("Row \(row)")
                            .dashFont(.body)
                            .foregroundColor(.dash.primaryText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding()
            }

            // Stays above the home indicator, and rises with the keyboard.
            TextField("Amount", text: $amount)
                .textFieldStyle(.roundedBorder)
                .padding()
        }
    }
}

#Preview("BottomSheet Natural Height") {
    BottomSheet(
        title: "Bottom Sheet",
        showBackButton: .constant(false),
        fillsHeight: false
    ) {
        VStack(alignment: .leading, spacing: 12) {
            Text("Natural height content")
                .dashFont(.calloutMedium)
                .foregroundColor(.dash.primaryText)

            Text("Use this with selfSizingSheet() so the sheet snaps to content height.")
                .dashFont(.body)
                .foregroundColor(.dash.secondaryText)
        }
        .padding()
    }
}

#Preview("BottomSheet Custom Background") {
    BottomSheet(
        title: "Bottom Sheet",
        showBackButton: .constant(false),
        fillsHeight: false,
        background: .dash.secondaryBackground
    ) {
        VStack(alignment: .leading, spacing: 12) {
            Text("Cards on a tinted sheet")
                .dashFont(.calloutMedium)
                .foregroundColor(.dash.primaryText)

            Text("The host picks the fill; cards drawn on top keep their own.")
                .dashFont(.body)
                .foregroundColor(.dash.secondaryText)
                .modifier(MenuViewModifier())
        }
        .padding()
    }
}

#Preview("BottomSheet Dismissal States") {
    VStack(spacing: 12) {
        BottomSheet(
            title: "Dismissal enabled",
            showBackButton: .constant(false),
            isDismissalEnabled: .constant(true),
            fillsHeight: false
        ) {
            Text("Swipe or use the close button.")
                .dashFont(.body)
                .foregroundColor(.dash.secondaryText)
                .padding()
        }

        BottomSheet(
            title: "Dismissal disabled",
            showBackButton: .constant(false),
            isDismissalEnabled: .constant(false),
            fillsHeight: false
        ) {
            Text("The dimmed close button and swipe are disabled.")
                .dashFont(.body)
                .foregroundColor(.dash.secondaryText)
                .padding()
        }

        BottomSheet(
            title: "Swipe blocked, close confirms",
            showBackButton: .constant(false),
            isDismissalEnabled: .constant(false),
            onClose: { /* host shows a "discard changes?" alert */ },
            fillsHeight: false
        ) {
            Text("The swipe is blocked, but the close button still reaches the host.")
                .dashFont(.body)
                .foregroundColor(.dash.secondaryText)
                .padding()
        }

        BottomSheet(
            title: "Close hidden",
            showBackButton: .constant(false),
            showsCloseButton: false,
            fillsHeight: false
        ) {
            Text("The host intentionally provides no close control.")
                .dashFont(.body)
                .foregroundColor(.dash.secondaryText)
                .padding()
        }
    }
    .background(Color.dash.primaryBackground)
}

#endif
