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

@available(iOS 14, macOS 10.15, *)
public extension Font {
    static var dash: DashFonts.Type { DashFonts.self }
}

@available(iOS 14, macOS 10.15, *)
public enum DashFonts {

    /// Large Title: 34pt Bold (line height: 41pt)
    public static let largeTitle: Font = DashTextStyle.largeTitle.font

    /// Title 1: 28pt Bold (line height: 34pt)
    public static let title1: Font = DashTextStyle.title1.font

    /// Title 2: 22pt Bold (line height: 28pt)
    public static let title2: Font = DashTextStyle.title2.font

    /// Title 3: 20pt Bold (line height: 25pt)
    public static let title3: Font = DashTextStyle.title3.font

    /// Title 3 Medium: 20pt Medium (line height: 25pt)
    public static let title3Medium: Font = DashTextStyle.title3Medium.font

    /// Headline: 17pt Bold (line height: 22pt)
    public static let headline: Font = DashTextStyle.headline.font

    /// Body: 17pt Regular (line height: 22pt)
    public static let body: Font = DashTextStyle.body.font

    /// Callout: 16pt Regular (line height: 21pt)
    public static let callout: Font = DashTextStyle.callout.font

    /// Callout Medium: 16pt Semibold (line height: 21pt)
    public static let calloutMedium: Font = DashTextStyle.calloutMedium.font

    /// Subhead Regular: 15pt Regular (line height: 20pt)
    public static let subhead: Font = DashTextStyle.subhead.font

    /// Subhead Medium: 15pt Medium (line height: 20pt)
    public static let subheadMedium: Font = DashTextStyle.subheadMedium.font

    /// Footnote Regular: 13pt Regular (line height: 18pt)
    public static let footnote: Font = DashTextStyle.footnote.font

    /// Footnote Medium: 13pt Medium (line height: 18pt)
    public static let footnoteMedium: Font = DashTextStyle.footnoteMedium.font
    public static let footnoteMedium2: Font = DashTextStyle.footnoteMedium.font

    /// Caption 1: 12pt Regular (line height: 16pt)
    public static let caption1: Font = DashTextStyle.caption1.font

    /// Caption 2: 11pt Regular (line height: 13pt)
    public static let caption2: Font = DashTextStyle.caption2.font
}
