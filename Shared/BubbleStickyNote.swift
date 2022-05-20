//
//  BStickyNote.swift
//  Timers
//
//  Created by Cristian Lapusan on 19.05.2022.
//

import SwiftUI

struct BubbleStickyNote: View {
    @EnvironmentObject var bubble:Bubble
    @EnvironmentObject var viewModel:ViewModel
            
    private let stickyHeight = CGFloat(40)
    private let font = Font.system(size: 24)
    private let cornerRadius = CGFloat(2)
    private let textPadding = EdgeInsets(top: 4, leading: 6, bottom: 4, trailing: 6)
    
    @State private var noteDeleted = false
    // MARK: - Drag to delete
    @State private var offsetX = CGFloat(0)
    private let offsetDeleteTriggerLimit = CGFloat(140)
    private var triggerDeleteAction:Bool { offsetX > offsetDeleteTriggerLimit }
    
    // MARK: -
    var body: some View {
        ZStack (alignment: .leading) {
            //stickyNote
            HStack (spacing:0) {
                calendarSymbol
                stickyNoteContentView
            }
            .foregroundColor(.label)
            .background(background)
            .cornerRadius(cornerRadius)
            .shadow(color: .black.opacity(0.1), radius: 2, x: 2, y: 2)
            //offset controlled by the user via drag gesture
            .offset(x: offsetX, y: 0)
            //drag the view to delete
            .gesture(
                DragGesture()
                    .onChanged { value in
                        withAnimation {
                            if !triggerDeleteAction {
                                offsetX = value.translation.width
                            } else {
                                if !noteDeleted {
                                    viewModel.deleteNote(for: bubble)
                                    noteDeleted = true //block drag gesture.. any other better ideas??
                                    UserFeedback.singleHaptic(.light)
                                }
                            }
                        }
                    }
                    .onEnded { _ in
                        withAnimation (.spring()) { offsetX = 0 }
                    }
            )
        }
    }
    
    // MARK: - Lego
    private var calendarSymbol: some View {
        Rectangle()
            .fill(bubble.hasCalendar ? Color.calendar : .clear)
            .frame(width: bubble.hasCalendar ? 10 : 0, height: stickyHeight)
    }
    
    private var background: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color.bubble(for: bubble.color!))
                .scaleEffect(0.4)
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color.clear)
                .background(.thinMaterial)
        }
    }
    
    @ViewBuilder
    private var stickyNoteContentView: some View {
        if !bubble.isNoteHidden {
            Text(bubble.note_)
                .padding(textPadding)
                .font(font)
        } else {
            Text("\(Image(systemName: "text.alignleft"))")
                .padding(textPadding)
                .font(.system(size: 20))
        }
    }
}

struct BubbleStickyNote_Previews: PreviewProvider {
    static var previews: some View {
        BubbleStickyNote()
    }
}
