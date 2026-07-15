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
public struct TopIntroView: View {
    private let title: String
    private let mainDescription: String?
    private let secondaryDescription: String?

    public init(title: String, mainDescription: String? = nil, secondaryDescription: String? = nil) {
        self.title = title
        self.mainDescription = mainDescription
        self.secondaryDescription = secondaryDescription
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            //MARK: Title
            Text(title)
                .dashFont(.title1)
                .foregroundColor(Color.dash.primaryText)

            //MARK: Main description

            if let mainDescription {
                Text(mainDescription)
                    .dashFont(.subhead)
                    .foregroundColor(Color.dash.primaryText)
            }


            //MARK: Secondary description

            if let secondaryDescription {
                Text(secondaryDescription)
                    .dashFont(.subhead)
                    .foregroundColor(Color.dash.primaryText)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.trailing, 40)
        .padding(.bottom, 10)
    }
}
