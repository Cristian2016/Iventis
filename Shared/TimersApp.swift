//
//  TimersApp.swift
//  Shared
//
//  Created by Cristian Lapusan on 15.04.2022.
//1 on first app launch a timer & stopwatch will be created
// isFirstAppLaunch key stored in UserDefaults.shared [NOT UserDefaults.standard]
//2 initialize and inject ViewModel and LayoutViewModel for entire view hierarchy as @StateObject instances
//3 scenePhase it used to start/stop backgroundTimer which is used by bubbles to update their displayed time. backgroundTimer sends a signal [notification] each second
// handleBecomeActive: called on app launch, returning from background or returning from inactive state
// handleEnterBackground: called when app killed or moved to background. NOT called on NotificationCenter, incoming call etc
//4 deleteActionView can either delete the entire bubble or just its history [all sessions] resetting the bubble to the .brandNew state
//6 used by iPad to show either iPhoneViewHierarchy [compact size] or iPadViewHierarchy [regular size]
//7 detect app launch to set bubble.timeComponents to bubble.currentClock

import SwiftUI
import MyPackage

@main
struct TimersApp: App {
    @AppStorage(UserDefaults.Key.isFirstAppLaunch, store: .shared)
    private var isFirstAppLaunch = true //1
    
    @Environment(\.scenePhase) private var scenePhase //3
    
    @StateObject private var viewModel = ViewModel() //2
    @StateObject private var layoutViewModel = LayoutViewModel() //2
    
    private let viewContext = PersistenceController.shared.container.viewContext
        
    var body: some Scene {
        WindowGroup {
            ZStack {
                if UIDevice.isIPad { iPadViewHierarchy() }
                else { iPhoneViewHierarchy() }
                
                if showDeleteActionView {
                    let bubble = viewModel.bubble(for: Int(viewModel.showDeleteAction_bRank!))
                    DeleteActionView(bubble)
                }
                if bubbleNotesShowing { BubbleStickyNoteList($viewModel.notesList_bRank) }
                if let pair = viewModel.pairOfNotesList { PairStickyNoteList(pair) }
                if let sdb = viewModel.theOneAndOnlyEditedSDB, let bubble = sdb.bubble {
                    MoreOptionsView(for: bubble)
                }
                if viewModel.showAlert_AlwaysOnDisplay { AlwaysOnDisplayAlertView() }
                if viewModel.confirm_AlwaysOnDisplay { AlwaysOnDisplayConfirmationView() }
                if viewModel.showMoreOptionsInfo { MoreOptionsInfo() }
                if viewModel.confirm_CalOn.show { CalOnConfirmationView() }
            }
            .ignoresSafeArea()
            .onAppear { createBubblesOnFirstAppLaunch() } //1
            .environment(\.managedObjectContext, viewContext)
            .environmentObject(viewModel) //2
            .environmentObject(layoutViewModel) //2
            .onChange(of: scenePhase) { handleScenePhaseChange($0) } //3
        }
    }
    
    init() {
        delayExecution(.now() + 0.001) {
            NotificationCenter.default.post(name: .appLaunched, object: nil)
        }
    } //7
    
    // MARK: - Methods
    private func handleScenePhaseChange(_ scenePhase:ScenePhase) {
        switch scenePhase {
            case .active: handleBecomeActive()
            case .background: handleEnterBackground()
            case .inactive: break
            @unknown default: fatalError()
        }
    } //3
    
    func handleBecomeActive() { viewModel.bubbleTimer(.start) } //3
    
    func handleEnterBackground() { viewModel.bubbleTimer(.pause) } //3
    
    private var showDeleteActionView:Bool {
        viewModel.showDeleteAction_bRank != nil &&
        layoutViewModel.bubbleCellFrame != nil
    } //4
    
    private func createBubblesOnFirstAppLaunch() {
        if isFirstAppLaunch {
            viewModel.createBubble(.stopwatch, "charcoal", "☕️ Break")
            viewModel.createBubble(.stopwatch, "green", "🌳 Outdoors")
            isFirstAppLaunch = false
        }
    } //1
    
    // MARK: -
    fileprivate var showDeleteAction:Bool { viewModel.showDeleteAction_bRank != nil }
    
    fileprivate var bubbleNotesShowing:Bool { viewModel.notesList_bRank != nil }
}

struct ViewHierarchy:View {
    var body: some View { BubbleList() }
}
