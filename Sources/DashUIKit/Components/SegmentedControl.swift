//
//  Created by Roman Chornyi
//  Copyright © 2025 Dash Core Group. All rights reserved.
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

private enum SegmentedControlLayout {
    static let containerPadding: CGFloat = 4
    static let containerCornerRadius: CGFloat = 20
    static let segmentCornerRadius: CGFloat = 16
    static let segmentVerticalPadding: CGFloat = 6
    static let height: CGFloat = 40
    static let shadowRadius: CGFloat = 10
    static let shadowY: CGFloat = 5
    static let animation = Animation.spring(response: 0.3, dampingFraction: 0.7)

    // Icon variant (artwork stacked over the label). It sizes to its content
    // instead of `height`, which only fits a single text line. The icons are
    // drawn to one height and differing widths — a single arrow is half as
    // wide as the double one — so pinning the height is what keeps the labels
    // under them on one line.
    static let iconHeight: CGFloat = 17
    static let iconLabelSpacing: CGFloat = 4
    static let iconSegmentVerticalPadding: CGFloat = 10
}

/// Which segment is selected. Kept apart from the view so the rule can be
/// tested without rendering.
enum SegmentedControlSelection {
    /// The segment drawn and announced as selected: the first option equal to
    /// `selection`, or `nil` when none is, in which case no segment is.
    static func selectedIndex<T: Equatable>(of selection: T, in options: [T]) -> Int? {
        options.firstIndex(of: selection)
    }
}

/// Each segment's bounds, by index, for drawing the pill in the same layout
/// pass as the segments.
private struct SegmentedControlBoundsKey: PreferenceKey {
    static var defaultValue: [Int: Anchor<CGRect>] { [:] }

    static func reduce(value: inout [Int: Anchor<CGRect>], nextValue: () -> [Int: Anchor<CGRect>]) {
        value.merge(nextValue()) { $1 }
    }
}

/// A row of mutually exclusive options with a sliding pill on a track. Tap a
/// segment to select it; the host owns the selection through the binding.
///
/// The first option equal to `selection` is the selected segment. When no
/// option matches, no segment is selected and no pill is drawn. Options are
/// expected to be distinct; of a repeated option only the first copy is ever
/// selected.
public struct SegmentedControl<T: Hashable>: View {
    private typealias Layout = SegmentedControlLayout
    private typealias Selection = SegmentedControlSelection

    private let options: [T]
    @Binding private var selection: T
    private let label: (T) -> String
    /// Artwork drawn above each label, chosen per selection state. `nil` (the
    /// default) keeps the text-only segment.
    ///
    /// It takes `isSelected` because a selected segment and an unselected one
    /// are usually two different files rather than one file tinted two ways —
    /// artwork that carries its own colour cannot be dimmed into the
    /// unselected treatment the label gets.
    private let icon: ((_ option: T, _ isSelected: Bool) -> DashIconSource)?

    /// - Parameters:
    ///   - options: The segments, in reading order. Expected to be distinct.
    ///   - selection: The selected option. A value that is not one of
    ///     `options` selects no segment.
    ///   - label: The text of each segment, also its VoiceOver label.
    ///   - icon: Artwork above each label, per option and selection state.
    ///     `nil` draws text-only segments.
    public init(
        options: [T],
        selection: Binding<T>,
        label: @escaping (T) -> String,
        icon: ((_ option: T, _ isSelected: Bool) -> DashIconSource)? = nil
    ) {
        self.options = options
        self._selection = selection
        self.label = label
        self.icon = icon
    }

    public var body: some View {
        let selectedIndex = Selection.selectedIndex(of: selection, in: options)

        HStack(spacing: 0) {
            ForEach(options.indices, id: \.self) { index in
                segmentCell(options[index], isSelected: index == selectedIndex)
                    .anchorPreference(key: SegmentedControlBoundsKey.self, value: .bounds) { [index: $0] }
            }
        }
        .padding(Layout.containerPadding)
        // The pill sits on the selected segment's bounds, resolved in the same
        // layout pass. Resolved bounds are left-to-right coordinates in either
        // direction, so the pill layer is laid out left to right too. With no
        // selected segment there is no pill, so one that appears does so in
        // place.
        .backgroundPreferenceValue(SegmentedControlBoundsKey.self) { bounds in
            GeometryReader { geometry in
                ZStack(alignment: .topLeading) {
                    Color.clear
                    if let selectedIndex, let anchor = bounds[selectedIndex] {
                        let frame = geometry[anchor]
                        RoundedRectangle(cornerRadius: Layout.segmentCornerRadius)
                            .fill(Color.dash.segmentControlBackground)
                            .shadow(color: Color.dash.shadow, radius: Layout.shadowRadius, x: 0, y: Layout.shadowY)
                            .frame(width: frame.width, height: frame.height)
                            .offset(x: frame.minX, y: frame.minY)
                    }
                }
                .environment(\.layoutDirection, .leftToRight)
            }
        }
        .animation(Layout.animation, value: selectedIndex)
        // The drawing takes no touches; a row of Buttons over the whole track,
        // inset included, does. Each is one segment's share of the track and
        // its VoiceOver element.
        .accessibilityHidden(true)
        .allowsHitTesting(false)
        .overlay {
            HStack(spacing: 0) {
                ForEach(options.indices, id: \.self) { index in
                    segmentButton(options[index], isSelected: index == selectedIndex)
                }
            }
            .accessibilityElement(children: .contain)
        }
        // The icon variant is two lines tall, so it sizes to its content —
        // `height` is the single-line text measurement. Either way the control
        // keeps its own height when its container offers more.
        .frame(height: icon == nil ? Layout.height : nil)
        .fixedSize(horizontal: false, vertical: true)
        .background(Color.dash.segmentControlBackgroundGroup)
        .clipShape(.rect(cornerRadius: Layout.containerCornerRadius))
    }

    private func segmentCell(_ option: T, isSelected: Bool) -> some View {
        segmentContent(option, isSelected: isSelected)
            .foregroundStyle(isSelected
                ? Color.dash.segmentControlContSelected
                : Color.dash.segmentControlContNotSelected)
            // A zero minimum gives every segment the same share whatever its
            // label, so the cells line up with the equal tap targets.
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding(.vertical, icon == nil
                ? Layout.segmentVerticalPadding
                : Layout.iconSegmentVerticalPadding)
            .frame(maxHeight: .infinity)
    }

    private func segmentButton(_ option: T, isSelected: Bool) -> some View {
        Button {
            select(option)
        } label: {
            Color.clear
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(label(option)))
        // The selected segment has nothing left to do on a double tap.
        .accessibilityHint(isSelected
            ? Text(verbatim: "")
            : Text(NSLocalizedString("Double tap to select", bundle: .module, comment: "DashUIKit")))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    @ViewBuilder
    private func segmentContent(_ option: T, isSelected: Bool) -> some View {
        if let icon {
            VStack(spacing: Layout.iconLabelSpacing) {
                Image(dash: icon(option, isSelected))
                    .resizable()
                    .scaledToFit()
                    .frame(height: Layout.iconHeight)
                segmentLabel(option)
            }
        } else {
            segmentLabel(option)
        }
    }

    private func segmentLabel(_ option: T) -> some View {
        Text(label(option))
            .font(Font.dash.footnoteMedium)
            .lineLimit(1)
    }

    /// The host sees the change inside the control's animation, so content it
    /// switches on the selection moves with the pill.
    private func select(_ option: T) {
        guard option != selection else { return }
        withAnimation(Layout.animation) {
            selection = option
        }
    }
}

extension SegmentedControl where T == String {
    /// Text-only segments whose labels are the options themselves.
    public init(options: [T], selection: Binding<T>) {
        self.init(options: options, selection: selection, label: { $0 })
    }
}

#if DEBUG
#Preview {
    SegmentedControlPreview()
}

private struct SegmentedControlPreview: View {
    @State private var two = "Single"
    @State private var three = "Day"
    @State private var four = "1D"

    var body: some View {
        VStack(spacing: 24) {
            SegmentedControl(options: ["Single", "Multiple"], selection: $two)

            SegmentedControl(options: ["Day", "Week", "Month"], selection: $three)

            SegmentedControl(options: ["1D", "1W", "1M", "1Y"], selection: $four)
        }
        .padding()
    }
}

#Preview("Icon variant") {
    SegmentedControlIconPreview()
}

#Preview("Icon variant, tall container") {
    // The control keeps its own height; the red frame is the space offered.
    SegmentedControlIconPreview.control(selection: .constant("Receive"))
        .frame(height: 200)
        .border(Color.dash.red)
        .padding()
}

#Preview("Right to left") {
    // The pill and the tap targets follow the mirrored row: "Day" is on the right.
    SegmentedControlPreview()
        .environment(\.layoutDirection, .rightToLeft)
}

#Preview("Narrow") {
    // Labels that do not fit truncate on one line.
    SegmentedControl(options: ["Active", "Disconnected", "Expired"], selection: .constant("Active"))
        .frame(width: 240)
        .padding()
}

#Preview("No matching selection") {
    // A selection that is none of the options draws no pill.
    SegmentedControl(options: ["Day", "Week", "Month"], selection: .constant("Year"))
        .padding()
}

#Preview("Dark") {
    VStack(spacing: 24) {
        SegmentedControlPreview()
        SegmentedControlIconPreview()
    }
    .background(Color.dash.primaryBackground)
    .preferredColorScheme(.dark)
}

/// The icon variant next to the text-only one, so the two stay recognisably the
/// same control: same track, same pill, only the segment is two lines tall. Tap
/// through the segments — each swaps between its coloured and grey artwork.
private struct SegmentedControlIconPreview: View {
    @State private var withIcons = "Internal"
    @State private var textOnly = "Internal"

    fileprivate static let options = ["Receive", "Internal", "Send"]

    fileprivate static func icon(_ option: String, isSelected: Bool) -> DashIconSource {
        switch option {
        case "Receive":
            return (isSelected ? DashIcon.SegmentedControl.receive : .receiveDisabled).source
        case "Send":
            return (isSelected ? DashIcon.SegmentedControl.send : .sendDisabled).source
        default:
            return (isSelected ? DashIcon.SegmentedControl.transfer : .transferDisabled).source
        }
    }

    fileprivate static func control(selection: Binding<String>) -> SegmentedControl<String> {
        SegmentedControl(options: options, selection: selection, label: { $0 }, icon: icon)
    }

    var body: some View {
        VStack(spacing: 24) {
            Self.control(selection: $withIcons)

            SegmentedControl(options: Self.options, selection: $textOnly)
        }
        .padding()
    }
}
#endif
