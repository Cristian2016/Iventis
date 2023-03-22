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
            Image.moreOptionsView.thumbnail()
            VStack(alignment: .leading, spacing: 8) {
                Text("*Use Yellow Areas to*")
                    .foregroundColor(.secondary)
                Divider()
                VStack(alignment: .leading) {
                    Text("**Save Delay** \(Image.tap) Tap")
                    Text("*If delay is set (not zero)*")
                        .foregroundColor(.secondary)
                }
                Text("**Remove** \(Image.leftSwipe) Swipe")
                
                VStack(alignment: .leading) {
                    Text("**Dismiss** \(Image.tap) Tap")
                    Text("*If delay is zero*")
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

struct MoreOptionsInfoView_Previews: PreviewProvider {
    static var previews: some View {
        MoreOptionsInfoView()
    }
}
