//
//  Created by Dash Core Group. All rights reserved.
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

/// Outside the views so the rows and the block measure from one place.
private enum Layout {
    /// Gap between the mark and the text.
    static let gap: CGFloat = 6
    /// The box the mark is centred in. It, not the text, sets the row height.
    static let markBox: CGFloat = 26
    /// The mark itself — every icon the design system draws for this row is
    /// this size.
    static let mark: CGFloat = 19
    /// Padding that lifts the 18pt text line box to the mark box's height.
    static let textVerticalPadding: CGFloat = 4
    /// Stroke of the marks drawn here, in the 19pt box.
    static let strokeWidth: CGFloat = 2
    /// The unfilled `pending` ring.
    static let ringWidth: CGFloat = 1.5
}

// MARK: - CriterionState

/// How one requirement currently stands.
@available(iOS 14, macOS 11, *)
public enum CriterionState: Equatable {
    /// Stated but not evaluated yet — an empty ring.
    case pending
    /// Being evaluated — a spinner in the mark's place.
    case checking
    /// Satisfied — green disc, white tick.
    case met
    /// Not satisfied — red disc, white cross.
    case failed
    /// Not satisfied, and it is the reason the user cannot continue — the same
    /// red disc, with the text in the error colour.
    case blocking
    /// Satisfied, but worth reading — yellow disc, white exclamation.
    case warning
}

// MARK: - Criterion

/// One requirement in a ``Criteria`` block.
@available(iOS 14, macOS 11, *)
public struct Criterion: Identifiable {
    /// What the row's mark slot holds — one of the standard discs, or the
    /// caller's own icon.
    enum Mark {
        case state(CriterionState)
        case icon(DashIconSource)
    }

    public let id: String
    public let text: String
    let mark: Mark

    /// `id` defaults to `text`, which is what distinguishes the rows in
    /// practice; pass one explicitly when a row's text changes while the row
    /// stays the same (an availability line, say), so it animates in place
    /// instead of being replaced. Two rows that share an `id` still render
    /// as two rows — ``Criteria`` tells repeats apart itself.
    public init(id: String? = nil, text: String, state: CriterionState) {
        self.id = id ?? text
        self.text = text
        self.mark = .state(state)
    }

    /// The design system's icon slot, for a row whose mark is none of the
    /// standard discs. Rendered in the same 19pt box, untinted — the artwork
    /// carries its own colour, exactly as the Figma slot does.
    public init(id: String? = nil, text: String, icon: DashIconSource) {
        self.id = id ?? text
        self.text = text
        self.mark = .icon(icon)
    }
}

// MARK: - Criteria

/// A block of requirements with their status, as under a username or password
/// field: one mark per row saying whether that rule is met.
///
/// Stateless — the host decides which rules exist, what they say and how each
/// one currently stands. A rule that should not be shown is simply not passed,
/// which is also how the design system models it: there is no "hidden" mark.
///
/// ```swift
/// Criteria([
///     Criterion(text: "Between 3 and 23 characters", state: .met),
///     Criterion(text: "Letters, numbers and hyphens only", state: .failed),
///     Criterion(text: "Username available", state: .checking),
/// ])
/// ```
@available(iOS 14, macOS 11, *)
public struct Criteria: View {
    private let items: [Criterion]
    private let spacing: CGFloat

    /// - Parameters:
    ///   - items: the requirements, in the order they should read.
    ///   - spacing: gap between rows. The default is the design's 10pt.
    public init(_ items: [Criterion], spacing: CGFloat = 10) {
        self.items = items
        self.spacing = spacing
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            ForEach(renderIdentities, id: \.key) { entry in
                CriterionRow(criterion: entry.item)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// Each item's `id`, made unique. A repeated `id` — two rules with the
    /// same text and no explicit id — would give SwiftUI two rows with one
    /// identity, and updates could land on the wrong one. The first
    /// occurrence keeps its bare `id`, so a row with a stable explicit id
    /// still animates in place; only later repeats get a suffix.
    private var renderIdentities: [(key: String, item: Criterion)] {
        var seen: [String: Int] = [:]
        return items.map { item in
            let count = seen[item.id, default: 0]
            seen[item.id] = count + 1
            return (count == 0 ? item.id : "\(item.id)#\(count)", item)
        }
    }
}

// MARK: - Row

@available(iOS 14, macOS 11, *)
private struct CriterionRow: View {
    let criterion: Criterion

    var body: some View {
        HStack(alignment: .top, spacing: Layout.gap) {
            mark
                .frame(width: Layout.markBox, height: Layout.markBox)

            Text(criterion.text)
                .dashFont(.footnote)
                .foregroundColor(textColor)
                // Without this a two-line requirement is truncated to one:
                // the row offers the text its ideal single-line height.
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, Layout.textVerticalPadding)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(criterion.text))
        .accessibilityValue(Text(accessibilityValue))
    }

    // MARK: Mark

    @ViewBuilder private var mark: some View {
        switch criterion.mark {
        case .icon(let source):
            Image(dash: source)
                .resizable()
                .scaledToFit()
                .frame(width: Layout.mark, height: Layout.mark)
        case .state(let state):
            switch state {
            case .pending:
                // `strokeBorder` insets by half the line width, so a 19pt
                // circle strokes at r 8.75 and still reaches 19pt across —
                // the design system's default icon to the point.
                Circle()
                    .strokeBorder(Color.dash.gray300Alpha50, lineWidth: Layout.ringWidth)
                    .frame(width: Layout.mark, height: Layout.mark)
            case .checking:
                // In the mark's own box, so the rows do not shift while a
                // check is running.
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .frame(width: Layout.mark, height: Layout.mark)
            case .met:
                disc(Color.dash.green) {
                    CheckShape()
                        .stroke(
                            Color.dash.white,
                            style: StrokeStyle(
                                lineWidth: Layout.strokeWidth,
                                lineCap: .round,
                                lineJoin: .round))
                }
            case .failed, .blocking:
                disc(Color.dash.red) {
                    // The design's cross spans 5pt of the 19pt disc, and
                    // `XmarkIcon` insets its stroke to 7/9 of `size` — the
                    // same symmetric shape, so 5 ÷ (7/9) reproduces it.
                    XmarkIcon(
                        size: Layout.mark * 5 / 19 / (7.0 / 9.0),
                        color: Color.dash.white,
                        lineWidth: Layout.strokeWidth)
                }
            case .warning:
                disc(Color.dash.yellow) {
                    ExclamationShape()
                        .stroke(
                            Color.dash.white,
                            style: StrokeStyle(
                                lineWidth: Layout.strokeWidth,
                                lineCap: .round,
                                lineJoin: .round))
                }
            }
        }
    }

    private func disc<Glyph: View>(
        _ color: Color,
        @ViewBuilder glyph: () -> Glyph
    ) -> some View {
        ZStack {
            Circle().fill(color)
            glyph()
        }
        .frame(width: Layout.mark, height: Layout.mark)
    }

    // MARK: Styling

    private var textColor: Color {
        switch criterion.mark {
        case .icon:
            return Color.dash.primaryText
        case .state(let state):
            // Only `blocking` colours the text: it is the one state that says
            // "this is why you cannot continue" rather than "this rule is not
            // met yet".
            return state == .blocking ? Color.dash.errorText : Color.dash.primaryText
        }
    }

    /// What VoiceOver reads after the requirement itself. The row combines its
    /// children, so without this the mark is silent and every state sounds
    /// identical.
    private var accessibilityValue: String {
        guard case .state(let state) = criterion.mark else { return "" }
        switch state {
        case .pending:
            return NSLocalizedString("Not checked yet", bundle: .module, comment: "DashUIKit")
        case .checking:
            return NSLocalizedString("Checking", bundle: .module, comment: "DashUIKit")
        case .met:
            return NSLocalizedString("Met", bundle: .module, comment: "DashUIKit")
        case .failed:
            return NSLocalizedString("Not met", bundle: .module, comment: "DashUIKit")
        case .blocking:
            // Not just unmet: this is the rule that stops the user going on,
            // which the red text says to a sighted user.
            return NSLocalizedString("Not met, required to continue", bundle: .module, comment: "DashUIKit")
        case .warning:
            return NSLocalizedString("Met, with a warning", bundle: .module, comment: "DashUIKit")
        }
    }
}

// MARK: - Marks drawn here

/// The tick inside the `met` disc, from the design system's own 19-unit
/// artwork (`M6.78571 9.94668L8.65314 12.2143L12.2143 7.69048`).
///
/// `CheckmarkIcon` is deliberately not reused: it comes from a different
/// source SVG (15×12, polyline aspect 0.746) while this tick is 5.43 × 4.52 —
/// aspect 0.832. Scaled to the right width it would draw about a tenth
/// flatter than the design.
@available(iOS 14, macOS 11, *)
private struct CheckShape: Shape {
    private static let viewBox: CGFloat = 19
    private static let points = [
        CGPoint(x: 6.78571, y: 9.94668),
        CGPoint(x: 8.65314, y: 12.2143),
        CGPoint(x: 12.2143, y: 7.69048),
    ]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let scaled = Self.points.map { point in
            CGPoint(
                x: rect.minX + rect.width * point.x / Self.viewBox,
                y: rect.minY + rect.height * point.y / Self.viewBox)
        }
        path.move(to: scaled[0])
        path.addLine(to: scaled[1])
        path.addLine(to: scaled[2])
        return path
    }
}

/// The exclamation inside the `warning` disc.
///
/// TODO(criteria-warning): the design system draws `Default`, `Xmark` and
/// `Checkmark` only — there is no warning icon to mirror yet, so this one is
/// drawn to match their weight and proportions in the same 19-unit box. Swap
/// it for the artwork once the design system has it.
@available(iOS 14, macOS 11, *)
private struct ExclamationShape: Shape {
    private static let viewBox: CGFloat = 19
    /// The stem, top to bottom, and then the dot as a zero-length segment the
    /// round cap turns into a circle — the same trick the source SVGs use.
    private static let stem = (top: CGPoint(x: 9.5, y: 5), bottom: CGPoint(x: 9.5, y: 10.5))
    private static let dot = CGPoint(x: 9.5, y: 13.75)

    func path(in rect: CGRect) -> Path {
        func place(_ point: CGPoint) -> CGPoint {
            CGPoint(
                x: rect.minX + rect.width * point.x / Self.viewBox,
                y: rect.minY + rect.height * point.y / Self.viewBox)
        }
        var path = Path()
        path.move(to: place(Self.stem.top))
        path.addLine(to: place(Self.stem.bottom))
        path.move(to: place(Self.dot))
        path.addLine(to: place(Self.dot))
        return path
    }
}

// MARK: - Previews

#if DEBUG

@available(iOS 17, macOS 14, *)
#Preview("Every state") {
    Criteria([
        Criterion(text: "Pending — not evaluated yet", state: .pending),
        Criterion(text: "Checking — a query is in flight", state: .checking),
        Criterion(text: "Met — the rule is satisfied", state: .met),
        Criterion(text: "Failed — the rule is not satisfied", state: .failed),
        Criterion(text: "Blocking — this is why Continue is disabled", state: .blocking),
        Criterion(text: "Warning — satisfied, but read this", state: .warning),
    ])
    .padding(20)
    .background(Color.dash.secondaryBackground)
}

@available(iOS 17, macOS 14, *)
#Preview("Username rules") {
    Criteria([
        Criterion(text: "Between 3 and 23 characters", state: .met),
        Criterion(text: "Letters, numbers and hyphens only", state: .failed),
        Criterion(text: "You need to have more 0.25 Dash to create this username", state: .met),
        Criterion(text: "Username available", state: .checking),
    ])
    .padding(20)
    .background(Color.dash.secondaryBackground)
}

@available(iOS 17, macOS 14, *)
#Preview("Wrapping") {
    Criteria([
        Criterion(
            text: "This username would also require voting — try adding a digit between 2 and 9",
            state: .blocking),
        Criterion(text: "Username available", state: .met),
    ])
    .frame(width: 260)
    .padding(20)
    .background(Color.dash.secondaryBackground)
}

@available(iOS 17, macOS 14, *)
#Preview("Icon slot") {
    Criteria([
        Criterion(text: "Standard disc", state: .met),
        Criterion(text: "The design system's icon slot", icon: .system("bolt.circle.fill")),
    ])
    .padding(20)
    .background(Color.dash.secondaryBackground)
}

@available(iOS 17, macOS 14, *)
#Preview("Dark") {
    Criteria([
        Criterion(text: "Between 3 and 23 characters", state: .met),
        Criterion(text: "Letters, numbers and hyphens only", state: .blocking),
        Criterion(text: "Username available", state: .pending),
    ])
    .padding(20)
    .background(Color.dash.secondaryBackground)
    .preferredColorScheme(.dark)
}

#endif
