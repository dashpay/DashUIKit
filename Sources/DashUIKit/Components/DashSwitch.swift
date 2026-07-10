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

#if canImport(UIKit)
import SwiftUI

// TODO: Add a custom DashToggleStyle using switchThumbFill / switchTrackFillOff /
// switchTrackFillOffDisabled tokens for full pixel-exact fidelity when needed.
@available(iOS 14, *)
public struct DashSwitch: View {

    @Binding private var isOn: Bool

    public init(isOn: Binding<Bool>) {
        self._isOn = isOn
    }

    public var body: some View {
        if #available(iOS 15, *) {
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(Color.dash.switchTrackFillOn as Color?)
        } else {
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .accentColor(Color.dash.switchTrackFillOn)
        }
    }
}

#if DEBUG

@available(iOS 17, *)
#Preview {
    @Previewable @State var on = true
    VStack(spacing: 20) {
        DashSwitch(isOn: $on)
        DashSwitch(isOn: .constant(false))
    }
    .padding()
}

#endif
#endif
