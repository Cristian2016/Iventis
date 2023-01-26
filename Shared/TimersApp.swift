//
//  TimersApp.swift
//  Shared
//
//  Created by Cristian Lapusan on 15.04.2022.
//

import SwiftUI
import MyPackage

@main
struct TimersApp: App {
    static var calManager:CalendarManager! /* set at init() */
    
    //store key in UserDefaults.shared [NOT UserDefaults.standard]
    @AppStorage(UserDefaults.Key.firstAppLaunchEver, store: .shared)
    private var firstAppLaunchEver = true
    
    fileprivate var showDeleteAction:Bool { viewModel.showDeleteAction_bRank != nil }
    
    fileprivate var bubbleNotesShowing:Bool { viewModel.notesList_bRank != nil }
    
    @Environment(\.scenePhase) private var scenePhase
    private let viewContext = PersistenceController.shared.container.viewContext
    @StateObject private var viewModel = ViewModel()
    @StateObject private var layoutViewModel = LayoutViewModel()
        
    //the root view of scene is a NavigationSplitView
    var body: some Scene {
        WindowGroup {
            ZStack {
                if UIDevice.isIPad { //iPad
                    iPadViewHierarchy()
                } else { //iPhone
                    NavigationStack(path: $viewModel.path) { ViewHierarchy() }.tint(.label)
                }
                
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
            .environment(\.managedObjectContext, viewContext)
            .environmentObject(viewModel)  /* inject ViewModel for entire view hierarchy */
            .environmentObject(layoutViewModel) /* inject LayoutViewModel for entire view hierarchy */
            .onChange(of: scenePhase) { handleScenePhaseChange($0) }
            .onAppear {
                if firstAppLaunchEver {
                    viewModel.createBubble(.stopwatch, "lemon")
                    firstAppLaunchEver = false
                }
            }
        }
    }
    
    //detect app launch to set bubble.timeComponents to bubble.currentClock
    init() {
        delayExecution(.now() + 0.001) {
            NotificationCenter.default.post(name: .appLaunched, object: nil)
        }
        TimersApp.calManager = CalendarManager.shared
    }
    
    // MARK: - Methods
    private func handleScenePhaseChange(_ scenePhase:ScenePhase) {
        switch scenePhase {
            case .active: handleBecomeActive()
            case .background: handleEnterBackground()
            case .inactive: break
            @unknown default: fatalError()
        }
    }
    
    ///called on app launch or returning from background
    ///also called when app returns from inactive state
    func handleBecomeActive() { viewModel.bubbleTimer(.start) }
    
    ///called when app killed or moved to background
    ///NOT called on NotificationCenter, incoming call etc
    func handleEnterBackground() { viewModel.bubbleTimer(.pause) }
    
    private var showDeleteActionView:Bool {
        viewModel.showDeleteAction_bRank != nil &&
        layoutViewModel.bubbleCellFrame != nil
    }
}

struct ViewHierarchy:View {
    var body: some View { BubbleList() }
}
