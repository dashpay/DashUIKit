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
public struct SuccessIllustration: View {

    public init() {}

    public var body: some View {
        ZStack {
            Color.dash.green

            Image(dash: .custom("checkmark", bundle: .dashUIKit))
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 29)
        }
        .frame(width: 90, height: 90)
        .clipShape(Circle())
    }
}

#if DEBUG

@available(iOS 14, macOS 11, *)
struct SuccessIllustration_Previews: PreviewProvider {
    static var previews: some View {
        SuccessIllustration()
            .padding()
            .previewLayout(.sizeThatFits)
    }
}

#endif
