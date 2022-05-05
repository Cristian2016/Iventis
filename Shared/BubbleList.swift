//
//  ContentView.swift
//  Shared
//
//  Created by Cristian Lapusan on 12.04.2022.
//

import SwiftUI
import CoreData
import Combine

struct ContainerView:View {
    var body: some View { VStack { BubbleList($predicate) } }
    
    @State var predicate:NSPredicate? = nil
}

struct BubbleList: View {
    // MARK: -
    var body: some View {
        ZStack {
            if results.isEmpty { EmptyBubbleListView() }
            else {
                VStack {
                    Spacer(minLength: 30) //distance from status bar
                    if predicate != nil { ExitFocusAlertView($predicate, $showDetail) }
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
                        .listRowSeparator(.hidden)
                        if showDetail.show {
                            DetailTopView(showDetail.rank)
                            DetailBottomView(showDetail.rank)
                        }
                    }
                    .padding(EdgeInsets(top: 0, leading: -10, bottom: 0, trailing: -10))
                    .listStyle(.sidebar)
                }
                .ignoresSafeArea()
            }
            LeftStrip($showPalette, isBubbleListEmpty: results.isEmpty)
            PaletteView($showPalette).environmentObject(viewModel)
            if deleteActionOffset != nil && showDeleteAction.show {
                let bubble = viewModel.bubble(for: showDeleteAction.rank!)
                DeleteActionView(bubble, $showDeleteAction, $predicate, deleteActionOffset!)
                    .environmentObject(viewModel) //pass viewmodel as well
            }
        }
        .onPreferenceChange(FrameKey.self) { new in
            if new.frame == .zero { return }
            self.deleteActionOffset = computeOffset(for: new.frame)
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
    
    //1
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.scenePhase) var scenePhase
    
    @State private var deleteActionOffset:CGFloat? = nil
        
    // MARK: -
    @StateObject private var viewModel = ViewModel()
    
//    private var bubbles: SectionedFetchResults<Bool, Bubble>
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
    
    private func computeOffset(for frame:CGRect) -> CGFloat {
        let cellLow = frame.origin.y + frame.height
        
        let deleteActionHeight = CGFloat(250)
        let deleteActionHigh = (UIScreen.size.height - deleteActionHeight)/2
        let deleteActionLow = deleteActionHigh + deleteActionHeight
        
        let spaceBelowCell = UIScreen.size.height - cellLow
        
        let offsetY:CGFloat
        let putBelow = spaceBelowCell - deleteActionHeight > 0
        let delta = cellLow - deleteActionHigh
        
        if putBelow {
            offsetY = delta + 15
        } else {
            //put up
            offsetY = frame.origin.y - deleteActionLow - 25
        }
        
        return offsetY
    }
}

// MARK: -
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        BubbleList(.constant(NSPredicate(value: true)))
    }
}

struct FrameKey:PreferenceKey {
    struct RankFrame:Equatable {
        let rank:Int
        let frame:CGRect
    }
    
    static var defaultValue = RankFrame(rank: -1, frame: .zero)
    static func reduce(value: inout RankFrame, nextValue: () -> RankFrame) {
        if value.frame == .zero { value = nextValue() }
    }
}
