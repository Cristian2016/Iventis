//
//  BubbleDeleteButtonShowMoreInfo.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 17.04.2023.
//

import SwiftUI

struct BubbleDeleteButtonShowMoreInfo: View {
    @State private var show = false
    
    var body: some View {
        ZStack {
            if show {
                VStack {
                    Text("A Bubble's activity is made up of entries. Calendar-enabled bubbles \(Image.calendar) will create a calendar event for each entry")
                        .padding()
                    Image("bubbleDeleteMoreInfo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                .onTapGesture {
                    Secretary.shared.bubbleDeleteButtonShowMore = false
                }
            }
        }
        .onReceive(Secretary.shared.$bubbleDeleteButtonShowMore) { show = $0 }
    }
}

struct BubbleDeleteButtonShowMoreInfo_Previews: PreviewProvider {
    static var previews: some View {
        BubbleDeleteButtonShowMoreInfo()
    }
}
