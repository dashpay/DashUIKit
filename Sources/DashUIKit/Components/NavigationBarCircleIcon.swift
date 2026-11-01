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

/// The navigation bar's round element: an icon centred in a 34pt circle with a
/// 1.5pt `toolbarRoundBorder` stroke, tinted `toolbarRoundContent`. The whole
/// circle is its hit-testing shape.
///
/// `NavigationBarElement.back`, `.close` and `.plus` draw through it. Use it
/// directly only to build something the bar doesn't ship — for a button use
/// `NavigationBarCircleButton`, for a menu `NavigationBarCircleMenu`.
///
/// The icon is sized by the component: an SF Symbol (`.system`) is set in
/// `Font.dash.subheadMedium`; a `.custom` / `.uiImage` asset renders at its own
/// size, so it should be drawn for the circle (the bundled nav glyphs are).
public struct NavigationBarCircleIcon: View {
    private let source: DashIconSource

    public init(_ source: DashIconSource) {
        self.source = source
    }

    public var body: some View {
        NavigationBarCircleIconContent(source: source)
    }
}

/// The drawing behind `NavigationBarCircleIcon`. `nonisolated` so the
/// nonisolated `NavigationBarElement.icon` can build it without the public
/// type committing to that isolation.
nonisolated struct NavigationBarCircleIconContent: View {
    let source: DashIconSource

    var body: some View {
        glyph
            .foregroundStyle(Color.dash.toolbarRoundContent)
            .frame(width: 34, height: 34)
            .overlay {
                Circle()
                    .strokeBorder(Color.dash.toolbarRoundBorder, lineWidth: 1.5)
            }
            .contentShape(Circle())
    }

    @ViewBuilder
    private var glyph: some View {
        switch source {
        case .system:
            Image(dash: source)
                .font(Font.dash.subheadMedium)
        case .custom, .uiImage:
            Image(dash: source)
                .fixedSize()
        }
    }
}

#if DEBUG
#Preview("NavigationBarCircleIcon") {
    HStack(spacing: 10) {
        NavigationBarCircleIcon(DashIcon.NavigationBar.back.source)
        NavigationBarCircleIcon(.system("arrow.clockwise"))
        NavigationBarCircleIcon(.system("ellipsis"))
    }
    .padding()
}
#endif
