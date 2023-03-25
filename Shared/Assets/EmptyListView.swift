//
//  EmptyBubbleListView.swift
//  Timers
//
//  Created by Cristian Lapusan on 25.04.2022.
//

import SwiftUI

struct EmptyListView: View {
    var body: some View {
        PermanentLabel(title: "Quick Start") {
            VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading) {
                    Text("**Create Bubbles** \(Image.rightSwipe) Swipe")
                    Text("*from left edge (yellow area)*")
                        .foregroundColor(.secondary)
                }
                
                VStack(alignment: .leading) {
                    Text("\(Image(systemName: "info.square.fill")) **Info** \(Image(systemName: "iphone.radiowaves.left.and.right")) Shake Device")
                    Text("*for guidance. At any time!*")
                        .foregroundColor(.secondary)
                }
                
                Text("*[Watch Short Tutorials](https://example.com)*")
                    .tint(.blue)
            }
            .restrictDynamicFontSize()
            .forceMultipleLines()
        }
    }
}

struct EmptyBubbleListView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyListView()
    }
}
