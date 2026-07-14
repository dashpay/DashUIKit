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
public struct List1View: View {

    public var label: String
    public var value: String

    public init(label: String = "Label", value: String = "Value") {
        self.label = label
        self.value = value
    }

    public var body: some View {
        HStack {
            Text(label)
                .dashFont(.subheadMedium)
                .foregroundColor(Color.dash.tertiaryText)

            Text(value)
                .dashFont(.subhead)
                .foregroundColor(Color.dash.primaryText)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }
}

@available(iOS 17, macOS 14, *)
#Preview {
    List1View()
}
