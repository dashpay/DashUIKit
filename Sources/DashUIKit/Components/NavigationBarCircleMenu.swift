//
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

/// A `Menu` whose label is a `NavigationBarCircleIcon` (e.g. the ⋯ overflow),
/// with the bar's touch area, press animation and disabled dimming. `accessibilityLabel` is a
/// `Text` — see `NavigationBarCircleButton`.
public struct NavigationBarCircleMenu<Content: View>: View {
    private let icon: DashIconSource
    private let accessibilityLabel: Text
    private let content: Content

    public init(
        _ icon: DashIconSource,
        accessibilityLabel: Text,
        @ViewBuilder content: () -> Content
    ) {
        self.icon = icon
        self.accessibilityLabel = accessibilityLabel
        self.content = content()
    }

    public var body: some View {
        // The bar's ButtonStyle draws the label, so the menu gets the same
        // press animation and disabled dimming as the circle buttons beside it.
        Menu {
            content
        } label: {
            NavigationBarCircleIcon(icon)
                .navigationBarTouchArea()
        }
        .menuStyle(.button)
        .buttonStyle(NavigationBarButtonStyle())
        .accessibilityLabel(accessibilityLabel)
    }
}

#if DEBUG
#Preview("NavigationBarCircleMenu") {
    NavigationBarCircleMenu(.system("ellipsis"), accessibilityLabel: Text("More")) {
        Button("Action") { }
    }
    .padding()
}
#endif
