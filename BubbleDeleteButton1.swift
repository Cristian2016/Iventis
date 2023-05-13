//
//  ActionsView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 03.05.2023.
//

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
                .fill(Color.background.opacity(0.5))
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
        
    private var deleteBubbleButton:some View {
        Button {
            hapticFeedback()
            viewModel.deleteBubble(bubble)
            dismiss()
        }
    label: {
        Text("Delete")
            .frame(maxWidth: .infinity)
            .font(.system(size: 32, weight: .medium, design: .rounded))
            .tint(.white)
    }
    }
    
    private var resetButton:some View {
        Button {
            hapticFeedback()
            viewModel.reset(bubble)
            Secretary.shared.deleteAction_bRank = nil
        }
    label: {
        
        let count = bubble.sessions_.count
        let text:LocalizedStringKey = count > 0 ? "^[\(bubble.sessions_.count) Entry](inflect: true)" : "0 Entries"
        
        ZStack(alignment: .bottom) {
            Text("Reset")
                .frame(maxWidth: .infinity)
                .font(.system(size: 32, weight: .medium, design: .rounded))
            Text(text)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.lightGray)
                .italic()
                .offset(y: 14)
        }
        
    }
    .tint(.white)
    }
    
    private var roundedBackground:some View {
        RoundedRectangle(cornerRadius: metrics.outerRadius)
            .fill(Color("deleteActionAlert1"))
    }
    
    // MARK: -
    private func dismiss() {
        withAnimation {
            Secretary.shared.deleteAction_bRank = nil
        }
    }
    
    private func hapticFeedback() { UserFeedback.singleHaptic(.heavy) }
    
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
