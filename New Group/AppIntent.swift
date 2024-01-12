//
//  AppIntent.swift
//  Timers
//
//  Created by Cristian Lapusan on 16.11.2023.
// all app names: run, count, Eventify
// .applicationName: special app name token. app main name ("Eventify") and for any app synonyms I have defined ("Run" and "Count")
//        guard let duration = duration else {
//            throw $duration.needsValueError(.init("For how long?"))
//        }

//        let value = try await $duration.requestValue()
// "\(.applicationName) \(\.$duration)"
        

import Foundation
import AppIntents
import SwiftUI

typealias Intent = AppIntent
typealias Shortcut = AppShortcut
typealias ShortcutsProvider = AppShortcutsProvider


struct CountIntent: Intent {
    
    static var title: LocalizedStringResource = "Counter" //Shortcuts App
    
    @Parameter(title: "Duration", defaultValue: 0, defaultUnit: .minutes, supportsNegativeNumbers: true)
    var duration: Measurement<UnitDuration>
    
    func perform() async throws -> some ProvidesDialog & ShowsSnippetView {
        await PersistenceController.shared.bContext.perform {
            let newBubble = Bubble(context: PersistenceController.shared.bContext)
            newBubble.created = Date()
            
            newBubble.initialClock = 0
            newBubble.currentClock = 0
            
            newBubble.color = "magenta"
            newBubble.rank = Int64(UserDefaults.generateRank())
            PersistenceController.shared.save(PersistenceController.shared.bContext)
        }
        
        return .result(dialog: "Ok", view: Image(systemName: "stopwatchok").font(.largeTitle))
    }
}

struct LibraryAppShortcuts: ShortcutsProvider {
    static var appShortcuts: [Shortcut] {
        Shortcut(intent: CountIntent(),
                 phrases: [ "\(.applicationName)",
                            "\(\.$duration) xbcf \(.applicationName)"
                          ],
                 shortTitle: "Count",
                 systemImageName: "stopwatch")
    }
}
