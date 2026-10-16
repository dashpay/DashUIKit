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

@available(iOS 14, macOS 11, *)
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
        ZStack {
            HStack {
                leading

                Spacer()

                trailing
            }
            .padding(.horizontal, 20)

            central
        }
        .frame(maxWidth: .infinity, minHeight: 74)
    }
}

@available(iOS 14, macOS 11, *)
public extension NavigationBar where Trailing == EmptyView {
    init(@ViewBuilder leading: () -> Leading, @ViewBuilder central: () -> Central) {
        self.init(leading: leading, central: central, trailing: { EmptyView() })
    }
}

@available(iOS 14, macOS 11, *)
public extension NavigationBar where Central == EmptyView {
    init(@ViewBuilder leading: () -> Leading, @ViewBuilder trailing: () -> Trailing) {
        self.init(leading: leading, central: { EmptyView() }, trailing: trailing)
    }
}

@available(iOS 14, macOS 11, *)
public extension NavigationBar where Leading == EmptyView {
    init(@ViewBuilder central: () -> Central, @ViewBuilder trailing: () -> Trailing) {
        self.init(leading: { EmptyView() }, central: central, trailing: trailing)
    }
}

@available(iOS 14, macOS 11, *)
public extension NavigationBar where Central == EmptyView, Trailing == EmptyView {
    init(@ViewBuilder leading: () -> Leading) {
        self.init(leading: leading, central: { EmptyView() }, trailing: { EmptyView() })
    }
}

@available(iOS 14, macOS 11, *)
public extension NavigationBar where Leading == EmptyView, Trailing == EmptyView {
    init(@ViewBuilder central: () -> Central) {
        self.init(leading: { EmptyView() }, central: central, trailing: { EmptyView() })
    }
}

@available(iOS 14, macOS 11, *)
public extension NavigationBar where Leading == EmptyView, Central == EmptyView {
    init(@ViewBuilder trailing: () -> Trailing) {
        self.init(leading: { EmptyView() }, central: { EmptyView() }, trailing: trailing)
    }
}

@available(iOS 14, macOS 11, *)
public enum NavigationBarElement: String {
    case back = "navigationbar-back"
    case close = "navigationbar-close"
    case plus = "navigationbar-plus"
    case info = "navigationbar-info"

    /// The element as drawn in the bar. `back`, `close` and `plus` are a glyph
    /// centred in a stroked circle; `info` is a self-contained icon.
    @MainActor @ViewBuilder
    public var icon: some View {
        switch self {
        case .back, .close, .plus:
            NavigationBarCircleIcon { glyph }
        case .info:
            glyph
        }
    }

    @MainActor
    private var glyph: some View {
        Image(dash: .custom(rawValue, bundle: .module))
            .fixedSize()
    }

    @MainActor
    public func button(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            icon
                .frame(height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(NavigationBarButtonStyle())
        .accessibilityLabel(Text(accessibilityLabelText))
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

/// The bar's round element: any glyph centred in a 34pt circle with a 1.5pt
/// `toolbarRoundBorder` stroke, tinted `toolbarRoundContent`. `back`, `close`
/// and `plus` are drawn with it; use it directly for a bar action that has no
/// bundled element (refresh, a `Menu` label).
@available(iOS 14, macOS 11, *)
public struct NavigationBarCircleIcon<Glyph: View>: View {
    private let glyph: Glyph

    public init(@ViewBuilder glyph: () -> Glyph) {
        self.glyph = glyph()
    }

    public var body: some View {
        glyph
            .foregroundColor(.dash.toolbarRoundContent)
            .frame(width: 34, height: 34)
            .overlay(
                Circle()
                    .strokeBorder(Color.dash.toolbarRoundBorder, lineWidth: 1.5)
            )
    }
}

/// A `NavigationBarCircleIcon` as a bar button: the same 44pt-tall touch area
/// and press animation as `NavigationBarElement.button(action:)`.
@available(iOS 14, macOS 11, *)
public struct NavigationBarCircleButton<Glyph: View>: View {
    private let accessibilityLabel: String
    private let action: () -> Void
    private let glyph: Glyph

    public init(
        accessibilityLabel: String,
        action: @escaping () -> Void,
        @ViewBuilder glyph: () -> Glyph
    ) {
        self.accessibilityLabel = accessibilityLabel
        self.action = action
        self.glyph = glyph()
    }

    public var body: some View {
        Button(action: action) {
            NavigationBarCircleIcon { glyph }
                .frame(height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(NavigationBarButtonStyle())
        .accessibilityLabel(Text(accessibilityLabel))
    }
}

@available(iOS 14, macOS 11, *)
private struct NavigationBarButtonStyle: ButtonStyle {
    @ViewBuilder
    func makeBody(configuration: Configuration) -> some View {
        let content = configuration.label
            .scaleEffect(configuration.isPressed ? 0.88 : 1)
            .opacity(configuration.isPressed ? 0.7 : 1)

        if #available(iOS 15, macOS 12, *) {
            content.animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
        } else {
            content.animation(.easeInOut(duration: 0.12))
        }
    }
}

@available(iOS 17, macOS 14, *)
#Preview("NavigationBar Back") {
    NavigationBar(
        leading: { NavigationBarElement.back.button { } }
    )
}

@available(iOS 17, macOS 14, *)
#Preview("NavigationBar Back Title") {
    NavigationBar(
        leading: { NavigationBarElement.back.button { } },
        central: {
            Text("Title")
                .dashFont(.subheadMedium)
                .foregroundColor(.dash.primaryText)
        }
    )
}

@available(iOS 17, macOS 14, *)
#Preview("NavigationBar Back Title Info") {
    NavigationBar(
        leading: { NavigationBarElement.back.button { } },
        central: {
            Text("Title")
                .dashFont(.subheadMedium)
                .foregroundColor(.dash.primaryText)
        },
        trailing: { NavigationBarElement.info.button { } }
    )
}

@available(iOS 17, macOS 14, *)
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
                HStack(spacing: 8) {
                    NavigationBarCircleButton(accessibilityLabel: "Refresh", action: { }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    Menu {
                        Button("Action") { }
                    } label: {
                        NavigationBarCircleIcon {
                            Image(systemName: "ellipsis")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .frame(height: 44)
                    }
                    .accessibilityLabel(Text("More"))
                }
            }
        )
    }
}

@available(iOS 17, macOS 14, *)
#Preview("NavigationBar Title Close") {
    NavigationBar(
        central: {
            Text("Title")
                .dashFont(.subheadMedium)
                .foregroundColor(.dash.primaryText)
        },
        trailing: { NavigationBarElement.close.button { } }
    )
}
