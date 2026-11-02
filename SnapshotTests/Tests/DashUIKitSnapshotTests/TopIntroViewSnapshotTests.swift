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

    /// A title alone, with one description, and with both; the last wraps
    /// inside the 40 pt it keeps clear on the trailing side.
    func testContent() throws {
        let view = VStack(spacing: 16) {
            TopIntroView(title: "Send")
            TopIntroView(title: "Choose a username", mainDescription: "It is how other people find you.")
            TopIntroView(
                title: "Recovery phrase",
                mainDescription: "Write these 12 words down in this order and keep them somewhere safe.",
                secondaryDescription: "Anyone who has them can spend your funds."
            )
        }
        try assertComponentSnapshots(of: view, named: "content")
    }
}
#endif
