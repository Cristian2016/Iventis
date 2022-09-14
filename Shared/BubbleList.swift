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
    @EnvironmentObject private var vm:ViewModel
    @SectionedFetchRequest var results:SectionedFetchResults<Bool, Bubble>
    
    
    // MARK: -
    var body: some View {
        ZStack {
            if isListEmpty { EmptyListView() }
            else {
                List (results, selection: $vm.rankOfSelectedBubble) { section in
                    Section {
                        ForEach (section) {
                            BubbleCell($0)
                            
                        }
//                        .onMove { source, destination in
//                            let moveAtTheBottom = (destination == section.count)
//                            let sourceRank = section[source.first!].rank
//
//                            if moveAtTheBottom {
//                                let destRank = section[destination - 1].rank
//                                vm.reorderRanks(sourceRank, destRank, true)
//                            } else {
//                                let destRank = section[destination].rank
//                                vm.reorderRanks(sourceRank, destRank)
//                            }
//                        }
                        .onMove(perform: vm.allowOnMove ? onMoveClosure : nil)
                    } header: { headerTitle(for: section.id.description) }
                        .listRowSeparator(.hidden)
                    
                    //bottom overscroll
                    if !section.id { bottomOverscoll }
                }
                .scrollIndicators(.hidden)
                .padding(EdgeInsets(top: 0, leading: -10, bottom: 0, trailing: -10))
                .listStyle(.plain)
            }
            Push(.topRight) {
                HStack {
                    DisplayAlwaysOnSymbol()
                    PlusButton()
                }
                .offset(y:-7)
            }
            .padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 20))
            
            if !notesShowing { LeftStrip($vm.isPaletteShowing, isListEmpty) }
            
            PaletteView($vm.isPaletteShowing)
        }
        .onPreferenceChange(BubbleCellLow_Key.self) { new in
            let frame = new.frame
            if frame == .zero { return }
            
            self.vm.deleteViewOffset =
            vm.compute_deleteView_YOffset(for: new.frame)
        }
    }
    
    private var  onMoveClosure: (IndexSet, Int) -> Void = { indexSet, Int in
        
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
    fileprivate var notesShowing:Bool { vm.notesList_bRank != nil }
        
    fileprivate var isListEmpty:Bool { results.isEmpty }
}
