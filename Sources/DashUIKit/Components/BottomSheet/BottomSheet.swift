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
    /// `true` (default) — greedy: content fills the sheet (use with an explicit detent or a
    /// `.large`/`.medium` detent). `false` — natural height: pair with `.selfSizingSheet()` so
    /// the sheet snaps to its content. Prefer `BottomSheet.selfSizing(...)` as the entry point
    /// when natural sizing is needed — it guarantees `fillsHeight: false` and the modifier are
    /// always applied together.
    public var fillsHeight: Bool = true
    @ViewBuilder public var content: () -> Content

    public init(
        title: String = "",
        showBackButton: Binding<Bool>,
        onBackButtonPressed: (() -> Void)? = nil,
        fillsHeight: Bool = true,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self._showBackButton = showBackButton
        self.onBackButtonPressed = onBackButtonPressed
        self.fillsHeight = fillsHeight
        self.content = content
    }

    public var body: some View {
        let sheet = VStack(spacing: 0) {
            grabber
                .frame(maxWidth: .infinity, minHeight: 18, maxHeight: 18, alignment: .center)

            header

            contentSection
        }
        .background(Color.dash.primaryBackground)

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

    private var grabber: some View {
        Rectangle()
            .foregroundColor(.clear)
            .frame(width: 36, height: 5)
            .background(Color.dash.grabberFill)
            .cornerRadius(5)
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
                NavigationBarElement.close.button { presentationMode.wrappedValue.dismiss() }
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
                    .background(Color.dash.primaryBackground)
            }
        } else {
            // Natural height — no greedy NavigationView / maxHeight so the sheet can self-size.
            content()
                .frame(maxWidth: .infinity)
                .background(Color.dash.primaryBackground)
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
        fallback: CGFloat = 0,
        maxHeightFraction: CGFloat = 0.95,
        cornerRadius: CGFloat? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        BottomSheet(
            title: title,
            showBackButton: showBackButton,
            onBackButtonPressed: onBackButtonPressed,
            fillsHeight: false,
            content: content
        )
        .selfSizingSheet(fallback: fallback, maxHeightFraction: maxHeightFraction, cornerRadius: cornerRadius)
    }
}

@available(iOS 14, macOS 11, *)
public extension View {
    /// Sizes a `BottomSheet` (built with `fillsHeight: false`) to its content's natural height —
    /// no hardcoded `.height(...)` needed. On iOS < 16 it is a no-op.
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
    ///   - cornerRadius: Optional corner radius applied via `presentationCornerRadius` on
    ///     iOS 16.4..<26 (iOS 26+ keeps the system corner styling). When provided, the sheet
    ///     background is also filled so the bottom safe-area strip matches the content.
    @ViewBuilder
    func selfSizingSheet(
        fallback: CGFloat = 0,
        maxHeightFraction: CGFloat = 0.95,
        cornerRadius: CGFloat? = nil
    ) -> some View {
        if #available(iOS 16.0, macOS 13.0, *) {
            let modified = modifier(SelfSizingSheetModifier(fallback: fallback, maxHeightFraction: maxHeightFraction))
            #if os(iOS)
            if #available(iOS 16.4, *), let cornerRadius {
                if #unavailable(iOS 26.0) {
                    // iOS 16.4..<26: apply the custom corner radius + fill the sheet background.
                    modified
                        .presentationCornerRadius(cornerRadius)
                        .presentationBackground(Color.dash.primaryBackground)
                } else {
                    // iOS 26+: keep the system corner styling, just fill the background.
                    modified
                        .presentationBackground(Color.dash.primaryBackground)
                }
            } else {
                modified
            }
            #else
            modified
            #endif
        } else {
            self
        }
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
