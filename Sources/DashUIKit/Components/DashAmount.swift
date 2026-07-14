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

// MARK: - Sign control

@available(iOS 14, macOS 11, *)
public enum DashAmountSign {
    /// Never render a sign: "0.05 Ð".
    case none
    /// Only render the minus for negatives: "-0.05 Ð"; positives have no prefix.
    case negativeOnly
    /// Render +/-: "+0.05 Ð", "-0.05 Ð".
    case always
}

// MARK: - Internal formatter

private enum DashAmountFormat {
    static let duffsPerDash: Decimal = 100_000_000

    static let numberFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.locale = .current
        f.minimumFractionDigits = 0
        f.maximumFractionDigits = 5
        f.usesGroupingSeparator = true
        return f
    }()

    static func string(forDuffs duffs: Int64) -> String {
        let value = Decimal(duffs) / duffsPerDash
        return numberFormatter.string(from: value as NSNumber) ?? "\(value)"
    }
}

// MARK: - DashAmount view

@available(iOS 14, macOS 11, *)
public struct DashAmount: View {

    public var amount: Int64
    public var fontSize: CGFloat
    public var weight: Font.Weight
    public var dashSymbolFactor: CGFloat
    public var sign: DashAmountSign

    public init(
        amount: Int64,
        fontSize: CGFloat = 13,
        weight: Font.Weight = .medium,
        dashSymbolFactor: CGFloat = 1,
        sign: DashAmountSign = .negativeOnly
    ) {
        self.amount = amount
        self.fontSize = fontSize
        self.weight = weight
        self.dashSymbolFactor = dashSymbolFactor
        self.sign = sign
    }

    public var body: some View {
        if amount == .max || amount == .min {
            Text(NSLocalizedString("Not available", bundle: .module, comment: "DashUIKit"))
                .font(.system(size: fontSize, weight: weight))
        } else {
            HStack(spacing: 0) {
                if let prefix = signPrefix {
                    Text(prefix)
                        .font(.system(size: fontSize, weight: weight))
                }
                Text(DashAmountFormat.string(forDuffs: abs(amount)))
                    .font(.system(size: fontSize, weight: weight))
                    .lineLimit(1)
                Image(dash: .custom("icon_dash_currency", bundle: .dashUIKit))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: fontSize * dashSymbolFactor,
                           height: fontSize * dashSymbolFactor)
                    .padding(.leading, 2)
            }
        }
    }

    private var signPrefix: String? {
        guard amount != 0 else { return nil }
        switch sign {
        case .none:         return nil
        case .negativeOnly: return amount < 0 ? "-" : nil
        case .always:       return amount > 0 ? "+" : "-"
        }
    }
}

#if DEBUG

@available(iOS 17, macOS 14, *)
#Preview("sign: .none (positive)") {
    DashAmount(amount: 6_791_000, fontSize: 15, sign: .none)
        .padding()
}

@available(iOS 17, macOS 14, *)
#Preview("sign: .negativeOnly — positive (no prefix)") {
    DashAmount(amount: 6_791_000, fontSize: 15, sign: .negativeOnly)
        .padding()
}

@available(iOS 17, macOS 14, *)
#Preview("sign: .negativeOnly — negative (-)") {
    DashAmount(amount: -6_791_000, fontSize: 15, sign: .negativeOnly)
        .padding()
}

@available(iOS 17, macOS 14, *)
#Preview("sign: .always — positive (+)") {
    DashAmount(amount: 6_791_000, fontSize: 15, sign: .always)
        .padding()
}

@available(iOS 17, macOS 14, *)
#Preview("sign: .always — negative (-)") {
    DashAmount(amount: -6_791_000, fontSize: 15, sign: .always)
        .padding()
}

@available(iOS 17, macOS 14, *)
#Preview("Zero (no sign in any mode)") {
    VStack(spacing: 8) {
        DashAmount(amount: 0, fontSize: 15, sign: .none)
        DashAmount(amount: 0, fontSize: 15, sign: .negativeOnly)
        DashAmount(amount: 0, fontSize: 15, sign: .always)
    }
    .padding()
}

@available(iOS 17, macOS 14, *)
#Preview("Not available (Int64.max)") {
    DashAmount(amount: .max, fontSize: 15)
        .padding()
}

#endif
