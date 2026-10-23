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

/// Finite set of trailing accessories for `MenuItem`.
/// Add a new case here — not a per-call-site font/color override — when a
/// new trailing look is needed, to keep all rows consistent.
public enum MenuItemAccessory {
    case none
    case toggle(isOn: Binding<Bool>)
    case text(String)
    case button(DashButton)
    /// Dash amount with an optional pre-formatted fiat sub-line.
    /// The caller converts the fiat value via its own exchange infrastructure;
    /// the library only renders the string it receives.
    case balance(dash: Int64, sign: DashAmountSign = .negativeOnly, fiat: String? = nil,
                 maximumFractionDigits: Int = DashAmountFormat.defaultMaximumFractionDigits)
    /// A picker row: the design system's tick on the chosen one.
    ///
    /// The mark keeps its slot while unselected, so nothing in the row shifts
    /// horizontally as the selection moves down a list.
    case selection(isSelected: Bool)
}

/// The glyph beside a row's title that says there is more to explain.
///
/// `.round` is the design system's own info mark; `.icon` stays open for a row
/// that needs to flag something else entirely.
public enum MenuItemInfo {
    case round(color: Color)
    case icon(DashIconSource)
}

public struct MenuItem: View {

    public var leadingIcon: DashIconSource?
    public var isEnabled: Bool
    public var disabledLeadingIcon: DashIconSource?
    public var title: String
    public var helpText: String?
    public var info: MenuItemInfo?
    public var accessory: MenuItemAccessory

    public init(
        leadingIcon: DashIconSource? = nil,
        isEnabled: Bool = true,
        disabledLeadingIcon: DashIconSource? = nil,
        title: String,
        helpText: String? = nil,
        info: MenuItemInfo? = nil,
        accessory: MenuItemAccessory = .none
    ) {
        self.leadingIcon = leadingIcon
        self.isEnabled = isEnabled
        self.disabledLeadingIcon = disabledLeadingIcon
        self.title = title
        self.helpText = helpText
        self.info = info
        self.accessory = accessory
    }

    public var body: some View {
        HStack(spacing: 10) {
            leading
            central
            Spacer()
            trailing
        }
        .padding(10)
    }

    @ViewBuilder
    private var leading: some View {
        let icon = isEnabled ? leadingIcon : (disabledLeadingIcon ?? leadingIcon)
        if let icon {
            Image(dash: icon)
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
        }
    }

    private var central: some View {
        VStack(alignment: .leading, spacing: 1) {
            HStack(spacing: 6) {
                Text(title)
                    .dashFont(.subheadMedium)
                    .foregroundColor(isEnabled ? Color.dash.primaryText : Color.dash.secondaryText)

                if let info {
                    switch info {
                    case .round(let color):
                        InfoRoundIcon(size: 19, color: color)
                            .frame(width: 20, height: 20, alignment: .center)
                    case .icon(let icon):
                        Image(dash: icon)
                            .frame(width: 20, height: 20, alignment: .center)
                    }
                }
            }

            if let helpText {
                Text(helpText)
                    .dashFont(.footnote)
                    .foregroundColor(isEnabled ? Color.dash.secondaryText : Color.dash.tertiaryText)
            }
        }
        .padding(.leading, 6)
    }

    @ViewBuilder
    private var trailing: some View {
        switch accessory {
        case .none:
            EmptyView()
        case .toggle(let isOn):
            // `SwitchView`, not `Toggle`: the system switch is green and sized
            // by UIKit, so a menu row rendered here did not match the switch
            // the same design system hands out everywhere else. It reads
            // `isEnabled` from the environment, which `.disabled` sets.
            SwitchView(isOn: isOn)
                .disabled(!isEnabled)
        case .text(let value):
            Text(value)
                .dashFont(.subhead)
                .foregroundColor(Color.dash.secondaryText)
        case .button(let button):
            button
        case .balance(let dash, let sign, let fiat, let maximumFractionDigits):
            VStack(alignment: .trailing, spacing: 1) {
                DashAmount(amount: dash, sign: sign, maximumFractionDigits: maximumFractionDigits)
                    .foregroundColor(Color.dash.primaryText)

                if dash != 0, dash != .max, dash != .min, let fiat {
                    Text(fiat)
                        .dashFont(.footnote)
                        .foregroundColor(Color.dash.secondaryText)
                }
            }
        case .selection(let isSelected):
            CheckmarkIcon()
                .opacity(isSelected ? 1 : 0)
                .accessibilityHidden(!isSelected)
        }
    }
}

#if DEBUG

#Preview("Title only") {
    MenuItem(title: "Notifications")
        .padding(.horizontal)
}

#Preview("Title + helpText") {
    MenuItem(
        title: "Recovery phrase",
        helpText: "Back up your wallet to keep your funds safe"
    )
    .padding(.horizontal)
}

#Preview("Title + info + helpText") {
    MenuItem(
        title: "Network fee",
        helpText: "Estimated cost for this transaction",
        info: .round(color: Color.dash.gray300Alpha70),
        accessory: .text("0.0001 DASH")
    )
    .padding(.horizontal)
}

#Preview("Accessory: toggle") {
    @Previewable @State var isOn = true
    MenuItem(
        title: "Enable biometrics",
        accessory: .toggle(isOn: $isOn)
    )
    .padding(.horizontal)
}

#Preview("Accessory: text") {
    MenuItem(
        title: "Balance",
        accessory: .text("0.0001 DASH")
    )
    .padding(.horizontal)
}

#Preview("Accessory: button") {
    MenuItem(
        title: "Withdraw",
        accessory: .button(DashButton(
            text: "Withdraw",
            size: .small,
            style: .tintedBlue,
            action: {}
        ))
    )
    .padding(.horizontal)
}

#Preview("Accessory: balance default (.negativeOnly)") {
    VStack(spacing: 0) {
        MenuItem(
            title: "Staking balance",
            accessory: .balance(dash: 6_791_000, fiat: "$1.23")
        )
        Divider().padding(.leading, 16)
        MenuItem(
            title: "Outgoing",
            accessory: .balance(dash: -6_791_000, fiat: "$1.23")
        )
    }
    .padding(.horizontal)
}

#Preview("Accessory: balance .always (transaction style)") {
    VStack(spacing: 0) {
        MenuItem(
            title: "Received",
            accessory: .balance(dash: 6_791_000, sign: .always, fiat: "$1.23")
        )
        Divider().padding(.leading, 16)
        MenuItem(
            title: "Sent",
            accessory: .balance(dash: -6_791_000, sign: .always, fiat: "$1.23")
        )
    }
    .padding(.horizontal)
}

#Preview("Accessory: balance zero") {
    MenuItem(
        title: "Available",
        accessory: .balance(dash: 0)
    )
    .padding(.horizontal)
}

#Preview("Accessory: balance not available") {
    MenuItem(
        title: "Pending",
        accessory: .balance(dash: .max)
    )
    .padding(.horizontal)
}

/// A picker list: one row marked, the rest holding the tick's slot empty.
#Preview("Accessory: selection") {
    VStack(spacing: 0) {
        MenuItem(
            leadingIcon: DashIcon.Menu.dashLogoSquare.source,
            title: "Transparent",
            accessory: .selection(isSelected: true)
        )

        MenuItem(
            leadingIcon: DashIcon.Features.platform.source,
            title: "Platform",
            accessory: .selection(isSelected: false)
        )

        MenuItem(
            leadingIcon: DashIcon.Features.shield.source,
            title: "Shielded",
            accessory: .selection(isSelected: false)
        )
    }
    .padding(.horizontal)
}

#Preview("Enabled vs disabled") {
    VStack(spacing: 0) {
        MenuItem(
            leadingIcon: DashIcon.Menu.receive.source,
            title: "Buy Dash",
            helpText: "From any crypto to your Dash Wallet"
        )

        Divider().padding(.leading, 16)

        MenuItem(
            leadingIcon: DashIcon.Menu.receive.source,
            isEnabled: false,
            disabledLeadingIcon: DashIcon.Menu.receiveDisabled.source,
            title: "Buy Dash",
            helpText: "From any crypto to your Dash Wallet"
        )
    }
    .padding(.horizontal)
}

#endif
