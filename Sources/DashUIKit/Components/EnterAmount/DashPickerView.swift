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
private enum Layout {
    static let hPadding: CGFloat = 6
    static let vPadding: CGFloat = 3
    static let cornerRadius: CGFloat = 6
}

@available(iOS 14, macOS 11, *)
public struct DashPickerView<Option: Hashable>: View {

    public let options: [Option]
    public let title: (Option) -> String
    @Binding public var selected: Option

    public init(options: [Option], title: @escaping (Option) -> String, selected: Binding<Option>) {
        self.options = options
        self.title = title
        self._selected = selected
    }

    public var body: some View {
        VStack(alignment: .center, spacing: 0) {
            ForEach(options, id: \.self) { option in
                Button {
                    selected = option
                } label: {
                    pickerOption(option)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func pickerOption(_ option: Option) -> some View {
        Text(title(option))
            .font(Font.dash.caption2)
            .foregroundColor(selected == option ? Color.dash.primaryText : Color.dash.tertiaryText)
            .padding(.horizontal, Layout.hPadding)
            .padding(.vertical, Layout.vPadding)
            .background(selected == option ? Color.dash.black1000Alpha5 : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: Layout.cornerRadius, style: .continuous))
    }
}

#if DEBUG

@available(iOS 17, macOS 14, *)
#Preview {
    DashPickerView(
        options: ["US$", "DASH", "BTC"],
        title: { $0 },
        selected: .constant("DASH")
    )
    .padding()
    .background(Color.dash.primaryBackground)
}

#endif
