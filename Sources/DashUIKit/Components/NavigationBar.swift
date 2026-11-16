//
//  Created by Roman Chornyi
//  Copyright © 2026 Dash Core Group. All rights reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  https://opensource.org/licenses/MIT
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import SwiftUI

public struct NavigationBar<Leading: View, Central: View, Trailing: View>: View {
    private let leading: Leading
    private let central: Central
    private let trailing: Trailing

    public init(
        @ViewBuilder leading: () -> Leading,
        @ViewBuilder central: () -> Central,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.leading = leading()
        self.central = central()
        self.trailing = trailing()
    }

    public var body: some View {
        // Each slot is exactly one subview, however many views its builder
        // returns (none for an omitted slot), so a slot with two buttons is
        // measured as both.
        NavigationBarSlotsLayout {
            HStack { leading }
            ZStack {
                central
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            HStack { trailing }
        }
    }
}

// MARK: - Layout

/// Places the leading and trailing slots at the edges and centres the central
/// slot over the full width, inset on both sides by the wider side plus a gap:
/// a long title ends in an ellipsis before it reaches either control. With no
/// side slots, the central slot spans the full width.
private struct NavigationBarSlotsLayout: Layout {
    static let edgePadding: CGFloat = 20
    /// The minimum gap between the title and a control.
    static let minimumSpacing: CGFloat = 10
    static let minimumHeight: CGFloat = 74

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        assert(subviews.count == 3, "NavigationBar passes leading, central and trailing")
        guard subviews.count == 3 else { return .zero }

        let leading = subviews[0].sizeThatFits(.unspecified)
        let trailing = subviews[2].sizeThatFits(.unspecified)
        let width = proposal.width ?? {
            let central = subviews[1].sizeThatFits(.unspecified).width
            return 2 * centralInset(leading: leading.width, trailing: trailing.width) + central
        }()
        let central = subviews[1].sizeThatFits(ProposedViewSize(
            width: centralWidth(in: width, leading: leading.width, trailing: trailing.width),
            height: nil))
        let height = max(Self.minimumHeight, leading.height, trailing.height, central.height)
        return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        guard subviews.count == 3 else { return }

        let leading = subviews[0].sizeThatFits(.unspecified)
        let trailing = subviews[2].sizeThatFits(.unspecified)

        subviews[0].place(at: CGPoint(x: bounds.minX + Self.edgePadding, y: bounds.midY),
                          anchor: .leading, proposal: ProposedViewSize(leading))
        subviews[2].place(at: CGPoint(x: bounds.maxX - Self.edgePadding, y: bounds.midY),
                          anchor: .trailing, proposal: ProposedViewSize(trailing))

        let width = centralWidth(in: bounds.width, leading: leading.width, trailing: trailing.width)
        subviews[1].place(at: CGPoint(x: bounds.midX, y: bounds.midY),
                          anchor: .center, proposal: ProposedViewSize(width: width, height: bounds.height))
    }

    private func centralInset(leading: CGFloat, trailing: CGFloat) -> CGFloat {
        let side = max(leading, trailing)
        guard side > 0 else { return 0 }
        return Self.edgePadding + side + Self.minimumSpacing
    }

    /// Never negative, so side slots wider than the bar leave no room for the
    /// central slot instead of pushing it past the bar's edges.
    private func centralWidth(in width: CGFloat, leading: CGFloat, trailing: CGFloat) -> CGFloat {
        max(0, width - 2 * centralInset(leading: leading, trailing: trailing))
    }
}

public extension NavigationBar where Trailing == EmptyView {
    init(@ViewBuilder leading: () -> Leading, @ViewBuilder central: () -> Central) {
        self.init(leading: leading, central: central, trailing: { EmptyView() })
    }
}

public extension NavigationBar where Central == EmptyView {
    init(@ViewBuilder leading: () -> Leading, @ViewBuilder trailing: () -> Trailing) {
        self.init(leading: leading, central: { EmptyView() }, trailing: trailing)
    }
}

public extension NavigationBar where Leading == EmptyView {
    init(@ViewBuilder central: () -> Central, @ViewBuilder trailing: () -> Trailing) {
        self.init(leading: { EmptyView() }, central: central, trailing: trailing)
    }
}

public extension NavigationBar where Central == EmptyView, Trailing == EmptyView {
    init(@ViewBuilder leading: () -> Leading) {
        self.init(leading: leading, central: { EmptyView() }, trailing: { EmptyView() })
    }
}

public extension NavigationBar where Leading == EmptyView, Trailing == EmptyView {
    init(@ViewBuilder central: () -> Central) {
        self.init(leading: { EmptyView() }, central: central, trailing: { EmptyView() })
    }
}

public extension NavigationBar where Leading == EmptyView, Central == EmptyView {
    init(@ViewBuilder trailing: () -> Trailing) {
        self.init(leading: { EmptyView() }, central: { EmptyView() }, trailing: trailing)
    }
}

public enum NavigationBarElement: String, CaseIterable {
    case back = "navigationbar-back"
    case close = "navigationbar-close"
    case plus = "navigationbar-plus"
    case info = "navigationbar-info"

    /// The element as drawn in the bar. `back`, `close` and `plus` are a
    /// `NavigationBarCircleIcon`; `info` is a self-contained icon.
    @ViewBuilder
    public var icon: some View {
        switch self {
        case .back, .close, .plus:
            NavigationBarCircleIconContent(source: source)
        case .info:
            Image(dash: source)
                .fixedSize()
        }
    }

    /// The imageset drawn for the element. The raw value is the same name,
    /// kept for hosts; drawing goes through `DashIcon` so the catalog check
    /// sees it.
    var asset: DashIcon.NavigationBar {
        switch self {
        case .back: return .back
        case .close: return .close
        case .plus: return .plus
        case .info: return .info
        }
    }

    private var source: DashIconSource { asset.source }

    /// The element as a button. Its accessibility identifier is
    /// `navigationbar-back`, `navigationbar-close`, `navigationbar-plus` or
    /// `navigationbar-info`, whatever the language.
    public func button(action: @escaping () -> Void) -> some View {
        NavigationBarButton(accessibilityLabel: Text(accessibilityLabelText), action: action) {
            icon
        }
        .accessibilityIdentifier(accessibilityIdentifier)
    }

    /// The button's accessibility identifier: a handle for UI tests that does
    /// not change with the language, unlike the label. Spelled out rather than
    /// taken from the raw value, so renaming an imageset cannot change it.
    var accessibilityIdentifier: String {
        switch self {
        case .back: return "navigationbar-back"
        case .close: return "navigationbar-close"
        case .plus: return "navigationbar-plus"
        case .info: return "navigationbar-info"
        }
    }

    var accessibilityLabelText: String {
        switch self {
        case .back:
            return NSLocalizedString("Back", bundle: .module, comment: "DashUIKit navigation bar")
        case .close:
            return NSLocalizedString("Close", bundle: .module, comment: "DashUIKit navigation bar")
        case .plus:
            return NSLocalizedString("Add", bundle: .module, comment: "DashUIKit navigation bar")
        case .info:
            return NSLocalizedString("Info", bundle: .module, comment: "DashUIKit navigation bar")
        }
    }
}

#Preview("NavigationBar Back") {
    NavigationBar(
        leading: { NavigationBarElement.back.button { } }
    )
}

#Preview("NavigationBar Back Title") {
    NavigationBar(
        leading: { NavigationBarElement.back.button { } },
        central: {
            Text("Title")
                .dashFont(.subheadMedium)
                .foregroundStyle(Color.dash.primaryText)
        }
    )
}

#Preview("NavigationBar Back Title Info") {
    NavigationBar(
        leading: { NavigationBarElement.back.button { } },
        central: {
            Text("Title")
                .dashFont(.subheadMedium)
                .foregroundStyle(Color.dash.primaryText)
        },
        trailing: { NavigationBarElement.info.button { } }
    )
}

#Preview("NavigationBar Variants") {
    VStack {
        NavigationBar(
            leading: { NavigationBarElement.back.button { } },
            trailing: { NavigationBarElement.info.button { } }
        )

        NavigationBar(
            leading: { NavigationBarElement.back.button { } },
            trailing: { NavigationBarElement.back.button { } }
        )

        NavigationBar(
            leading: { NavigationBarElement.back.button { } },
            trailing: { NavigationBarElement.close.button { } }
        )

        NavigationBar(
            leading: { NavigationBarElement.back.button { } },
            trailing: { NavigationBarElement.plus.button { } }
        )

        NavigationBar(
            leading: { NavigationBarElement.back.button { } },
            trailing: {
                HStack(spacing: 10) {
                    NavigationBarCircleButton(.system("arrow.clockwise"), accessibilityLabel: Text("Refresh")) { }
                    NavigationBarCircleMenu(.system("ellipsis"), accessibilityLabel: Text("More")) {
                        Button("Action") { }
                    }
                }
            }
        )

        NavigationBar(
            leading: { NavigationBarElement.back.button { } },
            trailing: {
                NavigationBarCircleButton(.system("arrow.clockwise"), accessibilityLabel: Text("Refresh")) { }
                    .disabled(true)
            }
        )
    }
}

#Preview("NavigationBar Title Close") {
    NavigationBar(
        central: {
            Text("Title")
                .dashFont(.subheadMedium)
                .foregroundStyle(Color.dash.primaryText)
        },
        trailing: { NavigationBarElement.close.button { } }
    )
}

#Preview("NavigationBar Long Titles") {
    let title = Text("A title far too long to fit between the controls")
        .dashFont(.subheadMedium)
        .foregroundStyle(Color.dash.primaryText)

    VStack {
        NavigationBar(
            leading: { NavigationBarElement.back.button { } },
            central: { title },
            trailing: { NavigationBarElement.info.button { } }
        )

        NavigationBar(
            leading: { NavigationBarElement.back.button { } },
            central: { title }
        )

        NavigationBar(
            leading: { NavigationBarElement.back.button { } },
            central: { title },
            trailing: {
                NavigationBarCircleButton(.system("arrow.clockwise"), accessibilityLabel: Text("Refresh")) { }
                NavigationBarCircleMenu(.system("ellipsis"), accessibilityLabel: Text("More")) {
                    Button("Action") { }
                }
            }
        )

        NavigationBar(central: { title })
    }
}
