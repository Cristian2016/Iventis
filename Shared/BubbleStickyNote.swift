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
        ZStack (alignment: .leading) {
            deleteOKView //the red view that turns green
            
            //stickyNote
            HStack (spacing:0) {
                calendarSymbol
                stickyNoteContentView
            }
            .foregroundColor(.label)
            .background(background)
            .cornerRadius(cornerRadius)
            .shadow(color: .black.opacity(0.1), radius: 2, x: 2, y: 2)
        }
    }
    
    // MARK: - Lego
    private var deleteOKView: some View {
        Text(!bubble.note_.isEmpty ? "Delete" : "Ok")
            .font(font)
            .padding(EdgeInsets(top: 5, leading: 12, bottom: 5, trailing: 12))
            .background(
                Rectangle()
                    .fill(!bubble.note_.isEmpty ? Color.red : .green)
            )
            .opacity(0)
    }
    
    private var calendarSymbol: some View {
        Rectangle()
            .fill(bubble.hasCalendar ? Color.calendar : .clear)
            .frame(width: bubble.hasCalendar ? 10 : 0, height: stickyHeight)
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
