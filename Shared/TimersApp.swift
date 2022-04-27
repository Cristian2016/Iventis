//
//  TimersApp.swift
//  Shared
//
//  Created by Cristian Lapusan on 15.04.2022.
//

import SwiftUI

@main
struct TimersApp: App {
    let viewContext = PersistenceController.shared.container.viewContext
    
    var body: some Scene {
        WindowGroup {
            BubbleList()
                .environment(\.managedObjectContext, viewContext)
        }
    }
    
    //detect app launch to set bubble.timeComponents to bubble.currentClock
    init() { NotificationCenter.default.post(name: .appLaunched, object: nil) }
}
