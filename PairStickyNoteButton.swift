//
//  PairStickyNoteButton.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 29.06.2022.
// it is technically a control, maybe button is not the best word
// it has an action closure
//1 transaction disables an animation

import SwiftUI

struct PairStickyNoteButton: View {
    @ObservedObject var pair: Pair
    @State var offsetX = CGFloat.zero
    
    var triggerPairDeleteAction:Bool { abs(offsetX) > 180 }
    var deleteLabelVisible:Bool { abs(offsetX) > 60 }
    @State var actionTriggered = false
    
    var action:() -> ()
    
    var body: some View {
        Push(.bottomRight) {
            ZStack {
                //"Delete"/"Done" Text
                Text(triggerPairDeleteAction ? "Done" : "Delete")
                    .transaction { transaction in
                        transaction.animation = nil
                    } //1
                    .foregroundColor(.white)
                    .font(.system(size: 24).weight(.medium))
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(triggerPairDeleteAction ? .green : .red)
                            .transaction { transaction in //1
                                transaction.animation = nil
                            }
                            .frame(width: 124, height: 44)
                    }
                    .offset(y: 8)
                    .opacity(deleteLabelVisible ? 1 : 0)
                    
                //Note Text
                Text(pair.note ?? "No Note")
                    .font(.system(size: 26))
                    .padding([.leading, .trailing], 10)
                    .background {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.background2)
                            .frame(height: 44)
                            .standardShadow(false)
                    }
                    .opacity(pair.note_.isEmpty ? 0 : 1)
                    .offset(x: offsetX)
                    .gesture(drag)
            }
        }
    }
    
    var drag: some Gesture {
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
}

struct PairStickyNoteButton_Previews: PreviewProvider {
    static let pair:Pair = {
        let pair = Pair(context: PersistenceController.shared.viewContext)
        pair.note = "Pula Mea"
        return pair
    }()
    
    static var previews: some View {
        PairStickyNoteButton(pair: pair) {  }
    }
}
