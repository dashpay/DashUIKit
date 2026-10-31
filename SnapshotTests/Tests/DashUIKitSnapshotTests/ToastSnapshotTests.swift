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
final class ToastSnapshotTests: XCTestCase {

    /// Every style but `.loading`, on the blue surface the preview uses, and one
    /// message longer than the toast is wide. `.loading` draws `LoadingSpinner`,
    /// whose timer moves the bright spoke while the image is taken.
    func testStyles() throws {
        let view = VStack(spacing: 12) {
            Toast(style: .warning, message: "Some coins are not available", onDismiss: {})
            Toast(style: .info, message: "Heads up", onDismiss: {})
            Toast(
                style: .error,
                message: "The payment could not be sent. Check your connection and try again.",
                onDismiss: {}
            )
            Toast(style: .success, message: "Done", onDismiss: {})
            Toast(style: .copied, message: "Copied to clipboard")
            Toast(style: .noInternet, message: "No internet connection")
        }
        try assertComponentSnapshots(of: view, named: "styles", background: .dash.blue)
    }
}
#endif
