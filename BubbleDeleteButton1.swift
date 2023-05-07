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
    private let deleteAction1:() -> ()
    private let deleteAction2:() -> ()
    
    init(_ bubble: Bubble, _ bubbleDeleteAction: @escaping () -> (), _ activityDeleteAction: @escaping () -> ()) {
        self.bubble = bubble
        self.color = Color.bubbleColor(forName: bubble.color)
        self.deleteAction1 = bubbleDeleteAction
        self.deleteAction2 = activityDeleteAction
    }
    
    var body: some View {
        VStack {
            deleteTitle
            VStack(spacing: 2) {
                deleteBubbleButton
                deleteActivityButton
            }
            .padding([.leading, .trailing], 4)
        }
        .padding([.top, .bottom])
        .background { roundedBackground}
        .padding([.leading, .trailing], 4)
    }
    
    private var deleteTitle:some View {
        Text("\(Image.trash) Delete")
            .foregroundColor(.red)
            .font(.system(.title3).weight(.medium))
    }
    
    private var deleteBubbleButton:some View {
        vRoundedRectangle(corners: [.topLeft, .topRight], radius: 30)
            .fill(color)
            .frame(height: 70)
            .overlay {
                Button { deleteAction1() }
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
                Button { deleteAction2() }
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
            .fill(.regularMaterial)
    }
    
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
        BubbleDeleteButton1(Self.bubble) { } _: { }
    }
}
