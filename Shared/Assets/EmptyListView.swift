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
            VStack(alignment: .leading, spacing: 8) {
                VStack(alignment: .leading) {
                    Text("**Create Bubbles** \(Image.rightSwipe) Swipe")
                    Text("*on the yellow area*")
                        .foregroundColor(.secondary)
                }
                
                VStack(alignment: .leading) {
                    Text("\(Image(systemName: "info.square.fill")) **Info** \(Image(systemName: "iphone.radiowaves.left.and.right")) Shake")
                    Text("*shake device at any time*")
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
