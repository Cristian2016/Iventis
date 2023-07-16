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
                    .foregroundStyle(.secondary)
                Divider()
                VStack(alignment: .leading) {
                    Text("**Save Delay** \(Image.tap) Tap")
                    Text("*(if delay is not zero)*")
                }
                
                VStack(alignment: .leading) {
                    Text("**Clear** \(Image.leftSwipe) Swipe")
                    Text("*in any direction*")
                }
                
                VStack(alignment: .leading) {
                    Text("**Dismiss** \(Image.tap) Tap")
                    Text("*(if delay is zero)*")
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
