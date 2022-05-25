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
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.managedObjectContext) private var viewContext
    
    @SectionedFetchRequest var results:SectionedFetchResults<Bool, Bubble>
    @StateObject private var viewModel = ViewModel()
    
    // MARK: -
    @Binding var predicate:NSPredicate?
    
    //showing Detail or DeleteAction views
    @State var showDetail_bRank:Int? = nil //bubble.rank
    @State var showDeleteAction_bRank:Int? = nil //bubble.rank
    @State var showAddNotes_bRank:Int? = nil //bubble rank
    
    @State private var deleteViewYOffset:CGFloat? = nil
    @State private var isActive = true
    @State var isPaletteShowing = false
    
    // MARK: -
    var body: some View {
        ZStack {
            if isListEmpty { EmptyListView() }
            else {
                ZStack {
                    if !isFocusOn && !notesShowing { UpDownArrows() }
                    if isFocusOn { ExitFocusView($predicate, $showDetail_bRank).zIndex(1)}
                    
                    VStack {
                        List {
                            ForEach(results) { section in
                                Section {
                                    ForEach (section) {
                                        BubbleCell($0, $predicate,
                                                   $showDetail_bRank,
                                                   $showDeleteAction_bRank,
                                                   $showAddNotes_bRank)
                                        .coordinateSpace(name: "BubbleCell")
                                                .environmentObject(viewModel)
                                    }
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
                                }
                            header: { headerTitle(for: section.id.description) }
                                    .accentColor(section.id != false ? .clear : .label) //collapse section indicators invisible
                            }
                            Spacer(minLength: 100) //overscroll
                        }
                        .padding(EdgeInsets(top: 0, leading: -10, bottom: 0, trailing: -10))
                        .listStyle(.sidebar)
                    }
                    .ignoresSafeArea(edges:.bottom)
                }
            }
            if !notesShowing {
                LeftStrip($isPaletteShowing, isListEmpty)
                    .environmentObject(viewModel)
            }
            
            //on top of everything show DetailView (TopDetailView and BottomDetailView
            if isFocusOn && !notesShowing { DetailView(showDetail_bRank) }
            
            if notesShowing { BubbleStickyNotesList($showAddNotes_bRank, viewModel) }
            
            if deleteViewOffsetComputed && deleteViewShowing {
                let bubble = viewModel.bubble(for: showDeleteAction_bRank!)
                DeleteView(bubble, $showDeleteAction_bRank, $predicate, deleteViewYOffset!)
                    .environmentObject(viewModel) //pass viewmodel as well
            }
            
            PaletteView($isPaletteShowing).environmentObject(viewModel)
        }
        .onPreferenceChange(BubbleCellLow_Key.self) { new in
            let frame = new.frame
            if frame == .zero { return }
            
            self.deleteViewYOffset = compute_YOffset(for: new.frame)
        }
        .onChange(of: scenePhase) {
            switch $0 {
                case .active:
                    viewModel.backgroundTimer(.start)
                case .background:
                    viewModel.backgroundTimer(.pause)
                case .inactive: //show notication center, app switcher
                    break
                @unknown default: fatalError()
            }
        }
    }
    
    // MARK: -
    init(_ predicate:Binding<NSPredicate?>) {
        UITableView.appearance().showsVerticalScrollIndicator = false
        _results = SectionedFetchRequest<Bool, Bubble>(entity: Bubble.entity(),
                                                        sectionIdentifier: \.isPinned,
                                                      sortDescriptors: BubbleList.descriptors,
                                                            predicate: predicate.wrappedValue,
                                                        animation: .default)
        _predicate = Binding(projectedValue: predicate)
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
        .font(.title3)
    }
    
    private static let descriptors = [
        NSSortDescriptor(key: "isPinned", ascending: false),
        NSSortDescriptor(key: "rank", ascending: false)
    ]
    
    private func compute_YOffset(for frame:CGRect) -> CGFloat {
        let cellDeleteViewGap = CGFloat(15)
        
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
        BubbleList(.constant(NSPredicate(value: true)))
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
    fileprivate var notesShowing:Bool { showAddNotes_bRank != nil }
    
    fileprivate var isFocusOn:Bool { predicate != nil }
    
    fileprivate var isListEmpty:Bool { results.isEmpty }
    
    fileprivate var deleteViewShowing:Bool { showDeleteAction_bRank != nil }
    
    var deleteViewOffsetComputed:Bool {
        deleteViewYOffset != nil
    }
}
