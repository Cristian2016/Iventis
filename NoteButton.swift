//
//  PairStickyNoteButton.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 29.06.2022.
// it is technically a control, maybe button is not the best word
// it has an action closure
//1 transaction disables an animation

import SwiftUI

struct NoteButton: View {
    // MARK: - Data and Action
    let content: String //what it displayes
    var action:() -> () //user intent
    
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
                    action()
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
        ZStack (alignment: .trailing) {
            //"Delete"/"Done" Text
            Text(triggerPairDeleteAction ?
                 "\(Image(systemName: "checkmark.circle")) Done"
                 : "\(Image(systemName: "trash"))  Delete"
            )
                .transaction { $0.animation = nil } //1
                .foregroundColor(.white)
                .font(.system(size: 24).weight(.medium))
                .padding()
//                .padding([.leading, .trailing], 4)
                .background {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(triggerPairDeleteAction ? .green : .red)
                        .transaction { $0.animation = nil } //1
                        .frame(height: 44)
                }
                .offset(y: 8)
                .opacity(deleteLabelVisible ? 1 : 0)
            
            //Note Text
            Text(content.isEmpty ? "Something" : content)
                .font(.system(size: 26))
                .padding([.leading, .trailing], 10)
                .background {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.background2)
                        .frame(height: 44)
                        .standardShadow(false)
                }
                .opacity(content.isEmpty ? 0 : 1)
                .offset(x: offsetX)
                .gesture(dragGesture)
        }
    }
}

struct PairNoteButton_Previews: PreviewProvider {
    static let pair:Pair = {
        let pair = Pair(context: PersistenceController.shared.viewContext)
        pair.note = "Pula Mea"
        return pair
    }()
    
    static var previews: some View {
        NoteButton(content: "Ok") {  /* delete action */ }
    }
}
