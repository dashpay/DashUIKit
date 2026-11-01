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
import SwiftUI
import UIKit
import XCTest
@testable import DashUIKit

/// Hosts the view in a window and checks when it reports, not only what.
@MainActor
final class ScrollViewWithOnScrollChangedTests: XCTestCase {

    private final class Recorder {
        var values: [CGPoint] = []
    }

    private struct Host: View {
        let recorder: Recorder

        var body: some View {
            ScrollViewWithOnScrollChanged {
                ForEach(0..<40, id: \.self) { index in
                    Text(verbatim: "Row \(index)").frame(height: 60)
                }
            } onScrollChanged: { recorder.values.append($0) }
        }
    }

    private var window: UIWindow?

    override func tearDown() async throws {
        window?.isHidden = true
        window = nil
        try await super.tearDown()
    }

    private func host(_ view: Host, topInset: CGFloat = 0) -> UIHostingController<Host> {
        let controller = UIHostingController(rootView: view)
        if topInset > 0 {
            controller.additionalSafeAreaInsets.top = topInset
        } else {
            controller.safeAreaRegions = []
        }
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 600))
        window.rootViewController = controller
        window.makeKeyAndVisible()
        self.window = window
        return controller
    }

    private func settle(_ milliseconds: Int) async throws {
        try await Task.sleep(for: .milliseconds(milliseconds))
    }

    /// Waits up to five seconds for `condition`, then lets pending updates land.
    private func wait(until condition: () -> Bool) async throws {
        for _ in 0..<100 where !condition() {
            try await settle(50)
        }
        try await settle(300)
    }

    private func scrollView(in view: UIView) -> UIScrollView? {
        if let scrollView = view as? UIScrollView, !(scrollView is UICollectionView) {
            return scrollView
        }
        return view.subviews.lazy.compactMap { self.scrollView(in: $0) }.first
    }

    func testFirstAppearanceReportsTheRestOriginOnce() async throws {
        let recorder = Recorder()
        _ = host(Host(recorder: recorder))
        try await wait { !recorder.values.isEmpty }

        XCTAssertEqual(recorder.values, [.zero])
        XCTAssertEqual(recorder.values.first?.x.sign, .plus)
        XCTAssertEqual(recorder.values.first?.y.sign, .plus)
    }

    func testFirstAppearanceUnderATopInsetReportsTheRestOriginOnce() async throws {
        let recorder = Recorder()
        _ = host(Host(recorder: recorder), topInset: 112)
        try await wait { !recorder.values.isEmpty }

        XCTAssertEqual(recorder.values, [.zero])
    }

    func testScrollingReportsTheNewOrigin() async throws {
        let recorder = Recorder()
        let controller = host(Host(recorder: recorder))
        try await wait { !recorder.values.isEmpty }
        let scrollView = try XCTUnwrap(scrollView(in: controller.view))

        scrollView.setContentOffset(CGPoint(x: 0, y: scrollView.contentOffset.y + 100), animated: false)
        try await wait { recorder.values.last == CGPoint(x: 0, y: -100) }

        XCTAssertEqual(recorder.values.last, CGPoint(x: 0, y: -100))
    }
}
#endif
