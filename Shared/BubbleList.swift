//
//  ContentView.swift
//  Shared
//
//  Created by Cristian Lapusan on 12.04.2022.
//

import SwiftUI
import CoreData

struct BubbleList: View {
    //1
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.scenePhase) var scenePhase
    
    // MARK: -
    @StateObject private var viewModel = ViewModel()
    @FetchRequest(entity: Bubble.entity(), sortDescriptors: [NSSortDescriptor(key: "rank", ascending: false)])
    private var bubbles:FetchedResults<Bubble>
    @State private var isActive = true
    
    @State var showDetail = false
    @State var showPalette = false
    
    // MARK: -
    static var formatter:DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        //        formatter.locale = Locale(identifier: "us")
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    // MARK: -
    init() {
        UITableView.appearance().showsVerticalScrollIndicator = false
    }
    
    // MARK: -
    var body: some View {
        GeometryReader { geo in
            ZStack {
                if bubbles.isEmpty { EmptyBubbleListView() }
                else {
                    VStack {
                        Spacer(minLength: geo.safeAreaInsets.top) //distance from status bar
                        List {
                            ForEach(bubbles) {
                                BubbleCell($0, $showDetail).environmentObject(viewModel)
                            }
                            .onDelete { delete($0) }
                            .listRowSeparator(.hidden)
                        }.listStyle(.plain)
                    }.ignoresSafeArea()
                }
                
                LeftStrip($showPalette, isBubbleListEmpty: bubbles.isEmpty) //it's invisible
                PaletteView($showPalette) //initially hidden
                    .environmentObject(viewModel)
                BubbleDetail($showDetail) //initially hidden
            }
        }
        .onChange(of: scenePhase, perform: {
            switch $0 {
                case .active:
                    viewModel.backgroundTimer(.start)
                    //update timeComponents for each running bubble
                    viewModel.updateCurrentClocks(bubbles)
                case .background:
                    viewModel.backgroundTimer(.pause)
                case .inactive: //show notication center, app switcher
                   break
                @unknown default: fatalError()
            }
        })
        .navigationBarHidden(true)
        .onAppear {
            //            viewModel.makeBubbles()
        }
    }
}

// MARK: -
extension BubbleList {
    private func delete(_ indexSet:IndexSet) {
        indexSet.forEach {
            viewModel.delete(bubbles[$0])
        }
    }
}

// MARK: -
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        BubbleList()
    }
}
