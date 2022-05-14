//
//  DragAndDropActionView.swift
//  Timers
//
//  Created by Cristian Lapusan on 14.05.2022.
//

import SwiftUI

struct DragAndDropActionButton: View {
    @Binding var userWantsToDragAndDropBubbles:Bool
    
    var body: some View {
        HStack {
            Spacer()
            Button {
                userWantsToDragAndDropBubbles.toggle()
                UserFeedback.doubleHaptic(.light)
            } label: {
                Label {
                    Text(userWantsToDragAndDropBubbles ? "~~Move~~" : "Move")
                        .font(.system(size: 26))
                } icon: {
                    Image(systemName: "arrow.up.arrow.down.circle.fill")
                        .font(.system(size: 30))
                }
            }
            .buttonStyle(.bordered)
            Spacer()
        }
           
    }
}

struct DragAndDropActionButton_Previews: PreviewProvider {
    static var previews: some View {
        DragAndDropActionButton(userWantsToDragAndDropBubbles: .constant(true))
    }
}
