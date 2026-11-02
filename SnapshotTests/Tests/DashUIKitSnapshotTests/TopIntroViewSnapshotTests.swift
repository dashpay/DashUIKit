//
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
#if canImport(UIKit)
import DashUIKit
import SwiftUI
import XCTest

@MainActor
final class TopIntroViewSnapshotTests: XCTestCase {

    private let title = "Username Voting"
    private let main = "As a masternode owner you can vote to approve requested usernames before users will be able to create it."
    private let secondary = "You can block the creation of the usernames that you feel inappropriate."

    func testDefaultColor() throws {
        let intro = TopIntroView(title: title, mainDescription: main, secondaryDescription: secondary)
        try assertComponentSnapshots(of: intro, named: "default")
    }

    /// The shapes most screens use: a title alone, and a title with one description.
    func testFewerDescriptions() throws {
        let intros = VStack(alignment: .leading, spacing: 24) {
            TopIntroView(title: title)
            TopIntroView(title: title, mainDescription: main)
        }
        try assertComponentSnapshots(of: intros, named: "fewer-descriptions")
    }

    /// Both descriptions take the colour; the title stays primary.
    func testSecondaryTextDescriptions() throws {
        let intro = TopIntroView(
            title: title,
            mainDescription: main,
            secondaryDescription: secondary,
            descriptionColor: Color.dash.secondaryText)
        try assertComponentSnapshots(of: intro, named: "secondary-text")
    }
}
#endif
