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
                    Spacer(minLength: 20) //distance from status bar
                    List {
                        ForEach(bubbles) { section in
                            Section {
                                ForEach (section) {
                                    BubbleCell($0, $showDetailView)
                                        .environmentObject(viewModel)
                                }
                            } header: { headerTitle(for: section.id.description) }
                        } //ForEach
                        .listRowSeparator(.hidden)
                    } //List
                    .listStyle(.grouped)
                } //VStack
                .ignoresSafeArea()
            } //else statement
            LeftStrip($showPalette, isBubbleListEmpty: bubbles.isEmpty) //it's invisible
            PaletteView($showPalette).environmentObject(viewModel)
            if showDetailView {
                DetailView(showDetailView: $showDetailView)
                    .scaleEffect(1)
                    .animation(.spring(), value: 1)
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
}

// MARK: -
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        BubbleList()
    }
}
