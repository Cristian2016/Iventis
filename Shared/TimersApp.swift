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
            ContainerView()
                .environment(\.managedObjectContext, viewContext)
//                .onAppear {
//                    let request = Session.fetchRequest()
//                    let sessions = try? PersistenceController.shared.viewContext.fetch(request)
//                    sessions?.forEach({ session in
//                        PersistenceController.shared.viewContext.delete(session)
//                    })
//                    try? PersistenceController.shared.viewContext.save()
//                }
        }
    }
    
    //detect app launch to set bubble.timeComponents to bubble.currentClock
    init() {
        delayExecution(.now() + 0.001) {
            NotificationCenter.default.post(name: .appLaunched, object: nil)
        }
    }
}
