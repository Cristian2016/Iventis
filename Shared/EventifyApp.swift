//
//  TimersApp.swift
//  Shared
//
//  Created by Cristian Lapusan on 15.04.2022.
//1 on first app launch a timer & stopwatch will be created
// isFirstAppLaunch key stored in UserDefaults.shared [NOT UserDefaults.standard]
//4 deleteActionView can either delete the entire bubble or just its history [all sessions] resetting the bubble to the .brandNew state
//6 used by iPad to show either iPhoneViewHierarchy [compact size] or iPadViewHierarchy [regular size]
//7 detect app launch to set bubble.timeComponents to bubble.currentClock
//8 on very first app launch TimerHistory CoreData object must be created. History will store timer durations. Timer Durations are added to History each time user creates a new timer
//9 timer history (History) CoreData object stores timer durations. User can choose with ease a timer duration that has already been created
//app launched, overlay (ControlCenter, incoming call, Notification Center, a Notification appeared, etc), app moves from background back to foreground, app switcher
// 1a app launched (it was killed)
// 2a app left foreground and moves to background
// 3a app was in the background and now returns in the foreground

import SwiftUI
import MyPackage
import SwiftData

@main
struct EventifyApp: App {
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            sBubble.self,
        ])
        
        let sharedDatabase = URL.sharedContainer.appendingPathComponent("sharedSwiftDataBase.sqlite")
        let modelConfiguration = ModelConfiguration(schema: schema, url: sharedDatabase)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @AppStorage(Storagekey.timerHistoryExists) private var timerHistoryExists = false //8
    private let viewContext = PersistenceController.shared.container.viewContext
    let viewModel:ViewModel
    
    @Environment(\.scenePhase) private var phase
    
    var body: some Scene {
        WindowGroup {
            ViewHierarchy()
                .restrictDynamicFontSize()
                .task { shouldCreateTimerDurationsHistory() }
                .environment(viewModel)
                .environment(viewModel.secretary)
                .environment(\.managedObjectContext, viewContext)
                .onChange(of: phase) { handle($0, $1) }
        }
        .modelContainer(sharedModelContainer)
    }
    
    private func handle(_ oldPhase:ScenePhase, _ newPhase:ScenePhase) {
        let appEntersBackground = newPhase == .background
        let appReturnsFromBackground = oldPhase == .background
        
        if appEntersBackground { viewModel.bubbleTimer(.pause) } //2a
        if appReturnsFromBackground { viewModel.bubbleTimer(.start) } //3a
        
        if newPhase == .inactive && oldPhase == .active {
            viewModel.refreshWidgets()
        }
    }
    
    //exactly one TimerHistory obj will be created. TimerHistory stores all TimerDuration objs
    private func shouldCreateTimerDurationsHistory() {
        if !timerHistoryExists {
            let bContext = PersistenceController.shared.bContext
            
            bContext.perform {
                let _ = TimerHistory(context: bContext)
                PersistenceController.shared.save(bContext)
                DispatchQueue.main.async {
                    self.timerHistoryExists = true
                }
            }
        }
    } //1
    
    init() {
        UIRefreshControl.appearance().tintColor = .clear //hide spinner
        let viewModel = ViewModel()
        viewModel.bubbleTimer(.start) //1a
        self.viewModel = viewModel
    }
}
