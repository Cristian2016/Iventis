//
//  PairCell1.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 30.01.2023.
//1 ex: if it's not @StateObject it will not update stickyNote content
// pair is actually the wrapped value. _pair is the StateObject struct
// @StateObject var pair:Pair means struct StateObject has a wrapped value of type Pair

import SwiftUI
import MyPackage

struct PairCell: View {
    @EnvironmentObject var viewModel:ViewModel
    @StateObject var pair:Pair //1
    let pairNumber:Int
    let duration:Float.TimeComponentsAsStrings?
    
    private let textPadding = EdgeInsets(top: 4, leading: 6, bottom: 4, trailing: 8)
    private let collapsedNoteWidth = CGFloat(50)
    
    var body:some View {
        if !pair.isFault {
            ZStack(alignment: .leading) {
                Push(.topRight) {
                    VStack(alignment: .trailing, spacing: 0) {
                        separatorLine
                        pairNumberView
                    }
                }
                .padding([.top], -4)
                .padding([.trailing], -16)
                
                VStack (alignment: .leading, spacing: 4) {
                    Rectangle()
                        .fill(.clear)
                        .frame(height: 10)
                    
                    pairStartView  //first line
                    pairPauseView //second line
                    if pair.pause == nil {
                        Push(.middle) {
                            PairBubbleCell(bubble: pair.session!.bubble!, metrics: BubbleCell.Metrics(BubbleCell.Metrics.width))
                        }
                        .padding([.top, .bottom])
                    }
                    else { durationView } //third line
                    
                    Spacer()
                }
                
                Push(.bottomRight) { stickyNote }
                    .padding([.trailing], -12)
            }
            .contentShape(gestureArea) //define gesture area
            .onTapGesture {  /* ⚠️ Idiotic! I need to put this shit here or else I can't scroll */ }
            .onLongPressGesture { userWantsNotesList() }
        }
    }
    
    // MARK: - Little Things
    
    private var gestureArea: some Shape { Rectangle().offset(x: 30) }
    
    private let metrics = Metrics()
    
    struct Metrics {
        //these two combined
        let durationFont = Font.system(size: 24, weight: .medium) //15 59 3
        let durationComponentsFont = Font.system(size: 22, weight: .medium) //h m s
        let pairNumberFont = Font.system(size: 18).weight(.medium)
    }
    
    @State private var noteDeleted:Bool = false
    @State private var offsetX:CGFloat = 0.0
    private let offsetDeleteTriggerLimit = CGFloat(180)
    private var triggerDeleteAction:Bool { abs(offsetX) >= offsetDeleteTriggerLimit }
    
    ///without delay the animation does not have time to take place
    //⚠️ not the best idea though...
    func deleteStickyNote() { viewModel.deleteStickyNote(for: pair) }
    
    var dragToDelete : some Gesture {
        DragGesture()
            .onChanged { value in
                withAnimation {
                    if !triggerDeleteAction {
                        offsetX = value.translation.width
                    } else {
                        if !noteDeleted {
                            deleteStickyNote()
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
                        deleteStickyNote()
                        noteDeleted = true
                        UserFeedback.singleHaptic(.light)
                    }
                }
            }
    }
    
    // MARK: - Lego
    private var stickyNote:some View {
        Push(.bottomRight) {//PairCell StickyNote
            StickyNote { stickyNoteContent }
            dragAction : { deleteStickyNote() }
            tapAction : { toggleStickyNoteVisibility() }
        }
    }
    private var stickyNoteContent:some View {
        stickyNoteText
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
    
    @ViewBuilder
    private var stickyNoteText:some View {
        if pair.isNoteHidden {
            Text("\(Image(systemName: "text.alignleft"))")
                .padding(textPadding)
                .font(.system(size: 20))
                .frame(width: collapsedNoteWidth)
        } else {
            Text(pair.note_.isEmpty ? "Something" : pair.note_)
        }
    }
    
    private var separatorLine:some View {
        Rectangle()
            .fill(Color.label)
            .frame(width: 30, height: 2)
    }
    
    private var pairNumberView:some View {
        Text(String(pairNumber)).font(metrics.pairNumberFont)
    }
    
    //start time and date
    private var pairStartView: some View {
        HStack(alignment: .firstTextBaseline) {
            //time
            Text(DateFormatter.time.string(from: pair.start ?? Date()))
                .font(.monospaced(.system(size: 22))())
            //date
            Text(DateFormatter.date.string(from: pair.start ?? Date()))
                .foregroundColor(.secondary)
        }
    }
    
    //pause time and date
    @ViewBuilder
    private var pairPauseView: some View {
        if let pause = pair.pause {
            let startAndPauseOnSameDay = DateFormatter.shortDate.string(from: pair.start!) == DateFormatter.shortDate.string(from: pause)
            
                HStack(alignment: .firstTextBaseline) {
                    Text(DateFormatter.time.string(from: pause))
                        .font(.monospaced(.system(size: 22))())
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
                        Text(duration.hr).font(metrics.durationFont)
                        Text("h").font(metrics.durationComponentsFont)
                    }
                }
                
                //min
                if duration.min != "0" {
                    HStack (alignment:.firstTextBaseline ,spacing: 0) {
                        Text(duration.min).font(metrics.durationFont)
                        Text("m").font(metrics.durationComponentsFont)
                    }
                }
                
                //sec
                HStack (alignment:.firstTextBaseline ,spacing: 0) {
                    Text(duration.sec + "." + duration.cents).font(metrics.durationFont)
                    Text("s").font(metrics.durationComponentsFont)
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
    private func userWantsNotesList() {
        UserFeedback.singleHaptic(.light)
        viewModel.pairOfNotesList = pair
        PersistenceController.shared.save()
    }
    
    ///show/hide Pair.note
    private func toggleStickyNoteVisibility() {
        UserFeedback.singleHaptic(.light)
        pair.isNoteHidden.toggle()
        PersistenceController.shared.save()
    }
}
