//
//  ActionsView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 03.05.2023.
//

import SwiftUI

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
                .fill(.white.opacity(0.001))
                .ignoresSafeArea()
                .onTapGesture { dismiss() }
            
            VStack(spacing: 4) {
                VStack(spacing: 8) {
                    HStack(spacing: 2) {
                        deleteBubbleButton
                            .background(
                                Rectangle()
                                    .fill(.red)
                                    .frame(height: 80)
                            )
                        deleteActivityButton
                    }
                }
                .padding([.top, .bottom])
                .background {
                    Rectangle()
                        .fill(Color("deleteActionAlert1"))
                        .standardShadow()
                }
                .clipShape(vRoundedRectangle(corners: [.topLeft, .topRight], radius: 30))
                .padding([.leading, .trailing])
                .standardShadow()
                
                DurationsView(bubble)
            }
            .frame(maxWidth: 320)
        }
    }
    
//    private let durations = [60, 120, 180, 240, 300, 600, 900, 1200, 1800, 2700, 3600, 7200]
    let durations1 = [1:60, 2:120, 3:180, 4:240, 5:300, 10:600, 15:900, 20:1200, 30:1800, 45:2700, 60:3600, 120:7200]
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 4)
    
    private var deleteTitle:some View {
        Text("\(Image.trash) Delete")
            .foregroundColor(.red)
            .font(.system(size: 22, weight: .medium))
    }
    
    private var deleteBubbleButton:some View {
        Button {
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
    
    private var deleteActivityButton:some View {
        Button {
            viewModel.reset(bubble)
            Secretary.shared.deleteAction_bRank = nil
        }
    label: {
        
        let count = bubble.sessions_.count
        let text:LocalizedStringKey = count > 0 ? "^[\(bubble.sessions_.count) Entry](inflect: true)" : "0 Entries"
        
        Text("Reset")
            .frame(maxWidth: .infinity)
            .font(.system(size: 32, weight: .medium, design: .rounded))
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
        return bubble
    }()
    
    static var previews: some View {
        BubbleDeleteButton1(Self.bubble)
    }
}
