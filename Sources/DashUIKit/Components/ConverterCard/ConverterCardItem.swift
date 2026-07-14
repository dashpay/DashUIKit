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

// MARK: - ConverterCardItem

/// Display data for a single row of `ConverterCard`.
///
/// The common case (a `DashIconSource` icon + a Dash balance) is fully described by the plain
/// values. For richer rows — a remotely-loaded icon, a custom trailing view, or a multi-line
/// subtitle — pass `iconView` / `trailingView` / `subtitleLineLimit`, which take precedence.
///
/// `id` drives the swap slide animation: it must be **stable per data-source across rebuilds**
/// (the Coinbase row keeps the same id whether it occupies the top or bottom slot). The default
/// `id = title` is sufficient when titles are distinct and stable. Pass an explicit `id` if the
/// title might change or if two rows could share a title.
@available(iOS 14, macOS 11, *)
public struct ConverterCardItem: Identifiable {
    public let id: AnyHashable
    /// Static leading icon. Ignored when `iconView` is non-nil.
    public let icon: DashIconSource?
    /// Custom leading view (e.g. a remotely-loaded coin icon). Takes precedence over `icon`.
    public let iconView: AnyView?
    public let title: String
    public let subtitle: String?
    /// Subtitle line cap; `nil` allows unlimited wrapping (e.g. a long address).
    public let subtitleLineLimit: Int?
    /// Dash balance in duffs (10⁸ per Dash) — rendered as a Dash amount when `showsBalance`.
    public let dashBalance: Int64
    public let fiat: String?
    /// Custom trailing view (e.g. a formatted `DashBalanceView`). Takes precedence over the
    /// built-in dash-balance rendering.
    public let trailingView: AnyView?
    /// When `false` (and no `trailingView`), the row hides its trailing balance.
    public let showsBalance: Bool

    public init(
        id: AnyHashable? = nil,
        icon: DashIconSource? = nil,
        iconView: AnyView? = nil,
        title: String,
        subtitle: String? = nil,
        subtitleLineLimit: Int? = 1,
        dashBalance: Int64 = 0,
        fiat: String? = nil,
        trailingView: AnyView? = nil,
        showsBalance: Bool = true
    ) {
        self.id = id ?? AnyHashable(title)
        self.icon = icon
        self.iconView = iconView
        self.title = title
        self.subtitle = subtitle
        self.subtitleLineLimit = subtitleLineLimit
        self.dashBalance = dashBalance
        self.fiat = fiat
        self.trailingView = trailingView
        self.showsBalance = showsBalance
    }
}
