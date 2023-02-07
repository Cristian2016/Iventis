//
//  tBubbleCell.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 07.02.2023.
//

import SwiftUI

struct tBubbleCell: View {
    @StateObject var bubble:Bubble
    @EnvironmentObject private var vm:ViewModel
    
    var body: some View {
        let _ = print("Update ContentView")
        Circle()
            .fill(Color.bubbleColor(forName: bubble.color))
            .overlay {
                Text(String(bubble.currentClock))
            }
            .onTapGesture {
                vm.toggleBubbleStart(bubble)
            }
    }
}

struct tBubbleCell_Previews: PreviewProvider {
    static let bubble:Bubble = {
        let bubble = Bubble(context: PersistenceController.preview.viewContext)
        let sdb = StartDelayBubble(context: PersistenceController.preview.viewContext)
        sdb.referenceDelay = 0
        
        bubble.sdb = sdb
        bubble.color = "sourCherry"
        return bubble
    }()
    static var previews: some View {
        tBubbleCell(bubble: bubble)
            .environmentObject(bubble)
            .environmentObject(ViewModel())
    }
}
