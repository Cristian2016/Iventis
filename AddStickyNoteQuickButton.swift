//
//  AddStickyNoteQuickButton.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 03.10.2022.
//

import SwiftUI

///temporary button that shows up in the BubbleList, for 5 seconds
struct AddStickyNoteQuickButton: View {
    @EnvironmentObject var viewModel:ViewModel
    
    // MARK: - Body
    var body: some View {
        Button { action() } label: { Label(text, systemImage: imageName)}
            .buttonStyle(.bordered)
    }
    
    // MARK: -
    let imageName = "tag.fill"
    let text = "Tag Current Pair"
    let action:() -> ()
    
    // MARK: -
    init(_ action: @escaping () -> ()) {
        self.action = action
    }
}

struct AddStickyNoteQuickButton_Previews: PreviewProvider {
    static var previews: some View {
        AddStickyNoteQuickButton { }
    }
}
