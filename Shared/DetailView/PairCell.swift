//
//  PairCell.swift
//  Timers
//
//  Created by Cristian Lapusan on 02.05.2022.
//

import SwiftUI

struct PairCell: View {
    //sticky note deletion
    @State private var noteDeleted:Bool = false
    @State private var offsetX:CGFloat = 0.0
    private let offsetDeleteTriggerLimit = CGFloat(180)
    private var triggerDeleteAction:Bool { offsetX >= offsetDeleteTriggerLimit }
    
    ///without delay the animation does not have time to take place
    //⚠️ not the best idea though...
    func deleteStickyWithDelay() {
        delayExecution(.now() + 1.5) {
            viewModel.deleteNote(for: pair)
        }
    }
    
    var dragToDelete : some Gesture {
        DragGesture()
            .onChanged { value in
                withAnimation {
                    if !triggerDeleteAction {
                        offsetX = value.translation.width
                    } else {
                        if !noteDeleted {
                            deleteStickyWithDelay()
                            noteDeleted = true //block drag gesture.. any other better ideas??
                            UserFeedback.singleHaptic(.light)
                        }
                    }
                }
            }
            .onEnded { value in
                withAnimation {
                    if value.translation.width < offsetDeleteTriggerLimit {
                        offsetX = 0
                    } else {
                        noteDeleted = true
                        UserFeedback.singleHaptic(.light)
                    }
                }
            }
    }
    
    @EnvironmentObject var viewModel:ViewModel
    @StateObject var pair:Pair
    let duration:Float.TimeComponentsAsStrings?
    let pairNumber:Int
    
    // MARK: - Little Things
    let contentFrameGap = CGFloat(4) //how much gap between content and its enclosing frame
    let durationFont = Font.system(size: 22, weight: .medium, design: .default)
    let durationComponentsFont = Font.system(size: 19, weight: .medium, design: .default)
    
    var body: some View {
        if !pair.isFault {
            ZStack {
                //PairCell
                VStack (alignment: .leading) {
                    separatorLine.overlay { pairNumberView }
                    pairStartView  //first line
                    pairPauseView //seconds line
                    if pair.pause == nil {
                        HStack {
                            Spacer()
                            SmallBubbleView(bubble: pair.session!.bubble!)
                            Spacer()
                        }
                    }
                    else { durationView } //third line
                }
                .padding(contentFrameGap)
                //gesture
                .contentShape(gestureArea) //define gesture area
                .highPriorityGesture(longPress)
                
                if let note = pair.note_, !note.isEmpty { noteViewAndBackground }
            }
        }
    }
    
    // MARK: -
    //avoid trigger longPress gesture and edge swipe simultaneously
    //the entire gesture area is shifted right by 30 points
    var gestureArea: some Shape { Rectangle().offset(x: 30) }
    
    //show stickyNotes list
    private var longPress: some Gesture {
        LongPressGesture(minimumDuration: 0.3)
            .onEnded { _ in userWantsNotesList() }
    }
    
    // MARK: - LEGO
    private var noteViewAndBackground: some View {
        Push(.bottomRight) {
            ZStack {
                DeleteConfirmationLabel(noteDeleted: $noteDeleted, offsetX: $offsetX)
                noteView
                    .offset(x: offsetX)
                    .gesture(dragToDelete)
            }
        }
    }
    
    private var noteView: some View {
        Text("\(pair.note_)").font(.title2)
            .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
            .background(
                Rectangle()
                    .fill(Color.background)
                    .standardShadow(false)
            )
    }
    
    private var pairNumberView: some View {
        HStack {
            Spacer()
            Text("\(pairNumber)")
                .foregroundColor(.label)
                .font(.system(size: 18).weight(.medium))
                .offset(x: 10, y: 14)
        }
    }
    
    private var separatorLine: some View {
        HStack {
            Spacer()
            Rectangle()
                .fill(Color.label)
                .frame(width: 30, height: 2)
                .offset(x: 14, y: -4)
        }
    }
    
    //start time and date
    private var pairStartView: some View {
        HStack {
            Text(DateFormatter.bubbleStyleTime.string(from: pair.start ?? Date()))
                .font(.monospaced(Font.system(size: 22))())
            Text(DateFormatter.bubbleStyleDate.string(from: pair.start ?? Date()))
                .foregroundColor(.secondary)
        }
    }
    
    //pause time and date
    @ViewBuilder
    private var pairPauseView: some View {
        if let pause = pair.pause {
            let startAndPauseOnSameDay = DateFormatter.bubbleStyleShortDate.string(from: pair.start!) == DateFormatter.bubbleStyleShortDate.string(from: pause)
            
                HStack {
                    Text(DateFormatter.bubbleStyleTime.string(from: pause))
                        .font(.monospaced(Font.system(size: 22))())
                    if !startAndPauseOnSameDay {
                        Text(DateFormatter.bubbleStyleDate.string(from: pause))
                            .foregroundColor(.secondary)
                    }
                }
        }
    }
    
    private var durationView:some View {
        HStack (spacing: 8) {
            if let duration = duration {
                //hr
                if duration.hr != "0" {
                    HStack (alignment:.firstTextBaseline ,spacing: 0) {
                        Text(duration.hr).font(durationFont)
                        Text("h").font(durationComponentsFont)
                    }
                }
                
                //min
                if duration.min != "0" {
                    HStack (alignment:.firstTextBaseline ,spacing: 0) {
                        Text(duration.min).font(durationFont)
                        Text("m").font(durationComponentsFont)
                    }
                }
                
                //sec
                HStack (alignment:.firstTextBaseline ,spacing: 0) {
                    Text(duration.sec + "." + duration.cents).font(durationFont)
                    Text("s").font(durationComponentsFont)
                }
            }
        }
    }
    
    // MARK: -
    init(_ pair:Pair, _ pairNumber:Int) {
        _pair = StateObject(wrappedValue: pair)
        let decoder = JSONDecoder()
        let result = try? decoder.decode(Float.TimeComponentsAsStrings.self, from: pair.durationAsStrings ?? Data())
        self.duration = result
        self.pairNumber = pairNumber
    }
    
    // MARK: - Intents
    func userWantsNotesList() {
        UserFeedback.singleHaptic(.light)
        viewModel.pairOfNotesList = pair
        PersistenceController.shared.save()
    }
}
