//
//  PairStickyNoteButton.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 29.06.2022.
// it is technically a control, maybe button is not the best word
// it has an action closure

import SwiftUI

struct PairStickyNoteButton: View {
    @ObservedObject var pair: Pair
    @State var offset = CGSize.zero
    
    var triggerPairDeleteAction:Bool { abs(offset.width) > 180 }
    var deleteLabelVisible:Bool { abs(offset.width) > 60 }
    @State var actionTriggered = false
    
    var action:() -> ()
    
    var body: some View {
        ZStack {
            
            Text(triggerPairDeleteAction ? "Done" : " Delete")
                .foregroundColor(.white)
                .font(.system(size: 24).weight(.medium))
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(triggerPairDeleteAction ? .green : .red)
                        .standardShadow(false)
                }
                .opacity(deleteLabelVisible ? 1 : 0)
            
            Text(pair.note ?? "No Note")
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.background)
                        .standardShadow(false)
                }
                .opacity(pair.note_.isEmpty ? 0 : 1)
                .offset(x: offset.width, y: offset.height)
                .gesture(drag)
        }
    }
    
    var drag: some Gesture {
        DragGesture()
            .onChanged {
                offset = $0.translation
                
                if triggerPairDeleteAction && !actionTriggered {
                    print("trigger delete action") //⚠️ must be printed only once
                    actionTriggered = true
                    action()
                    withAnimation(.easeInOut(duration: 2)) {
                        offset = .zero
                    }
                }
            }
            .onEnded { value in
                withAnimation { offset = .zero }
                if actionTriggered { actionTriggered = false }
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
