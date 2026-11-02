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
final class List8ViewSnapshotTests: XCTestCase {

    private static var avatar: some View {
        Circle().fill(Color.dash.gray300)
    }

    private static let showsAvatar = false

    /// With an avatar and without one; an avatar builder that produces no view
    /// lays out like no avatar. Long values truncate in the middle by default,
    /// at the tail on request, and a long label and a long value share the width.
    func testEveryState() throws {
        let view = VStack(spacing: 0) {
            List8View(label: "To", value: "username") { Self.avatar }
            List8View(label: "To", value: "username")
            List8View(label: "To", value: "a-very-long-username-that-does-not-fit-the-row") {
                if Self.showsAvatar { Self.avatar }
            }
            List8View(
                label: "To",
                value: "Alexandra Konstantinopoulou-Whitfield of the Treasury Reserve",
                truncationMode: .tail
            ) { Self.avatar }
            List8View(label: "To", value: "a-very-long-username-that-does-not-fit-the-row") { Self.avatar }
            List8View(label: "A longer translated label", value: "bob") { Self.avatar }
            List8View(label: "A longer translated label", value: "a-very-long-username") { Self.avatar }
        }
        try assertComponentSnapshots(of: view, named: "states")
    }
}
#endif
