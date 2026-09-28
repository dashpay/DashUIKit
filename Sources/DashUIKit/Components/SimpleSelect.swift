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

// MARK: - SimpleSelect

/// One option in a short list the user picks from: a name, a line saying what
/// picking it means, and a card that carries the selection itself.
///
/// The card *is* the control — there is no trailing radio or checkmark. The
/// description is part of what is being chosen, so it would be wrong for it to
/// sit outside the hit target; selection is shown by the card's own border and
/// fill instead.
///
/// For a row with an icon, a trailing value or an explicit radio/checkbox mark,
/// use ``RadioButtonRow``.
@available(iOS 14, macOS 11, *)
public struct SimpleSelect: View {
    private let title: String
    private let description: String?
    private let isSelected: Bool
    private let action: () -> Void

    public init(
        title: String,
        description: String? = nil,
        isSelected: Bool,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.description = description
        self.isSelected = isSelected
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .dashFont(.subheadMedium)
                    .foregroundColor(Color.dash.primaryText)

                if let description {
                    Text(description)
                        .dashFont(.footnote)
                        .foregroundColor(Color.dash.secondaryText)
                }
            }
            .multilineTextAlignment(.leading)
            // Options stand in a column and are compared with each other, so
            // they take the width they are offered rather than each shrinking
            // to its own text.
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.dash.blueAlpha5 : Color.clear))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected ? Color.dash.blue : Color.dash.gray300Alpha30,
                        lineWidth: 1.5))
            // An unselected card has no fill, and an unfilled shape takes taps
            // only where it is drawn — without this only the text is tappable.
            .contentShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}

#if DEBUG

@available(iOS 17, macOS 14, *)
#Preview("SimpleSelect") {
    struct Harness: View {
        @State private var selected = 0

        var body: some View {
            VStack(spacing: 10) {
                SimpleSelect(
                    title: "Shielded balance",
                    description: "Keeps your username private",
                    isSelected: selected == 0,
                    action: { selected = 0 })

                SimpleSelect(
                    title: "Dash balance",
                    description: "Funds will be traceable to your username",
                    isSelected: selected == 1,
                    action: { selected = 1 })

                SimpleSelect(
                    title: "No description",
                    isSelected: selected == 2,
                    action: { selected = 2 })
            }
            .padding(20)
            .background(Color.dash.primaryBackground)
        }
    }

    return Harness()
}

#endif
