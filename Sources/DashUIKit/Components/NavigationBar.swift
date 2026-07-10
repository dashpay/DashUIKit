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
        .frame(maxWidth: .infinity, minHeight: 64)
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

    public var icon: some View {
        Image(dash: .custom(rawValue, bundle: .module))
            .resizable()
            .scaledToFit()
    }

    public func button(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            icon
                .fixedSize()
                .frame(width: 44, height: 44, alignment: .center)
                .contentShape(Rectangle())
        }
        .buttonStyle(NavigationBarButtonStyle())
    }
}

@available(iOS 14, macOS 11, *)
private struct NavigationBarButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.88 : 1)
            .opacity(configuration.isPressed ? 0.7 : 1)
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
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
