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
    let viewModel = ViewModel()
    
    var body: some Scene {
        WindowGroup {
            ViewHierarchy()
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
    var body: some View { BubbleList($predicate) }
    
    @State var predicate:NSPredicate? = nil
}
