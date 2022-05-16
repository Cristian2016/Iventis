//
//  BubbleCell1.swift
//  BubblesSwiftUI
//
//  Created by Cristian Lapusan on 13.04.2022.
// https://stackoverflow.com/questions/58284994/swiftui-how-to-handle-both-tap-long-press-of-button

import SwiftUI

struct BubbleCell: View {
    ///added to bubbleCell only if cellLow value is needed. ex: to know how to position DeleteActionView
    private var cellLowEmitterView:some View { Circle().fill(Color.clear) }
    //showing Detail or DeleteAction views
    @Binding var showDeleteActionView_bubbleRank:Int? //bubble.rank
    @Binding var showDetailView_BubbleRank:Int?
    @Binding var addBubbleNotesView_BubbleRank:Int?
    
    @Binding var predicate:NSPredicate?
    
    @Environment(\.editMode) var editMode
    
    @EnvironmentObject private var viewModel:ViewModel
    
    @StateObject var bubble:Bubble
    private let bubbleColor:Color
    
    @State private var scale: CGFloat = 1.4
    
    private var isRunning:Bool { bubble.state == .running }
    @State private var isSecondsTapped = false
    @State private var isSecondsLongPressed = false
    
    private var sec:Int = 0
    private var min:Int = 0
    private var hr:Int = 0
    
    init(_ bubble:Bubble,
         _ showDetailView_BubbleRank:Binding<Int?>,
         _ predicate:Binding<NSPredicate?>,
         _ showDeleteActionView_BubbleRank:Binding<Int?>,
         _ addBubbleNotesView_BubbleRank:Binding<Int?>) {
                
        _showDeleteActionView_bubbleRank = Binding(projectedValue: showDeleteActionView_BubbleRank)
        _showDetailView_BubbleRank = Binding(projectedValue: showDetailView_BubbleRank)
        
        _bubble = StateObject(wrappedValue: bubble)
        _predicate = Binding(projectedValue: predicate)
        
        self.bubbleColor = Color.bubble(for: bubble.color!)
        
        switch bubble.kind {
            case .stopwatch: sec = 0
            default: break
        }
        if !bubble.isObservingBackgroundTimer { bubble.observeBackgroundTimer() }
        _addBubbleNotesView_BubbleRank = Binding(projectedValue: addBubbleNotesView_BubbleRank)
    }
    
    private let spacing:CGFloat = -30
    
    //⚠️ this property determines how many bubbles on screen to fit
    static var edge:CGFloat = {
        print(UIScreen.main.bounds.height)
        return dic[UIScreen.size.height] ?? 140
    }()
    
    ///component padding
    private let padding = CGFloat(0)
    
    private var minOpacity:Double {
        bubble.bubbleCell_Components.min > "0" || bubble.bubbleCell_Components.hr > "0" ? 1 : 0.001
    }
    private var hrOpacity:Double { bubble.bubbleCell_Components.hr > "0" ? 1 : 0.001 }
        
    // MARK: -
    var body: some View {
        ZStack {
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
            if bubble.state != .running {
                centsView.onTapGesture {
                    UserFeedback.singleHaptic(.heavy)
                    viewModel.toggleStart(bubble)
                }
            }
            timeComponentsViews
            if bubble.hasCalendar { calendarView }
            if !bubble.isNoteHidden {
                noteView
                    .onTapGesture {
                        print(bubble.note_.isEmpty)
                        //show AddNotesView again
                        addBubbleNotesView_BubbleRank = Int(bubble.rank)
                    }
            }
        }
        .scaleEffect(editMode?.wrappedValue == .active ? 0.9 : 1.0)
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
            Button { showDeleteActionView_bubbleRank = Int(bubble.rank)}
        label: { Label { Text("Delete") }
            icon: { Image.trash } }.tint(.red)
            
            //more options
            Button { viewModel.showMoreOptions(bubble) }
        label: { Label { Text("More") }
            icon: { Image(systemName: "ellipsis.circle.fill") } }.tint(.lightGray)
        }
    }
    
    // MARK: -
    private var timeComponentsViews:some View {
        ZStack {
            //HOURS
            Push(.leading) {
                Text(bubble.bubbleCell_Components.hr)
                    .modifier(TextModifier())
                //background
                    .background { circleBackground }
                    .opacity(hrOpacity)
                //animations
                    .scaleEffect(isSecondsLongPressed ? 0.2 : 1.0)
                    .offset(x: isSecondsLongPressed ? 20 : 0.0, y: 0)
                    .animation(.secondsLongPressed.delay(0.2), value: isSecondsLongPressed)
                //gestures
                    .onTapGesture(count: 2) { print("edit duration") }
                    .onTapGesture {
                        addBubbleNotesView_BubbleRank = Int(bubble.rank)
                    }
            }
            .offset(x: editMode?.wrappedValue == .active ? -70 : 0, y: 0)
            .zIndex(1) //make sure hours text is fully visible by being on top of all the other views
            //MINUTES
            Push(.middle) {
                Text(bubble.bubbleCell_Components.min)
                    .modifier(TextModifier())
                //background
                    .background { circleBackground }
                    .opacity(minOpacity)
                //animations
                    .scaleEffect(isSecondsLongPressed ? 0.2 : 1.0)
                    .offset(x: isSecondsLongPressed ? 10 : 0.0, y: 0)
                    .animation(.secondsLongPressed.delay(0.1), value: isSecondsLongPressed)
                //gestures
                    .onTapGesture { withAnimation {
                        editMode?.wrappedValue = .inactive
                        toggleDetailView()
                        //also viewModel.userTogglesDetail called within toggleDetailView()
                    } }
            }
            .offset(x: editMode?.wrappedValue == .active ? -35 : 0, y: 0)
            //SECONDS
            Push(.trailing) {
                Text(bubble.bubbleCell_Components.sec)
                    .modifier(TextModifier())
                //background
                    .background { circleBackground }
                //animations secondsTapped
                    .scaleEffect(isSecondsTapped ? 0.6 : 1.0)
                    .animation(.secondsTapped, value: isSecondsTapped)
                //animations seconds long pressed
                    .scaleEffect(isSecondsLongPressed ? 0.2 : 1.0)
                    .animation(.secondsLongPressed, value: isSecondsLongPressed)
                //gestures
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
        }
    }
    
    // MARK: - Legoes
    ///hundredths of a second that is :)
    private var centsView:some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Text(bubble.bubbleCell_Components.cents)
                    .background(Circle()
                        .foregroundColor(Color("pauseStickerColor"))
                        .padding(-12))
                    .foregroundColor(Color("pauseStickerFontColor"))
                    .font(.system(size: 24, weight: .semibold, design: .default))
                //animations:scale, offset and opacity
                    .scaleEffect(isSecondsTapped && !isRunning ? 2 : 1.0)
                    .offset(x: isSecondsTapped && !isRunning ? -20 : 0,
                            y: isSecondsTapped && !isRunning ? -20 : 0)
                    .opacity(isSecondsTapped && !isRunning ? 0 : 1)
                    .animation(.spring(response: 0.3, dampingFraction: 0.2), value: isSecondsTapped)
            }
        }
        .padding(EdgeInsets(top: 0, leading: 0, bottom: 6, trailing: 8))
        .zIndex(1)
    }
    
    private var calendarView:some View {
        VStack {
            HStack {
                CalendarView().offset(x: -10, y: -10)
                Spacer()
            }
            Spacer()
        }
    }
    
    private var noteView:some View {
        VStack {
            HStack {
                NoteView(content: bubble.note ?? "").offset(x: -20, y: -22)
                Spacer()
            }
            Spacer()
        }
    }
    
    private var circleBackground: some View {
        Circle()
            .fill(bubbleColor)
            .frame(width: BubbleCell.edge, height: BubbleCell.edge)
    }
    
    // MARK: -Bub
    var tapGesture: some Gesture {
        TapGesture(count: 2)
            .onEnded { print("Double tap") }
            .simultaneously(with: TapGesture().onEnded { print("Single Tap") })
    }
    
    static let dic:[CGFloat:CGFloat] = [ /* 12mini */728:140, /* 8 */667:150,  /* ipdo */568:125,  /* 13 pro max */926:150,  /* 13 pro */844:147,  /* 11 pro max */896:150, 812:130,  /* 8max */736:167]
    
    // MARK: - Methods
    ///show/hide DetailView
    fileprivate func toggleDetailView() {
        UserFeedback.singleHaptic(.medium)
        let predicateNotSet = predicate == nil
        
        //%i integer, %f float, %@ object??
        predicate = predicateNotSet ? NSPredicate(format: "rank == %i", bubble.rank) : nil
        showDetailView_BubbleRank = predicateNotSet ? Int(bubble.rank) : nil
        
        //ask viewModel
        let rank = Int(bubble.rank)
        viewModel.userTogglesDetail(rank)
    }
    
    private var showDeleteActionView:Bool {
        guard let actionViewBubbleRank = showDeleteActionView_bubbleRank else { return false }
        return bubble.rank == actionViewBubbleRank
    }
    
    private var showDetailView:Bool {
        guard let showDetailView_BubbleRank = showDetailView_BubbleRank else { return false }
        return bubble.rank == showDetailView_BubbleRank
    }
}

// MARK: - Modifiers
extension BubbleCell {
    struct TextModifier : ViewModifier {
        func body(content: Content) -> some View {
            content
                .font(.system(size: Ratio.bubbleToFontSize * UIScreen.size.width * 0.85))
                .foregroundColor(.white)
                .frame(width: BubbleCell.edge, height: BubbleCell.edge)
        }
    }
}

//struct BubbleCell1_Previews: PreviewProvider {
//    static var previews: some View {
//        BubbleCell(PersistenceController.preview.)
//    }
//}

// MARK: - Little Helpers
extension BubbleCell {
    private var calendarActionName:String {
        bubble.hasCalendar ? "Cal OFF" : "Cal ON"
    }
    
    private var calendarActionImageName:String {
        bubble.hasCalendar ? "calendar" : "calendar"
    }
    
    private var calendarActionColor:Color {
        bubble.hasCalendar ? Color.calendarOff : .calendar
    }
}
