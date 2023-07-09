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
    private let secretary = Secretary.shared
    
    let metrics = Metrics()    
    @ObservedObject private var bubble:Bubble
    
    @EnvironmentObject private var viewModel:ViewModel
    @Environment(NewViewModel.self) private var newViewModel
    
    @EnvironmentObject private var layoutViewModel:LayoutViewModel
    @Environment(\.scenePhase) private var phase
        
    // MARK: - Body
    var body: some View {
        ZStack {
            Push(.topRight) {
                WidgetSymbol(rank: bubble.rank)
                    .padding([.top], 10)
            }
            ThreeCircles(bubble: bubble, metrics: metrics)
            ThreeLabels(metrics.timeComponentsFontSize, bubble)
        }
        .overlay { if bubble.hasCalendar && noNote { calendarSymbol }}
        .overlay { stickyNote }
        .listRowSeparator(.hidden)
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            toggleFavoriteButton
            toggleCalendarButton
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            editButton
            moreOptionsButton
        }
    }
    
    // MARK: - Legos
    private var editButton:some View {
        Button {
            secretary.deleteAction_bRank = bubble.rank
        } label: {
            Label("Control", systemImage: "slider.vertical.3")
        }
        .tint(.red)
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
    private var moreOptionsButton:some View {
        Button {
            newViewModel.moreOptionsBubble = bubble
        }
    label: { Label { Text("More") } icon: { Image.more } }.tint(.lightGray)
    }
    
    private var noteButtonContent:some View { BubbleNote().environmentObject(bubble) }
    
    private var calendarSymbol:some View { Push(.topLeft) { CalendarSticker() }.offset(x: -10) }
    
    private var stickyNote:some View {
        Push(.topLeft) { StickyNote (alignment: .leading)
            { noteButtonContent }
        dragAction: { viewModel.deleteStickyNote(for: bubble) }
            tapAction : { handleNoteTap() }
        }
        .offset(x: -12, y: -8)
    }
    
    // MARK: - Internal
    @GestureState var isDetectingLongPress = false
            
    // MARK: -
    init(_ bubble:Bubble) {
        _bubble = ObservedObject(wrappedValue: bubble)
    }
    
    func handleNoteTap() {
        let bContext = PersistenceController.shared.bContext
        let objID = bubble.objectID
        
        bContext.perform {
            UserFeedback.singleHaptic(.light)
            let thisBubble = PersistenceController.shared.grabObj(objID) as! Bubble
            thisBubble.isNoteHidden.toggle()
            PersistenceController.shared.save(bContext)
        }
    }
}

// MARK: - Little Helpers
extension BubbleCell {
    // MARK: - Helpers
    private var calendarActionName:String {
        guard CalendarManager.shared.calendarAccessStatus != .revoked else { return "No Access" }
        return bubble.hasCalendar ? "Cal OFF" : "Cal ON"
    }
    
    private var calendarActionImageName:String {
        guard CalendarManager.shared.calendarAccessStatus != .revoked else { return "calendar.badge.exclamationmark"
        }
        return bubble.hasCalendar ? "calendar" : "calendar"
    }
    
    private var calendarActionColor:Color { bubble.hasCalendar ? Color.calendarOff : .calendar }
}

extension BubbleCell {
    private var isBubbleRunning:Bool { bubble.state == .running }
    
    private var noNote:Bool { bubble.note_.isEmpty  }
    
    ///circle diameter, font size, spacing and so on
    struct Metrics {
        let timeComponentsFontSize = 375 * CGFloat(0.16)
        let hundredthsFontSize:CGFloat = 375 * CGFloat(0.06)
        
        let circleScale = CGFloat(1.8)
        let hstackScale = CGFloat(0.833)
        let ratio = CGFloat(2.05)
    }
}
