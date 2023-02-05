//
//  BStickyNote.swift
//  Timers
//
//  Created by Cristian Lapusan on 19.05.2022.
//

import SwiftUI

struct BubbleNote: View {
    @EnvironmentObject var bubble:Bubble
    @EnvironmentObject var viewModel:ViewModel
            
    private let stickyHeight = CGFloat(44)
    private let font = Font.system(size: 24)
    private let cornerRadius = CGFloat(2)
    private let textPadding = EdgeInsets(top: 4, leading: 6, bottom: 4, trailing: 8)
    let collapsedNoteWidth = CGFloat(50)
    
    // MARK: -
    var body: some View {
        if !bubble.isFault {
            HStack (spacing:0) {
                calendarSymbol
                stickyNoteTextView
            }
            .foregroundColor(.label)
            .background(background)
            .cornerRadius(cornerRadius)
            .shadow(color: .black.opacity(0.1), radius: 2, y: 2)
        }
    }
    
    // MARK: - Lego 4
    @ViewBuilder
    private var calendarSymbol: some View {
        if !bubble.note_.isEmpty {
            Rectangle()
                .fill(bubble.hasCalendar ? Color.calendar : .clear)
                .frame(width: bubble.hasCalendar ? 10 : 0, height: stickyHeight)
        }
    }
    
    @ViewBuilder
    private var stickyNoteTextView: some View {
        if !bubble.note_.isEmpty {
            if !bubble.isNoteHidden {
                Text(bubble.note_)
                    .padding(textPadding)
                    .font(font)
            } else {
                Text("\(Image(systemName: "text.alignleft"))")
                    .padding(textPadding)
                    .font(.system(size: 20))
                    .frame(width: collapsedNoteWidth)
            }
        }
    }
    
    private var background: some View {
        ZStack {
//            RoundedRectangle(cornerRadius: cornerRadius)
//                .fill(Color.bubbleColor(forName: bubble.color!))
//                .scaleEffect(0.4)
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color.clear)
                .background(Color.background1)
        }
    }
}

struct BubbleStickyNote_Previews: PreviewProvider {
    static var previews: some View {
        BubbleNote()
    }
}
