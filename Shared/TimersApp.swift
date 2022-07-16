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
                
                if let sdb = vm.sdb, let bubble = sdb.bubble {
                    MoreOptionsView(bubble: bubble)
                }
                
                if vm.showAlwaysOnDisplayAlert {
                    AlertView {
                        Label("Always-On Display", systemImage: "sun.max.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.black)
                    } _: {
                        Text("This option drains the battery faster. Use only if needed. Do not forget to turn it off again")
                            .foregroundColor(.gray)
                    } dismissAction: {
                        vm.showAlwaysOnDisplayAlert = false
                    }
                }
                
                if vm.showMoreOptionsInfo { MoreOptionsInfo() }
            }
            .ignoresSafeArea()
            .environment(\.managedObjectContext, viewContext)
            .environmentObject(vm)
            .onChange(of: scenePhase) {
                switch $0 {
                    case .active:
                        /* app launch, back to foreground */
                        vm.backgroundTimer(.start)
                    case .background:
                        vm.backgroundTimer(.pause)
                    case .inactive:
                        //show notication center, app switcherbreak
                        break
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
}

struct ViewHierarchy:View {
    var body: some View { BubbleList() }
}
