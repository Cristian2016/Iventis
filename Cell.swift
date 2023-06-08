//
//  Cell.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 05.05.2023.
//

import SwiftUI

struct Cell: View {
    @ObservedObject var bubble:Bubble
    @EnvironmentObject private var viewModel:ViewModel
    private let secretary = Secretary.shared
    
    var body: some View {
        Rectangle()
            .fill(.clear)
            .aspectRatio(2.0, contentMode: .fit)
            .overlay {
                ZStack {
                    HStack {
                        circle
                        circle
                    }
                   circle
                }
            }
            .padding([.leading, .trailing], -14)
            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                toggleFavoriteButton
                toggleCalendarButton
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                deleteActionButton
                moreOptionsButton
            }
    }
    
    private var circle:some View {
        Circle()
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
        Button { secretary.deleteAction_bRank = bubble.rank }
        label: { Label { Text("Delete") } icon: { Image.trash } }.tint(.red) }
    
    private var moreOptionsButton:some View {
        Button { viewModel.showMoreOptions(for: bubble) }
    label: { Label { Text("More") } icon: { Image.more } }.tint(.lightGray)
    }
}

extension Cell {
    // MARK: - Helpers
    private var calendarActionName:String { bubble.hasCalendar ? "Cal OFF" : "Cal ON" }
    
    private var calendarActionImageName:String { bubble.hasCalendar ? "calendar" : "calendar" }
    
    private var calendarActionColor:Color { bubble.hasCalendar ? Color.calendarOff : .calendar }
}

//struct Cell_Previews: PreviewProvider {
//    static var previews: some View {
//        Cell()
//    }
//}
