//
//  TimersApp.swift
//  Shared
//
//  Created by Cristian Lapusan on 15.04.2022.
//

import SwiftUI

@main
struct TimersApp: App {
    static var calManager:CalendarManager!
    
    //store firstAppLaunchEver key in the shared UserDefaults, NOT in UserDefaults.standard
    @AppStorage(UserDefaults.Key.firstAppLaunchEver, store: UserDefaults.shared)
    var firstAppLaunchEver = true
    
    var deleteViewOffsetComputed:Bool { vm.deleteViewOffset != nil }
    fileprivate var deleteViewShowing:Bool { vm.showDeleteAction_bRank != nil }
    
    fileprivate var bubbleNotesShowing:Bool { vm.notesList_bRank != nil }
    
    @Environment(\.scenePhase) var scenePhase
    let viewContext = PersistenceController.shared.container.viewContext
    @StateObject var vm = ViewModel()
    
    //the root view of scene is a NavigationSplitView
    var body: some Scene {
        WindowGroup {
            ZStack {
                NavigationSplitView {
                    ViewHierarchy()
                } detail: {
                    VStack {
                        if let rank = vm.rankOfSelectedBubble {
                            //bubbleCell for iOS
                            if !UIDevice.isIPad {
                                List {
                                    if let bubble = vm.bubble(for: rank) {
                                        BubbleCell(bubble).listRowSeparator(.hidden)
                                    }
                                }
                                .scrollDisabled(true)
                                .listStyle(.plain)
                                .frame(height: 160)
                            }
                            DetailView(vm.rankOfSelectedBubble)
                            
                        } else {
                            VStack {
                                Text("Bubble Detail")
                                Text("Select a Bubble")
                            }
                        }
                    }
                    .padding([.top], 2)
                }
                .accentColor(.label)
                
                if deleteViewOffsetComputed && deleteViewShowing {
                    let bubble = vm.bubble(for: vm.showDeleteAction_bRank!)
                    DeleteView(bubble)
                }
                
                if bubbleNotesShowing { BubbleStickyNoteList($vm.notesList_bRank) }
                if let pair = vm.pairOfNotesList { PairStickyNoteList(pair) }
                
                if let sdb = vm.theOneAndOnlyEditedSDB, let bubble = sdb.bubble {
                    MoreOptionsView(for: bubble)
                }
                
                if vm.showAlert_AlwaysOnDisplay { AlwaysOnDisplayAlertView() }
                
                if vm.confirm_AlwaysOnDisplay { AlwaysOnDisplayConfirmationView() }
                
                if vm.showMoreOptionsInfo { MoreOptionsInfo() }
                
                if vm.confirm_CalOn.show { CalOnConfirmationView() }
            }
            .ignoresSafeArea()
            .environment(\.managedObjectContext, viewContext)
            .environmentObject(vm)  /* inject ViewModel for entire view hierarchy */
            .onChange(of: scenePhase) { handleScenePhaseChange($0) }
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
            case .inactive: handleInactivePhase()
            @unknown default: fatalError()
        }
    }
    
    ///called on app launch or returning from background
    ///also called when app returns from inactive state
    func handleBecomeActive() { vm.bubbleTimer(.start) }
    
    ///called when app killed or moved to background
    ///NOT called on NotificationCenter, incoming call etc
    func handleEnterBackground() { vm.bubbleTimer(.pause) }
    
    func handleInactivePhase() {
        print("scenePhase.inactive")
        print(vm.allBubbles(runningOnly: false).count)
    }
}

struct ViewHierarchy:View {
    var body: some View { BubbleList() }
}
