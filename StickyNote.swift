//
//  PairStickyNoteButton.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 29.06.2022.
// it is technically a control, maybe button is not the best word
// it has an action closure
//1 transaction disables an animation

import SwiftUI
import MyPackage

struct StickyNote<Content:View>: View {
    // MARK: - Data and Action
    let alignment:Alignment
    
    let content: Content //what it displayes
    var dragAction:() -> () //user intent
    var tapAction:() -> ()
    
    init(
        alignment: Alignment = .trailing,
        @ViewBuilder content: () -> Content,
        dragAction: @escaping () -> Void,
        tapAction: @escaping () -> Void
    ) {
        self.alignment = alignment
        self.content = content()
        self.dragAction = dragAction //delete bubble/pair sticky note
        self.tapAction = tapAction
    }
    
    // MARK: -
    @State var offsetX = CGFloat.zero
    @State var deleteActionTriggered = false
    
    var deleteOffsetReached:Bool { abs(offsetX) > 250 }
    var deleteLabelVisible:Bool { abs(offsetX) > 60 }
    
    var dragGesture: some Gesture {
        DragGesture()
            .onChanged {
                offsetX = $0.translation.width
                
                //if statement must be executed only once!
                if deleteOffsetReached && !deleteActionTriggered {
                    deleteActionTriggered = true
                    UserFeedback.singleHaptic(.medium)
                    dragAction()
                    withAnimation(.easeInOut(duration: 2)) { offsetX = 0 }
                }
            }
            .onEnded { _ in
                if deleteActionTriggered {
                    delayExecution(.now() + 1.5) { offsetX = 0 }
                    deleteActionTriggered = false
                }
                else { withAnimation { offsetX = 0 } }
            }
    }
    
    // MARK: -
    var body: some View {
        ZStack (alignment: alignment) {
            //"Delete"/"Done" Text
            deleteConfirmationLabel  /* |🗑️ Delete| */
            content
                .offset(x: offsetX)
                //gestures
                .gesture(dragGesture)
                .onTapGesture { tapAction() }
        }
    }
    
    // MARK: -
    private var deleteConfirmationLabel:some View {
        Text(deleteOffsetReached ? "\(Image.checkmark) Done" : "\(Image.trash) Delete")
        .transaction { $0.animation = nil } //1
        .foregroundColor(.white)
        .font(.system(size: 24).weight(.medium))
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 2)
                .fill(deleteOffsetReached ? .green : .red)
                .transaction { $0.animation = nil } //1
                .frame(height: 44)
        }
        .opacity(deleteLabelVisible ? 1 : 0)
    }
}

struct DeleteConfirmationLabel: View {
    @State private var deleteOffsetReached = false
    @State private var deleteLabelVisible = false
    
    var body: some View {
        Text(deleteOffsetReached ? "\(Image.checkmark) Done" : "\(Image.trash) Delete")
        .transaction { $0.animation = nil } //1
        .foregroundColor(.white)
        .font(.system(size: 24).weight(.medium))
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 2)
                .fill(deleteOffsetReached ? .green : .red)
                .transaction { $0.animation = nil } //1
                .frame(height: 44)
        }
        .opacity(deleteLabelVisible ? 1 : 0)
    }
}
