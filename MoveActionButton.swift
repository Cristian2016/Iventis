//
//  DragAndDropActionView.swift
//  Timers
//
//  Created by Cristian Lapusan on 14.05.2022.
//

import SwiftUI

struct MoveActionButton: View {
    @Environment(\.editMode) var editMode
    
    var body: some View {
        HStack {
            Spacer()
            Button {
                if editMode?.wrappedValue != .active {
                    editMode?.wrappedValue = .active
                } else {
                    editMode?.wrappedValue = .inactive
                }
                
                UserFeedback.doubleHaptic(.light)
            } label: {
                Label {
                   Text(editMode?.wrappedValue == .active ? "Cancel" : "Reorder")
                } icon: {
                    Image(systemName: "arrow.up.arrow.down.circle.fill")
                        .font(.system(size: 30))
                }
            }
            .tint(editMode?.wrappedValue == .active ? .red : .green)
            .buttonStyle(.borderedProminent)
            Spacer()
        }
           
    }
}

struct DragAndDropActionButton_Previews: PreviewProvider {
    static var previews: some View {
        MoveActionButton()
    }
}
