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

/// The one implementation of a navigation bar button: touch area, press and
/// disabled styling, accessibility label. `NavigationBarElement.button(action:)`
/// and `NavigationBarCircleButton` both render through it.
nonisolated struct NavigationBarButton<Label: View>: View {
    private let accessibilityLabel: Text
    private let action: () -> Void
    private let label: Label

    init(
        accessibilityLabel: Text,
        action: @escaping () -> Void,
        @ViewBuilder label: () -> Label
    ) {
        self.accessibilityLabel = accessibilityLabel
        self.action = action
        self.label = label()
    }

    var body: some View {
        Button(action: action) {
            label.navigationBarTouchArea()
        }
        .buttonStyle(NavigationBarButtonStyle())
        .accessibilityLabel(accessibilityLabel)
    }
}

extension View {
    /// The bar's touch area: 44pt tall, and at least 44pt wide for hit
    /// testing. The extra width is hit area only — the element keeps its
    /// hug width in layout, so a 34pt circle stays aligned to the bar's
    /// 20pt inset.
    nonisolated func navigationBarTouchArea() -> some View {
        frame(height: 44)
            .contentShape(NavigationBarHitShape())
    }

    /// Dims a bar element while it is disabled — the one place the bar's
    /// disabled look is defined.
    nonisolated func navigationBarDisabledDimming(_ isEnabled: Bool) -> some View {
        opacity(isEnabled ? 1 : navigationBarDisabledOpacity)
    }
}

/// Opacity of a disabled bar element (button, menu, `BottomSheet` close).
let navigationBarDisabledOpacity: Double = 0.35

/// The element's frame, widened symmetrically to at least 44pt.
private struct NavigationBarHitShape: Shape {
    func path(in rect: CGRect) -> Path {
        let outset = max(0, (44 - rect.width) / 2)
        return Path(rect.insetBy(dx: -outset, dy: 0))
    }
}

struct NavigationBarButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        NavigationBarButtonStyleBody(configuration: configuration)
    }
}

/// A view, not inline in `makeBody`, so it can read `isEnabled`: a custom
/// `ButtonStyle` gets no automatic disabled dimming.
private struct NavigationBarButtonStyleBody: View {
    let configuration: ButtonStyleConfiguration

    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.88 : 1)
            .opacity(configuration.isPressed ? 0.7 : 1)
            .navigationBarDisabledDimming(isEnabled)
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
    }
}
