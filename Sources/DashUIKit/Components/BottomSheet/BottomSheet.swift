import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

@available(iOS 14, macOS 11, *)
public struct BottomSheet<Content: View>: View {
    @Environment(\.presentationMode) private var presentationMode

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
    public var fillsHeight: Bool = true
    /// Fill behind the whole sheet — grabber, header and content alike. Also
    /// used as the presentation background so the home-indicator inset the
    /// detent adds matches; a host that only restyles its own content would
    /// otherwise get a strip of this colour along the bottom edge.
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

            header

            contentSection
        }
        .background(background)

        Group {
            if fillsHeight {
                sheet.edgesIgnoringSafeArea(.bottom)
            } else {
                // Publish the natural content height for `.selfSizingSheet()`. The bottom safe area is
                // intentionally NOT ignored here, so the measured height excludes the home-indicator
                // inset — `.presentationDetents([.height])` adds that inset itself.
                //
                // `.fixedSize(vertical:)` is critical: it makes the sheet report its *ideal* height
                // independent of the height the sheet currently offers. Without it the measurement is
                // coupled to the detent (detent <- measured <- offered height <- detent), so it ping-pongs
                // by ~the safe-area inset and the presenting view (HomeView) jitters up/down.
                sheet
                    .fixedSize(horizontal: false, vertical: true)
                    .background(
                        GeometryReader { proxy in
                            Color.clear.preference(
                                key: BottomSheetHeightPreferenceKey.self,
                                value: proxy.size.height
                            )
                        }
                    )
            }
        }
        .modifier(BottomSheetDismissalModifier(isEnabled: isDismissalEnabled))
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

    private var header: some View {
        NavigationBar(
            leading: {
                if showBackButton {
                    NavigationBarElement.back.button { onBackButtonPressed?() }
                }
            },
            central: {
                Text(title)
                    .dashFont(.calloutMedium)
                    .foregroundColor(.dash.primaryText)
            },
            trailing: {
                if showsCloseButton {
                    NavigationBarElement.close.button {
                        BottomSheetDismissalAction.perform(
                            isDismissalEnabled: isDismissalEnabled,
                            onClose: onClose,
                            dismiss: { presentationMode.wrappedValue.dismiss() }
                        )
                    }
                    .disabled(!isCloseButtonActive)
                    .opacity(isCloseButtonActive ? 1 : 0.35)
                }
            }
        )
    }

    @ViewBuilder
    private var contentSection: some View {
        if fillsHeight {
            NavigationView {
                content()
                    #if os(iOS)
                    .navigationBarHidden(true)
                    #endif
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(background)
            }
        } else {
            // Natural height — no greedy NavigationView / maxHeight so the sheet can self-size.
            content()
                .frame(maxWidth: .infinity)
                .background(background)
        }
    }
}

@available(iOS 14, macOS 11, *)
public struct BottomSheetHeightPreferenceKey: PreferenceKey {
    public static let defaultValue: CGFloat = 0

    public static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

@available(iOS 14, macOS 11, *)
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

@available(iOS 14, macOS 11, *)
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

@available(iOS 14, macOS 11, *)
private struct BottomSheetDismissalModifier: ViewModifier {
    let isEnabled: Bool

    // The value is passed to the modifier rather than deciding whether to apply
    // it: a `@ViewBuilder` if/else would hand back `_ConditionalContent`, and
    // flipping between its branches makes SwiftUI rebuild the sheet, taking the
    // host's state inside `content()` with it.
    func body(content: Content) -> some View {
        content.interactiveDismissDisabled(!isEnabled)
    }
}

@available(iOS 14, macOS 11, *)
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

@available(iOS 16.0, macOS 13.0, *)
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
                        .onChange(of: proxy.size.height) { update($0) }
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

@available(iOS 17, macOS 14, *)
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

@available(iOS 17, macOS 14, *)
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

@available(iOS 17, macOS 14, *)
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

@available(iOS 17, macOS 14, *)
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
