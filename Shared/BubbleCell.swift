//
//  BubbleCell1.swift
//  BubblesSwiftUI
//
//  Created by Cristian Lapusan on 13.04.2022.
// https://stackoverflow.com/questions/58284994/swiftui-how-to-handle-both-tap-long-press-of-button


import SwiftUI

//Background
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
    
    @ViewBuilder //it has gradient
    private var secondsShape: some View {
        if bubble.hasWidget {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.bubbleColor(forName: bubble.color ?? "cyan"))
        } else {
            Circle()
                .fill(Color.bubbleColor(forName: bubble.color ?? "cyan").gradient)
        }
    }
    
    @ViewBuilder
    private var shape: some View {
        if bubble.hasWidget {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.bubbleColor(forName: bubble.color ?? "cyan"))
        } else {
            Circle()
                .fill(Color.bubbleColor(forName: bubble.color ?? "cyan"))
        }
    }
}

extension BubbleCell {
    var timeComponents: some View {
        HStack (spacing: BubbleCell.metrics.spacing) {
            //HOURS
            Circle().fill(Color.clear)
                .overlay { Text(bubble.bubbleCell_Components.hr) }
                .opacity(hrOpacity)
            //animations
                .scaleEffect(isSecondsLongPressed ? 0.2 : 1.0)
                .offset(x: isSecondsLongPressed ? 20 : 0.0, y: 0)
                .animation(.secondsLongPressed.delay(0.2), value: isSecondsLongPressed)
            //gestures
            .onTapGesture { userWantsDetailView() }
            .highPriorityGesture(
                LongPressGesture(minimumDuration: 0.3)
                    .onEnded { _ in
                        userWantsNotesList()
                    }
            )
            
            //MINUTES
            Circle().fill(Color.clear)
                .overlay { Text(bubble.bubbleCell_Components.min) }
                .opacity(minOpacity)
            //animations
                .scaleEffect(isSecondsLongPressed ? 0.2 : 1.0)
                .offset(x: isSecondsLongPressed ? 10 : 0.0, y: 0)
                .animation(.secondsLongPressed.delay(0.1), value: isSecondsLongPressed)
                //gestures
                .onTapGesture { userWantsDetailView() }
            
            //SECONDS
            ZStack {
                Circle().fill(Color.clear)
                    .overlay { Text(bubble.bubbleCell_Components.sec) }
                //animations
                    .scaleEffect(isSecondsLongPressed ? 0.2 : 1.0)
                    .animation(.secondsLongPressed, value: isSecondsLongPressed)
                //gestures
                    .onTapGesture { userTappedSeconds() }
                    .highPriorityGesture(longPress)
            }
            .overlay {
                if !isBubbleRunning {
                    Push(.bottomRight) {
                        hundredthsView
                            .onTapGesture { userTappedHundredths() }
                    }
                }
            }
        }
        .font(.system(size: BubbleCell.metrics.fontSize))
        .foregroundColor(.white)
    }
    
    //⚠️ if minDuration is 0.3, it has a shorter minDuration than onDrag, so it will work! Otherwise it doesn't
    var longPress: some Gesture {
        LongPressGesture(minimumDuration: 0.3)
            .onEnded { _ in userLongPressedSeconds() }
    }
}

struct BubbleCell: View {
    // MARK: - Constants
    static var metrics = Metrics()
    
    // MARK: - Dependencies
    @StateObject var bubble:Bubble
    @EnvironmentObject private var vm:ViewModel
    
    private let noteOffset = CGSize(width: 0, height: -6)
    
    // MARK: -
    @State private var isSecondsTapped = false
    @State private var isSecondsLongPressed = false
    
    // MARK: -
    init(_ bubble:Bubble) {
        _bubble = StateObject(wrappedValue: bubble)
        if !bubble.isObservingBackgroundTimer { bubble.observeBackgroundTimer() }
    }
    
    func userWantsNotesList() {
        UserFeedback.singleHaptic(.light)
        showNotesList()
        PersistenceController.shared.save()
    }
    
    func handleNoteTap() {
        UserFeedback.singleHaptic(.light)
        bubble.isNoteHidden.toggle()
        PersistenceController.shared.save()
    }
    
    // MARK: - Intents
    private func userTappedHours() { vm.rankOfSelectedBubble = Int(bubble.rank) }
    
    private func userTappedHundredths() {
        UserFeedback.singleHaptic(.heavy)
        vm.toggleStart(bubble)
    }
    
    private func userTappedSeconds() {
        isSecondsTapped = true
        delayExecution(.now() + 0.1) { isSecondsTapped = false }
        
        //feedback
        UserFeedback.singleHaptic(.heavy)
        
        //user intent model
        vm.toggleStart(bubble)
    }
    
    private func userLongPressedSeconds() {
        isSecondsLongPressed = true
        delayExecution(.now() + 0.25) { isSecondsLongPressed = false }
        
        //feedback
        UserFeedback.doubleHaptic(.heavy)
        
        //user intent model
        vm.endSession(bubble)
    }
    
    ///user taps minutes or hours
    private func userWantsDetailView() {
        if vm.rankOfSelectedBubble == nil {
            vm.rankOfSelectedBubble = Int(bubble.rank)
            vm.isDetailViewShowing = true
        }
    }
        
    // MARK: -
    var body: some View {
        ZStack {
            background
            timeComponents
            let putTransparentGeometryReaderView = showDeleteActionView || showDetailView
            if putTransparentGeometryReaderView {
                cellLowEmitterView
                    .background {
                        GeometryReader {
                            let value = BubbleCellLow_Key.RankFrame(rank: Int(bubble.rank), frame: $0.frame(in: .global))
                            Color.clear.preference(key: BubbleCellLow_Key.self, value: value)
                        }
                    }
            }
        }
        //subviews
        .overlay { if !noNote {
            bubbleNote
                .offset(noteOffset)
                .onTapGesture { handleNoteTap() }
        } } //noteView
        .overlay { if bubble.hasCalendar && noNote { calendarView } } //calendar symbol
        //gestures
        .onDrag { NSItemProvider() }
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            
            //pin
            Button { vm.togglePin(bubble) }
        label: { Label { Text(bubble.isPinned ? "Unpin" : "Pin") }
            icon: { Image(systemName: bubble.isPinned ? "pin.slash.fill" : "pin.fill") } }
        .tint(bubble.isPinned ? .gray : .orange)
            
            //calendar
            Button {
                vm.toggleCalendar(bubble)
                CalendarManager.shared.shouldCreateCalendarEventsForExistingSessions(of: bubble)
            }
        label: { Label { Text(calendarActionName) }
            icon: { Image(systemName: calendarActionImageName) } }
        .tint(calendarActionColor)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            //delete
            Button {
                vm.showDeleteAction_bRank = Int(bubble.rank)
                delayExecution(.now() + 0.2) {
                    vm.isDetailViewShowing = false
                }
            }
        label: { Label { Text("Delete") }
            icon: { Image.trash } }.tint(.red)
            
            //more options
            Button { vm.showMoreOptions(bubble) }
        label: { Label { Text("More") }
            icon: { Image(systemName: "ellipsis.circle.fill") } }.tint(.lightGray)
        }
    }
    
    // MARK: - Legoes
    ////added to bubbleCell only if cellLow value is needed. ex: to know how to position DeleteActionView
    private var cellLowEmitterView: some View {
        Circle()
        .fill(Color.clear)
        .frame(width: 10, height: 10)
    }
    
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
            .frame(width: 50, height: 50)
            .padding(BubbleCell.metrics.hundredthsInsets)
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
        
    private var bubbleNote:some View {
        Push(.topLeft) {
            BubbleNote().environmentObject(bubble)
        }
    }
    
    // MARK: - Methods
    ///show/hide DetailView
    fileprivate func toggleDetailView() {
        UserFeedback.singleHaptic(.medium)
        
        vm.rankOfSelectedBubble = Int(bubble.rank)
        
        //ask viewModel
        let rank = Int(bubble.rank)
        vm.userTogglesDetail(rank)
    }
    
    private var showDeleteActionView:Bool {
        guard let actionViewBubbleRank = vm.showDeleteAction_bRank else { return false }
        return bubble.rank == actionViewBubbleRank
    }
    
    private var showDetailView:Bool {
        guard let selectedBubbleRank = vm.rankOfSelectedBubble else { return false }
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
    private func showNotesList () { vm.notesList_bRank = Int(bubble.rank) }
    
    private var calendarActionName:String { bubble.hasCalendar ? "Cal OFF" : "Cal ON" }
    
    private var calendarActionImageName:String { bubble.hasCalendar ? "calendar" : "calendar" }
    
    private var calendarActionColor:Color { bubble.hasCalendar ? Color.calendarOff : .calendar }
}

extension BubbleCell {
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
        let fontRatio = CGFloat(0.42)
        let spacingRatio = CGFloat(-0.28)
        
        lazy var spacing = circleDiameter * spacingRatio
        lazy var fontSize = circleDiameter * fontRatio
        lazy var hundredthsFontSize = circleDiameter / 6
        
//        lazy var hundredthsInsets = EdgeInsets(top: 0, leading: 0, bottom: 14, trailing: 10)
        lazy var hundredthsInsets = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
    }
}
