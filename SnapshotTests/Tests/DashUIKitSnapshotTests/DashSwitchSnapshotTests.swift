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
final class DashSwitchSnapshotTests: XCTestCase {

    /// On and off, enabled and disabled. Each binding is constant, so no
    /// toggle animation runs. The system switch draws its thumb as a visual
    /// effect, which a render without a host app leaves out: the images pin the
    /// track and its tint, not the thumb.
    func testStates() throws {
        let view = HStack(spacing: 20) {
            DashSwitch(isOn: .constant(true))
            DashSwitch(isOn: .constant(false))
            DashSwitch(isOn: .constant(true)).disabled(true)
            DashSwitch(isOn: .constant(false)).disabled(true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        try assertComponentSnapshots(of: view, named: "states")
    }
}
#endif
