//
//  EmptyBubbleListView.swift
//  Timers
//
//  Created by Cristian Lapusan on 25.04.2022.
//

import SwiftUI

struct EmptyBubbleListView: View {
    var body: some View {
        VStack {
            
            VStack (alignment:.leading) {
                Text("Empty Bubble List")
                    .font(.largeTitle)
                HStack {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: UIScreen.main.bounds.size.width * 0.25))
                        .foregroundColor(.green)
                    VStack (alignment:.leading) {
                        Text("Swipe right")
                            .font(.system(size: UIScreen.main.bounds.size.width * 0.07, weight: .medium, design: .monospaced))
                            .foregroundColor(.green)
                        Text("from Left Screen Edge")
                            .foregroundColor(.secondary)
                        Text("to add a Bubble")
                            .foregroundColor(.secondary)
                    }
                   
                }
            }
        }
    }
}

struct EmptyBubbleListView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyBubbleListView()
    }
}
