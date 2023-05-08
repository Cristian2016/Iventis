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
            VStack {
                VStack(spacing: 8) {
                    deleteTitle
                    HStack(spacing: 2) {
                        deleteBubbleButton
                        deleteActivityButton
                    }
                    .padding([.leading, .trailing], 4)
                }
                
                .padding([.top, .bottom])
                .background { roundedBackground}
                .padding([.leading, .trailing], 4)
                
                LazyVGrid(columns: columns) {
                    ForEach(durations, id: \.self) { number in
                        Button(String(number/60)) {
                            viewModel.change(bubble, into: .timer(Float(number)))
                        }
                    }
                }
                .buttonStyle(.bordered)
                .font(.system(size: 32))
                .foregroundColor(.white)
            }
            .padding([.leading, .trailing], 4)
            .padding([.top, .bottom])
            .frame(maxWidth: 370)
            .background {
                RoundedRectangle(cornerRadius: 50)
                    .fill(Color.background3.gradient)
                    .standardShadow()
            }
        }
    }
    
    private let durations = [60, 120, 180, 240, 300, 600, 900, 1200, 1800, 2700, 3600, 7200]
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 4)
    
    private var deleteTitle:some View {
        Text("\(Image.trash) Delete")
            .foregroundColor(.red)
            .font(.system(size: 26, weight: .medium))
    }
    
    private var deleteBubbleButton:some View {
        vRoundedRectangle(corners: [.bottomLeft], radius: 30)
            .fill(color)
            .frame(height: 70)
            .overlay {
                Button {
                    viewModel.deleteBubble(bubble)
                    dismiss()
                }
            label: {
                    Text("Bubble")
                        .frame(maxWidth: .infinity)
                        .font(.system(size: 32, weight: .medium, design: .rounded))
                }
                .tint(.white)
            }
    }
    
    private var deleteActivityButton:some View {
        vRoundedRectangle(corners: [.bottomRight], radius: 30)
            .fill(color)
            .frame(height: 70)
            .overlay {
                Button {
                    viewModel.reset(bubble)
                    Secretary.shared.deleteAction_bRank = nil
                }
            label: {
                
                let count = bubble.sessions_.count
                let text:LocalizedStringKey = count > 0 ? "^[\(bubble.sessions_.count) Entry](inflect: true)" : "0 Entries"
                
                Text(text)
                    .frame(maxWidth: .infinity)
                    .font(.system(size: 32, weight: .medium, design: .rounded))
                }
                .tint(.white)
            }
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
        bubble.color = "silver"
        return bubble
    }()
    
    static var previews: some View {
        BubbleDeleteButton1(Self.bubble)
    }
}
