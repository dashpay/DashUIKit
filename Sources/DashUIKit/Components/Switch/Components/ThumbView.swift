//
//  ThumbView.swift
//  DashUIKit
//
//  Created by Roman Chornyi on 29.07.2026.
//

import SwiftUI

struct ThumbView: View {

    private struct Constants {
        static let switchThumbFill: Color = Color.dash.white
        static let switchThumbRadius: CGFloat = 1000
    }

    var body: some View {
        Rectangle()
          .foregroundStyle(Color.clear)
          .frame(width: 39, height: 24)
          .background(Constants.switchThumbFill)
          .cornerRadius(Constants.switchThumbRadius)
          .shadow(color: Color.dash.switchThumbShadow.opacity(0.06), radius: 1, x: 0, y: 1)
          .shadow(color: Color.dash.switchThumbShadow.opacity(0.1), radius: 1.5, x: 0, y: 1)
    }
}

#if DEBUG

#Preview {
    ThumbView()
        .padding()
}

#endif
