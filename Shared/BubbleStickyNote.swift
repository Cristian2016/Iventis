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
    
    var body: some View {
        HStack (spacing:0) {
            Rectangle()
                .fill(bubble.hasCalendar ? Color.calendar : .clear)
                .frame(width: bubble.hasCalendar ? 10 : 0, height: stickyHeight)
            Text(bubble.note_)
                .padding(textPadding)
        }
        .foregroundColor(.label)
        .font(font)
        .background(background)
        .cornerRadius(cornerRadius)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 2, y: 2)
    }
    
    private var redCalendarSymbol:some View {
        HStack {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.calendar)
                .frame(width: 10)
            Spacer()
        }
    }
    
    private var background: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color.white)
                .scaleEffect(0.4)
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color.clear)
                .background(.thinMaterial)
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
    
    // MARK: -
    @State private var offsetX = CGFloat(0)
    private let offsetDeleteTriggerLimit = CGFloat(140)
    private var triggerDeleteAction:Bool { offsetX > offsetDeleteTriggerLimit }
}

struct BubbleStickyNote_Previews: PreviewProvider {
    static var previews: some View {
        BubbleStickyNote()
    }
}
