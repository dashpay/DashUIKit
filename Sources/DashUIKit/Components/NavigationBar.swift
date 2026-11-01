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
