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
            Image.dpv
                .resizable()
                .scaledToFit()
                .frame(height: 200)
            VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading) {
                    Text("**Create Timer** \(Image.tap) Tap")
                    Text("*If \(Image.roundCheckmark) symbol shows*")
                        .foregroundColor(.secondary)
                }
                VStack(alignment: .leading) {
                    Text("**Clear Display** \(Image.leftSwipe) Swipe")
                    Text("*Any direction works*")
                        .foregroundColor(.secondary)
                }
                VStack(alignment: .leading) {
                    Text("**Dismiss** \(Image.tap) Tap")
                    Text("*If \(Image.roundCheckmark) doesn't show*")
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