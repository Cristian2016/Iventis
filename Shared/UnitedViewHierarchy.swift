//
//  UnitedViewHierarchy.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 29.01.2023.
//
//3 scenePhase it used to start/stop backgroundTimer which is used by bubbles to update their displayed time. backgroundTimer sends a signal [notification] each second
// handleBecomeActive: called on app launch, returning from background or returning from inactive state
// handleEnterBackground: called when app killed or moved to background. NOT called on NotificationCenter, incoming call etc
//3 ⚠️ never put scenePhase in App struct! it recomputed body 3 times because of it

import SwiftUI

struct UnitedViewHierarchy: View {
    @AppStorage(UserDefaults.Key.isFirstAppLaunch, store: .shared)
    private var isFirstAppLaunch = true //1
    
    @StateObject private var layoutViewModel = LayoutViewModel() //2
    @StateObject private var viewModel = ViewModel() //2
    @Environment(\.scenePhase) private var scenePhase //3 ⚠️
    
    private let viewContext = PersistenceController.shared.container.viewContext
    
    var body: some View {
        ZStack {
            if UIDevice.isIPad { iPadViewHierarchy() }
            else { iPhoneViewHierarchy() }
            
            if showDeleteActionView {
                let bubble = viewModel.bubble(for: Int(viewModel.deleteAction_bRank!))
                DeleteActionView(bubble)
            }
            
            if let session = viewModel.sessionToDelete?.0 {
                DeleteSessionConfirmationView(session, viewModel.sessionToDelete!.1)
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
        .onAppear { createBubblesOnFirstAppLaunch() } //1
        .environment(\.managedObjectContext, viewContext)
        .environmentObject(viewModel) //2
        .environmentObject(layoutViewModel) //2
        .onChange(of: scenePhase) { handleScenePhaseChange($0) } //3
    }
    
    // MARK: - Methods
    private func handleScenePhaseChange(_ scenePhase:ScenePhase) {
        switch scenePhase {
            case .active: handleBecomeActive()
            case .background: handleEnterBackground()
            case .inactive: break
            @unknown default: fatalError()
        }
    } //3
    
    private func handleBecomeActive() { viewModel.bubbleTimer(.start) } //3
    
    private func handleEnterBackground() { viewModel.bubbleTimer(.pause) } //3
        
    private func createBubblesOnFirstAppLaunch() {
        return
        if isFirstAppLaunch {
            viewModel.createBubble(.stopwatch, "charcoal", "☕️ Break")
            viewModel.createBubble(.stopwatch, "green", "🌳 Outdoors")
            isFirstAppLaunch = false
        }
    } //1
    
    // MARK: -
    private var showDeleteActionView:Bool {
        viewModel.deleteAction_bRank != nil
    } //4
    
    fileprivate var bubbleNotesShowing:Bool { viewModel.notesList_bRank != nil }
}

struct UnitedViewHierarchy_Previews: PreviewProvider {
    static var previews: some View {
        UnitedViewHierarchy()
    }
}
