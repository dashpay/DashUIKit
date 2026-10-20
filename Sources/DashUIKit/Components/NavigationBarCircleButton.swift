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

/// A `NavigationBarCircleIcon` as a bar button, for an action the bar has no
/// bundled element for (refresh, …). Same touch area, press animation and
/// disabled dimming as `NavigationBarElement.button(action:)`.
///
/// `accessibilityLabel` is a `Text`, so `Text("Refresh")` is looked up in the
/// host's string table like a SwiftUI `Button` title; pass
/// `Text(verbatim:)` for an already-localized string.
@available(iOS 14, macOS 11, *)
public struct NavigationBarCircleButton: View {
    private let icon: DashIconSource
    private let accessibilityLabel: Text
    private let action: () -> Void

    public init(
        _ icon: DashIconSource,
        accessibilityLabel: Text,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.accessibilityLabel = accessibilityLabel
        self.action = action
    }

    public var body: some View {
        NavigationBarButton(accessibilityLabel: accessibilityLabel, action: action) {
            NavigationBarCircleIcon(icon)
        }
    }
}

#if DEBUG
@available(iOS 17, macOS 14, *)
#Preview("NavigationBarCircleButton") {
    HStack(spacing: 10) {
        NavigationBarCircleButton(.system("arrow.clockwise"), accessibilityLabel: Text("Refresh")) { }
        NavigationBarCircleButton(.system("arrow.clockwise"), accessibilityLabel: Text("Refresh")) { }
            .disabled(true)
    }
    .padding()
}
#endif
