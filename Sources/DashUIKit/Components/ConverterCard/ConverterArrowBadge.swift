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

// MARK: - ConverterArrowBadge

/// The arrow badge centered on the seam between the two `ConverterCard` rows.
///
/// - `onSwap == nil` → static `arrow-down` icon, non-interactive.
/// - `onSwap != nil` → tappable `diagonal-up-down` button that rotates 180° on each tap and fires
///   the swap action.
@available(iOS 14, macOS 11, *)
struct ConverterArrowBadge: View {
    let onSwap: (() -> Void)?
    @State private var rotation: Double = 0

    var body: some View {
        Group {
            if let onSwap {
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) { rotation += 180 }
                    onSwap()
                } label: {
                    badge(iconName: "diagonal-up-down", iconRotation: rotation)
                }
                .buttonStyle(.plain)
            } else {
                badge(iconName: "arrow-down", iconRotation: 0)
            }
        }
        .frame(height: 35)
        .padding(.horizontal, 10)
    }

    private func badge(iconName: String, iconRotation: Double) -> some View {
        RoundedRectangle(cornerRadius: 10, style: .continuous)
            .fill(Color.dash.secondaryBackground)
            .frame(width: 35, height: 35)
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(Color.dash.primaryBackground, lineWidth: 5)
            )
            .overlay(
                Image(dash: .custom(iconName, bundle: .dashUIKit))
                    .rotationEffect(.degrees(iconRotation))
            )
    }
}
