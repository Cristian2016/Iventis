//
//  ActionsView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 07.05.2023.
//

import SwiftUI

struct ActionsView: View {
    let bubble:Bubble
    let bDeleteAction:() -> ()
    let aDeleteAction:() -> ()
    
    init(bubble: Bubble, bDeleteAction: @escaping () -> Void, aDeleteAction: @escaping () -> Void) {
        self.bubble = bubble
        self.bDeleteAction = bDeleteAction
        self.aDeleteAction = aDeleteAction
    }
    
    var body: some View {
        VStack {
            BubbleDeleteButton1(bubble, bDeleteAction, aDeleteAction)
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
        ActionsView(bubble: Self.bubble) { } aDeleteAction: { }
    }
}
