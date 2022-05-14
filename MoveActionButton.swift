//
//  DragAndDropActionView.swift
//  Timers
//
//  Created by Cristian Lapusan on 14.05.2022.
//

import SwiftUI

struct MoveActionButton: View {
    @Environment(\.editMode) var editMode
    
    let fontSize = CGFloat(35)
    let topPadding = CGFloat(24)
    static let height = CGFloat(74)
    
    var body: some View {
        HStack {
            Spacer()
            Button {
                toggleEditMode()
                
            } label: {
                Label {
                   Text(editMode?.wrappedValue == .active ? "Cancel" : "Reorder")
                        .font(.title2)
                } icon: {
                    Image(systemName: "arrow.up.arrow.down.circle.fill")
                        .font(.system(size: fontSize))
                        .foregroundColor(editMode?.wrappedValue == .active ? .red : .green)
                }
            }
            .tint(editMode?.wrappedValue == .active ? .red : .green)
            .buttonStyle(.bordered)
            Spacer()
        }
           
    }
    
    func toggleEditMode() {
        withAnimation {
            if editMode?.wrappedValue != .active {
                editMode?.wrappedValue = .active
            } else {
                editMode?.wrappedValue = .inactive
            }
        }
        UserFeedback.doubleHaptic(.light)
    }
}

struct DragAndDropActionButton_Previews: PreviewProvider {
    static var previews: some View {
        MoveActionButton()
    }
}
