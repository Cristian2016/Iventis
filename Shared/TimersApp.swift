//
//  TimersApp.swift
//  Shared
//
//  Created by Cristian Lapusan on 15.04.2022.
//

import SwiftUI

@main
struct TimersApp: App {
    @Environment(\.scenePhase) var scenePhase
    let viewContext = PersistenceController.shared.container.viewContext
    @StateObject var viewModel = ViewModel()
    @State var visibility = NavigationSplitViewVisibility.doubleColumn
    
    //the root view of scene is a NavigationSplitView
    var body: some Scene {
        WindowGroup {
            NavigationSplitView(columnVisibility: $visibility) {
                ViewHierarchy()
            } detail: {
                VStack {
                    if let rank = viewModel.rankOfSelectedBubble {
                        //bubbleCell for iOS
                        if !UIDevice.isIPad {
                            BubbleCell(viewModel.bubble(for: rank)!).padding([.leading, .trailing], 6)
                        }
                        DetailView(viewModel.rankOfSelectedBubble)
                    } else {
                        VStack {
                            Text("Bubble Detail")
                            Text("Select a Bubble")
                        }
                    }
                }
                .padding([.top])
            }
            .environment(\.managedObjectContext, viewContext)
            .environmentObject(viewModel)
            .onChange(of: scenePhase) {
                switch $0 {
                    case .active:
                        viewModel.backgroundTimer(.start)
                    case .background:
                        viewModel.backgroundTimer(.pause)
                    case .inactive: //show notication center, app switcher
                        break
                    @unknown default: fatalError()
                }
            }
        }
    }
    
    //detect app launch to set bubble.timeComponents to bubble.currentClock
    init() {
        delayExecution(.now() + 0.001) {
            NotificationCenter.default.post(name: .appLaunched, object: nil)
        }
    }
}

struct ViewHierarchy:View {
    var body: some View { BubbleList() }
}
