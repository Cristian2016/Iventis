//
//  ContentView.swift
//  Shared
//
//  Created by Cristian Lapusan on 12.04.2022.
//

import SwiftUI
import CoreData
import Combine

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
    @State var showDetailView = false
    @State var showPalette = false
    
    // MARK: -
    init() {
        UITableView.appearance().showsVerticalScrollIndicator = false
    }
    
    // MARK: -
    var body: some View {
        ZStack {
            if bubbles.isEmpty { EmptyBubbleListView() }
            else {
                VStack {
                    Spacer(minLength: 30) //distance from status bar
                    List {
                        ForEach(bubbles) { section in
                            Section {
                                ForEach (section) { bubble in
                                    BubbleCell(bubble, $showDetailView)
                                        .opacity(cellOpacity(for: bubble))
                                        .environmentObject(viewModel)
                                }
                            } header: { headerTitle(for: section.id.description) }
                        }
                        .listRowSeparator(.hidden)
                    }
                    .offset(x: 0, y: listOffset())
                    .listStyle(.sidebar)
                }
                .ignoresSafeArea()
            }
            LeftStrip($showPalette, isBubbleListEmpty: bubbles.isEmpty)
            PaletteView($showPalette).environmentObject(viewModel)
            if showDetailView { DetailView(showDetailView: $showDetailView) }
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
    private static var formatter:DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        //        formatter.locale = Locale(identifier: "us")
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    private func headerTitle(for sectionID:String) -> Text {
        if sectionID == "false" {
            return Text("Bubbles")
                .foregroundColor(.label)
                .font(.title3)
        } else {
            return Text("\(Image(systemName: "pin.fill")) Pinned")
                .foregroundColor(.orange)
                .font(.title3)
        }
    }
    
    private static let descriptors = [
        NSSortDescriptor(key: "isPinned", ascending: false),
        NSSortDescriptor(key: "rank", ascending: false)
    ]
    
    private func cellOpacity(for bubble:Bubble) -> Double {
        guard let bubbleInSpotlightID = viewModel.bubbleInSpotlight?.id else { return 1 }
        return (bubbleInSpotlightID == bubble.objectID.description) ? 1 : 0
    }
    
    private func listOffset() -> CGFloat {
        if viewModel.bubbleInSpotlight == nil { return 0 }
        else { return -viewModel.bubbleInSpotlight!.y + 40 }
    }
}

// MARK: -
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        BubbleList()
    }
}
