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

// MARK: - ReceiveEstimateView

/// A centered "you will receive" estimate shown beneath an amount input in convert/swap flows.
/// Renders (in priority order): a spinner while loading, an error message, or the estimated
/// receive amount under a caption. Collapses to nothing when `isVisible` is `false`.
///
/// The `title` label is passed in so the component stays localization-agnostic.
@available(iOS 14, macOS 11, *)
public struct ReceiveEstimateView: View {

    private let isVisible: Bool
    private let isLoading: Bool
    private let errorMessage: String?
    private let amount: String?
    private let fiat: String?
    private let title: String
    private let approximate: Bool

    /// - Parameters:
    ///   - fiat: optional fiat value shown after the amount, joined with `≈` (e.g.
    ///     `"22 DASH ≈ $6.04"`). When `nil` only `amount` is shown.
    ///   - approximate: when `true` (and no `fiat`) the amount is prefixed with `~` (an estimate,
    ///     e.g. a swap quote); when `false` it is shown exactly (e.g. a transfer where the fee is
    ///     added on top and does not change the received amount).
    public init(
        isVisible: Bool,
        title: String,
        amount: String?,
        fiat: String? = nil,
        isLoading: Bool = false,
        errorMessage: String? = nil,
        approximate: Bool = true
    ) {
        self.isVisible = isVisible
        self.title = title
        self.amount = amount
        self.fiat = fiat
        self.isLoading = isLoading
        self.errorMessage = errorMessage
        self.approximate = approximate
    }

    private func amountText(_ amount: String) -> String {
        if let fiat { return "\(amount) ≈ \(fiat)" }
        return approximate ? "~ \(amount)" : amount
    }

    public var body: some View {
        if isVisible {
            VStack(alignment: .center, spacing: 0) {
                if isLoading {
                    ProgressView()
                } else if let errorMessage {
                    // An error (e.g. insufficient balance) supersedes the receive estimate — both can
                    // be set at once, so show the error first.
                    Text(errorMessage)
                        .dashFont(.caption1)
                        .foregroundColor(Color.dash.errorText)
                } else if let amount {
                    Text(title)
                        .dashFont(.caption1)
                        .foregroundColor(Color.dash.tertiaryText)

                    Text(amountText(amount))
                        .dashFont(.subhead)
                        .foregroundColor(Color.dash.primaryText)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .transition(.opacity)
        }
    }
}

#if DEBUG
@available(iOS 14, macOS 11, *)
struct ReceiveEstimateView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 24) {
            ReceiveEstimateView(isVisible: true, title: "Receive amount", amount: nil, isLoading: true)
            ReceiveEstimateView(isVisible: true, title: "Receive amount", amount: nil, errorMessage: "Insufficient balance")
            ReceiveEstimateView(isVisible: true, title: "Receive amount", amount: "0.0123 BTC")
            ReceiveEstimateView(isVisible: true, title: "You will receive", amount: "0.5 DASH", approximate: false)
        }
        .padding()
        .background(Color.dash.primaryBackground)
    }
}
#endif
