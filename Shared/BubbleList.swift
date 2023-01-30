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

import SwiftUI
import CoreData
import Combine
import MyPackage

struct BubbleList: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var viewModel:ViewModel
    @SectionedFetchRequest var bubbles:SectionedFetchResults<Bool, Bubble>
    
    @State private var bubbleCellSize = CGSize(width: 1, height: 1)
    
    // MARK: -
    var body: some View {
        ZStack /* 4 */ {
            list
            PaletteView($viewModel.isPaletteShowing)
        }
    }
    
    // MARK: -
    init() {
        UITableView.appearance().showsVerticalScrollIndicator = false
        _bubbles = SectionedFetchRequest<Bool, Bubble>(
            entity: Bubble.entity(),
            sectionIdentifier: \.isPinned,
            sortDescriptors: BubbleList.descriptors,
            predicate: nil,
            animation: .default
        )
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
    
    // MARK: - Lego
    private var list:some View {
        ZStack {
            if isListEmpty { EmptyListView() }
            else {
                GeometryReader { geo in
                    let metrics = BubbleCell.Metrics(geo.size.width) //7
                    
                    List (bubbles) { section in
                        let isPinnedSection = section.id.description == "true" //5
                        Section {
                            ForEach (section) { bubble in
                                ZStack { //1
                                    NavigationLink(value: bubble) { }
                                    BubbleCell(bubble, metrics)
                                }
                            }
                        } header: { /* headerTitle(for: section.id.description) */ }
                            .listRowSeparator(.hidden)
                            .listSectionSeparator(
                                isPinnedSection ? .visible : .hidden, edges: [.bottom]) //1
                                                                                        //bottom overscroll
                        if !section.id { bottomOverscoll }
                    }
                    .toolbar(viewModel.isPaletteShowing ? .hidden : .automatic)
                    .toolbarBackground(.ultraThinMaterial)
                    .toolbar {
                        ToolbarItemGroup {
                            AutoLockSymbol()
                            PlusSymbol()
                        }
                    }
                }
                .scrollIndicators(.hidden)
                .padding(EdgeInsets(top: 0, leading: -14, bottom: 0, trailing: -14))
                .listStyle(.plain)
                .navigationDestination(for: Bubble.self) { bubble in
                    VStack {
                        GeometryReader { geo in
                            let metrics = BubbleCell.Metrics(geo.size.width)
                            List { BubbleCell(bubble, metrics)
                                .readSize($bubbleCellSize)
                            } //3
                        }
                        .scrollDisabled(true)
                        .listStyle(.plain)
                        .frame(height: (bubbleCellSize.height) * 1.1)
                        .padding([.leading, .trailing], -10) //2
//                        DetailView(Int(bubble.rank))
                    }
                    .padding([.top], 1)
                }
            }
            
            if !notesShowing { LeftStrip($viewModel.isPaletteShowing, isListEmpty) }
        }
    }
}

// MARK: -
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        BubbleList()
    }
}

// MARK: - Little Helpers
extension BubbleList {
    fileprivate var notesShowing:Bool { viewModel.notesList_bRank != nil }
        
    fileprivate var isListEmpty:Bool { bubbles.isEmpty }
}
