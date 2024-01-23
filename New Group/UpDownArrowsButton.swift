//
//  DragAndDropActionView.swift
//  Timers
//
//  Created by Cristian Lapusan on 14.05.2022.
//

import SwiftUI
import MyPackage

///Drag and Drop (Reaarange) bubbles
struct UpDownArrowsButton: View {
    @Environment(\.editMode) var editMode
    
    ///how view is positioned on screen
    let padding = EdgeInsets(top: -4, leading: 0, bottom: 2, trailing: 12)
    let fontSize = CGFloat(30)
    
    // MARK: -
    var body: some View { button }
    
    // MARK: -
    private var button:some View {
        Button { toggleEditMode() }
    label: {
        Label { }
    icon: {
        Image(systemName: "arrow.up.arrow.down")
            .font(.system(size: fontSize).weight(.regular))
            .foregroundStyle(editMode?.wrappedValue == .active ? .pink : .blue)
    }
    }
    .tint(editMode?.wrappedValue == .active ? .pink : .blue)
    .buttonStyle(.borderless)
    }
    
    // MARK: - Methods
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
        UpDownArrowsButton()
    }
}
