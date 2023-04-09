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

import SwiftUI
import MyPackage

@main
struct TimersApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup { ViewHierarchy() }
    }
    
    init() {
        let center = NotificationCenter.default
        delayExecution(.now() + 0.001) { center.post(name: .appLaunched, object: nil) }
    } //7
}
