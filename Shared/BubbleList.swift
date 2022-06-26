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
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var viewModel:ViewModel
    @SectionedFetchRequest var results:SectionedFetchResults<Bool, Bubble>
    
    // MARK: -
    var body: some View {
        ZStack {
            if isListEmpty { EmptyListView() }
            else {
                ZStack {
                    VStack {
                        List (results, selection: $viewModel.rankOfSelectedBubble) { section in
                            Section {
                                ForEach (section) { BubbleCell($0) }
                                .onMove {
                                    let moveAtTheBottom = ($1 == section.count)
                                    let sourceRank = section[$0.first!].rank
                                    
                                    if moveAtTheBottom {
                                        let destRank = section[$1 - 1].rank
                                        viewModel.reorderRanks(sourceRank, destRank, true)
                                    } else {
                                        let destRank = section[$1].rank
                                        viewModel.reorderRanks(sourceRank, destRank)
                                    }
                                }
                            } header: { headerTitle(for: section.id.description) }
                                .listRowSeparator(.hidden)
                            
                            //overscroll
                            if !section.id { Spacer().frame(height: 200) }
                        }
                        .scrollIndicators(.hidden)
                        .padding(EdgeInsets(top: 0, leading: -10, bottom: 0, trailing: -10))
                        .listStyle(.plain)
                    }
                    .ignoresSafeArea(edges:.bottom)
                }
            }
            PlusButton().environmentObject(viewModel)
            
            if !notesShowing {
                LeftStrip($viewModel.isPaletteShowing, isListEmpty).environmentObject(viewModel)
            }
            
            if notesShowing { BubbleStickyNotesList($viewModel.stickyNotesList_bRank) }
            
            if deleteViewOffsetComputed && deleteViewShowing {
                let bubble = viewModel.bubble(for: viewModel.showDeleteAction_bRank!)
                DeleteView(bubble).environmentObject(viewModel)
            }
            
            PaletteView($viewModel.isPaletteShowing).environmentObject(viewModel)
        }
        .onPreferenceChange(BubbleCellLow_Key.self) { new in
            let frame = new.frame
            if frame == .zero { return }
            
            self.viewModel.deleteViewOffset = compute_deleteView_YOffset(for: new.frame)
        }
    }
    
    // MARK: -
    init() {
        UITableView.appearance().showsVerticalScrollIndicator = false
        _results = SectionedFetchRequest<Bool, Bubble>(entity: Bubble.entity(),
                                                       sectionIdentifier: \.isPinned,
                                                       sortDescriptors: BubbleList.descriptors,
                                                       predicate: nil,
                                                       animation: .default)
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
    
    @ViewBuilder
    private func headerTitle(for sectionID:String) -> some View {
        HStack {
            //text
            if sectionID == "false" {
                Text("Bubbles")
                    .foregroundColor(.label)
                    .fontWeight(.medium)
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
    
    private func compute_deleteView_YOffset(for frame:CGRect) -> CGFloat {
        let cellDeleteViewGap = CGFloat(70)
        
        let cellLow = frame.origin.y + frame.height
        
        let deleteViewHeight = DeleteView.height
        let deleteViewHigh = (UIScreen.size.height - deleteViewHeight)/2
        let deleteViewLow = deleteViewHigh + deleteViewHeight
        
        //available space below bubble cell
        let spaceBelowCell = UIScreen.size.height - cellLow
        
        //put deleteActionView below cell it's the prefered way to go
        let putBelow = spaceBelowCell - (cellDeleteViewGap + deleteViewHeight) > 0
        let delta = cellLow - deleteViewHigh
        
        let deleteView_YOffset:CGFloat
        
        if putBelow { deleteView_YOffset = delta + cellDeleteViewGap }
        else {//put up
            deleteView_YOffset = frame.origin.y - (deleteViewLow + cellDeleteViewGap) - 10
        }
        
        return deleteView_YOffset
    }
}

// MARK: -
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        BubbleList()
    }
}


///bubbleCell reports its frame so that deleteActionView knows how to position itself
///CellLow is Bubble.(originY + height)
struct BubbleCellLow_Key:PreferenceKey {
    struct RankFrame:Equatable {
        let rank:Int
        let frame:CGRect
    }
    
    static var defaultValue = RankFrame(rank: -1, frame: .zero)
    static func reduce(value: inout RankFrame, nextValue: () -> RankFrame) {
        if value.frame == .zero { value = nextValue() }
    }
}

// MARK: - Little Helpers
extension BubbleList {
    fileprivate var notesShowing:Bool { viewModel.stickyNotesList_bRank != nil }
        
    fileprivate var isListEmpty:Bool { results.isEmpty }
    
    fileprivate var deleteViewShowing:Bool { viewModel.showDeleteAction_bRank != nil }
    
    var deleteViewOffsetComputed:Bool { viewModel.deleteViewOffset != nil }
}
