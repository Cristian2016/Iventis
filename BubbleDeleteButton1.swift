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
            Rectangle()
                .fill(Color.black.opacity(0.5))
                .onTapGesture { dismiss() }
            
            VStack(spacing: 6) {
                VStack(spacing: 8) {
                    HStack(spacing: 2) {
                        deleteBubbleButton
                            .background(
                                Rectangle()
                                    .fill(.red)
                                    .frame(height: 80)
                            )
                         
                        if !bubble.sessions_.isEmpty { resetButton }
                    }
                }
                .padding([.top, .bottom])
                .background {
                    Rectangle()
                        .fill(Color("deleteActionAlert1"))
                }
                .clipShape(vRoundedRectangle(corners: [.topLeft, .topRight], radius: 30))
                .padding([.leading, .trailing])
                DurationsView(bubble)
            }
            .compositingGroup()
            .standardShadow()
            .frame(maxWidth: 320)
        }
        .ignoresSafeArea()
    }
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 4)
    
    // MARK: - Lego
        
    private var deleteBubbleButton:some View {
        Button { deleteBubble() } label: { deleteLabel }
    }
    
    private var resetButton:some View {
        Button { resetBubble() } label: { resetLabel }
    }
    
    private var roundedBackground:some View {
        RoundedRectangle(cornerRadius: metrics.outerRadius)
            .fill(Color("deleteActionAlert1"))
    }
    
    private var deleteLabel:some View { Text("Delete").modifier(ButtonLook()) }
    
    private var resetLabel:some View { Text("Reset").modifier(ButtonLook()) }
    
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
        let session = Session(context: context)
        bubble.addToSessions(session)
        return bubble
    }()
    
    static var previews: some View {
        BubbleDeleteButton1(Self.bubble)
    }
}
