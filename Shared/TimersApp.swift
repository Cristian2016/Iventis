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
    @State var visibility = NavigationSplitViewVisibility.doubleColumn
    
    //the root view of scene is a NavigationSplitView
    var body: some Scene {
        WindowGroup {
            ZStack {
                NavigationSplitView(columnVisibility: $visibility) {
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
                
                if bubbleNotesShowing { BubbleNotesList($vm.notesList_bRank) }
                if let pair = vm.pairOfNotesList { PairNotesList(pair) }
                
                if let sdb = vm.oneAndOnlySDB, let bubble = sdb.bubble {
                    MoreOptionsView(for: bubble)
                }
                
                if vm.showAlert_AlwaysOnDisplay {
                    GenericAlertView(alertContent: Alert.alwaysOnDisplay) {
                        vm.showAlert_AlwaysOnDisplay = false //dismiss alert
                    } buttonAction: {
                        
                    }
                }
                
                if vm.showMoreOptionsInfo { MoreOptionsInfo() }
            }
            .ignoresSafeArea()
            .environment(\.managedObjectContext, viewContext)
            .environmentObject(vm)  /* inject ViewModel for entire view hierarchy */
            .onChange(of: scenePhase) {
                switch $0 {
                    case .active: handleBecomeActive()
                    case .background: handleEnterBackground()
                    case .inactive: handleInactivePhase()
                    @unknown default: fatalError()
                }
            }
            .onAppear {
                //                delayExecution(.now() + 2) { firstAppLaunchEver = false }
                //
                //                firstAppLaunchEver = false
                
                delayExecution(.now() + 5) {
                    print("key \(UserDefaults.shared.value(forKey: UserDefaults.Key.firstAppLaunchEver) as? Bool)")
                    //                    print("key \(UserDefaults.shared.bool(forKey: UserDefaults.Key.firstAppLaunchEver))")
                    //                    vm.makeBubblesOnFirstAppLaunchEver()
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
    ///called on app launch or returning from background
    ///also called when app returns from inactive state
    func handleBecomeActive() {
        //Bubble
        vm.bubbleTimer(.start)
        
        //SDB
        vm.sdbTimer(.start)
        //start observing
        
    }
    
    ///called when app killed or moved to background
    ///NOT called on NotificationCenter, incoming call etc
    func handleEnterBackground() {
        print("scenePhase.background")
        vm.bubbleTimer(.pause)
        
        //pause all running sdb
        
        //pause sdbTimer
        vm.sdbTimer(.pause)
    }
    
    func handleInactivePhase() {
        print("scenePhase.inactive")
        print(vm.allBubbles(runningOnly: false).count)
    }
}

struct ViewHierarchy:View {
    var body: some View { BubbleList() }
}
