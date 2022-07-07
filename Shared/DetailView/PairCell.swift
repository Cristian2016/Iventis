//
//  PairCell.swift
//  Timers
//
//  Created by Cristian Lapusan on 02.05.2022.
//

import SwiftUI

struct PairCell: View {
    @EnvironmentObject var viewModel:ViewModel
    @StateObject var pair:Pair
    
    //sticky note deletion
    @State private var noteDeleted:Bool = false
    @State private var offsetX:CGFloat = 0.0
    private let offsetDeleteTriggerLimit = CGFloat(180)
    private var triggerDeleteAction:Bool { abs(offsetX) >= offsetDeleteTriggerLimit }
    
    ///without delay the animation does not have time to take place
    //⚠️ not the best idea though...
    func deleteNote() { viewModel.deleteNote(for: pair) }
    
    var dragToDelete : some Gesture {
        DragGesture()
            .onChanged { value in
                withAnimation {
                    if !triggerDeleteAction {
                        offsetX = value.translation.width
                    } else {
                        print("triggerDeleteAction")
                        if !noteDeleted {
                            deleteNote()
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
                        deleteNote()
                        noteDeleted = true
                        UserFeedback.singleHaptic(.light)
                    }
                }
            }
    }

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
                
                //like a button it has a closure for action
                Push(.bottomRight) {
                    NoteButton { noteButtonContent }
                    dragAction : { deleteNote() }
                    tapAction : {  }
                }
                .offset(y: 12)
            }
        }
    }
    
    // MARK: -
    private var noteButtonContent:some View {
        Text(pair.note_.isEmpty ? "Something" : pair.note_)
            .font(.system(size: 26))
            .padding([.leading, .trailing], 10)
            .background {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.background2)
                    .frame(height: 44)
                    .standardShadow(false)
            }
            .opacity(pair.note_.isEmpty ? 0 : 1)
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
            Text(DateFormatter.time.string(from: pair.start ?? Date()))
                .font(.monospaced(Font.system(size: 22))())
            Text(DateFormatter.date.string(from: pair.start ?? Date()))
                .foregroundColor(.secondary)
        }
    }
    
    //pause time and date
    @ViewBuilder
    private var pairPauseView: some View {
        if let pause = pair.pause {
            let startAndPauseOnSameDay = DateFormatter.shortDate.string(from: pair.start!) == DateFormatter.shortDate.string(from: pause)
            
                HStack {
                    Text(DateFormatter.time.string(from: pause))
                        .font(.monospaced(Font.system(size: 22))())
                    if !startAndPauseOnSameDay {
                        Text(DateFormatter.date.string(from: pause))
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
