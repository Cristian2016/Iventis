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
//13 toolbar items is an HStack { PlusButton AutoLock etc }
//14 remove gray cell selectio

import SwiftUI
import CoreData
import Combine
import MyPackage

struct BubbleList: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var viewModel:ViewModel
    @EnvironmentObject private var layoutViewModel:LayoutViewModel
    @SectionedFetchRequest var bubbles:SectionedFetchResults<Bool, Bubble>

    private let secretary = Secretary.shared
                
    // MARK: -
    var body: some View {
//        let _ = print("BubbleList body")
        ZStack {
            if isListEmpty { EmptyListView() }
            else {
                GeometryReader { geo in
                    let metrics = BubbleCell.Metrics(geo.size.width) //7
                    
                    List (bubbles) { section in
                        let value = section.id.description == "true" //5
                        Section {
                            ForEach (section) { bubble in
                                ZStack {
                                    NavigationLink(value: bubble) { }.opacity(0)
                                    BubbleCell(bubble, metrics)
                                }
                            }
                        }
                        .listRowSeparator(.hidden)
                        .listSectionSeparator(value ? .visible : .hidden, edges: [.bottom])
                        
                        if secretary.showFavoritesOnly {
                            ShowAllBubblesButton().listRowSeparator(.hidden)
                        }
                        
                        if !section.id { bottomOverscoll }
                    }
                    .scrollIndicators(.hidden)
                    .listStyle(.plain)
                    .toolbarBackground(.ultraThinMaterial)
                    .toolbar { ToolbarItemGroup {
                        AddNoteButton()
                        AutoLockButton()
                        PlusSymbol()
                    }}
                    .padding(BubbleCell.padding) //9
                    .background { RefresherView() } //11
                    .onAppear {}
//                    .refreshable {
//                        if Secretary.shared.pinnedBubblesCount != 0 { secretary.showFavoritesOnly.toggle() }
//                    } //11
                }
            }
            LeftStrip(isListEmpty)
        }
    }
    
    // MARK: - Lego
    private func detailView(_ bubble:Bubble) -> some View {
        GeometryReader {
            let metrics = BubbleCell.Metrics($0.size.width) //10
            DetailView(Int(bubble.rank), bubble, metrics)
        }
    }
    
    private var bottomOverscoll: some View {
        Spacer()
            .frame(height: 200)
            .listRowSeparator(.hidden)
    }
    
    // MARK: -
    init(_ showFavoritesOnly: Bool, _ showDetail_bRank:Int64? = nil) {
        var predicate:NSPredicate?
        if showFavoritesOnly { predicate = NSPredicate(format: "isPinned == true")}
        if let rank = showDetail_bRank {
            predicate = NSPredicate(format: "rank == %D", rank)
        }
                
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

// MARK: - Little Helpers
extension BubbleList {
        
    fileprivate var isListEmpty:Bool { bubbles.isEmpty }
    
    struct Widths {
        var portrait:CGFloat?
        var landscape:CGFloat?
        
        var isComputed:Bool {
            portrait != nil && landscape != nil
        }
    }
}
