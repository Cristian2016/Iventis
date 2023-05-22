//
//  EditActionTitle.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 22.05.2023.
//

import SwiftUI

struct EditActionTitle: View {
    private let bubble:Bubble
    
    var body: some View {
        VStack(spacing: 10) {
            let color = Color.bubbleColor(forName: bubble.color)
            
            Text("\(bubble.isTimer ? Image.timer : Image.stopwatch) \(Color.userFriendlyBubbleColorName(for: bubble.color))")
                .font(.system(size: 30, weight: .medium))
                .foregroundColor(color)
            HStack {
                if !bubble.note_.isEmpty {
                    Text(bubble.note_)
                    Divider()
                        .frame(height: 20)
                }
                Text("Activity \(bubble.sessions_.count)")
            }
            .font(.system(size: 20))
            .foregroundColor(.white)
        }
    }
    
    init(_ bubble: Bubble) {
        self.bubble = bubble
    }
}

struct EditActionTitle_Previews: PreviewProvider {
    static var previews: some View {
        EditActionTitle(EditActionView_Previews.bubble)
    }
}
