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
    private let secretary = Secretary.shared
    
    @State private var components:Float.TimeComponentsAsStrings = .zeroAll
    
    let metrics = Metrics()
    
    @StateObject private var bubble:Bubble
    
    @EnvironmentObject private var viewModel:ViewModel
    @EnvironmentObject private var layoutViewModel:LayoutViewModel
        
    // MARK: - Body
    var body: some View {
//        let _ = print("BubbleCell \(bubble.color ?? "nocolor") body")
        ZStack {
            ThreeCircles(bubble: bubble, metrics: metrics)
            ThreeLabels(metrics.timeComponentsFontSize, bubble)
        }
        .overlay { if bubble.hasCalendar && noNote { calendarSymbol }}
        .overlay { stickyNote }
        .overlay { CalendarEventCreatedConfirmation(rank: bubble.rank) } //1
        .overlay { CalendarEventRemovedConfirmation(rank: bubble.rank) } //1
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
    
    private var noteButtonContent:some View {
        BubbleNote().environmentObject(bubble)
    }
    
    private var calendarSymbol:some View {
        VStack {
            HStack {
                CalendarSticker().offset(x: -10)
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
        .offset(x: -12, y: -8)
    }
        
    // MARK: - Internal
    @GestureState var isDetectingLongPress = false
            
    // MARK: -
    init(_ bubble:Bubble) {
        _bubble = StateObject(wrappedValue: bubble)
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
    
    // MARK: - User Intents
    
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
