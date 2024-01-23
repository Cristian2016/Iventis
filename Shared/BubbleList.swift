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
//15 user taps notification when timer is done. when notification tapped -> BubbleList is notified via NotificationCenter to scroll to timer

import SwiftUI
import CoreData
import Combine
import MyPackage

struct BubbleList: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(Secretary.self) private var secretary
    
    @SectionedFetchRequest var sections:SectionedFetchResults<Bool, Bubble>
    
    @State private var showPairNotes = false
    
    private static let publisher = NotificationCenter.Publisher(center: .default, name: .scrollToTimer)
    
    // MARK: -
    var body: some View {
        let isListEmpty = sections.isEmpty
        
        ZStack(alignment: .leading) {
            if isListEmpty {
                EmptyListView()
            }
            else {
                List (sections) { bubbles in
                    let pinnedSection = bubbles.id.description == "true" //5
                    
                    Section {
                        if pinnedSection {
                            PinnedSection(bubbles: bubbles)
                        } else {
                            UnpinnedSection(bubbles: bubbles)
                        }
                    }
                    .listRowSeparator(.hidden)
                    .listSectionSeparator(pinnedSection ? .visible : .hidden, edges: [.bottom])
                    
                    if !bubbles.id { bottomOverscoll }
                }
                .background {
                    let pinnedSectionExists = sections.count != 1
                    
                    if pinnedSectionExists {
                        RefresherView()
                    }
                }
                .refreshable { refresh() }
                .navigationDestination(for: Bubble.self) { DetailView($0) }
                .scrollIndicators(.hidden)
                .listStyle(.plain)
                .toolbarBackground(.ultraThinMaterial)
            }
            
            LeftStrip()
        }
        .toolbar {
            ToolbarItemGroup {
                if !isListEmpty {
                    ZStack(alignment: .trailing) {
                        CaffeinatedButton()
                        LapNoteButton()
                    }
                }
                PlusButton()
            }
        }
    }
    
    // MARK: -
    init() {
        let descriptors = [
            NSSortDescriptor(key: "isPinned", ascending: false),
            NSSortDescriptor(key: "rank", ascending: false)
        ]
        
        _sections = SectionedFetchRequest<Bool, Bubble>(
            sectionIdentifier: \.isPinned,
            sortDescriptors: descriptors,
            animation: .default
        )
    } //12
    
    // MARK: -
    private func refresh() {
        withAnimation {
            secretary.showFavoritesOnly.toggle()
        }
    }
    
    private var bottomOverscoll: some View {
        Spacer()
            .frame(height: 200)
            .listRowSeparator(.hidden)
    }
}
