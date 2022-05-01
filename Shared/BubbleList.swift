//
//  ContentView.swift
//  Shared
//
//  Created by Cristian Lapusan on 12.04.2022.
//

import SwiftUI
import CoreData
import Combine

struct ContainerView:View {
    @State var predicate:NSPredicate? = nil
    
    var body: some View {
        VStack {
            BubbleList($predicate)
        }
    }
}

struct BubbleList: View {
    //1
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.scenePhase) var scenePhase
        
    // MARK: -
    @StateObject private var viewModel = ViewModel()
    
//    private var bubbles: SectionedFetchResults<Bool, Bubble>
    @SectionedFetchRequest var fetchRequest:SectionedFetchResults<Bool, Bubble>
    @Binding var predicate:NSPredicate?
    
    // MARK: -
    @State private var isActive = true
    @State var showDetailView = false
    @State var showPalette = false
    
    // MARK: -
    init(_ predicate:Binding<NSPredicate?>) {
        UITableView.appearance().showsVerticalScrollIndicator = false
        _fetchRequest = SectionedFetchRequest<Bool, Bubble>(entity: Bubble.entity(),
                                                        sectionIdentifier: \.isPinned,
                                                      sortDescriptors: BubbleList.descriptors,
                                                            predicate: predicate.wrappedValue,
                                                        animation: .default)
        _predicate = Binding(projectedValue: predicate)
    }
    
    // MARK: -
    var body: some View {
        ZStack {
            if fetchRequest.isEmpty { EmptyBubbleListView() }
            else {
                VStack {
                    Spacer(minLength: 30) //distance from status bar
                    if predicate != nil { SpotlightAlertView($predicate, $showDetailView) }
                    List {
                        ForEach(fetchRequest) { section in
                            Section {
                                ForEach (section) { bubble in
                                        BubbleCell(bubble, $showDetailView, $predicate)
                                            .environmentObject(viewModel)
                                }
                            } header: { headerTitle(for: section.id.description) }
                        }
                        .listRowSeparator(.hidden)
                    }
                    .padding(EdgeInsets(top: 0, leading: -10, bottom: 0, trailing: -10))
                    .listStyle(.sidebar)
                }
                .ignoresSafeArea()
            }
            if showDetailView {
                DetailView($showDetailView)
                    .offset(x: 0, y: -40)
                    .environmentObject(viewModel)
            }
            LeftStrip($showPalette, isBubbleListEmpty: fetchRequest.isEmpty)
            PaletteView($showPalette).environmentObject(viewModel)
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
        BubbleList(.constant(NSPredicate(value: true)))
    }
}
