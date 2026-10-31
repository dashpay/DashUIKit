//
//  SwitchView.swift
//  DashUIKit
//
//  Created by Roman Chornyi on 29.07.2026.
//

import SwiftUI

/// The design system's switch: a blue track with a white thumb, drawn by hand
/// rather than tinting the system `Toggle`.
///
/// To assistive technologies it is a native `Toggle` with a hidden label: the
/// same traits, the same state value, which VoiceOver speaks in the user's
/// language, the same disabled state, and activation flips `isOn`. Give it a
/// name with `.accessibilityLabel(_:)`, or let a row that combines its children
/// supply one.
public struct SwitchView: View {

    private struct Constants {
        static let switchTrackFillOn: Color = Color.dash.blue
        static let switchTrackFillOnDisabled: Color = Color.dash.black1000Alpha20
        static let switchTrackFillOff: Color = Color.dash.gray300Alpha50
        static let switchTrackFillOffDisabled: Color = Color.dash.black1000Alpha20
        static let switchTrackWidth: CGFloat = 64
        static let switchTrackPadding: CGFloat = 2
        static let switchTrackRadius: CGFloat = 1000
        static let animationDuration: Double = 0.2
    }

    @Environment(\.isEnabled) private var isEnabled

    @Binding private var isOn: Bool

    public init(isOn: Binding<Bool>) {
        self._isOn = isOn
    }

    public var body: some View {
        HStack(alignment: .center, spacing: 0) {
            ThumbView()
        }
        .frame(maxWidth: .infinity, alignment: isOn ? .trailing : .leading)
        .padding(Constants.switchTrackPadding)
        .frame(width: Constants.switchTrackWidth, alignment: .leading)
        .background(trackFill)
        .cornerRadius(Constants.switchTrackRadius)
        .animation(.easeInOut(duration: Constants.animationDuration), value: isOn)
        .contentShape(Rectangle())
        .onTapGesture { isOn.toggle() }
        // The system control's semantics, not hand-made ones: VoiceOver
        // localizes a toggle's state only when it comes from a real `Toggle`.
        .accessibilityRepresentation {
            Toggle(isOn: $isOn) { EmptyView() }
                .labelsHidden()
        }
    }

    private var trackFill: Color {
        switch (isOn, isEnabled) {
        case (true, true): return Constants.switchTrackFillOn
        case (true, false): return Constants.switchTrackFillOnDisabled
        case (false, true): return Constants.switchTrackFillOff
        case (false, false): return Constants.switchTrackFillOffDisabled
        }
    }
}

#if DEBUG

#Preview("States") {
    VStack(alignment: .leading, spacing: 20) {
        SwitchView(isOn: .constant(true))
        SwitchView(isOn: .constant(false))
        SwitchView(isOn: .constant(true)).disabled(true)
        SwitchView(isOn: .constant(false)).disabled(true)
    }
    .padding()
}

#Preview("Interactive") {
    @Previewable @State var isOn = false
    SwitchView(isOn: $isOn)
        .padding()
}

#endif
