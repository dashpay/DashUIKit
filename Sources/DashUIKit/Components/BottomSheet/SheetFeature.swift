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

// MARK: - SheetFeature

/// One "here is what this gives you" line inside a `BottomSheet`: an icon
/// beside a name and a sentence explaining it. Stack several to describe what a
/// feature unlocks.
///
/// The icon slot is a `ViewBuilder` rather than a `DashIconSource` because the
/// leading mark is not always an image — a tinted glyph, a badge or a coloured
/// container all appear in this position. It is sized to 40×40 here so a column
/// of features stays aligned whatever each row puts in it.
@available(iOS 14, macOS 11, *)
public struct SheetFeature<Icon: View>: View {
    public var title: String
    public var description: String
    @ViewBuilder public var icon: () -> Icon

    public init(
        title: String,
        description: String,
        @ViewBuilder icon: @escaping () -> Icon
    ) {
        self.title = title
        self.description = description
        self.icon = icon
    }

    public var body: some View {
        HStack(alignment: .top, spacing: 16) {
            icon()
                .frame(width: 40, height: 40)

            VStack(alignment: .leading, spacing: 2) {
                // `.subheadMedium`, not `.subhead` + `.fontWeight`: the
                // modifier is macOS 13, and the weight belongs to a type token
                // anyway — the library carries both weights of this size.
                Text(title)
                    .dashFont(.subheadMedium)
                    .foregroundColor(Color.dash.primaryText)

                Text(description)
                    .dashFont(.subhead)
                    .foregroundColor(Color.dash.primaryText)
            }
            .padding(.top, 10)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
    }
}

@available(iOS 14, macOS 11, *)
public extension SheetFeature where Icon == AnyView {
    /// Convenience for the common case: a template asset tinted to `iconColor`.
    init(
        title: String,
        description: String,
        icon source: DashIconSource,
        iconColor: Color = Color.dash.blue
    ) {
        self.init(title: title, description: description) {
            AnyView(
                Image(dash: source)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .foregroundColor(iconColor)
            )
        }
    }
}

#if DEBUG

@available(iOS 17, macOS 14, *)
#Preview("Feature list") {
    VStack(alignment: .leading, spacing: 16) {
        SheetFeature(
            title: "Identity",
            description: "Register a username and be paid by name instead of an address.",
            icon: .custom("feature-identity", bundle: .dashUIKit))
        SheetFeature(
            title: "Platform",
            description: "Store contacts and profile data on Dash Platform.",
            icon: .custom("feature-platform", bundle: .dashUIKit))
        SheetFeature(
            title: "Shield",
            description: "Move funds into shielded balances that stay off the public ledger.",
            icon: .custom("feature-shield", bundle: .dashUIKit))
    }
    .padding(20)
    .background(Color.dash.primaryBackground)
}

@available(iOS 17, macOS 14, *)
#Preview("Custom icon slot") {
    SheetFeature(
        title: "Anything in the slot",
        description: "The icon is a ViewBuilder, so a badge or a coloured container fits too."
    ) {
        Circle().fill(Color.dash.blueAlpha10)
            .overlay(InfoRoundIcon(size: 20))
    }
    .padding(20)
    .background(Color.dash.primaryBackground)
}

#endif
