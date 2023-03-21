//
//  DPInfoView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 21.03.2023.
//

import SwiftUI

struct DPInfoView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("*Ex: Set Duration*")
                .foregroundColor(.secondary)
            Text("**1 hour** \(Image.tap)Tap 01")
            Text("**20 min** \(Image.tap)Tap 00 20")
            Text("**5 min** \(Image.tap)Tap 00 05")
            Text("**50 sec** \(Image.tap)Tap 00 00 50")
            Text("*Tap any Yellow Area to create the timer*")
                .foregroundColor(.secondary)
            
            HStack(alignment: .top) {
                Image.dpv
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                VStack(alignment: .leading, spacing: 4) {
                    Text("***Yellow Gesture Areas***")
                        .foregroundColor(.secondary)
                    VStack(alignment: .leading) {
                        Text("**Dismiss** \(Image.tap) Tap")
                        Text("*If Duration not set*")
                            .foregroundColor(.secondary)
                    }
                    VStack(alignment: .leading) {
                        Text("**Create Timer** \(Image.tap) Tap")
                        Text("*If \(Image.roundCheckmark) symbol shows*")
                            .foregroundColor(.secondary)
                    }
                    Text("**Clear Display** \(Image.leftSwipe) Swipe")
                }
            }
        }
        .font(.system(size: 20))
    }
}

struct DPInfoView_Previews: PreviewProvider {
    static var previews: some View {
        DPInfoView()
    }
}
