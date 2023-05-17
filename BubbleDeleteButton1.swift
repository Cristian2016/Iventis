//
//  ActionsView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 03.05.2023.
//
//        let count = bubble.sessions_.count
//        let text:LocalizedStringKey = count > 0 ? "^[\(bubble.sessions_.count) Entry](inflect: true)" : "0 Entries"

import SwiftUI
import MyPackage

struct BubbleDeleteButton1: View {
    private let bubble:Bubble
    private let color:Color
    private let metrics = Metrics()
    @EnvironmentObject private var viewModel:ViewModel
    
    init(_ bubble: Bubble) {
        self.bubble = bubble
        self.color = Color.bubbleColor(forName: bubble.color)
    }
    
    var body: some View {
        ZStack {
            screenDarkBackground.onTapGesture { dismiss() }
            
            VStack {
                HStack {//buttons stack
                    deleteBubbleButton
                    resetButton
                }
                .padding([.top, .bottom])
                .background { darkRectangle }
                .clipShape(vRoundedRectangle(corners: [.topLeft, .topRight], radius: 30))
                
                DurationsView(bubble) //digits stack
            }
            .compositingGroup()
            .standardShadow()
            .frame(maxWidth: 290)
        }
    }
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 4)
    
    // MARK: - Lego
    private var deleteBubbleButton:some View {
        Button { deleteBubble() } label: { deleteLabel }
            .background(
                Rectangle()
                    .fill(.red)
                    .frame(height: 80)
            )
    }
    
    @ViewBuilder
    private var resetButton:some View {
        if !bubble.sessions_.isEmpty {
            Button { resetBubble() } label: { resetLabel }
        }
    }
    
    private var roundedBackground:some View {
        RoundedRectangle(cornerRadius: metrics.outerRadius)
            .fill(Color("deleteActionAlert1"))
    }
    
    private var deleteLabel:some View { Text("Delete").modifier(ButtonLook()) }
    
    private var resetLabel:some View { Text("Reset").modifier(ButtonLook()) }
    
    private var darkRectangle:some View {
        Rectangle()
            .fill(Color("deleteActionAlert1"))
    }
    
    private var screenDarkBackground:some View {
        Color.black
            .opacity(0.5)
            .ignoresSafeArea()
    }
    
    // MARK: - Methods
    private func dismiss() {
        withAnimation {
            Secretary.shared.deleteAction_bRank = nil
        }
    }
    
    private func hapticFeedback() { UserFeedback.singleHaptic(.heavy) }
        
    private func resetBubble() {
        hapticFeedback()
        viewModel.reset(bubble)
        Secretary.shared.deleteAction_bRank = nil
    }
    
    private func deleteBubble() {
        hapticFeedback()
        viewModel.deleteBubble(bubble)
        dismiss()
    }
    
    struct ButtonLook:ViewModifier {
        func body(content: Content) -> some View {
            content
                .frame(maxWidth: .infinity)
                .font(.system(size: 32, weight: .medium, design: .rounded))
                .tint(.white)
        }
    }
    
    // MARK: -
    struct Metrics {
        let outerRadius = CGFloat(40)
    }
}

struct BubbleDeleteButton1_Previews: PreviewProvider {
    static let bubble:Bubble = {
        let context = PersistenceController.preview.viewContext
        let bubble = Bubble(context: context)
        bubble.color = "orange"
        bubble.initialClock = 10
//        bubble.currentClock = 10
        let session = Session(context: context)
        bubble.addToSessions(session)
        return bubble
    }()
    
    static var previews: some View {
        BubbleDeleteButton1(Self.bubble)
    }
}
