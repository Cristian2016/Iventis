//
//  BubbleCell1.swift
//  BubblesSwiftUI
//
//  Created by Cristian Lapusan on 13.04.2022.
// https://stackoverflow.com/questions/58284994/swiftui-how-to-handle-both-tap-long-press-of-button
//

import SwiftUI

extension BubbleCell {
    enum Shape {
        case circle
        case square
    }
    
    ///3 Circles or Squares in the background
    var background: some View {
        HStack (spacing: BubbleCell.metrics.spacing) {
            //Hours
            shape.opacity(hrOpacity)
            //Minutes
            shape.opacity(minOpacity)
            //Seconds
            shape
        }
    }
    
    @ViewBuilder
    private var shape: some View {
        if bubble.hasWidget {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.bubble(for: bubble.color ?? "cyan"))
        } else {
            Circle()
                .fill(Color.bubble(for: bubble.color ?? "cyan"))
        }
    }
}

struct BubbleCell: View {
    // MARK: - Constants
    static var metrics = Metrics()
    
    // MARK: - Dependencies
    @StateObject var bubble:Bubble
    @EnvironmentObject private var viewModel:ViewModel
    
    let stickyNoteOffset = CGSize(width: 0, height: -6)
    
    // MARK: -
    @Environment(\.editMode) var editMode //used to toggle move rows
    
    @State private var isSecondsTapped = false
    @State private var isSecondsLongPressed = false
    
    // MARK: -
    init(_ bubble:Bubble) {
        _bubble = StateObject(wrappedValue: bubble)
        if !bubble.isObservingBackgroundTimer { bubble.observeBackgroundTimer() }
    }
    
    func handleLongPress() {
        UserFeedback.singleHaptic(.light)
        if bubble.note_.isEmpty { showNotesList() }
        else {
            bubble.isNoteHidden.toggle()
            PersistenceController.shared.save()
        }
    }
    
    func handleStickyNoteTap() {
        UserFeedback.singleHaptic(.light)
        showNotesList()
    }
        
    // MARK: -
    var body: some View {
        ZStack {
            background
//            let putTransparentGeometryReaderView = showDeleteActionView || showDetailView
//            if putTransparentGeometryReaderView {
//                cellLowEmitterView
//                    .background {
//                        GeometryReader {
//                            let value = BubbleCellLow_Key.RankFrame(rank: Int(bubble.rank), frame: $0.frame(in: .global))
//                            Color.clear.preference(key: BubbleCellLow_Key.self, value: value)
//                        }
//                    }
//            }
            
//            hrMinSecStack
//            if bubble.hasCalendar && noNote { calendarView }
//            if !noNote {
//                bubbleStickyNote
//                    .offset(stickyNoteOffset)
//                    .onTapGesture { handleStickyNoteTap() }
//            }
        }
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            
            //pin
            Button { viewModel.togglePin(bubble) }
        label: { Label { Text(bubble.isPinned ? "Unpin" : "Pin") }
            icon: { Image(systemName: bubble.isPinned ? "pin.slash.fill" : "pin.fill") } }
        .tint(bubble.isPinned ? .gray : .orange)
            
            //calendar
            Button {
                viewModel.toggleCalendar(bubble)
                CalendarManager.shared.shouldExportToCalendarAllSessions(of: bubble)
            }
        label: { Label { Text(calendarActionName) }
            icon: { Image(systemName: calendarActionImageName) } }
        .tint(calendarActionColor)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            //delete
            Button { viewModel.showDeleteAction_bRank = Int(bubble.rank)}
        label: { Label { Text("Delete") }
            icon: { Image.trash } }.tint(.red)
            
            //more options
            Button { viewModel.showMoreOptions(bubble) }
        label: { Label { Text("More") }
            icon: { Image(systemName: "ellipsis.circle.fill") } }.tint(.lightGray)
        }
    }
    
    private func presentDetail() {
        print(#function)
        viewModel.rankOfSelectedBubble = Int(bubble.rank)
    }
    
    // MARK: - Legoes
    private var hrMinSecStack:some View {
        ZStack {
            HStack (spacing: BubbleCell.metrics.spacing) {
                hoursView
                    .onTapGesture { presentDetail() }
                    .onLongPressGesture { handleLongPress() }
                    .zIndex(1)
                minutesView
                    .onTapGesture { withAnimation(.easeInOut(duration: 0.05)) {
                        editMode?.wrappedValue = .inactive
                        presentDetail()
                    } }
                    .onLongPressGesture { print("edit duration") }
                secondsView
                    .onTapGesture {
                        isSecondsTapped = true
                        delayExecution(.now() + 0.1) { isSecondsTapped = false }
                        
                        //feedback
                        UserFeedback.singleHaptic(.heavy)
                        
                        //user intent model
                        viewModel.toggleStart(bubble)
                    }
                    .onLongPressGesture {
                        isSecondsLongPressed = true
                        delayExecution(.now() + 0.25) { isSecondsLongPressed = false }
                        
                        //feedback
                        UserFeedback.doubleHaptic(.heavy)
                        
                        //user intent model
                        viewModel.endSession(bubble)
                    }
            }
            Text(bubble.bubbleCell_Components.min)
        }
        .frame(height: BubbleCell.metrics.circleDiameter)
        .font(.system(size: BubbleCell.metrics.fontSize))
        .foregroundColor(.white)
//        .onDrag { NSItemProvider() }
    }
    
    var hoursView : some View {
        circle
            .overlay { Text(bubble.bubbleCell_Components.hr) }
            .opacity(hrOpacity)
        //animations
            .scaleEffect(isSecondsLongPressed ? 0.2 : 1.0)
            .offset(x: isSecondsLongPressed ? 20 : 0.0, y: 0)
            .animation(.secondsLongPressed.delay(0.2), value: isSecondsLongPressed)
    }
    
    var minutesView : some View {
        circle //MINUTES
            .opacity(minOpacity)
        //animations
            .scaleEffect(isSecondsLongPressed ? 0.2 : 1.0)
            .offset(x: isSecondsLongPressed ? 10 : 0.0, y: 0)
            .animation(.secondsLongPressed.delay(0.1), value: isSecondsLongPressed)
    }
    
    var secondsView : some View {
        ZStack {
            circle //SECONDS
                .overlay { Text(bubble.bubbleCell_Components.sec) }
            //animations secondsTapped
                .scaleEffect(isSecondsTapped ? 0.6 : 1.0)
                .animation(.secondsTapped, value: isSecondsTapped)
            //animations seconds long pressed
                .scaleEffect(isSecondsLongPressed ? 0.2 : 1.0)
                .animation(.secondsLongPressed, value: isSecondsLongPressed)
            
            if !isBubbleRunning {
                Push(.bottomRight) {
                    hundredthsView
                        .onTapGesture {
                        UserFeedback.singleHaptic(.heavy)
                        viewModel.toggleStart(bubble)
                    }
                }
            }
        }
    }
    
    ////added to bubbleCell only if cellLow value is needed. ex: to know how to position DeleteActionView
    private var cellLowEmitterView: some View { Circle().fill(Color.clear) }
    
    ///hundredths of a second that is :)
    private var hundredthsView:some View {
        Text(bubble.bubbleCell_Components.cents)
            .background(Circle()
                .foregroundColor(Color("pauseStickerColor"))
                .padding(-12))
            .foregroundColor(Color("pauseStickerFontColor"))
            .font(.system(size: BubbleCell.metrics.hundredthsFontSize, weight: .semibold, design: .default))
        //animations:scale, offset and opacity
            .scaleEffect(isSecondsTapped && !isBubbleRunning ? 2 : 1.0)
            .offset(x: isSecondsTapped && !isBubbleRunning ? -20 : 0,
                    y: isSecondsTapped && !isBubbleRunning ? -20 : 0)
            .opacity(isSecondsTapped && !isBubbleRunning ? 0 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.2), value: isSecondsTapped)
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 6, trailing: 14))
            .zIndex(1)
    }
    
    private var calendarView:some View {
        VStack {
            HStack {
                CalendarSticker().offset(x: -10, y: -10)
                Spacer()
            }
            Spacer()
        }
    }
        
    private var bubbleStickyNote:some View {
        Push(.topLeft) {
            BubbleStickyNote()
                .environmentObject(viewModel)
                .environmentObject(bubble)
        }
    }
    
    private var circle: some View {
        Circle().fill(Color.bubble(for: bubble.color ?? "cyan"))
    }
    
    // MARK: - Methods
    ///show/hide DetailView
    fileprivate func toggleDetailView() {
        UserFeedback.singleHaptic(.medium)
        
        viewModel.rankOfSelectedBubble = Int(bubble.rank)
        
        //ask viewModel
        let rank = Int(bubble.rank)
        viewModel.userTogglesDetail(rank)
    }
    
    private var showDeleteActionView:Bool {
        guard let actionViewBubbleRank = viewModel.showDeleteAction_bRank else { return false }
        return bubble.rank == actionViewBubbleRank
    }
    
    private var showDetailView:Bool {
        guard let selectedBubbleRank = viewModel.rankOfSelectedBubble else { return false }
        return bubble.rank == selectedBubbleRank
    }
}

// MARK: - Modifiers
extension BubbleCell {
    struct TextModifier : ViewModifier {
        let fontSize:CGFloat
        let diameter:CGFloat
        
        func body(content: Content) -> some View {
            content
                .font(.system(size: fontSize))
                .foregroundColor(.white)
                .frame(width: diameter, height: diameter)
        }
    }
}

extension View {
    func textify(fontSize:CGFloat, diameter:CGFloat) -> some View { self.modifier(BubbleCell.TextModifier(fontSize: fontSize, diameter: diameter)) }
}

// MARK: - Little Helpers
extension BubbleCell {
    // MARK: - Helpers
    private func showNotesList () { viewModel.stickyNotesList_bRank = Int(bubble.rank) }
    
    private var calendarActionName:String { bubble.hasCalendar ? "Cal OFF" : "Cal ON" }
    
    private var calendarActionImageName:String { bubble.hasCalendar ? "calendar" : "calendar" }
    
    private var calendarActionColor:Color { bubble.hasCalendar ? Color.calendarOff : .calendar }
}

extension BubbleCell {
    var isInEditMode:Bool { editMode?.wrappedValue == .active }
    
    private var isBubbleRunning:Bool { bubble.state == .running }
    
    //stopwatch: minutes and hours stay hidden initially
    private var minOpacity:Double {
        bubble.bubbleCell_Components.min > "0" || bubble.bubbleCell_Components.hr > "0" ? 1 : 0.001
    }
    private var hrOpacity:Double { bubble.bubbleCell_Components.hr > "0" ? 1 : 0.001 }
    
    private var noNote:Bool { bubble.note_.isEmpty }
    
    ///circle diameter, font size, spacing and so on
    struct Metrics {
        var circleDiameter:CGFloat = {
            if UIDevice.isIPad {
                return 140
            } else {
               return CGFloat(UIScreen.main.bounds.size.width / 2.7)
            }
        }()
        let fontRatio = CGFloat(0.4)
        let spacingRatio = CGFloat(-0.28)
        
        lazy var spacing = circleDiameter * spacingRatio
        lazy var fontSize = circleDiameter * fontRatio
        lazy var hundredthsFontSize = circleDiameter / 6
    }
}
