import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

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

            if hasHeaderContent {
                header
            }

            contentSection
        }
        .background(background)

        Group {
            if fillsHeight {
                // `.container` rather than every region: the point is to let the
                // sheet's background run under the home indicator, and
                // `edgesIgnoringSafeArea` — like `ignoresSafeArea(.all)` — also
                // swallows `.keyboard`, which switches off SwiftUI's keyboard
                // avoidance for the whole sheet. Hosts with a text field then
                // find their content pinned under the keyboard with no way to
                // scroll to it.
                sheet.ignoresSafeArea(.container, edges: .bottom)
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
        // Pass the flag rather than branching on it: an if/else is
        // `_ConditionalContent`, which rebuilds the sheet and drops host state.
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
                            dismiss: { presentationMode.wrappedValue.dismiss() }
                        )
                    }
                    .disabled(!isCloseButtonActive)
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
        selfSizing(
            title: title,
            showBackButton: showBackButton,
            onBackButtonPressed: onBackButtonPressed,
            isDismissalEnabled: isDismissalEnabled,
            showsCloseButton: showsCloseButton,
            isCloseButtonEnabled: isCloseButtonEnabled,
            onClose: onClose,
            fallback: fallback,
            maxHeightFraction: maxHeightFraction,
            background: background,
            cornerRadius: cornerRadius,
            animatesHeightChanges: false,
            content: content)
    }

    /// `selfSizing(...)` that can animate its height changes after the first measurement; the
    /// rules, and when a change is not animated, are on
    /// `selfSizingSheet(fallback:maxHeightFraction:background:cornerRadius:animatesHeightChanges:)`.
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
        animatesHeightChanges: Bool,
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
            cornerRadius: cornerRadius,
            animatesHeightChanges: animatesHeightChanges)
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
    ///
    /// The sheet adds no animation of its own to height changes; for content that switches in
    /// place, use the overload that takes `animatesHeightChanges:`.
    @ViewBuilder
    func selfSizingSheet(
        fallback: CGFloat = 0,
        maxHeightFraction: CGFloat = 0.95,
        background: Color = .dash.primaryBackground,
        cornerRadius: CGFloat? = nil
    ) -> some View {
        selfSizingSheet(
            fallback: fallback,
            maxHeightFraction: maxHeightFraction,
            background: background,
            cornerRadius: cornerRadius,
            animatesHeightChanges: false)
    }

    /// `selfSizingSheet(fallback:maxHeightFraction:background:cornerRadius:)` that can animate
    /// the sheet's height changes. `fallback`, `maxHeightFraction`, `background` and
    /// `cornerRadius` work as they do there.
    ///
    /// - Parameter animatesHeightChanges: For content that switches in place between views of
    ///   different heights (a preset list and a keypad). When `true`, after a change of the
    ///   measured height the sheet's top edge moves to the new height with the system sheet
    ///   spring instead of jumping, with the content held at that edge. Not animated: the
    ///   first measurement, which replaces `fallback` (or `.medium` when there is none); a
    ///   change that leaves the capped detent where it is (both heights above the
    ///   `maxHeightFraction` cap); and any change with Reduce Motion on, where the edge jumps.
    ///   The content stays at the top edge whenever this is `true`, so when the keyboard
    ///   shrinks the sheet the overflow is at the bottom. A provisional measurement during
    ///   presentation followed by the settled one counts as a change, so that second step can
    ///   animate. With `false` the sheet adds no animation and leaves the layout alone, as the
    ///   overload without `animatesHeightChanges` does.
    @ViewBuilder
    func selfSizingSheet(
        fallback: CGFloat = 0,
        maxHeightFraction: CGFloat = 0.95,
        background: Color = .dash.primaryBackground,
        cornerRadius: CGFloat? = nil,
        animatesHeightChanges: Bool
    ) -> some View {
        let modified = modifier(SelfSizingSheetModifier(
            fallback: fallback,
            maxHeightFraction: maxHeightFraction,
            animatesHeightChanges: animatesHeightChanges))
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
    let animatesHeightChanges: Bool
    @State private var measured: CGFloat = 0
    /// The detent heights animated changes are leaving. The sheet animates its edge only when
    /// the selected detent moves to another one in its set; a set that swaps one height for
    /// another makes it jump. So a height being left stays in the set for the update in which
    /// the selection moves on, and is dropped right after. Every height left in one turn is
    /// kept, so the detent the sheet shows or was just given is offered whichever it is.
    @State private var outgoing: Set<CGFloat> = []
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        let maxHeight = maxSheetHeight
        let current = SelfSizingSheetHeight.resolved(
            measured: measured, fallback: fallback, maxHeight: maxHeight)
        // Measure the wrapped content directly — reliable on first layout (`onAppear`) and on
        // changes, without depending on a published preference.
        content
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .onAppear { update(proxy.size.height, maxHeight: maxHeight) }
                        .onChange(of: proxy.size.height) { _, newHeight in
                            update(newHeight, maxHeight: maxHeight)
                        }
                }
            )
            .modifier(TopAligned(isActive: animatesHeightChanges))
            // The selection is always the current height: the sheet follows the measurement,
            // and a drag to the outgoing detent in the moment it is still offered is not kept.
            .presentationDetents(
                SelfSizingSheetHeight.detents(current: current, outgoing: outgoing),
                selection: .constant(SelfSizingSheetHeight.detent(for: current)))
            .presentationDragIndicator(.hidden)
    }

    /// `maxHeight` is the cap the current detent was given.
    private func update(_ newHeight: CGFloat, maxHeight: CGFloat) {
        guard newHeight > 0, newHeight != measured else { return }
        guard animatesHeightChanges else {
            measured = newHeight
            return
        }
        let animates = SelfSizingSheetHeight.animates(
            reduceMotion: reduceMotion,
            from: measured,
            to: newHeight,
            maxHeight: maxHeight)
        if animates {
            // Only a change after the first measurement is animated, so this is never the fallback.
            let leaving = min(measured, maxHeight)
            let needsDrop = outgoing.isEmpty
            // The sheet moves its edge with its own spring, whatever this transaction's curve.
            withAnimation(.smooth) {
                outgoing.insert(leaving)
                measured = newHeight
            }
            // Dropped on the next turn of the main queue, once the sheet has taken the new
            // selection with both detents in its set. Not in `withAnimation`'s completion:
            // nothing in SwiftUI animates here, so that can run before the sheet sees the
            // change, and the sheet then jumps. A change applied without animation leaves
            // pending outgoing heights alone: they are dropped here as well, once per turn.
            if needsDrop {
                DispatchQueue.main.async { outgoing = [] }
            }
        } else {
            measured = newHeight
        }
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

/// Content of a sheet with an animated detent: while the detent catches up with content that
/// already changed, the two differ in height. Active, it takes exactly the height the sheet
/// offers (a zero minimum, or it would grow to taller content and be centred) and keeps the
/// content at its top edge, so the header stays put whether the content grew or shrank.
/// Inactive, the layout is left as it is.
private struct TopAligned: ViewModifier {
    let isActive: Bool

    func body(content: Content) -> some View {
        content.frame(
            minHeight: isActive ? 0 : nil,
            maxHeight: isActive ? .infinity : nil,
            alignment: .top)
    }
}

/// The height decisions of `selfSizingSheet`, kept apart from the view so they can be tested.
enum SelfSizingSheetHeight {
    /// The detent height: the measurement once there is one, `fallback` before it, capped at
    /// `maxHeight`. Zero means "nothing to size to yet".
    static func resolved(measured: CGFloat, fallback: CGFloat, maxHeight: CGFloat) -> CGFloat {
        min(measured > 0 ? measured : fallback, maxHeight)
    }

    /// The detent for a resolved height: `.medium` while there is nothing to size to, so the
    /// sheet is never given a 0-height detent.
    static func detent(for height: CGFloat) -> PresentationDetent {
        height > 0 ? .height(height) : .medium
    }

    /// The detents offered: the current one, plus the ones animated changes are leaving while
    /// the selection moves away from them.
    static func detents(current: CGFloat, outgoing: Set<CGFloat>) -> Set<PresentationDetent> {
        var detents: Set<PresentationDetent> = [detent(for: current)]
        for height in outgoing where height > 0 {
            detents.insert(.height(height))
        }
        return detents
    }

    /// Whether a sheet that animates its height changes animates this one. `measured` is the
    /// current measurement (zero before the first), `newMeasured` the one arriving; both are
    /// compared capped at the current `maxHeight`. Not with Reduce Motion on, not for the
    /// first measurement (it replaces the fallback as is), and not when the detent does not
    /// move.
    static func animates(
        reduceMotion: Bool,
        from measured: CGFloat,
        to newMeasured: CGFloat,
        maxHeight: CGFloat
    ) -> Bool {
        guard !reduceMotion, measured > 0 else { return false }
        return min(measured, maxHeight) != min(newMeasured, maxHeight)
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

/// A presented self-sizing sheet whose content switches in place between a short and a tall
/// view, so the height change can be watched with and without `animatesHeightChanges`.
private struct SelfSizingSheetResizePreview: View {
    let animatesHeightChanges: Bool
    @State private var isPresented = true
    @State private var isTall = false

    var body: some View {
        Button("Show sheet") { isPresented = true }
            .sheet(isPresented: $isPresented) {
                BottomSheet.selfSizing(
                    title: animatesHeightChanges ? "Animates" : "Jumps",
                    showBackButton: .constant(false),
                    animatesHeightChanges: animatesHeightChanges
                ) {
                    SelfSizingSheetResizeContent(isTall: $isTall)
                }
            }
    }
}

private struct SelfSizingSheetResizeContent: View {
    @Binding var isTall: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(isTall ? "Tall content" : "Short content")
                .dashFont(.calloutMedium)
                .foregroundStyle(Color.dash.primaryText)

            if isTall {
                ForEach(1...6, id: \.self) { row in
                    Text("Row \(row)")
                        .dashFont(.body)
                        .foregroundStyle(Color.dash.secondaryText)
                        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                        .modifier(MenuViewModifier())
                }
            }

            DashButton(
                text: isTall ? "Show less" : "Show more",
                fillsWidth: true,
                size: .large,
                style: .tintedBlue
            ) { isTall.toggle() }
        }
        .padding()
    }
}

#Preview("BottomSheet Self-Sizing Resize, animated") {
    SelfSizingSheetResizePreview(animatesHeightChanges: true)
}

#Preview("BottomSheet Self-Sizing Resize, no animation") {
    SelfSizingSheetResizePreview(animatesHeightChanges: false)
}

#endif
