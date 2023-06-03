//
//  TimersApp.swift
//  Shared
//
//  Created by Cristian Lapusan on 15.04.2022.
//1 on first app launch a timer & stopwatch will be created
// isFirstAppLaunch key stored in UserDefaults.shared [NOT UserDefaults.standard]
//2 initialize and inject ViewModel and LayoutViewModel for entire view hierarchy as @StateObject instances
//4 deleteActionView can either delete the entire bubble or just its history [all sessions] resetting the bubble to the .brandNew state
//6 used by iPad to show either iPhoneViewHierarchy [compact size] or iPadViewHierarchy [regular size]
//7 detect app launch to set bubble.timeComponents to bubble.currentClock
//8 on very first app launch TimerHistory CoreData object must be created. History will store timer durations. Timer Durations are added to History each time user creates a new timer
//9 timer history (History) CoreData object stores timer durations. User can choose with ease a timer duration that has already been created

import SwiftUI
import MyPackage

@main
struct TimersApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @AppStorage("historyCreated") private var timerHistoryExists = false //8
    
    var body: some Scene {
        WindowGroup {
            ViewHierarchy()
                .task { createTimerHistory() }
        }
    }
    
    private func createTimerHistory() {
        if !timerHistoryExists {
            let bContext = PersistenceController.shared.bContext
            
            bContext.perform {
                let _ = TimerHistory(context: bContext)
                PersistenceController.shared.save(bContext)
                self.timerHistoryExists = true
            }
        }
    } //1
    
    init() {
        let center = NotificationCenter.default
        delayExecution(.now() + 0.001) { center.post(name: .appLaunched, object: nil) }
    } //7
}
