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
                .frame(height: 200)
            VStack(alignment: .leading, spacing: 10) {
                Text("**Save Delay** \(Image.tap) Tap")
                VStack(alignment: .leading) {
                    Text("**Clear Display** \(Image.leftSwipe) Swipe")
                    Text("*Any direction works*")
                        .foregroundColor(.secondary)
                }
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
