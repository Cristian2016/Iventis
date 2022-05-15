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
    //showing Detail or DeleteAction views
    @State var showDeleteActionView_BubbleRank:Int? = nil //bubble.rank
    @State var showDetailView_BubbleRank:Int? = nil //bubble.rank
    
    @Environment(\.editMode) var editMode
    private var isFocusModeOn:Bool { predicate != nil }
    
    var body: some View {
        ZStack {
            if results.isEmpty { EmptyBubbleListView() }
            else {
                ZStack {
                    if isFocusModeOn {
                        VStack {
                            ExitFocusAlertView($predicate, $showDetailView_BubbleRank)
                                .background(Rectangle()
                                    .fill(Color.background1)
                                    .frame(width: UIScreen.size.width)
                                    .padding(.bottom, -5)
                                )
                                .padding()
                            Spacer()
                        }
                        .zIndex(1)
                        .ignoresSafeArea()
                    }
                    
                    VStack {
                        Spacer(minLength: showDetailView_BubbleRank != nil ? 50 : 30) //distance from status bar
                        List {
                            ForEach(results) { section in
                                Section {
                                    ForEach (section) {
                                        BubbleCell($0,
                                                   $showDetailView_BubbleRank,
                                                   $predicate,
                                                   $showDeleteActionView_BubbleRank)
                                        .coordinateSpace(name: "BubbleCell")
                                                .environmentObject(viewModel)
                                    }
                                    .onMove { indices, destinationIndex in
                                        let source = section[indices.first!].rank
                                        let destination = section[destinationIndex].rank
                                        viewModel.reorderRanks(source, destination)
                                    }
                                } header: {
                                    headerTitle(for: section.id.description)
                                }
                                .accentColor(section.id == true ? .orange : .black)
                            }
                            
                            if !isFocusModeOn { MoveActionButton() }
                            Spacer(minLength: 80)
                        }
                        .padding(EdgeInsets(top: 0, leading: -10, bottom: 0, trailing: -10))
                        .listStyle(.sidebar)
                    }
                    .ignoresSafeArea()
                }
            }
            
            LeftStrip($showPalette, isBubbleListEmpty: results.isEmpty)
            
            //on top of everything show DetailView (TopDetailView and BottomDetailView
            if predicate != nil { DetailView(showDetailView_BubbleRank) }
            
            if deleteActionViewYOffset != nil && showDeleteActionView_BubbleRank != nil {
                let bubble = viewModel.bubble(for: showDeleteActionView_BubbleRank!)
                DeleteActionView(bubble, $showDeleteActionView_BubbleRank, $predicate, deleteActionViewYOffset!)
                    .environmentObject(viewModel) //pass viewmodel as well
            }
            
            PaletteView($showPalette).environmentObject(viewModel)
        }
        .onPreferenceChange(BubbleCellLow_Key.self) { new in
            let frame = new.frame
            if frame == .zero { return }
            
            self.deleteActionViewYOffset = compute_YOffset(for: new.frame)
        }
        .onChange(of: scenePhase, perform: {
            switch $0 {
                case .active:
                    viewModel.backgroundTimer(.start)
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
    //1
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.scenePhase) var scenePhase
    
    @State private var deleteActionViewYOffset:CGFloat? = nil
    @StateObject private var viewModel = ViewModel()
    @SectionedFetchRequest var results:SectionedFetchResults<Bool, Bubble>
    @Binding var predicate:NSPredicate?
    
    // MARK: -
    @State private var isActive = true
    @State var showPalette = false
    
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
            if sectionID == "false" { Text("Bubbles") .foregroundColor(.label) }
            else { Text("\(Image(systemName: "pin.fill")) Pinned").foregroundColor(.orange) }
            
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
        
        let deleteViewHeight = DeleteActionView.height
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
