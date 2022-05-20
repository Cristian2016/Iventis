//
//  BubbleCell1.swift
//  BubblesSwiftUI
//
//  Created by Cristian Lapusan on 13.04.2022.
// https://stackoverflow.com/questions/58284994/swiftui-how-to-handle-both-tap-long-press-of-button

import SwiftUI

struct BubbleCell: View {
    @Environment(\.editMode) var editMode //used to toggle move rows
    
    // MARK: - Dependencies
    @StateObject var bubble:Bubble
    @EnvironmentObject private var viewModel:ViewModel
    
    // MARK: -
    @Binding var predicate:NSPredicate? //detail view
    
    //showing DeleteAction Detail or AddNotes Views
    @Binding var showDetail_bRank:Int? //show detail view
    @Binding var showDeleteAction_bRank:Int? //show delete action
    @Binding var showAddNotes_bRank:Int? //show
    
    // MARK: -
    ////added to bubbleCell only if cellLow value is needed. ex: to know how to position DeleteActionView
    private var cellLowEmitterView:some View { Circle().fill(Color.clear) }
            
    private var isRunning:Bool { bubble.state == .running }
    @State private var isSecondsTapped = false
    @State private var isSecondsLongPressed = false
    
    private let circleDiameter = Global.circleDiameter
    
    init(_ bubble:Bubble,
         _ predicate:Binding<NSPredicate?>,
         _ showDetail_bRank:Binding<Int?>,
         _ showDeleteAction_bRank:Binding<Int?>,
         _ showAddNotes_bRank:Binding<Int?>) {
                
        _showDetail_bRank = Binding(projectedValue: showDetail_bRank)
        _showDeleteAction_bRank = Binding(projectedValue: showDeleteAction_bRank)
        _showAddNotes_bRank = Binding(projectedValue: showAddNotes_bRank)
        
        _bubble = StateObject(wrappedValue: bubble)
        _predicate = Binding(projectedValue: predicate)
                
        if !bubble.isObservingBackgroundTimer { bubble.observeBackgroundTimer() }
    }
    
    private var minOpacity:Double {
        bubble.bubbleCell_Components.min > "0" || bubble.bubbleCell_Components.hr > "0" ? 1 : 0.001
    }
    private var hrOpacity:Double { bubble.bubbleCell_Components.hr > "0" ? 1 : 0.001 }
        
    // MARK: -
    var body: some View {
        ZStack {
            if !bubble.note_.isEmpty {
                noteView
                    .zIndex(10)
                    .onTapGesture {
                        //show AddNotesView again
                        showAddNotes_bRank = Int(bubble.rank)
                    }
            }
            
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
            if bubble.hasCalendar && bubble.note_.isEmpty { calendarView }
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
            Button { showDeleteAction_bRank = Int(bubble.rank)}
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
                Text(bubble.bubbleCell_Components.hr).textify()
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
                        if bubble.note_.isEmpty {
                            showAddNotes_bRank = Int(bubble.rank)
                        } else {
                            bubble.isNoteHidden.toggle()
                            PersistenceController.shared.save()
                        }
                    }
            }
            .offset(x: editMode?.wrappedValue == .active ? -70 : 0, y: 0)
            .zIndex(1) //make sure hours text is fully visible by being on top of all the other views
                       //MINUTES
            Push(.middle) {
                Text(bubble.bubbleCell_Components.min).textify()
                //background
                    .background { circleBackground }
                    .opacity(minOpacity)
                //animations
                    .scaleEffect(isSecondsLongPressed ? 0.2 : 1.0)
                    .offset(x: isSecondsLongPressed ? 10 : 0.0, y: 0)
                    .animation(.secondsLongPressed.delay(0.1), value: isSecondsLongPressed)
                //gestures
                    .onTapGesture { withAnimation(.easeInOut(duration: 0.05)) {
                        editMode?.wrappedValue = .inactive
                        toggleDetailView()
                        //also viewModel.userTogglesDetail called within toggleDetailView()
                    } }
            }
            .offset(x: editMode?.wrappedValue == .active ? -35 : 0, y: 0)
            //SECONDS
            Push(.trailing) {
                Text(bubble.bubbleCell_Components.sec).textify()
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
                CalendarSticker().offset(x: -10, y: -10)
                Spacer()
            }
            Spacer()
        }
    }
        
    private var noteView:some View {
        VStack {
            HStack {
                BubbleStickyNote()
                    .environmentObject(viewModel)
                    .environmentObject(bubble)
                    .offset(x: -5, y: -7)
                Spacer()
            }
            Spacer()
        }
    }
    
    private var circleBackground: some View {
        Circle()
            .fill(Color.bubble(for: bubble.color ?? "cyan"))
            .frame(width: circleDiameter, height: circleDiameter)
    }
    
    // MARK: - Methods
    ///show/hide DetailView
    fileprivate func toggleDetailView() {
        UserFeedback.singleHaptic(.medium)
        let predicateNotSet = predicate == nil
        
        //%i integer, %f float, %@ object??
        predicate = predicateNotSet ? NSPredicate(format: "rank == %i", bubble.rank) : nil
        showDetail_bRank = predicateNotSet ? Int(bubble.rank) : nil
        
        //ask viewModel
        let rank = Int(bubble.rank)
        viewModel.userTogglesDetail(rank)
    }
    
    private var showDeleteActionView:Bool {
        guard let actionViewBubbleRank = showDeleteAction_bRank else { return false }
        return bubble.rank == actionViewBubbleRank
    }
    
    private var showDetailView:Bool {
        guard let showDetailView_BubbleRank = showDetail_bRank else { return false }
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
                .frame(width: Global.circleDiameter, height: Global.circleDiameter)
        }
    }
}

extension View {
    func textify() -> some View { self.modifier(BubbleCell.TextModifier()) }
}

// MARK: - Little Helpers
extension BubbleCell {
    private var calendarActionName:String { bubble.hasCalendar ? "Cal OFF" : "Cal ON" }
    
    private var calendarActionImageName:String { bubble.hasCalendar ? "calendar" : "calendar" }
    
    private var calendarActionColor:Color { bubble.hasCalendar ? Color.calendarOff : .calendar }
}
