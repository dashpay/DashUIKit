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
public struct MenuViewModifier: ViewModifier {
    var shadowRadius: CGFloat
    var innerPadding: CGFloat

    public init(shadowRadius: CGFloat = 10, innerPadding: CGFloat = 6) {
        self.shadowRadius = shadowRadius
        self.innerPadding = innerPadding
    }

    public func body(content: Content) -> some View {
        content
            .padding(innerPadding)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.dash.secondaryBackground)
            )
            .shadow(color: Color.dash.shadow, radius: shadowRadius, x: 0, y: 5)
    }
}
