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

/// A label ↔ value row with a round 24 pt avatar before the value — the design system's
/// `list-8`, for "who" rows such as the recipient on a payment confirmation.
///
/// The avatar is the caller's view, laid out in a fixed 24 × 24 frame and clipped round; pass
/// a view that fills its frame (a `resizable()` image, a shape). It is hidden from VoiceOver,
/// which reads the row as one element, "label, value". A row with no avatar is a `List1View`.
///
/// Both texts stay on one line. When they do not fit together they share the width, so the
/// value never disappears behind a long label; the value truncates in the middle, keeping the
/// end of a username that may be what tells two recipients apart.
@available(iOS 14, macOS 11, *)
public struct List8View<Avatar: View>: View {

    public var label: String
    public var value: String
    private let avatar: Avatar

    public init(label: String, value: String, @ViewBuilder avatar: () -> Avatar) {
        self.label = label
        self.value = value
        self.avatar = avatar()
    }

    public var body: some View {
        HStack(spacing: 20) {
            Text(label)
                .dashFont(.subheadMedium)
                .foregroundColor(Color.dash.tertiaryText)
                .lineLimit(1)

            HStack(spacing: 8) {
                avatar
                    .frame(width: 24, height: 24)
                    .clipShape(Circle())
                    .accessibilityHidden(true)

                Text(value)
                    .dashFont(.subhead)
                    .foregroundColor(Color.dash.primaryText)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .accessibilityElement(children: .combine)
    }
}

#if DEBUG

@available(iOS 17, macOS 14, *)
#Preview("Every state") {
    VStack(spacing: 0) {
        List8View(label: "To", value: "username") {
            Circle().fill(Color.dash.gray300)
        }
        List8View(label: "To", value: "a-very-long-username-that-does-not-fit-the-row") {
            Circle().fill(Color.dash.gray300)
        }
        List8View(label: "A longer translated label", value: "a-very-long-username") {
            Circle().fill(Color.dash.gray300)
        }
    }
}

#endif
