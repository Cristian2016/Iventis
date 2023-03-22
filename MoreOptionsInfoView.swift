//
//  MoreOptionsInfoView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 21.03.2023.
//

import SwiftUI

struct MoreOptionsInfoView: View {
    var body: some View {
        HStack(alignment: .top) {
            Image.moreOptionsView
                .resizable()
                .scaledToFit()
                .frame(height: 220)
            VStack(alignment: .leading, spacing: 8) {
                Text("*Use Yellow Areas to*")
                    .foregroundColor(.secondary)
                Divider()
                Text("**Save Delay** \(Image.tap) Tap")
                Text("**Clear Display** \(Image.leftSwipe) Swipe")
                Text("**Dismiss** \(Image.tap) Tap")
            }
        }
    }
}

struct MoreOptionsInfoView_Previews: PreviewProvider {
    static var previews: some View {
        MoreOptionsInfoView()
    }
}
