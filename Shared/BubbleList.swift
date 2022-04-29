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
    
    @SectionedFetchRequest<Bool, Bubble>(entity: Bubble.entity(),
                                         sectionIdentifier: \.isPinned,
                                         sortDescriptors: descriptors,
                                         predicate: nil,
                                         animation: .default)
    private var bubbles: SectionedFetchResults<Bool, Bubble>
    
    // MARK: -
    @State private var isActive = true
    @State var showDetail = false
    @State var showPalette = false
    
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
                        Spacer(minLength: geo.safeAreaInsets.top * 0.25) //distance from status bar
                        List {
                            ForEach(bubbles) { section in
                                Section {
                                    ForEach (section) {
                                        BubbleCell($0, $showDetail)
                                            .environmentObject(viewModel)
                                    }
                                } header: { headerTitle(for: section.id.description) }
                            }
                            .listRowSeparator(.hidden)
                        }
                        .listStyle(.plain)
                    }
                    .ignoresSafeArea()
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
//                    viewModel.updateCurrentClocks(bubbles)
                case .background:
                    viewModel.backgroundTimer(.pause)
                case .inactive: //show notication center, app switcher
                   break
                @unknown default: fatalError()
            }
        })
        .navigationBarHidden(true)
    }
    
    // MARK: -
    static var formatter:DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        //        formatter.locale = Locale(identifier: "us")
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    private func headerTitle(for sectionID:String) -> Text {
        if sectionID == "false" {
            return Text("Bubbles").foregroundColor(.black)
        } else {
            return Text("\(Image(systemName: "pin.fill")) Pinned").foregroundColor(.pink)
        }
    }
    
    static let descriptors = [
        NSSortDescriptor(key: "isPinned", ascending: false),
        NSSortDescriptor(key: "rank", ascending: false)
    ]
}

// MARK: -
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        BubbleList()
    }
}
