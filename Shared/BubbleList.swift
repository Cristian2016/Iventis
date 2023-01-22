//
//  ContentView.swift
//  Shared
//
//  Created by Cristian Lapusan on 12.04.2022.
// 1: NavigationLink has a disclosure triangle. DT must be hidden, therefore behind the BubbleCell
// 2: BubbleCell in detailView must look the same as in BubbleList
// 3: custom modifier that reads BubbleCell.height and sets bubbleCellHeight. The List in DetailView contains only one BubbleCell and will have its height restricted to bubbleCellHeight

import SwiftUI
import CoreData
import Combine
import MyPackage

struct BubbleList: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var viewModel:ViewModel
    @SectionedFetchRequest var results:SectionedFetchResults<Bool, Bubble>
    @State private var bubbleCellSize = CGSize(width: 1, height: 1) /*  */
    
    // MARK: -
    var body: some View {
        ZStack {
            if isListEmpty { EmptyListView() }
            else {
                GeometryReader { geo in
                    let metrics = BubbleCell.Metrics(width: geo.size.width)
                    
                    List (results) { section in
                        Section {
                            ForEach (section) { bubble in
                                ZStack { //1
                                    NavigationLink(value: bubble) { }
                                    BubbleCell(bubble, metrics: metrics)
                                }
                            }
                        } header: { headerTitle(for: section.id.description) }
                            .listRowSeparator(.hidden)
                        
                        //bottom overscroll
                        if !section.id { bottomOverscoll }
                    }
                }
                .scrollIndicators(.hidden)
                .padding(EdgeInsets(top: 0, leading: -10, bottom: 0, trailing: -10))
                .listStyle(.plain)
                .navigationDestination(for: Bubble.self) { bubble in
                    VStack {
                        GeometryReader { geo in
                            let metrics = BubbleCell.Metrics(width: geo.size.width)
                            List { BubbleCell(bubble, metrics: metrics).readSize($bubbleCellSize)
                            } //3
                        }
                            .scrollDisabled(true)
                            .listStyle(.plain)
                            .frame(height: bubbleCellSize.height * 1.1)
                            .padding([.leading, .trailing], -10) //2
                        DetailView(Int(bubble.rank))
                    }
                    .padding([.top], 1)
                }
            }
            Push(.topRight) {
                HStack {
                    AlwaysOnDisplaySymbol()
                    PlusButton()
                }
                .offset(y:-7)
            }
            .padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 20))
            
            if !notesShowing { LeftStrip($viewModel.isPaletteShowing, isListEmpty) }
            
            PaletteView($viewModel.isPaletteShowing)
        }
        .onPreferenceChange(BubbleCellLow_Key.self) { new in
            let frame = new.frame
            if frame == .zero { return }
            
            self.viewModel.deleteViewOffset =
            viewModel.compute_deleteView_YOffset(for: new.frame)
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
    fileprivate var notesShowing:Bool { viewModel.notesList_bRank != nil }
        
    fileprivate var isListEmpty:Bool { results.isEmpty }
}
