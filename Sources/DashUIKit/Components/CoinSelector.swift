//
//  Created by Dash Core Group. All rights reserved.
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
public enum CoinSelectorTrailing {
    case price(String)
    case halted
}

private enum CoinSelectorLayout {
    static let spacing: CGFloat = 16
    static let textSpacing: CGFloat = 1
    static let padding: CGFloat = 10
    static let badgeHPadding: CGFloat = 8
    static let badgeVPadding: CGFloat = 2
    static let badgeCornerRadius: CGFloat = 6
}

@available(iOS 14, macOS 11, *)
public struct CoinSelector<Icon: View>: View {

    private let name: String
    private let code: String
    private let network: String?
    private let trailing: CoinSelectorTrailing?
    private let icon: Icon

    public init(
        name: String,
        code: String,
        network: String? = nil,
        trailing: CoinSelectorTrailing? = nil,
        @ViewBuilder icon: () -> Icon
    ) {
        self.name = name
        self.code = code
        self.network = network
        self.trailing = trailing
        self.icon = icon()
    }

    private var isHalted: Bool {
        if case .halted = trailing { return true }
        return false
    }

    public var body: some View {
        HStack(spacing: CoinSelectorLayout.spacing) {
            icon
            info
            trailingView
        }
        .padding(CoinSelectorLayout.padding)
        .opacity(isHalted ? 0.5 : 1.0)
        .contentShape(Rectangle())
    }

    private var info: some View {
        VStack(alignment: .leading, spacing: CoinSelectorLayout.textSpacing) {
            Text(name)
                .dashFont(.subheadMedium)
                .foregroundColor(Color.dash.primaryText)
                .lineLimit(1)
                .truncationMode(.tail)
            Text(code)
                .dashFont(.footnote)
                .foregroundColor(Color.dash.tertiaryText)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var trailingView: some View {
        if case .halted = trailing {
            haltedLabel
        } else {
            VStack(alignment: .trailing, spacing: 0) {
                if case .price(let value) = trailing {
                    Text(value)
                        .dashFont(.caption1)
                        .foregroundColor(Color.dash.primaryText)
                        .lineLimit(1)
                }
                if let network {
                    Text(network)
                        .dashFont(.caption1)
                        .foregroundColor(Color.dash.tertiaryText)
                        .lineLimit(1)
                        .fixedSize()
                }
            }
        }
    }

    private var haltedLabel: some View {
        Text(NSLocalizedString("halted", bundle: .module, comment: "DashUIKit"))
            .dashFont(.caption1)
            .foregroundColor(Color.dash.tertiaryText)
            .padding(.horizontal, CoinSelectorLayout.badgeHPadding)
            .padding(.vertical, CoinSelectorLayout.badgeVPadding)
            .background(Color.dash.black1000Alpha8)
            .clipShape(RoundedRectangle(cornerRadius: CoinSelectorLayout.badgeCornerRadius, style: .continuous))
    }
}

#if DEBUG

@available(iOS 14, macOS 11, *)
struct CoinSelector_Previews: PreviewProvider {

    static var iconPlaceholder: some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(Color.dash.blue)
            .frame(width: 30, height: 30)
    }

    static var previews: some View {
        VStack(spacing: 0) {
            CoinSelector(name: "Rune", code: "RUNE", network: "Maya", trailing: .price("$0.40")) {
                iconPlaceholder
            }
            CoinSelector(name: "Ethereum", code: "ETH", network: "NEAR", trailing: .price("$3,200.00")) {
                iconPlaceholder
            }
            CoinSelector(name: "USD Coin", code: "USDC", network: "Multiple", trailing: .price("$1.00")) {
                iconPlaceholder
            }
            CoinSelector(name: "Tether", code: "USDT", trailing: .halted) {
                iconPlaceholder
            }
            CoinSelector(name: "Bitcoin", code: "BTC") {
                iconPlaceholder
            }
        }
        .previewLayout(.sizeThatFits)
    }
}

#endif
