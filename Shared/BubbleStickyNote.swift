//
//  Note.swift
//  Time Dots
//
//  Created by Cristian Lapusan on 08.04.2022.
//

import SwiftUI

struct BStickyNote: View {
    @EnvironmentObject var bubble:Bubble
    @EnvironmentObject var viewModel:ViewModel
    
    let content:String
    let cornerRadius = CGFloat(2)
    
    let height = CGFloat(42)
    
    @Binding var bubbleHasCalendar:Bool
    
    @State private var offsetX = CGFloat(0)
    private let offsetDeleteTriggerLimit = CGFloat(140)
    
    private var triggerDeleteAction:Bool { offsetX > offsetDeleteTriggerLimit }
    
    init(content:String, _ bubbleHasCalendar:Binding<Bool>) {
        self.content = content
        _bubbleHasCalendar = Binding(projectedValue: bubbleHasCalendar)
    }
    
    var body: some View {
        ZStack {
            deleteSymbol
            ZStack {
                HStack {
                    Spacer()
                    Label {
                        Text(content).foregroundColor(.label)
                        .font(.system(size: 24)) } icon: { }
                    Spacer()
                }
                .background(background)
                if bubbleHasCalendar { redCalendarSymbol }
            }
            .offset(x: self.offsetX, y: 0)
            .padding()
            .foregroundColor(.black)
            .gesture(
                DragGesture()
                    .onChanged {value in
                        if triggerDeleteAction { return }
                        
                        withAnimation(.default) {
                            offsetX = value.translation.width
                            if triggerDeleteAction {
                                UserFeedback.singleHaptic(.light)
                                viewModel.deleteNote(for: bubble)
                            }
                        }
                    }
                    .onEnded { _ in
                        withAnimation(.spring()) { offsetX = CGFloat(0) }
                    }
            )
        }
    }
    
    // MARK: -
    private var background: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color.white)
                .scaleEffect(0.4)
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color.clear)
                .background(.thinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 2, x: 2, y: 2)
        }
    }
    
    private var redCalendarSymbol:some View {
        HStack {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.calendar)
                .frame(width: 10)
            Spacer()
        }
    }
    
    private var deleteSymbol: some View {
        Text(triggerDeleteAction ? "Done" : "Delete")
            .foregroundColor(.white)
            .font(.system(size: 26))
            .padding(EdgeInsets(top: 5, leading: 19, bottom: 5, trailing: 19))
            .background(
                Rectangle()
                    .fill((offsetX == 0) ? .clear : ( triggerDeleteAction ? .green : Color.red))
            )
    }
}

//struct Note_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
//            BubbleStickyNote(content: "Workout", .constant(true))
//        }
//    }
//}
