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
    // MARK: - Dependencies
    @Environment(ViewModel.self) private var viewModel
    @StateObject var pair:Pair //1
        
    // MARK: -
    @State private var shouldShowPairBubbleCell = false
    
    // MARK: -
    let pairNumber:Int
    let duration:Float.TimeComponentsAsStrings?
    
    private let metrics = Metrics()
    
    private let textPadding = EdgeInsets(top: 4, leading: 6, bottom: 4, trailing: 8)
    private let collapsedNoteWidth = CGFloat(50)
    
    // MARK: -
    var body:some View {
        let isPairClosed = pair.pause != nil
        HStack {
            VStack (alignment: .leading, spacing: 6) {
                pairStartLabel
                pairPauseLabel
                if isPairClosed { pairDurationLabel }
                else { PairBubbleCell(bubble: pair.session?.bubble) }
            }
            Spacer()
        }
        .padding(.init(top: 14, leading: 10, bottom: 14, trailing: 0))
        .frame(maxWidth: .infinity)
        .overlay(alignment: .topTrailing) { pairNumberView }
        .overlay(alignment: .bottomTrailing) { stickyNote }
        .contentShape(gestureArea) //define gesture area
        .onTapGesture {  /* ⚠️ Idiotic! I need to put this shit here or else I can't scroll */ }
        .onLongPressGesture { showPairNotes() }
    }
    
    // MARK: - Little Things
    
    private var gestureArea: some Shape { Rectangle().offset(x: 30) }
    
    @State private var offsetX:CGFloat = 0.0
    private let offsetDeleteTriggerLimit = CGFloat(180)
    private var triggerDeleteAction:Bool { abs(offsetX) >= offsetDeleteTriggerLimit }
    
    ///without delay the animation does not have time to take place
    //⚠️ not the best idea though...
    func deleteStickyNote() { viewModel.deleteStickyNote(for: pair) }
    
    // MARK: - Lego
    private var stickyNote:some View {
        StickyNote { stickyNoteContent }
        dragAction : { deleteStickyNote() }
        tapAction : { toggleStickyNoteVisibility() }
    }
    
    private var stickyNoteContent:some View {
        stickyNoteText
            .font(.system(size: 26))
            .padding([.leading, .trailing], 10)
            .background {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.background1)
                    .frame(height: 44)
                    .shadow(color: .black.opacity(0.1), radius: 2, y: 2)
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
    
    private var pairNumberView:some View {
        VStack(alignment: .trailing, spacing: 0) {
            Rectangle()
                .fill(Color.lightGray)
                .frame(width: 20, height: 1)
            Text(String(pairNumber))
                .pairCountModifier()
        }
    }
    
    //start time and date
    private var pairStartLabel: some View {
        HStack(alignment: .firstTextBaseline) {
            //time
            Text(DateFormatter.time.string(from: pair.start ?? Date()))
            //date
            Text(DateFormatter.date.string(from: pair.start ?? Date()))
        }
        .font(.system(size: 22))
        .foregroundStyle(.secondary)
    }
    
    //pause time and date
    @ViewBuilder
    private var pairPauseLabel: some View {
        if let pause = pair.pause {
            let startAndPauseOnSameDay = DateFormatter.shortDate.string(from: pair.start ?? Date()) == DateFormatter.shortDate.string(from: pause)
            
            HStack(alignment: .firstTextBaseline) {
                Text(DateFormatter.time.string(from: pause))
                if !startAndPauseOnSameDay {
                    Text(DateFormatter.date.string(from: pause))
                }
            }
            .font(.system(size: 22))
            .foregroundStyle(.secondary)
        }
    }
    
    private var pairDurationLabel:some View {
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
                let sec = duration.sec + "." + duration.hundredths
                if sec != "0.00" {
                    HStack (alignment:.firstTextBaseline ,spacing: 0) {
                        Text(sec).font(metrics.durationFont)
                        Text("s").font(metrics.durationComponentsFont)
                    }
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
    private func showPairNotes() {
        HelpOverlay.Model.shared.topmostView(.lapNotes)
        UserFeedback.singleHaptic(.light)
        viewModel.notes_Pair = pair
    }
    
    ///show/hide Pair.note
    private func toggleStickyNoteVisibility() {
        UserFeedback.singleHaptic(.light)
        let bContext = PersistenceController.shared.bContext
        let objID = pair.objectID
        
        bContext.perform {
            let thisPair = PersistenceController.shared.grabObj(objID) as! Pair
            thisPair.isNoteHidden.toggle()
            PersistenceController.shared.save(bContext)
        }
    }
}

extension PairCell {
    struct Metrics {
        //these two combined
        let durationFont = Font.system(size: 22, weight: .medium) //15 59 3
        let durationComponentsFont = Font.system(size: 20, weight: .medium) //h m s
        let pairNumberFont = Font.system(size: 18).weight(.medium)
    }
}
