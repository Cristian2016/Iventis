//
//  DPInfoView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 21.03.2023.
//

import SwiftUI

struct DPInfoView: View {
    var body: some View {
        HStack(alignment: .top) {
            Image.dpv.thumbnail()
            
            VStack(alignment: .leading, spacing: 8) {
                Text("*Use Yellow Areas to*")
                    .foregroundColor(.secondary)
                Divider()
                VStack(alignment: .leading) {
                    Text("**Create Timer** \(Image.tap) Tap")
                    Text("*if \(Image.roundCheckmark) symbol shows*")
                        .foregroundColor(.secondary)
                }
                VStack(alignment: .leading) {
                    Text("**Clear** \(Image.leftSwipe) Swipe")
                    Text("*in any direction*")
                        .foregroundColor(.secondary)
                }
                VStack(alignment: .leading) {
                    Text("**Dismiss** \(Image.tap) Tap")
                    Text("*if \(Image.roundCheckmark) symbol hidden*")
                        .foregroundColor(.secondary)
                }
            }
        }
        .font(.system(size: 22))
    }
}

struct DPInfoView_Previews: PreviewProvider {
    static var previews: some View {
        DPInfoView()
    }
}
