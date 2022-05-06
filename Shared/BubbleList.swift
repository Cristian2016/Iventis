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
    var body: some View {
        ZStack {
            if results.isEmpty { EmptyBubbleListView() }
            else {
                ZStack {
                    if predicate != nil {
                        VStack {
                            ExitFocusAlertView($predicate, $showDetail)
                                .background(Rectangle()
                                    .fill(Color.background1)
                                    .frame(width: UIScreen.size.width)
                                )
                                .padding()
                                .padding(.top, 8)
                            Spacer()
                        }
                        .zIndex(1)
                        .ignoresSafeArea()
                    }
                    VStack {
                        Spacer(minLength: showDetail.show ? 50 : 30) //distance from status bar
                        List {
                            ForEach(results) { section in
                                Section {
                                    ForEach (section) {
                                        BubbleCell($0,
                                                   $showDetail,
                                                   $predicate,
                                                   $showDeleteAction)
                                                .environmentObject(viewModel)
                                    }
                                } header: { headerTitle(for: section.id.description) }
                            }
//                            if showDetail.show { TopDetailView(showDetail.rank) }
                        }
                        .padding(EdgeInsets(top: 0, leading: -10, bottom: 0, trailing: -10))
                        .listStyle(.sidebar)
                    }
                    .ignoresSafeArea()
                }
                
            }
            LeftStrip($showPalette, isBubbleListEmpty: results.isEmpty)
            
            //on top of everything
            if showDetail.show {
                VStack {
                    Spacer()
                    TopDetailView(showDetail.rank)
                        .frame(width: UIScreen.size.width * 0.96, height: 140)
                    BottomDetailView(showDetail.rank)
                        .frame(width: UIScreen.size.width * 0.96, height: 410)
                }
                .ignoresSafeArea()
            }
            
            if deleteViewOffset != nil && showDeleteAction.show {
                let bubble = viewModel.bubble(for: showDeleteAction.rank!)
                DeleteActionView(bubble, $showDeleteAction, $predicate, deleteViewOffset!)
                    .environmentObject(viewModel) //pass viewmodel as well
            }
            
            PaletteView($showPalette).environmentObject(viewModel)
        }
        .onPreferenceChange(BubbleCellLowKey.self) { new in
            if new.frame == .zero { return }
            self.deleteViewOffset = compute_YOffset(for: new.frame)
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
    @State private var deleteViewOffset:CGFloat? = nil
    @StateObject private var viewModel = ViewModel()
    @SectionedFetchRequest var results:SectionedFetchResults<Bool, Bubble>
    @Binding var predicate:NSPredicate?
    
    // MARK: -
    @State private var isActive = true
    @State var showDetail:(show:Bool, rank:Int?) = (false, nil)
    @State var showPalette = false
    @State var showDeleteAction:(show:Bool, rank:Int?) = (false, nil)
    
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
struct BubbleCellLowKey:PreferenceKey {
    struct RankFrame:Equatable {
        let rank:Int
        let frame:CGRect
    }
    
    static var defaultValue = RankFrame(rank: -1, frame: .zero)
    static func reduce(value: inout RankFrame, nextValue: () -> RankFrame) {
        if value.frame == .zero { value = nextValue() }
    }
}
