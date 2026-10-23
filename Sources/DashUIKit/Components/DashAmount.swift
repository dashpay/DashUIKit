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

public enum DashAmountSign {
    /// Never render a sign: "0.05 Ð".
    case none
    /// Only render the minus for negatives: "-0.05 Ð"; positives have no prefix.
    case negativeOnly
    /// Render +/-: "+0.05 Ð", "-0.05 Ð".
    case always
}

// MARK: - Internal formatter

public enum DashAmountFormat {
    static let duffsPerDash: Decimal = 100_000_000

    /// Five is what a balance wants: enough to be exact at everyday sizes,
    /// short enough not to dominate a row. It is NOT enough for every figure —
    /// a Core fee of a few hundred duffs rounds to zero at five places — so the
    /// digit count is a parameter and this is only its default.
    public static let defaultMaximumFractionDigits = 5

    static func numberFormatter(maximumFractionDigits: Int) -> NumberFormatter {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.locale = .current
        f.minimumFractionDigits = 0
        f.maximumFractionDigits = maximumFractionDigits
        f.usesGroupingSeparator = true
        return f
    }

    static func string(forDuffs duffs: Int64, maximumFractionDigits: Int) -> String {
        let value = Decimal(duffs) / duffsPerDash
        return numberFormatter(maximumFractionDigits: maximumFractionDigits)
            .string(from: value as NSNumber) ?? "\(value)"
    }
}

// MARK: - DashAmount view

public struct DashAmount: View {

    public var amount: Int64
    public var fontSize: CGFloat
    public var weight: Font.Weight
    public var dashSymbolFactor: CGFloat
    public var sign: DashAmountSign
    /// Raise it for a figure the default would round away — a Core network fee
    /// is a few hundred duffs, which is zero at five places.
    public var maximumFractionDigits: Int

    public init(
        amount: Int64,
        fontSize: CGFloat = 13,
        weight: Font.Weight = .medium,
        dashSymbolFactor: CGFloat = 1,
        sign: DashAmountSign = .negativeOnly,
        maximumFractionDigits: Int = DashAmountFormat.defaultMaximumFractionDigits
    ) {
        self.amount = amount
        self.fontSize = fontSize
        self.weight = weight
        self.dashSymbolFactor = dashSymbolFactor
        self.sign = sign
        self.maximumFractionDigits = maximumFractionDigits
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
                Text(DashAmountFormat.string(forDuffs: abs(amount), maximumFractionDigits: maximumFractionDigits))
                    .font(.system(size: fontSize, weight: weight))
                    .lineLimit(1)
                DashIcon.Common.iconDashCurrency.image
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

#Preview("sign: .none (positive)") {
    DashAmount(amount: 6_791_000, fontSize: 15, sign: .none)
        .padding()
}

#Preview("sign: .negativeOnly — positive (no prefix)") {
    DashAmount(amount: 6_791_000, fontSize: 15, sign: .negativeOnly)
        .padding()
}

#Preview("sign: .negativeOnly — negative (-)") {
    DashAmount(amount: -6_791_000, fontSize: 15, sign: .negativeOnly)
        .padding()
}

#Preview("sign: .always — positive (+)") {
    DashAmount(amount: 6_791_000, fontSize: 15, sign: .always)
        .padding()
}

#Preview("sign: .always — negative (-)") {
    DashAmount(amount: -6_791_000, fontSize: 15, sign: .always)
        .padding()
}

#Preview("Zero (no sign in any mode)") {
    VStack(spacing: 8) {
        DashAmount(amount: 0, fontSize: 15, sign: .none)
        DashAmount(amount: 0, fontSize: 15, sign: .negativeOnly)
        DashAmount(amount: 0, fontSize: 15, sign: .always)
    }
    .padding()
}

#Preview("Not available (Int64.max)") {
    DashAmount(amount: .max, fontSize: 15)
        .padding()
}

#endif
