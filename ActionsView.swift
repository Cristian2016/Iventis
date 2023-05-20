//
//  ActionsView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 07.05.2023.
//

import SwiftUI

struct ActionsView: View {
    let bubble:Bubble
    @EnvironmentObject private var viewModel:ViewModel
    
    init(bubble: Bubble) {
        self.bubble = bubble
    }
    @State private var show = false
    
    var body: some View {
        ZStack {
            VStack {
                Action1View(bubble: bubble)
            }
        }
        .onReceive(Secretary.shared.$deleteAction_bRank) { output in
            show = output == nil ? false : true
        }
    }
    
    // MARK: -
    let gridSpacing = CGFloat(1)
    private let digits = [["7", "8", "9"], ["4", "5", "6"], ["1", "2", "3"], ["*", "0", "✕"]]
}

struct ActionsView_Previews: PreviewProvider {
    static let bubble:Bubble = {
        let context = PersistenceController.preview.viewContext
        let bubble = Bubble(context: context)
        bubble.color = "silver"
        return bubble
    }()
    
    static var previews: some View {
        ActionsView(bubble: Self.bubble)
    }
}
