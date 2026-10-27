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
import UIKit
import XCTest
@testable import DashUIKit

final class DashIconTests: XCTestCase {

    /// Every case names an imageset that ships in the package bundle, so a
    /// raw value that drifts from the catalog fails here, not as a blank image.
    func testEveryCaseResolvesInThePackageBundle() {
        assertResolves(DashIcon.Common.self)
        assertResolves(DashIcon.Icons.self)
        assertResolves(DashIcon.Illustrations.self)
        assertResolves(DashIcon.Features.self)
        assertResolves(DashIcon.Checkbox.self)
        assertResolves(DashIcon.SegmentedControl.self)
        assertResolves(DashIcon.SearchBar.self)
        assertResolves(DashIcon.Menu.self)
        assertResolves(DashIcon.NavigationBar.self)
        assertResolves(DashIcon.SystemMessage.self)
        assertResolves(DashIcon.Toast.self)
        assertResolves(DashIcon.Other.self)
        assertResolves(DashIcon.AdditionalInfo.self)
        assertResolves(DashIcon.Transaction.self)
    }

    private func assertResolves<Group: CaseIterable & DashIconAsset>(
        _ group: Group.Type,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        for icon in group.allCases {
            XCTAssertNotNil(
                UIImage(named: icon.assetName, in: .dashUIKit, compatibleWith: nil),
                "\(group).\(icon) → \"\(icon.assetName)\"",
                file: file,
                line: line
            )
        }
    }
}
#endif
