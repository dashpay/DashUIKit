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

import Combine
import SwiftUI

// MARK: - LoadingIllustration

/// Wrapper that centers the loading spinner inside a fixed-size frame, matching the
/// Maya design (Figma node 6:254 — a 90×90 frame containing a 61.73 spinner).
@available(iOS 14, macOS 11, *)
public struct LoadingIllustration: View {

    /// Diameter of the spinner.
    public var size: CGFloat
    /// Spinner tint.
    public var color: Color
    /// Size of the surrounding square frame (the spinner is centered within it).
    public var containerSize: CGFloat

    public init(size: CGFloat = 61.73, color: Color = LoadingSpinner.defaultColor, containerSize: CGFloat = 90) {
        self.size = size
        self.color = color
        self.containerSize = containerSize
    }

    public var body: some View {
        ZStack {
            LoadingSpinner(size: size, color: color)
        }
        .frame(width: containerSize, height: containerSize)
    }
}

// MARK: - LoadingSpinner

/// A spinner built from `spokeCount` capsules arranged in a ring. Mirrors the standard iOS
/// `UIActivityIndicatorView`: the spokes are **static**, and instead of rotating the whole ring
/// the bright "head" steps clockwise from spoke to spoke while the others fade — i.e. each line
/// changes opacity in turn. The opacity crossfades between steps for a smooth iOS-style look.
@available(iOS 14, macOS 11, *)
public struct LoadingSpinner: View {

    /// Default tint — DS blue.
    public static let defaultColor = Color.dash.blue

    /// Diameter of the spinner.
    public let size: CGFloat
    /// Spoke tint.
    public let color: Color
    /// Number of spokes in the ring.
    public let spokeCount: Int
    /// Seconds for the bright head to travel once around the ring.
    public let duration: Double

    /// Index of the currently-brightest spoke; advances clockwise on each timer tick.
    @State private var phase = 0
    /// Fires once per spoke step (duration / spokeCount). Created once so it isn't restarted
    /// on every body re-evaluation.
    private let timer: Publishers.Autoconnect<Timer.TimerPublisher>

    public init(size: CGFloat = 61.73, color: Color = defaultColor, spokeCount: Int = 12, duration: Double = 1) {
        self.size = size
        self.color = color
        self.spokeCount = spokeCount
        self.duration = duration
        self.timer = Timer
            .publish(every: duration / Double(max(spokeCount, 1)), on: .main, in: .common)
            .autoconnect()
    }

    private var stepInterval: Double { duration / Double(max(spokeCount, 1)) }

    public var body: some View {
        ZStack {
            ForEach(0..<spokeCount, id: \.self) { index in
                Capsule()
                    .fill(color)
                    .opacity(opacity(for: index))
                    // Proportions taken from the Figma SVG (viewBox 61.73):
                    // width 0.083·size, height 0.25·size, outer edge at radius 0.5·size.
                    .frame(width: size * 0.083, height: size * 0.25)
                    .offset(y: -size * 0.375)
                    .rotationEffect(.degrees(Double(index) / Double(spokeCount) * 360))
            }
        }
        .frame(width: size, height: size)
        .onReceive(timer) { _ in
            // Step the bright head one spoke clockwise; crossfade the opacities.
            withAnimation(.linear(duration: stepInterval)) {
                phase = (phase + 1) % spokeCount
            }
        }
    }

    /// Graduated "comet-tail" opacity, brightest at the head (`phase`) and fading backward
    /// (counter-clockwise) along the ring.
    private func opacity(for index: Int) -> Double {
        guard spokeCount > 1 else { return 0.75 }
        let distanceFromHead = (index - phase + spokeCount) % spokeCount
        return 0.2 + 0.55 * (1 - Double(distanceFromHead) / Double(spokeCount - 1))
    }
}

#if DEBUG

@available(iOS 14, macOS 11, *)
struct LoadingIllustration_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 40) {
            LoadingIllustration()
            LoadingIllustration(size: 32, color: .red)
            LoadingSpinner(size: 24, color: .gray, spokeCount: 8, duration: 0.8)
        }
        .previewLayout(.sizeThatFits)
        .padding()
    }
}

#endif
