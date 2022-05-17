//
//  DragAndDropActionView.swift
//  Timers
//
//  Created by Cristian Lapusan on 14.05.2022.
//

import SwiftUI

struct RearrangeButton: View {
    @Environment(\.editMode) var editMode
    
    let fontSize = CGFloat(40)
    
    var body: some View {
        Push(.topRight) {
            button
        }
        .padding(EdgeInsets(top: -8, leading: 0, bottom: 2, trailing: 16))
        .zIndex(3)
    }
    
    @ViewBuilder
    private var button:some View {
        HStack {
            Button { toggleEditMode() }
        label: {
            Label {
//                Text(editMode?.wrappedValue == .active ? "Cancel" : "Move")
//                    .font(.title2)
            } icon: {
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
    }
    
    private func toggleEditMode() {
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
        RearrangeButton()
    }
}
