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
//10 is this overkill? A single obsevable object only to manage the navigationStack?? Not sure though

import SwiftUI

struct UnitedViewHierarchy: View {
    @AppStorage(UserDefaults.Key.isFirstAppLaunch, store: .shared)
    private var isFirstAppLaunch = true //1
    
    @StateObject private var layoutViewModel = LayoutViewModel() //2
    @StateObject private var viewModel = ViewModel() //2
    @StateObject private var pathViewModel = PathViewModel() //10
    
    @Environment(\.scenePhase) private var scenePhase //3 ⚠️
    
    private let secretary = Secretary.shared
    @State private var deleteActionBubbleRank:Int64?
    @State private var sessionToDelete:(session:Session, sessionRank:String)?
    
    @State private var notesForPair:Pair?
    @State private var notesForBubble:Bubble?
    
    private let viewContext = PersistenceController.shared.container.viewContext
    
    var body: some View {
        let _ = print("UnitedViewHierarchy body")
        
        ZStack {
            if UIDevice.isIPad { iPadViewHierarchy() }
            else { iPhoneViewHierarchy() }
            
            if showDeleteActionView {
                if let bubble = viewModel.bubble(for: Int(secretary.deleteAction_bRank!)) {
                    BubbleDeleteActionAlert(bubble)
                }
            }
            
            SessionDeleteActionAlert()
            
            if let pair = notesForPair { PairStickyNoteList(pair) }
            MoreOptionsView()
            AlwaysOnDisplayAlertView() //shown until user removes it forever
            AlwaysOnDisplayConfirmationView() //shown each time user toggles the button in toolbar
            if viewModel.showMoreOptionsInfo { MoreOptionsInfo() }
            if bubbleNotesShowing { BubbleStickyNoteList(notesForBubble!) }
        }
        .onAppear { createBubblesOnFirstAppLaunch() } //1
        .environment(\.managedObjectContext, viewContext)
        .environmentObject(viewModel) //2
        .environmentObject(layoutViewModel) //2
        .environmentObject(pathViewModel) //10
        .onChange(of: scenePhase) { handleScenePhaseChange($0) } //3
        //listen to publishers and listen for changes
        .onReceive(secretary.$deleteAction_bRank) { deleteActionBubbleRank = $0 }
        .onReceive(viewModel.notesForPair) { notesForPair = ($0 != nil) ? $0! : nil }
        .onReceive(viewModel.notesForBubble) { notesForBubble = ($0 != nil) ? $0! : nil }
        .onReceive(secretary.$sessionToDelete) { sessionToDelete = $0 }
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
        deleteActionBubbleRank != nil
    } //4
    
    fileprivate var bubbleNotesShowing:Bool { notesForBubble != nil }
}

struct UnitedViewHierarchy_Previews: PreviewProvider {
    static var previews: some View {
        UnitedViewHierarchy()
    }
}
