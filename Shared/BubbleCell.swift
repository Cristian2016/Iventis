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
    
    private let secretary = Secretary.shared
    
    @State private var components:Float.TimeComponentsAsStrings = .init(hr: "0", min: "0", sec: "0", cents: "0")
    
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
                ThreeLabels(metrics.spacing,
                            metrics.timeComponentsFontSize,
                            startDelayBubble,
                            $isSecondsTapped,
                            $isSecondsLongPressed,
                            bubble)
            }
//            //subviews
            .overlay { if bubble.hasCalendar && noNote { calendarSymbol }}
            .overlay { stickyNote }
            
            .overlay { CalendarEventCreatedConfirmation(rank: bubble.rank) } //1
            .overlay { CalendarEventRemovedConfirmation(rank: bubble.rank) } //1
            
            .overlay { if !isBubbleRunning { hundredthsView }}
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
    }
    
    // MARK: - Legos    
    
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
            secretary.deleteAction_bRank = bubble.rank
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
    
    private var hundredthsView:some View {
        Push(.bottomRight) {
            Text(components.cents)
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
    
    // MARK: - Internal
    @GestureState var isDetectingLongPress = false
        
    private let noteOffset = CGSize(width: 0, height: -6)
    
    @State private var isSecondsTapped = false
    @State private var isSecondsLongPressed = false
    
    // MARK: -
    init(_ bubble:Bubble, _ metrics:Metrics) {
        print(#function, " bCell")
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
    //Start/Pause Bubble 2 ways
    /* 1 */private func userTappedHundredths() {
        UserFeedback.singleHaptic(.heavy)
        viewModel.toggleBubbleStart(bubble)
    }
    
    ///long press on hours to show the notes list
    func showNotesList() {
        UserFeedback.singleHaptic(.light)
        viewModel.notesForBubble.send(bubble)
        PersistenceController.shared.save()
    }
    
    // MARK: -
    var confirm_CalEventCreated:Bool { secretary.confirm_CalEventCreated == bubble.rank }
    var confirm_CalEventRemoved:Bool { secretary.confirm_CalEventRemoved == bubble.rank }
    
    ///show bubbleCell.frame if it's the same rank and the frame is not set and detailView does not show. In the Detailview there is no need to compute deleteActionView.yOffset
    private var computeBubbleCellFrame:Bool {
        secretary.deleteAction_bRank == bubble.rank
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
        components.min > "0" || components.hr > "0" ? 1 : 0.001
    }
    private var hrOpacity:Double { components.hr > "0" ? 1 : 0.001 }
    
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
