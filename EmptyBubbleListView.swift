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
            let width = UIScreen.main.bounds.width
            
            VStack (alignment:.center) {
                HStack {
                    Text("Empty\nBubble List").font(.system(size: width * 0.12, weight: .medium, design: .default))
                    Spacer()
                }
                .offset(x: 20, y: 0)
                
                HStack {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: width * 0.25))
                        .foregroundColor(.green)
                    VStack (alignment:.leading) {
                        Text("Swipe right")
                            .font(.system(size: width * 0.08, weight: .medium, design: .monospaced))
                            .foregroundColor(.green)
                        VStack (alignment:.leading) {
                            Text("from Left Screen Edge")
                            Text("[Yellow Strip]")
                            Text("to add a Bubble")
                        }
                        .foregroundColor(.secondary)
                    }
                   
                }
            }
            .padding(10)
        }
    }
}

struct EmptyBubbleListView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyBubbleListView()
    }
}
