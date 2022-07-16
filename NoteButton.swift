//
//  PairStickyNoteButton.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 29.06.2022.
// it is technically a control, maybe button is not the best word
// it has an action closure
//1 transaction disables an animation

import SwiftUI

struct NoteButton<Content:View>: View {
    // MARK: - Data and Action
    let content: Content //what it displayes
    var dragAction:() -> () //user intent
    var tapAction:() -> ()
    let alignment:Alignment
    
    init(alignment: Alignment = .trailing, @ViewBuilder content: () -> Content, dragAction: @escaping () -> Void, tapAction: @escaping () -> Void) {
        self.content = content()
        self.dragAction = dragAction
        self.alignment = alignment
        self.tapAction = tapAction
    }
    
    // MARK: -
    @State var offsetX = CGFloat.zero
    @State var actionTriggered = false
    
    var triggerPairDeleteAction:Bool { abs(offsetX) > 180 }
    var deleteLabelVisible:Bool { abs(offsetX) > 60 }
    
    var dragGesture: some Gesture {
        DragGesture()
            .onChanged {
                offsetX = $0.translation.width
                
                //if statement must be executed only once!
                if triggerPairDeleteAction && !actionTriggered {
                    actionTriggered = true
                    UserFeedback.singleHaptic(.medium)
                    dragAction()
                    withAnimation(.easeInOut(duration: 2)) { offsetX = 0 }
                }
            }
            .onEnded { value in
                if actionTriggered {
                    delayExecution(.now() + 1.5) { offsetX = 0 }
                    actionTriggered = false
                }
                else { withAnimation { offsetX = 0 } }
            }
    }
    
    // MARK: -
    var body: some View {
        ZStack (alignment: alignment) {
            //"Delete"/"Done" Text
            deleteText
            content
                .offset(x: offsetX)
                //gestures
                .gesture(dragGesture)
                .onTapGesture { tapAction() }
        }
    }
    
    // MARK: -
    private var deleteText:some View {
        Text(triggerPairDeleteAction ?
             "\(Image(systemName: "checkmark")) Done"
             : "\(Image(systemName: "trash")) Delete"
        )
        .transaction { $0.animation = nil } //1
        .foregroundColor(.white)
        .font(.system(size: 24).weight(.medium))
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 2)
                .fill(triggerPairDeleteAction ? .green : .red)
                .transaction { $0.animation = nil } //1
                .frame(height: 44)
        }
        .opacity(deleteLabelVisible ? 1 : 0)
    }
}

//struct PairNoteButton_Previews: PreviewProvider {
//    static let pair:Pair = {
//        let pair = Pair(context: PersistenceController.shared.viewContext)
//        pair.note = "Pula Mea"
//        return pair
//    }()
//
//    static var previews: some View {
//        NoteButton(content: "Ok") {  /* delete action */ }
//    }
//}
