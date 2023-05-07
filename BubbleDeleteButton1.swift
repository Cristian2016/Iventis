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
                deleteTitle
                VStack(spacing: 2) {
                    deleteBubbleButton
                    deleteActivityButton
                }
                .padding([.leading, .trailing], 4)
                
                Button("20 minutes") {
                    
                    if bubble.state == .running {
                        
                    } else {
                        viewModel.change(bubble, into: .timer(3600))
                    }
                }
            }
            .padding([.top, .bottom])
            .background { roundedBackground}
            .padding([.leading, .trailing], 4)
        }
    }
    
    private var deleteTitle:some View {
        Text("\(Image.trash) Delete")
            .foregroundColor(.red)
            .font(.system(size: 22, weight: .medium))
    }
    
    private var deleteBubbleButton:some View {
        vRoundedRectangle(corners: [.topLeft, .topRight], radius: 30)
            .fill(color)
            .frame(height: 70)
            .overlay {
                Button { viewModel.deleteBubble(bubble) }
            label: {
                    Text("Bubble")
                        .frame(maxWidth: .infinity)
                        .font(.system(size: 28, weight: .medium, design: .rounded))
                }
                .tint(.white)
            }
    }
    
    private var deleteActivityButton:some View {
        vRoundedRectangle(corners: [.bottomLeft, .bottomRight], radius: 30)
            .fill(color)
            .frame(height: 70)
            .overlay {
                Button {
                    viewModel.reset(bubble)
                    Secretary.shared.deleteAction_bRank = nil
                }
            label: {
                Text("Activity")
                    .frame(maxWidth: .infinity)
                    .font(.system(size: 28, weight: .medium, design: .rounded))
                }
                .tint(.white)
            }
    }
    
    private var roundedBackground:some View {
        RoundedRectangle(cornerRadius: metrics.outerRadius)
            .fill(.ultraThickMaterial)
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
