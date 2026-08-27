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

import Foundation

// MARK: - DashCurrencySymbol (internal)

enum DashCurrencySymbol {
    /// Locale-based currency symbol (deterministic; no app state).
    static func symbol(for currencyCode: String) -> String {
        let locale = Locale.current as NSLocale
        if let s = locale.displayName(forKey: .currencySymbol, value: currencyCode), !s.isEmpty {
            return s
        }
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = currencyCode
        return f.currencySymbol
    }
}

// MARK: - CurrencyOption

public enum CurrencyOption: Hashable {
    case fiat(String)
    case dash
    case coin(String)

    public var isFiat: Bool {
        if case .fiat = self { return true }
        return false
    }

    public var isCoinInput: Bool {
        if case .coin = self { return true }
        return false
    }

    public var displayName: String {
        switch self {
        case .fiat(let code): return code
        case .dash: return "DASH"
        case .coin(let code): return code
        }
    }

    public var symbol: String? {
        switch self {
        case .fiat(let code):
            return DashCurrencySymbol.symbol(for: code)
        case .dash: return nil
        case .coin(let code): return code
        }
    }
}
