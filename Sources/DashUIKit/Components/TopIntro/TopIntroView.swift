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

/// A screen's intro above its content: a title and up to two descriptions.
/// The title is always `primaryText`; the descriptions are too unless the
/// host passes another `Color.dash` text token.
public struct TopIntroView: View {
    private let title: String
    private let mainDescription: String?
    private let secondaryDescription: String?
    private let descriptionColor: Color

    /// Both descriptions in `primaryText`.
    public init(title: String, mainDescription: String? = nil, secondaryDescription: String? = nil) {
        self.init(
            title: title,
            mainDescription: mainDescription,
            secondaryDescription: secondaryDescription,
            descriptionColor: Color.dash.primaryText)
    }

    /// Both descriptions in `descriptionColor`: a `Color.dash` text token such
    /// as `secondaryText`, so the intro stays on the design palette.
    public init(
        title: String,
        mainDescription: String? = nil,
        secondaryDescription: String? = nil,
        descriptionColor: Color
    ) {
        self.title = title
        self.mainDescription = mainDescription
        self.secondaryDescription = secondaryDescription
        self.descriptionColor = descriptionColor
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            //MARK: Title
            Text(title)
                .dashFont(.title1)
                .foregroundStyle(Color.dash.primaryText)

            //MARK: Main description

            if let mainDescription {
                Text(mainDescription)
                    .dashFont(.subhead)
                    .foregroundStyle(descriptionColor)
            }


            //MARK: Secondary description

            if let secondaryDescription {
                Text(secondaryDescription)
                    .dashFont(.subhead)
                    .foregroundStyle(descriptionColor)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.trailing, 40)
        .padding(.bottom, 10)
    }
}

#if DEBUG

#Preview("Primary-text descriptions") {
    TopIntroView(
        title: "Confirm details",
        mainDescription: "Review the amount before continuing.",
        secondaryDescription: "You can always go back and edit it.")
        .padding(.horizontal, 20)
}

#Preview("Title only") {
    TopIntroView(title: "Confirm details")
        .padding(.horizontal, 20)
}

#Preview("One description") {
    TopIntroView(title: "Confirm details", mainDescription: "Review the amount before continuing.")
        .padding(.horizontal, 20)
}

#Preview("Secondary-text descriptions") {
    TopIntroView(
        title: "Username Voting",
        mainDescription: "As a masternode owner you can vote to approve requested usernames before users will be able to create it.",
        secondaryDescription: "You can block the creation of the usernames that you feel inappropriate.",
        descriptionColor: Color.dash.secondaryText)
        .padding(.horizontal, 20)
}

#endif
