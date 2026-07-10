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
#if canImport(UIKit)
import UIKit
#endif

@available(iOS 14, macOS 10.15, *)
public extension Color {
    static var dash: DashColors.Type { DashColors.self }
}

@available(iOS 14, macOS 10.15, *)
public enum DashColors {

    // MARK: Text

    public static var primaryText: Color { dashAsset("PrimaryText") }
    public static var secondaryText: Color { dashAsset("SecondaryText") }
    public static var tertiaryText: Color { dashAsset("TertiaryText") }
    public static var whiteText: Color { dashAsset("WhiteText") }
    public static var blueText: Color { dashAsset("BlueText") }
    public static var successText: Color { dashAsset("SuccessText") }
    public static var errorText: Color { dashAsset("ErrorText") }

    // MARK: Background

    public static var primaryBackground: Color { dashAsset("PrimaryBackground") }
    public static var secondaryBackground: Color { dashAsset("SecondaryBackground") }
    public static var tertiaryBackground: Color { dashAsset("TertiaryBackground") }
    public static var blueBackground: Color { dashAsset("BlueBackground") }

    // MARK: Badge

    public static var badgeBackground1: Color { dashAsset("BadgeBackground1") }
    public static var badgeBackground2: Color { dashAsset("BadgeBackground2") }
    public static var badgeBackgroundCont1: Color { dashAsset("BadgeBackgroundCont1") }
    public static var badgeBackgroundCont2: Color { dashAsset("BadgeBackgroundCont2") }

    // MARK: Bottom Nav

    public static var bottomNavBackground: Color { dashAsset("BottomNavBackground") }

    // MARK: Buttons

    public static var buttonFilledBlueBackground: Color { dashAsset("ButtonFilledBlueBackground") }
    public static var buttonFilledBlueBackgroundDisabled: Color { dashAsset("ButtonFilledBlueBackgroundDisabled") }
    public static var buttonFilledBlueContent: Color { dashAsset("ButtonFilledBlueContent") }
    public static var buttonFilledBlueContentDisabled: Color { dashAsset("ButtonFilledBlueContentDisabled") }

    public static var buttonFilledOrangeBackground: Color { dashAsset("ButtonFilledOrangeBackground") }
    public static var buttonFilledOrangeBackgroundDisabled: Color { dashAsset("ButtonFilledOrangeBackgroundDisabled") }
    public static var buttonFilledOrangeContent: Color { dashAsset("ButtonFilledOrangeContent") }
    public static var buttonFilledOrangeContentDisabled: Color { dashAsset("ButtonFilledOrangeContentDisabled") }

    public static var buttonFilledRedBackground: Color { dashAsset("ButtonFilledRedBackground") }
    public static var buttonFilledRedBackgroundDisabled: Color { dashAsset("ButtonFilledRedBackgroundDisabled") }
    public static var buttonFilledRedContent: Color { dashAsset("ButtonFilledRedContent") }
    public static var buttonFilledRedContentDisabled: Color { dashAsset("ButtonFilledRedContentDisabled") }

    public static var buttonFilledWhiteBackground: Color { dashAsset("ButtonFilledWhiteBackground") }
    public static var buttonFilledWhiteBackgroundDisabled: Color { dashAsset("ButtonFilledWhiteBackgroundDisabled") }
    public static var buttonFilledWhiteContent: Color { dashAsset("ButtonFilledWhiteContent") }
    public static var buttonFilledWhiteContentDisabled: Color { dashAsset("ButtonFilledWhiteContentDisabled") }

    public static var buttonPlainBlackContent: Color { dashAsset("ButtonPlainBlackContent") }
    public static var buttonPlainBlackContentDisabled: Color { dashAsset("ButtonPlainBlackContentDisabled") }

    public static var buttonPlainBlueContent: Color { dashAsset("ButtonPlainBlueContent") }
    public static var buttonPlainBlueContentDisabled: Color { dashAsset("ButtonPlainBlueContentDisabled") }

    public static var buttonPlainRedContent: Color { dashAsset("ButtonPlainRedContent") }
    public static var buttonPlainRedContentDisabled: Color { dashAsset("ButtonPlainRedContentDisabled") }

    public static var buttonPlainWhiteContent: Color { dashAsset("ButtonPlainWhiteContent") }
    public static var buttonPlainWhiteContentDisabled: Color { dashAsset("ButtonPlainWhiteContentDisabled") }

    public static var buttonStrokeGrayBackgroundDisabled: Color { dashAsset("ButtonStrokeGrayBackgroundDisabled") }
    public static var buttonStrokeGrayContent: Color { dashAsset("ButtonStrokeGrayContent") }
    public static var buttonStrokeGrayContentDisabled: Color { dashAsset("ButtonStrokeGrayContentDisabled") }
    public static var buttonStrokeGrayStroke: Color { dashAsset("ButtonStrokeGrayStroke") }

    public static var buttonTintedBlueBackground: Color { dashAsset("ButtonTintedBlueBackground") }
    public static var buttonTintedBlueBackgroundDisabled: Color { dashAsset("ButtonTintedBlueBackgroundDisabled") }
    public static var buttonTintedBlueContent: Color { dashAsset("ButtonTintedBlueContent") }
    public static var buttonTintedBlueContentDisabled: Color { dashAsset("ButtonTintedBlueContentDisabled") }

    public static var buttonTintedGrayBackground: Color { dashAsset("ButtonTintedGrayBackground") }
    public static var buttonTintedGrayBackgroundDisabled: Color { dashAsset("ButtonTintedGrayBackgroundDisabled") }
    public static var buttonTintedGrayContent: Color { dashAsset("ButtonTintedGrayContent") }
    public static var buttonTintedGrayContentDisabled: Color { dashAsset("ButtonTintedGrayContentDisabled") }

    public static var buttonTintedWhiteBackground: Color { dashAsset("ButtonTintedWhiteBackground") }
    public static var buttonTintedWhiteBackgroundDisabled: Color { dashAsset("ButtonTintedWhiteBackgroundDisabled") }
    public static var buttonTintedWhiteContent: Color { dashAsset("ButtonTintedWhiteContent") }
    public static var buttonTintedWhiteContentDisabled: Color { dashAsset("ButtonTintedWhiteContentDisabled") }

    // MARK: Grabber

    public static var grabberFill: Color { dashAsset("GrabberFill") }

    // MARK: List

    public static var listGiftCardNumberBackground: Color { dashAsset("ListGiftCardNumberBackground") }

    // MARK: Nav

    public static var navBackButton: Color { dashAsset("NavBackButton") }

    // MARK: Overlay

    public static var backgroundOverlay: Color { dashAsset("BackgroundOverlay") }

    // MARK: Search

    public static var searchBackground: Color { dashAsset("SearchBackground") }
    public static var searchClearIcon: Color { dashAsset("SearchClearIcon") }
    public static var searchIcon: Color { dashAsset("SearchIcon") }
    public static var searchPlaceholder: Color { dashAsset("SearchPlaceholder") }
    public static var searchTextEntered: Color { dashAsset("SearchTextEntered") }

    // MARK: Segment Control

    public static var segmentControlBackground: Color { dashAsset("SegmentControlBackground") }
    public static var segmentControlBackgroundGroup: Color { dashAsset("SegmentControlBackgroundGroup") }
    public static var segmentControlContNotSelected: Color { dashAsset("SegmentControlContNotSelected") }
    public static var segmentControlContSelected: Color { dashAsset("SegmentControlContSelected") }
    public static var segmentControlDivider: Color { dashAsset("SegmentControlDivider") }

    // MARK: Select

    public static var selectBackgroundSelected: Color { dashAsset("SelectBackgroundSelected") }
    public static var selectStrokeDefault: Color { dashAsset("SelectStrokeDefault") }
    public static var selectStrokeSelected: Color { dashAsset("SelectStrokeSelected") }

    // MARK: Shortcut Bar

    public static var shortcutBarBackground: Color { dashAsset("ShortcutBarBackground") }

    // MARK: Status Bar

    public static var statusBarElements: Color { dashAsset("StatusBarElements") }

    // MARK: Stepper

    public static var stepperBorder: Color { dashAsset("StepperBorder") }
    public static var stepperBorderDisabled: Color { dashAsset("StepperBorderDisabled") }
    public static var stepperElement: Color { dashAsset("StepperElement") }
    public static var stepperElementDisabled: Color { dashAsset("StepperElementDisabled") }

    // MARK: Switch

    public static var switchThumbFill: Color { dashAsset("SwitchThumbFill") }
    public static var switchTrackFillOff: Color { dashAsset("SwitchTrackFillOff") }
    public static var switchTrackFillOffDisabled: Color { dashAsset("SwitchTrackFillOffDisabled") }
    public static var switchTrackFillOn: Color { dashAsset("SwitchTrackFillOn") }

    // MARK: TextField

    public static var textFieldCryptoAddressBackground: Color { dashAsset("TextFieldCryptoAddressBackground") }
    public static var textFieldCryptoAddressIcon: Color { dashAsset("TextFieldCryptoAddressIcon") }

    // MARK: Toast

    public static var toastBackground: Color { dashAsset("ToastBackground") }
    public static var toastText: Color { dashAsset("ToastText") }

    // MARK: Toolbar

    public static var toolbarRoundBorder: Color { dashAsset("ToolbarRoundBorder") }
    public static var toolbarRoundContent: Color { dashAsset("ToolbarRoundContent") }

    // MARK: Top Intro

    public static var topIntroButtonBackground: Color { dashAsset("TopIntroButtonBackground") }
    public static var topIntroButtonContent: Color { dashAsset("TopIntroButtonContent") }

    // MARK: Tokens

    // MARK: Tokens / Blue

    public static var blue: Color { dashAsset("Blue") }
    public static var blueAlpha5: Color { dashAsset("BlueAlpha5") }
    public static var blueAlpha10: Color { dashAsset("BlueAlpha10") }
    public static var blueAlpha20: Color { dashAsset("BlueAlpha20") }
    public static var blueAlpha30: Color { dashAsset("BlueAlpha30") }
    public static var blueAlpha40: Color { dashAsset("BlueAlpha40") }
    public static var blueAlpha50: Color { dashAsset("BlueAlpha50") }
    public static var blueAlpha90: Color { dashAsset("BlueAlpha90") }

    // MARK: Tokens / Gray

    public static var black: Color { dashAsset("Black") }
    public static var black1000Alpha5: Color { dashAsset("Black1000Alpha5") }
    public static var black1000Alpha8: Color { dashAsset("Black1000Alpha8") }
    public static var black1000Alpha10: Color { dashAsset("Black1000Alpha10") }
    public static var black1000Alpha15: Color { dashAsset("Black1000Alpha15") }
    public static var black1000Alpha20: Color { dashAsset("Black1000Alpha20") }
    public static var black1000Alpha30: Color { dashAsset("Black1000Alpha30") }
    public static var black1000Alpha40: Color { dashAsset("Black1000Alpha40") }
    public static var black1000Alpha50: Color { dashAsset("Black1000Alpha50") }
    public static var black1000Alpha60: Color { dashAsset("Black1000Alpha60") }
    public static var black1000Alpha70: Color { dashAsset("Black1000Alpha70") }
    public static var black1000Alpha80: Color { dashAsset("Black1000Alpha80") }
    public static var black1000Alpha90: Color { dashAsset("Black1000Alpha90") }
    public static var black800: Color { dashAsset("Black800") }
    public static var black900: Color { dashAsset("Black900") }
    public static var gray50: Color { dashAsset("Gray50") }
    public static var gray100: Color { dashAsset("Gray100") }
    public static var gray200: Color { dashAsset("Gray200") }
    public static var gray300: Color { dashAsset("Gray300") }
    public static var gray300Alpha5: Color { dashAsset("Gray300Alpha5") }
    public static var gray300Alpha10: Color { dashAsset("Gray300Alpha10") }
    public static var gray300Alpha20: Color { dashAsset("Gray300Alpha20") }
    public static var gray300Alpha30: Color { dashAsset("Gray300Alpha30") }
    public static var gray300Alpha40: Color { dashAsset("Gray300Alpha40") }
    public static var gray300Alpha50: Color { dashAsset("Gray300Alpha50") }
    public static var gray300Alpha60: Color { dashAsset("Gray300Alpha60") }
    public static var gray300Alpha70: Color { dashAsset("Gray300Alpha70") }
    public static var gray300Alpha80: Color { dashAsset("Gray300Alpha80") }
    public static var gray300Alpha90: Color { dashAsset("Gray300Alpha90") }
    public static var gray400: Color { dashAsset("Gray400") }
    public static var gray400Alpha10: Color { dashAsset("Gray400Alpha10") }
    public static var gray400Alpha13: Color { dashAsset("Gray400Alpha13") }
    public static var gray400Alpha25: Color { dashAsset("Gray400Alpha25") }
    public static var gray500: Color { dashAsset("Gray500") }

    // MARK: Tokens / Green

    public static var green: Color { dashAsset("Green") }
    public static var greenAlpha10: Color { dashAsset("GreenAlpha10") }

    // MARK: Tokens / Light Blue

    public static var lightBlue: Color { dashAsset("LightBlue") }
    public static var lightBlueAlpha10: Color { dashAsset("LightBlueAlpha10") }

    // MARK: Tokens / Orange

    public static var orange: Color { dashAsset("Orange") }
    public static var orangeAlpha10: Color { dashAsset("OrangeAlpha10") }

    // MARK: Tokens / Red

    public static var red: Color { dashAsset("Red") }
    public static var redAlpha5: Color { dashAsset("RedAlpha5") }
    public static var redAlpha10: Color { dashAsset("RedAlpha10") }

    // MARK: Tokens / White

    public static var white: Color { dashAsset("White") }
    public static var whiteAlpha5: Color { dashAsset("WhiteAlpha5") }
    public static var whiteAlpha10: Color { dashAsset("WhiteAlpha10") }
    public static var whiteAlpha15: Color { dashAsset("WhiteAlpha15") }
    public static var whiteAlpha20: Color { dashAsset("WhiteAlpha20") }
    public static var whiteAlpha30: Color { dashAsset("WhiteAlpha30") }
    public static var whiteAlpha40: Color { dashAsset("WhiteAlpha40") }
    public static var whiteAlpha50: Color { dashAsset("WhiteAlpha50") }
    public static var whiteAlpha60: Color { dashAsset("WhiteAlpha60") }
    public static var whiteAlpha70: Color { dashAsset("WhiteAlpha70") }
    public static var whiteAlpha80: Color { dashAsset("WhiteAlpha80") }
    public static var whiteAlpha90: Color { dashAsset("WhiteAlpha90") }

    // MARK: Tokens / Yellow

    public static var yellow: Color { dashAsset("Yellow") }
    public static var yellowAlpha10: Color { dashAsset("YellowAlpha10") }

    // MARK: Tokens / Custom

    public static var purple: Color { dashAsset("Purple") }
    public static var topper: Color { dashAsset("Topper") }
    public static var uphold: Color { dashAsset("Uphold") }

    // MARK: Shadow

    public static var shadow: Color {
        #if canImport(UIKit)
        Color(
            UIColor { traitCollection in
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    return .clear
                default:
                    return UIColor(red: 0.72, green: 0.76, blue: 0.8, alpha: 0.1)
                }
            }
        )
        #else
        .clear
        #endif
    }
}

@available(iOS 14, macOS 10.15, *)
private extension DashColors {
    static func dashAsset(_ name: String) -> Color {
        Color(name, bundle: .module)
    }
}
