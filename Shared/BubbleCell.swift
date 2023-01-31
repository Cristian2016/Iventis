//
//  BubbleCell1.swift
//  BubblesSwiftUI
//
//  Created by Cristian Lapusan on 13.04.2022.
// https://stackoverflow.com/questions/58284994/swiftui-how-to-handle-both-tap-long-press-of-button
//1 do not show stickyNote when calEventCreatedConfirmation is visible. for aesthetic reasons only

import SwiftUI
import MyPackage

struct BubbleCell: View {
    ///padding with respect to the list edges so that it comes closer to the edges of the screen
    static let padding = EdgeInsets(top: 0, leading: -12, bottom: 0, trailing: -12)
    
    let metrics: Metrics
    @StateObject private var bubble:Bubble
    @StateObject private var startDelayBubble:StartDelayBubble
    
    @EnvironmentObject private var viewModel:ViewModel
    @EnvironmentObject private var layoutViewModel:LayoutViewModel
        
    // MARK: - Body
    var body: some View {
        VStack {
            ZStack {
                threeCircles //🔴🔴🔴
                threeLabels //⓿⓳➓
            }
//            //subviews
            .overlay { if bubble.hasCalendar && noNote { calendarSymbol }}
            .overlay { stickyNote }
            
            .overlay { if confirm_CalEventCreated { calEventCreatedConfirmation }} //1
            .overlay { if confirm_CalEventRemoved { calEventRemovedConfirmation }} //1
            
            .overlay { if !isBubbleRunning { hundredthsView }}
            
            if viewModel.fiveSeconds_bRank == bubble.rank { fiveSecondsBar }
        }
        .listRowSeparator(.hidden)
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            toggleFavoriteButton
            toggleCalendarButton
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            deleteActionButton
            moreOptionsButton
        }
        .onAppear { bubble.addObserver() }
    }
    
    // MARK: - Legos
    private var fiveSecondsBar:some View {
        HStack {
            BorderlessLabel(title: "Undo Start", symbol: "arrow.uturn.backward")
                .onTapGesture {
                    print("Undo Start")
                }
            Divider().frame(height: 20)
            BorderlessLabel(title: "Add Tag", symbol: "tag")
                .onTapGesture {
                    print("Add Tag")
                }
        }
        .font(.title)
    }
    
    private var calEventCreatedConfirmation:some View {
        Push(.leading) {
            ConfirmView(content: .eventCreated)
        }
    }
    private var calEventRemovedConfirmation:some View {
        Push(.leading) {
            ConfirmView(content: .eventRemoved)
        }
    }
    
    //Leading Swipe actions
    private var toggleFavoriteButton:some View {
        Button { viewModel.togglePin(bubble) }
    label: { Label { Text(bubble.isPinned ? "Unpin" : "Pin") }
        icon: { Image(systemName: bubble.isPinned ? "pin.slash.fill" : "pin.fill") } }
    .tint(bubble.isPinned ? .gray : .orange)
    }
    private var toggleCalendarButton:some View {
        Button { viewModel.toggleCalendar(bubble) }
    label: { Label { Text(calendarActionName) }
        icon: { Image(systemName: calendarActionImageName) } }
    .tint(calendarActionColor)
    }
    
    //trailing Swipe actions
    private var deleteActionButton:some View {
        Button {
            viewModel.deleteAction_bRank = bubble.rank
//            delayExecution(.now() + 0.2) { vm.isDetailViewShowing = false }
        }
    label: { Label { Text("Delete") }
        icon: { Image.trash } }.tint(.red)
    }
    private var moreOptionsButton:some View {
        Button { viewModel.showMoreOptions(for: bubble) }
    label: { Label { Text("More") }
        icon: { Image(systemName: "ellipsis.circle.fill") } }.tint(.lightGray)
    }
    
    ///time components [threeLabels] background
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
//            //animations
                .scaleEffect(isSecondsLongPressed ? 0.2 : 1.0)
                .animation(.secondsLongPressed, value: isSecondsLongPressed)
//            //gestures
                .gesture(tap)
                .gesture(longPress)
//            //overlays
                .overlay {
                    if startDelayBubble.referenceDelay > 0 { SDButton(bubble.sdb) }
                }
        }
        //font
        .font(.system(size: metrics.timeComponentsFontSize))
        .fontDesign(.rounded)
        .foregroundColor(.white)
    }
    
    private var hundredthsView:some View {
        Push(.bottomRight) {
            Text(bubble.components.cents)
                .padding()
                .background(Circle().foregroundColor(.pauseStickerColor))
                .foregroundColor(.pauseStickerFontColor)
                .font(.system(size: metrics.hundredthsFontSize, weight: .semibold, design: .rounded))
            //animations:scale, offset and opacity
                .scaleEffect(isSecondsTapped && !isBubbleRunning ? 2 : 1.0)
                .offset(x: isSecondsTapped && !isBubbleRunning ? -20 : 0,
                        y: isSecondsTapped && !isBubbleRunning ? -20 : 0)
                .opacity(isSecondsTapped && !isBubbleRunning ? 0 : 1)
                .animation(.spring(response: 0.3, dampingFraction: 0.2), value: isSecondsTapped)
                .zIndex(1)
                .onTapGesture { userTappedHundredths() }
        }
    }
    
    private var noteButtonContent:some View {
        BubbleNote().environmentObject(bubble)
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
    
    private var stickyNote:some View {
        Push(.topLeft) {
            StickyNote (alignment: .leading)
            { noteButtonContent }
        dragAction: { viewModel.deleteStickyNote(for: bubble) }
            tapAction : { handleNoteTap() }
        }
        .offset(y: -16)
    }
    
    // MARK: - Gestures
    private var tap:some Gesture { TapGesture().onEnded { _ in userTappedSeconds() }}
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
    init(_ bubble:Bubble, _ metrics:Metrics) {
        _bubble = StateObject(wrappedValue: bubble)
        _startDelayBubble = StateObject(wrappedValue: bubble.sdb!)
        self.metrics = metrics
    }
    
    func handleNoteTap() {
        UserFeedback.singleHaptic(.light)
        bubble.isNoteHidden.toggle()
        PersistenceController.shared.save()
    }
    
    // MARK: - User Intents
    private func endSession() {
        isSecondsLongPressed = true
        delayExecution(.now() + 0.25) { isSecondsLongPressed = false }
        
        //feedback
        UserFeedback.doubleHaptic(.heavy)
        
        //user intent model
        viewModel.endSession(bubble)
    }
    
    ///user taps minutes or hours to show/hide a DetailView of the tapped [selected] bubble
    private func toggleBubbleDetail() {
//        vm.rankOfSelectedBubble = Int(bubble.rank)
        viewModel.isDetailViewShowing = true
        viewModel.path = viewModel.path.isEmpty ? [bubble] : []
    }
    
    //Start/Pause Bubble 2 ways
    /* 1 */private func userTappedHundredths() {
        UserFeedback.singleHaptic(.heavy)
        viewModel.toggleBubbleStart(bubble)
    }
    
    /* 2 */private func userTappedSeconds() {
        isSecondsTapped = true
        delayExecution(.now() + 0.1) { isSecondsTapped = false }
        
        //feedback
        UserFeedback.singleHaptic(.heavy)
        
        //user intent model
        viewModel.toggleBubbleStart(bubble)
}
    
    ///long press on hours to show the notes list
    func showNotesList() {
        UserFeedback.singleHaptic(.light)
        viewModel.notesList_bRank = Int(bubble.rank)
        PersistenceController.shared.save()
    }
    
    // MARK: - Methods
    private var showDetailView:Bool {
        guard let selectedBubbleRank = viewModel.rankOfSelectedBubble else { return false }
        return bubble.rank == selectedBubbleRank
    }
    
    // MARK: -
    var confirm_CalEventCreated:Bool { viewModel.confirm_CalEventCreated == bubble.rank }
    var confirm_CalEventRemoved:Bool { viewModel.confirm_CalEventRemoved == bubble.rank }
    
    ///show bubbleCell.frame if it's the same rank and the frame is not set and detailView does not show. In the Detailview there is no need to compute deleteActionView.yOffset
    private var computeBubbleCellFrame:Bool {
        viewModel.deleteAction_bRank == bubble.rank
    }
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
        static var width:CGFloat = 0
        
        init(_ width:CGFloat) {
            self.spacing = width * -0.18
            self.timeComponentsFontSize = width * CGFloat(0.16)
            self.hundredthsFontSize = width * CGFloat(0.06)
            Metrics.width = width
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

//struct BubbleCell_Previews: PreviewProvider {
//    static let bubble:Bubble = {
//        let bubble = Bubble(context: PersistenceController.preview.viewContext)
//        bubble.color = "red"
//        bubble.currentClock = 340
//        bubble.kind = .stopwatch
//        bubble.initialClock = 0
//        bubble.sdb = StartDelayBubble(context: PersistenceController.preview.viewContext)
//        bubble.sdb?.currentDelay = 90
//        return bubble
//    }()
//    static var previews: some View {
//        BubbleCell(bubble, BubbleCell.Metrics(300))
//    }
//}
