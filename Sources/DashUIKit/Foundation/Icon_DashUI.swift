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

/// A named icon shipped in DashUIKit's asset catalog.
///
/// Every icon group below is a `String`-backed enum whose raw value is the
/// imageset name, so a typo becomes a compile error instead of a blank image.
///
/// ```swift
/// Image(dash: DashIcon.Menu.send.source)
/// DashIcon.Toast.success.image.resizable().frame(width: 24, height: 24)
/// ```
@available(iOS 14, macOS 11, *)
public protocol DashIconAsset {
    /// The imageset name in the asset catalog.
    var assetName: String { get }
}

@available(iOS 14, macOS 11, *)
public extension DashIconAsset where Self: RawRepresentable, Self.RawValue == String {
    var assetName: String { rawValue }

    /// The icon as a `DashIconSource`, for components that take one.
    var source: DashIconSource { .custom(assetName, bundle: .dashUIKit) }

    /// The icon as a plain `Image`. Styling is the caller's job.
    var image: Image { Image(dash: source) }
}

/// Namespace for every icon in the library's asset catalog, grouped the same
/// way the catalog is.
@available(iOS 14, macOS 11, *)
public enum DashIcon {

    // MARK: - Common
    /// `root of the catalog`
    public enum Common: String, CaseIterable, DashIconAsset {
        case arrowDown = "arrow-down"
        case checkmark = "checkmark"
        case chevronDownCurrencySelect = "chevron-down-currency-select"
        case diagonalUpDown = "diagonal-up-down"
        case enterAmountDash = "enter-amount-dash"
        case iconDashCurrency = "icon_dash_currency"
        case illustrationXmark = "illustration-xmark"
    }

    // MARK: - Icons
    /// `Icons`
    public enum Icons: String, CaseIterable, DashIconAsset {
        case copyOutline = "copy-outline"
    }

    // MARK: - Illustrations
    /// `Illustrations`
    public enum Illustrations: String, CaseIterable, DashIconAsset {
        case crowdnodeWarning = "crowdnode.warning"
        case dashDex = "illustration-dash-dex"
    }

    // MARK: - Features
    /// `Features`
    ///
    /// The illustrated rows of an explainer sheet (`SheetFeature`). Several
    /// come in a plain and a `-purple` variant — the plain one is tinted by
    /// the caller, the purple one carries its own colour.
    public enum Features: String, CaseIterable, DashIconAsset {
        case identity = "feature-identity"
        case instant = "feature-instant"
        case platform = "feature-platform"
        case platformPurple = "feature-platform-purple"
        case shield = "feature-shield"
        case shieldPurple = "feature-shield-purple"
        case timer = "feature-timer"
        case timerPurple = "feature-timer-purple"
    }

    // MARK: - Checkbox
    /// `Components/Checkbox`
    public enum Checkbox: String, CaseIterable, DashIconAsset {
        case checkmarkChecked = "checkbox-checkmark-checked"
        case checkmarkUnchecked = "checkbox-checkmark-unchecked"
    }

    // MARK: - SegmentedControl
    /// `Segmented control`
    ///
    /// One arrow per direction, in that direction's colour, plus a grey
    /// `-disabled` twin for the segment that is not selected. The colour is
    /// in the artwork rather than applied at the call site, so a segment
    /// switches file rather than tint when the selection moves.
    public enum SegmentedControl: String, CaseIterable, DashIconAsset {
        case receive = "segmented-control-receive"
        case receiveDisabled = "segmented-control-receive-disabled"
        case send = "segmented-control-send"
        case sendDisabled = "segmented-control-send-disabled"
        case transfer = "segmented-control-transfer"
        case transferDisabled = "segmented-control-transfer-disabled"
    }

    // MARK: - SearchBar
    /// `Components/SearchBar`
    public enum SearchBar: String, CaseIterable, DashIconAsset {
        case magnifyingglassIcon = "searchbar-magnifyingglass-icon"
        case xmarkIcon = "searchbar-xmark-icon"
    }

    // MARK: - Menu
    /// `Menu`
    public enum Menu: String, CaseIterable, DashIconAsset {
        case accountError = "menu-account-error"
        case accountLink = "menu-account-link"
        case accountOnline = "menu-account-online"
        case accountProcessing = "menu-account-processing"
        case accountSuccess = "menu-account-success"
        case accountWarning = "menu-account-warning"
        case addressBook = "menu-address-book"
        case advancedSecurity = "menu-advanced-security"
        case appReview = "menu-app-review"
        case appearance = "menu-appearance"
        case applePay = "menu-apple-pay"
        case atm = "menu-atm"
        case autohideBalance = "menu-autohide-balance"
        case backup = "menu-backup"
        case bank = "menu-bank"
        case battery = "menu-battery"
        case blockchair = "menu-blockchair"
        case buySell = "menu-buy-sell"
        case buySellDash2 = "menu-buy-sell-dash-2"
        case clipboard = "menu-clipboard"
        case coinbase = "menu-coinbase"
        case connections = "menu-connections"
        case convert = "menu-convert"
        case creditCard = "menu-credit-card"
        case credits = "menu-credits"
        case crowdnode = "menu-crowdnode"
        case csvExport = "menu-csv-export"
        case ctx = "menu-ctx"
        case currentLocation = "menu-current-location"
        case dashLogoSquare = "menu-dash-logo-square"
        case explore = "menu-explore"
        case extendPublicKey = "menu-extend-public-key"
        case faceID = "menu-face-id"
        case faceIDRounded = "menu-face-id-rounded"
        case file = "menu-file"
        case flexa = "menu-flexa"
        case floppyDisk = "menu-floppy-disk"
        case gPay = "menu-g-pay"
        case importPrivateKey = "menu-import-private-key"
        case infoRect = "menu-info-rect"
        case invitation = "menu-invitation"
        case invitationOpen = "menu-invitation-open"
        case linkAccount2 = "menu-link-account-2"
        case localCurrency = "menu-local-currency"
        case logout = "menu-logout"
        case masternodeKeys = "menu-masternode-keys"
        case maya = "menu-maya"
        case merchant = "menu-merchant"
        case mixing = "menu-mixing"
        case networkMonitor = "menu-network-monitor"
        case notification = "menu-notification"
        case notificationNew = "menu-notification-new"
        case paypal = "menu-paypal"
        case piggyCards = "menu-piggy-cards"
        case pin = "menu-pin"
        case qr = "menu-qr"
        case receive = "menu-receive"
        case receiveDisabled = "menu-receive-disabled"
        case recoveryPhrase = "menu-recovery-phrase"
        case rescanBlockchain = "menu-rescan-blockchain"
        case resetWallet = "menu-reset-wallet"
        case reverseSyncing = "menu-reverse-syncing"
        case scanQR = "menu-scan-qr"
        case security = "menu-security"
        case send = "menu-send"
        case sendAccount = "menu-send-account"
        case sendAccountDisabled = "menu-send-account-disabled"
        case sendAddress = "menu-send-address"
        case sendDisabled = "menu-send-disabled"
        case settings = "menu-settings"
        case shield = "menu-shield"
        case shieldAdvanced = "menu-shield-advanced"
        case shieldIntermediate = "menu-shield-intermediate"
        case shortcuts = "menu-shortcuts"
        case spend = "menu-spend"
        case spendingConfirmation = "menu-spending-confirmation"
        case staking = "menu-staking"
        case support = "menu-support"
        case tools = "menu-tools"
        case tools2 = "menu-tools-2"
        case topper = "menu-topper"
        case touchID = "menu-touch-id"
        case transfer = "menu-transfer"
        case uphold = "menu-uphold"
        case userSearch = "menu-user-search"
        case usernameVoting = "menu-username-voting"
        case wallet = "menu-wallet"
        case zenledger = "menu-zenledger"
    }

    // MARK: - NavigationBar
    /// `Navigation bar`
    public enum NavigationBar: String, CaseIterable, DashIconAsset {
        case back = "navigationbar-back"
        case close = "navigationbar-close"
        case info = "navigationbar-info"
        case plus = "navigationbar-plus"
    }

    // MARK: - SystemMessage
    /// `System message`
    public enum SystemMessage: String, CaseIterable, DashIconAsset {
        case infoRectSmall = "system-message-info-rect-small"
        case shieldSmall = "system-message-shield-small"
        case timerSmall = "system-message-timer-small"
        case unmixedFunds = "system-message-unmixed-funds"
        case usernameChange = "system-message-username-change"
        case warningTriangle = "system-message-warning-triangle"
    }

    // MARK: - Toast
    /// `Toast`
    public enum Toast: String, CaseIterable, DashIconAsset {
        case copied = "toast-copied"
        case error = "toast-error"
        case info = "toast-info"
        case noWifi = "toast-no-wifi"
        case success = "toast-success"
        case warning = "toast-warning"
    }

    // MARK: - Other
    /// `Other`
    public enum Other: String, CaseIterable, DashIconAsset {
        case textFieldClear = "text-field-clear"
        case textFieldQR = "text-field-qr"
    }

    // MARK: - AdditionalInfo
    /// `Transactions/AdditionalInfo`
    public enum AdditionalInfo: String, CaseIterable, DashIconAsset {
        case error = "additional-info-error"
        case giftCard = "additional-info-gift-card"
        case received = "additional-info-received"
        case sent = "additional-info-sent"
    }

    // MARK: - Transaction
    /// `Transactions/Preview`
    public enum Transaction: String, CaseIterable, DashIconAsset {
        case allTrans = "transaction-all-trans"
        case coinbaseReceived = "transaction-coinbase-received"
        case contactRequestApprove = "transaction-contact-request-approve"
        case contactRequestSent = "transaction-contact-request-sent"
        case convert = "transaction-convert"
        case crowdnode = "transaction-crowdnode"
        case error = "transaction-error"
        case giftCard = "transaction-gift-card"
        case internalTransfer = "transaction-internal-transfer"
        case mining = "transaction-mining"
        case mixing = "transaction-mixing"
        case received = "transaction-received"
        case sent = "transaction-sent"
        case upholdReceived = "transaction-uphold-received"
    }
}
