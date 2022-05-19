//
//  Note.swift
//  Time Dots
//
//  Created by Cristian Lapusan on 08.04.2022.
//

import SwiftUI

struct BubbleStickyNote: View {
    let content:String
    let lineWidth:CGFloat
    let cornerRadius:CGFloat
    
    let ratio:CGFloat
    let height = CGFloat(42)
    
    @Binding var bubbleHasCalendar:Bool
    @State private var offset = CGSize.zero
    
    init(content:String, lineWidth:CGFloat = 3, radius:CGFloat = 0, _ bubbleHasCalendar:Binding<Bool>) {
        self.content = content
        self.ratio = (content.count < 8) ? CGFloat(2.8) : 2.8
        self.lineWidth = lineWidth
        self.cornerRadius = radius
        
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
            .offset(self.offset)
            .frame(width: height * ratio, height: height)
            .padding()
            .foregroundColor(.black)
            .gesture(
                DragGesture()
                    .onChanged {value in
                        withAnimation(.default) {
                            offset = value.translation
                        }
                    }
                    .onEnded { _ in
                        withAnimation(.spring()) { offset = .zero }
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
                .aspectRatio(ratio, contentMode: .fill)
                .cornerRadius(2)
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
        Text("Delete")
            .foregroundColor(.white)
            .font(.system(size: 26))
            .padding(EdgeInsets(top: 5, leading: 19, bottom: 5, trailing: 19))
            .background(
                Rectangle()
                    .fill((offset == .zero) ? .background1 : Color.red)
            )
    }
}

struct Note_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            BubbleStickyNote(content: "Workout", .constant(true))
        }
    }
}
