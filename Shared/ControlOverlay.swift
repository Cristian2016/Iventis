//
//  TestView01.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 03.12.2023.
//  ControlOverlay1.transition. cant't use transition inside body, only outside

import SwiftUI
import MyPackage

struct ControlOverlay: View {
    @Environment(Secretary.self) private var secretary
    @Environment(ViewModel.self) private var viewModel
    
    @AppStorage("controlFirstTime") private var firstTime = true
    
    //TabView
    @State private var selectedTab:String
    
    private let bubble:Bubble
    private let color:Color
    
    var body: some View {
        ZStack {
            Background(.dark(.Opacity.overlay))
                .onTapGesture { dismiss() }
                .overlay(alignment: .top) {
                    ControlOverlay.BubbleLabel(.hasBubble(bubble))
                }
            
            OverlayScrollView {
                VStack {
                    Buttons(bubble: bubble)
                    TabView(selection: $selectedTab) {
                        MinutesGrid(bubble, color, $selectedTab).tag("MinutesGrid")
                        HistoryGrid(bubble, $selectedTab).tag("HistoryGrid") //1
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
                .padding(.init(top: 14, leading: 8, bottom: 12, trailing: 8))
                .frame(maxWidth: 350, maxHeight: 360)
                .background(.regularMaterial, in: shape)
                .compositingGroup()
                .standardShadow()
            } action: {
                dismiss()
            }
        }
        .onChange(of: selectedTab) { oldValue, newValue in
            if oldValue == "HistoryGrid" && firstTime {
                firstTime = false
            }
        }
    }
    
    init ?(_ bubble:Bubble?) {
        guard let bubble = bubble else { return nil }
        
        self.bubble = bubble
        self.color = Color.bubbleColor(forName: bubble.color)
        
        _selectedTab = State(initialValue: bubble.selectedTab ?? "MinutesGrid")
    }
    
    private func dismiss() {
        HintOverlay.Model.shared.topmostView(viewModel.path.isEmpty ? .bubbleList : .detail)
        
        secretary.controlBubble(.hide)
        //save selectedTab to CoreData
        let bContext = PersistenceController.shared.bContext
        let objID = bubble.objectID
        
        bContext.perform {
            let theBubble = PersistenceController.shared.grabObj(objID) as? Bubble
            theBubble?.selectedTab = selectedTab
            PersistenceController.shared.save(bContext)
        }
    }
    
    private var shape:some InsettableShape {
        let radii = RectangleCornerRadii(topLeading: 20, bottomLeading: 36, bottomTrailing: 36, topTrailing: 20)
        return UnevenRoundedRectangle(cornerRadii: radii, style: .continuous)
    }
}
