//
//  EmptyBubbleListView.swift
//  Timers
//
//  Created by Cristian Lapusan on 25.04.2022.
//

import SwiftUI

struct EmptyListView: View {
    @Environment(Secretary.self) private var secretary
    
    var body: some View {
        HStack(spacing: 0) {
            Color.clear
                .frame(width: 40)
            content
        }
        
    }
    
    private var content:some View {
        ContentUnavailableView {
            Label("\(Text("\(Image(systemName: "questionmark.circle.fill")) Help").foregroundStyle(.blue))", systemImage: "iphone.radiowaves.left.and.right")
                .symbolRenderingMode(.monochrome)
                .fontWeight(.light)
        } description: {
            Text("Shake device for help.\nSwipe from left edge to start")
        } actions: {
            HelpOverlay.ButtonStack()
        }
    }
    
    private func openYouTubeTutorial() {
        if let url = URL(string: "https://www.youtube.com/shorts/SBSt06RrlLk") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

struct EmptyBubbleListView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyListView()
            .environment(Secretary())
    }
}
