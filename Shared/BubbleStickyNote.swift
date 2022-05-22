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
            
    private let stickyHeight = CGFloat(44)
    private let font = Font.system(size: 24)
    private let cornerRadius = CGFloat(2)
    private let textPadding = EdgeInsets(top: 4, leading: 6, bottom: 4, trailing: 8)
    
    @State private var noteDeleted = false
    
    // MARK: - Drag to delete
    @State private var offsetX = CGFloat(0)
    private let offsetDeleteTriggerLimit = CGFloat(180)
    private var triggerDeleteAction:Bool { offsetX >= offsetDeleteTriggerLimit }
    
    var dragGesture : some Gesture {
        DragGesture()
            .onChanged { value in
                withAnimation {
                    if !triggerDeleteAction {
                        offsetX = value.translation.width
                    } else {
                        if !noteDeleted {
                            deleteStickyWithDelay()
                            noteDeleted = true //block drag gesture.. any other better ideas??
                            UserFeedback.singleHaptic(.light)
                        }
                    }
                }
            }
            .onEnded { value in
                withAnimation {
                    if value.translation.width < offsetDeleteTriggerLimit {
                        //user lets go without deleting the sticky
                        //so sticky snaps back to its initial position
                        offsetX = 0
                    } else {
                        //user wants to delete sticky and goes all the way
                        //block drag gesture.. any other better ideas??
                        deleteStickyWithDelay()
                        noteDeleted = true
                        UserFeedback.singleHaptic(.light)
                    }
                }
            }
    }
    
    ///without delay the animation does not have time to take place
    //⚠️ not the best idea though...
    func deleteStickyWithDelay() {
        delayExecution(.now() + 1.5) {
            viewModel.deleteNote(for: bubble)
        }
    }
    
    // MARK: -
    var body: some View {
        if !bubble.isFault {
            ZStack (alignment: .leading) {
                deleteConfirmationLabel
                //stickyNote
                HStack (spacing:0) {
                    calendarSymbol
                    stickyNoteContentView
                }
                .foregroundColor(.label)
                .background(background)
                .cornerRadius(cornerRadius)
                .shadow(color:.black.opacity(0.1), radius: 2, x: 2, y: 2)
                //offset controlled by the user via drag gesture
                .offset(x: offsetX, y: 0)
                .opacity(triggerDeleteAction ? 0 : 1)
                //drag the view to delete
                .gesture(dragGesture)
            }
        }
    }
    
    private var deleteConfirmationLabel: some View {
        Rectangle()
            .fill(noteDeleted ? Color.green : .red)
            .frame(width: 124, height: 40)
            .overlay {
                Text(noteDeleted ? "Done" : "Delete")
                    .foregroundColor(.white)
                    .font(.system(size: 24).weight(.medium))
            }
            .opacity(offsetX > 60 ? 1 : 0)
            .offset(y: 10)
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
