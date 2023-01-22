//
//  BubbleCell1.swift
//  BubblesSwiftUI
//
//  Created by Cristian Lapusan on 13.04.2022.
// https://stackoverflow.com/questions/58284994/swiftui-how-to-handle-both-tap-long-press-of-button

import SwiftUI
import MyPackage

struct BubbleCell: View {
    // MARK: - Dependencies
    let metrics: Metrics
    @StateObject var bubble:Bubble
    @StateObject var sdb:SDB  /* I made
                               this one since apparently bubble.sdb.referenceDelay does not emit */
    @EnvironmentObject private var vm:ViewModel
    
    // MARK: - Body
    var body: some View {
//        let _ = Self._printChanges()
        
        VStack {
            ZStack {
                threeCircles //🔴🔴🔴
                threeLabels //⓿⓳➓
                let addPositionEmitterView = showDeleteActionView || showDetailView
                if addPositionEmitterView { cellLowEmitterView.background {
                    GeometryReader {
                        let value = BubbleCellLow_Key.RankFrame(rank: Int(bubble.rank), frame: $0.frame(in: .global))
                        Color.clear.preference(key: BubbleCellLow_Key.self, value: value)
                    }
                } }
            }
            //subviews
            .overlay { if bubble.hasCalendar && noNote { calendarSymbol }} //calSymbol
            .overlay {
                Push(.topLeft) {
                    StickyNote (alignment: .leading)
                    { noteButtonContent }
                dragAction: { vm.deleteStickyNote(for: bubble) }
                    tapAction : { handleNoteTap() }
                }
                .offset(y: -16)
            } //stickyNote
            .overlay {
                if confirm_CalEventCreated { CalEventCreatedConfirmationView() }
            } //event created confirmation
            .overlay {
                if !isBubbleRunning {
                    hundredthsView
                        .onTapGesture { userTappedHundredths() }
                }
            } //hundredths view
        }
        .listRowSeparator(.hidden)
        .onAppear { resumeObserveTimer() }
        //used to compute spacing
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
            
        }
          //gestures
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            
            //pin
            Button { vm.togglePin(bubble) }
        label: { Label { Text(bubble.isPinned ? "Unpin" : "Pin") }
            icon: { Image(systemName: bubble.isPinned ? "pin.slash.fill" : "pin.fill") } }
        .tint(bubble.isPinned ? .gray : .orange)
            
            //calendar
            Button { vm.toggleCalendar(bubble) }
        label: { Label { Text(calendarActionName) }
            icon: { Image(systemName: calendarActionImageName) } }
        .tint(calendarActionColor)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            //delete
            Button {
                vm.showDeleteAction_bRank = Int(bubble.rank)
                delayExecution(.now() + 0.2) { vm.isDetailViewShowing = false }
            }
        label: { Label { Text("Delete") }
            icon: { Image.trash } }.tint(.red)
            
            //more options
            Button { vm.showMoreOptions(for: bubble) }
        label: { Label { Text("More") }
            icon: { Image(systemName: "ellipsis.circle.fill") } }.tint(.lightGray)
        }
    }
    
    // MARK: - Legos
    ///timeComponentsView background
    private var threeCircles: some View {
        HStack (spacing: metrics.spacing) {
            /* Hr */ bubbleShape.opacity(hrOpacity)
            /* Min */ bubbleShape.opacity(minOpacity)
            /* Sec */ bubbleShape
        }
    }
    
    private var threeLabels: some View {
        HStack (spacing: metrics.spacing) {
            //HOURS
            Circle().fill(Color.clear)
                .overlay { Text(bubble.components.hr) }
                .opacity(hrOpacity)
            //animations
                .scaleEffect(isSecondsLongPressed ? 0.2 : 1.0)
                .offset(x: isSecondsLongPressed ? 20 : 0.0, y: 0)
                .animation(.secondsLongPressed.delay(0.2), value: isSecondsLongPressed)
            //gestures
                .onTapGesture { toggleBubbleDetail() }
                .onLongPressGesture { showNotesList() }
            
            //MINUTES
            Circle().fill(Color.clear)
                .overlay { Text(bubble.components.min) }
                .opacity(minOpacity)
            //animations
                .scaleEffect(isSecondsLongPressed ? 0.2 : 1.0)
                .offset(x: isSecondsLongPressed ? 10 : 0.0, y: 0)
                .animation(.secondsLongPressed.delay(0.1), value: isSecondsLongPressed)
                //gestures
                .onTapGesture { toggleBubbleDetail() }
            
            //SECONDS
            Circle().fill(Color.clear)
                .contentShape(Circle())
                .overlay { Text(bubble.components.sec) }
            //animations
                .scaleEffect(isSecondsLongPressed ? 0.2 : 1.0)
                .animation(.secondsLongPressed, value: isSecondsLongPressed)
            //gestures
                .gesture(tap)
                .gesture(longPress)
            //overlays
                .overlay {
                    if sdb.referenceDelay > 0 { SDButton(bubble.sdb) }
                }
        }
        //font
        .font(.system(size: metrics.timeComponentsFontSize))
        .foregroundColor(.white)
    }
    
    private var hundredthsView:some View {
        Push(.bottomRight) {
            Text(bubble.components.cents)
                .background(Circle()
                    .foregroundColor(Color("pauseStickerColor"))
                    .padding(-12))
                .foregroundColor(Color("pauseStickerFontColor"))
                .font(.system(size: metrics.hundredthsFontSize, weight: .semibold, design: .default))
            //animations:scale, offset and opacity
                .scaleEffect(isSecondsTapped && !isBubbleRunning ? 2 : 1.0)
                .offset(x: isSecondsTapped && !isBubbleRunning ? -20 : 0,
                        y: isSecondsTapped && !isBubbleRunning ? -20 : 0)
                .opacity(isSecondsTapped && !isBubbleRunning ? 0 : 1)
                .animation(.spring(response: 0.3, dampingFraction: 0.2), value: isSecondsTapped)
                .frame(width: 50, height: 50)
                .zIndex(1)
        }
    }
    
    private var noteButtonContent:some View {
        BubbleNote().environmentObject(bubble)
    }
    
    private var cellLowEmitterView: some View {
        Circle()
            .fill(Color.clear)
            .frame(width: 10, height: 10)
    }
    
    private var calendarSymbol:some View {
        VStack {
            HStack {
                CalendarSticker().offset(x: -10, y: -10)
                Spacer()
            }
            Spacer()
        }
        .padding([.leading], 4)
    }
    
    // MARK: - Gestures
    private var tap:some Gesture { TapGesture().onEnded { _ in userTappedSeconds() } }
    private var longPress: some Gesture {
        LongPressGesture(minimumDuration: 0.3)
            .updating($isDetectingLongPress, body: { currentState, gestureState, _ in
                /* ⚠️ it does not work on .gesture(longPress) modifier. use maybe .simultaneousGesture or .highPriority */
                gestureState = currentState
                print("updating")
            })
            .onEnded { _ in
                endSession()
            }
    }
    
    // MARK: - Internal
    @GestureState var isDetectingLongPress = false
        
    private let noteOffset = CGSize(width: 0, height: -6)
    
    @State private var isSecondsTapped = false
    @State private var isSecondsLongPressed = false
    
    // MARK: -
    init(_ bubble:Bubble, metrics:Metrics) {
        _bubble = StateObject(wrappedValue: bubble)
        _sdb = StateObject(wrappedValue: bubble.sdb!)
        self.metrics = metrics
    }
    
    func handleNoteTap() {
        UserFeedback.singleHaptic(.light)
        bubble.isNoteHidden.toggle()
        PersistenceController.shared.save()
    }
    
    // MARK: - User Intents
    /*
     when cell appears bubbleCell will resume observing timer. if it doesn't resume, correct time will not be displayed to the user */
    private func resumeObserveTimer() /* onAppear */ { vm.addObserver(for: bubble) }
    
    private func endSession() {
        isSecondsLongPressed = true
        delayExecution(.now() + 0.25) { isSecondsLongPressed = false }
        
        //feedback
        UserFeedback.doubleHaptic(.heavy)
        
        //user intent model
        vm.endSession(bubble)
    }
    
    ///user taps minutes or hours to show/hide a DetailView of the tapped [selected] bubble
    private func toggleBubbleDetail() {
//        vm.rankOfSelectedBubble = Int(bubble.rank)
        vm.isDetailViewShowing = true
        vm.path = vm.path.isEmpty ? [bubble] : []
    }
    
    //Start/Pause Bubble 2 ways
    /* 1 */private func userTappedHundredths() {
        UserFeedback.singleHaptic(.heavy)
        vm.toggleBubbleStart(bubble)
    }
    
    /* 2 */private func userTappedSeconds() {
        isSecondsTapped = true
        delayExecution(.now() + 0.1) { isSecondsTapped = false }
        
        //feedback
        UserFeedback.singleHaptic(.heavy)
        
        //user intent model
        vm.toggleBubbleStart(bubble)
}
    
    ///long press on hours to show the notes list
    func showNotesList() {
        UserFeedback.singleHaptic(.light)
        vm.notesList_bRank = Int(bubble.rank)
        PersistenceController.shared.save()
    }
    
    // MARK: - Methods
    private var showDeleteActionView:Bool {
        guard let actionViewBubbleRank = vm.showDeleteAction_bRank else { return false }
        return bubble.rank == actionViewBubbleRank
    }
    
    private var showDetailView:Bool {
        guard let selectedBubbleRank = vm.rankOfSelectedBubble else { return false }
        return bubble.rank == selectedBubbleRank
    }
    
    // MARK: -
    var confirm_CalEventCreated:Bool { vm.confirm_CalEventCreated == bubble.rank }
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
    private var calendarActionName:String { bubble.hasCalendar ? "Cal OFF" : "Cal ON" }
    
    private var calendarActionImageName:String { bubble.hasCalendar ? "calendar" : "calendar" }
    
    private var calendarActionColor:Color { bubble.hasCalendar ? Color.calendarOff : .calendar }
}

extension BubbleCell {
    private var isBubbleRunning:Bool { bubble.state == .running }
    
    //stopwatch: minutes and hours stay hidden initially
    private var minOpacity:Double {
        bubble.components.min > "0" || bubble.components.hr > "0" ? 1 : 0.001
    }
    private var hrOpacity:Double { bubble.components.hr > "0" ? 1 : 0.001 }
    
    private var noNote:Bool { bubble.note_.isEmpty  }
    
    ///circle diameter, font size, spacing and so on
    struct Metrics {
        init(width:CGFloat) {
            self.spacing = width * -0.18
            self.timeComponentsFontSize = width * CGFloat(0.16)
            self.hundredthsFontSize = width * CGFloat(0.06)
        }
        
        let spacing:CGFloat
        let timeComponentsFontSize:CGFloat
        let hundredthsFontSize:CGFloat
    }
}

//Background
extension BubbleCell {
    ///either circle or square. Square means bubble has a widget
    enum BubbleShape {
        case circle
        case square
    }
    
    ///either a circle or a square
    @ViewBuilder
    private var bubbleShape: some View {
        if bubble.hasWidget {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.bubbleColor(forName: bubble.color))
        } else {
            Circle()
                .fill(Color.bubbleColor(forName: bubble.color))
        }
    }
}
