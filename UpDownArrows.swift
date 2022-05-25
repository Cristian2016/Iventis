//
//  DragAndDropActionView.swift
//  Timers
//
//  Created by Cristian Lapusan on 14.05.2022.
//

import SwiftUI

///Drag and Drop (Reaarange) bubbles
struct UpDownArrows: View {
    @Environment(\.editMode) var editMode
    
    ///how view is positioned on screen
    let padding = EdgeInsets(top: -8, leading: 0, bottom: 2, trailing: 8)
    
    let fontSize = CGFloat(40)
    
    var body: some View {
        Push(.topRight) { button }
        .padding(padding)
    }
    
    @ViewBuilder
    private var button:some View {
        Button { toggleEditMode() }
    label: {
        Label { }
    icon: {
        Image(systemName: "arrow.up.arrow.down.circle")
            .font(.system(size: fontSize).weight(.regular))
            .foregroundColor(editMode?.wrappedValue == .active ? .pink : .blue)
            .padding(5)
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.background1)
            }
    }
    }
    .tint(editMode?.wrappedValue == .active ? .pink : .blue)
    .buttonStyle(.borderless)
    }
    
    private func toggleEditMode() {
        withAnimation (.easeOut(duration: 0.2)) {
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
        UpDownArrows()
    }
}
