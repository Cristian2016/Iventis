//
//  ContentView.swift
//  Shared
//
//  Created by Cristian Lapusan on 12.04.2022.
//1 NavigationLink has a disclosure triangle. DT must be hidden, therefore behind the BubbleCell
//2 BubbleCell in detailView must look the same as in BubbleList
//3 custom modifier that reads BubbleCell.height and sets bubbleCellHeight. The List in DetailView contains only one BubbleCell and will have its height restricted to bubbleCellHeight
//4 ZStack is necessary so that PaletteView.height is all the way to the top of the device. it PaletteView would be inside list, it would be clipped at the top
//5 isPinnedSection computed only to find out if there should be a separator line or not
//6 if Text Size increases to 310%, the stroke is cut off slightly. to prevent that add a bit of padding
// using strokeBorder is better than stroke! because stroke does not overspill. stroke does overspill slightly
//7 BubbleCell must know list width in order to compute its spacing which is esential for the look
//8 toolbar hides when PaletteView shows
//9 BubbleCell must extend horizontally to the edges. -14 points is a good value for smallest phone iPhone SE3
//10 BubbleCell must know width of the parent view to compute spacing and have same design regardless of device or orientation
//11 user can pull down to toggle pinned bubbles only. refresherView shows when used pulls to refresh the table
//12 initializer with or without predicate. when predicate is set, it fetches only pinned bubbles [bubble.isPinned]. otherwise it fetches everything

import SwiftUI
import CoreData
import Combine
import MyPackage

struct BubbleList: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var viewModel:ViewModel
    @EnvironmentObject private var layoutViewModel:LayoutViewModel
    @SectionedFetchRequest var bubbles:SectionedFetchResults<Bool, Bubble>
        
    // MARK: -
    var body: some View {
        ZStack {
            if isListEmpty { EmptyListView() }
            else {
                GeometryReader { geo in
                    let metrics = BubbleCell.Metrics(geo.size.width) //7
                    
                    List (bubbles) { section in
                        let value = section.id.description == "true" //5
                        Section {
                            ForEach (section) { bubble in
                                ZStack { //1
                                    NavigationLink(value: bubble) { /* leave it empty */ }
                                    BubbleCell(bubble, metrics)
                                }
                            }
                        }
                        .listRowSeparator(.hidden)
                        .listSectionSeparator(value ? .visible : .hidden, edges: [.bottom])
                        if !section.id { bottomOverscoll }
                        if viewModel.showFavoritesOnly { showAllButton } //11
                    }
                    .scrollIndicators(.hidden)
                    .listStyle(.plain)
                    .toolbarBackground(.ultraThinMaterial)
                    .toolbar {
                        ToolbarItemGroup {
                            buttonsBar
                            Button {
                                
                            } label: {
                                
                            }
                        }
                    }
                    .padding(BubbleCell.padding) //9
                    .navigationDestination(for: Bubble.self) { detailView($0) }
                    .background { refresherView } //11
                    .refreshable { viewModel.showFavoritesOnly.toggle() } //11
                }
            }
            
            if !notesShowing { LeftStrip($viewModel.isPaletteShowing, isListEmpty) }
        }
    }
    
    // MARK: - Lego
    private var showAllButton:some View {
        Text("\(Image(systemName: "eye")) Show All")
            .listRowSeparator(.hidden)
            .font(.footnote)
            .foregroundColor(.secondary)
            .onTapGesture { viewModel.showFavoritesOnly = false }
            .padding([.leading], 4)
    } //11
    
    private var refresherView:some View {
        VStack(spacing: 4) {
            let condition = viewModel.showFavoritesOnly
            let title = condition ?  "Show All" : "Show Pinned Only"
            let symbol = condition ? "eye" : "pin"
            let color = condition ? .secondary : Color.orange
            
            BorderlessLabel(title: title, symbol: symbol,color: color)
            Image(systemName: "chevron.compact.down")
                .foregroundColor(color)
            Spacer()
        }
        .padding([.top], 4)
    } //11
    
    private func detailView(_ bubble:Bubble) -> some View {
        GeometryReader {
            let metrics = BubbleCell.Metrics($0.size.width) //10
            DetailView(Int(bubble.rank), bubble, metrics)
        }
    }
    
    private var buttonsBar:some View {
        HStack {
            AutoLockSymbol()
            PlusSymbol()
        }
    }
    
    // MARK: -
    
    init(_ showFavoritesOnly: Bool) {
        var predicate:NSPredicate?
        if showFavoritesOnly { predicate = NSPredicate(format: "isPinned == true")}
        
        UITableView.appearance().showsVerticalScrollIndicator = false
        _bubbles = SectionedFetchRequest<Bool, Bubble>(
            entity: Bubble.entity(),
            sectionIdentifier: \.isPinned,
            sortDescriptors: BubbleList.descriptors,
            predicate: predicate,
            animation: .default
        )
    } //12
    
    // MARK: -
    private static var formatter:DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        //        formatter.locale = Locale(identifier: "us")
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    private var bottomOverscoll: some View {
        Spacer()
            .frame(height: 200)
            .listRowSeparator(.hidden)
    }
    
    @ViewBuilder
    private func headerTitle(for sectionID:String) -> some View {
        HStack {
            //text
            if sectionID == "false" {
                HStack {
                    Text("Bubbles")
                        .foregroundColor(.label)
                        .fontWeight(.medium)
                }
                
            }
            else { Text("\(Image(systemName: "pin.fill")) Pinned")
                    .foregroundColor(.orange)
                    .fontWeight(.medium)
            }
            
            //rectangle to allow collapse along the entire width
            Rectangle().foregroundColor(.white.opacity(0.001))
        }
        .font(.system(size: 26))
    }
    
    private static let descriptors = [
        NSSortDescriptor(key: "isPinned", ascending: false),
        NSSortDescriptor(key: "rank", ascending: false)
    ]
}

// MARK: -
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        BubbleList(false)
    }
}

// MARK: - Little Helpers
extension BubbleList {
    fileprivate var notesShowing:Bool { viewModel.notesList_bRank != nil }
        
    fileprivate var isListEmpty:Bool { bubbles.isEmpty }
}
