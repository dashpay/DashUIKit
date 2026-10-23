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
          .foregroundColor(.clear)
          .frame(width: 39, height: 24)
          .background(Constants.switchThumbFill)
          .cornerRadius(Constants.switchThumbRadius)
          .shadow(color: Color(red: 0.1, green: 0.13, blue: 0.15).opacity(0.06), radius: 1, x: 0, y: 1)
          .shadow(color: Color(red: 0.1, green: 0.13, blue: 0.15).opacity(0.1), radius: 1.5, x: 0, y: 1)
    }
}

#if DEBUG

#Preview {
    ThumbView()
        .padding()
}

#endif
