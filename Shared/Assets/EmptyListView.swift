//
//  EmptyBubbleListView.swift
//  Timers
//
//  Created by Cristian Lapusan on 25.04.2022.
//

import SwiftUI

struct EmptyListView: View {
    @Environment(Secretary.self) private var secretary
    @AppStorage("isFirstLaunch") var isFirstLaunch = true
    
    var body: some View {
        if isFirstLaunch {
            firstLaunchContent
                .onDisappear {
                    if isFirstLaunch { isFirstLaunch = false }
                }
        } else {
            content
        }
    }
    
    private var firstLaunchContent:some View {
        ContentUnavailableView(label: {
            Label("Welcome to Iventis", image: "iventisSymbol")
        }, description: {
            Text("Your Daily Activity Tracker")
            Text("Tap \(Image(systemName: "plus")) to start,\nor swipe right from left edge")
        }, actions: {
            HintOverlay.ButtonStack()
        })
    }
    
    private var content:some View {
        ContentUnavailableView {
            Label("No Trackers", image: "iventisSymbol")
        } description: {
            Text("Tap \(Image(systemName: "plus")) or swipe from left edge")
        } actions: {
            HintOverlay.ButtonStack()
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
