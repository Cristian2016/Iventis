//
//  BubbleCell1.swift
//  BubblesSwiftUI
//
//  Created by Cristian Lapusan on 13.04.2022.
// https://stackoverflow.com/questions/58284994/swiftui-how-to-handle-both-tap-long-press-of-button

import SwiftUI

struct BubbleCell: View {
    // MARK: - Modifiers
    struct TextModifier : ViewModifier {
        func body(content: Content) -> some View {
            content
                .font(.system(size: Ratio.bubbleToFontSize * UIScreen.size.width * 0.85))
                .foregroundColor(.white)
                .frame(width: BubbleCell.edge, height: BubbleCell.edge)
        }
    }
    
    @EnvironmentObject private var viewModel:ViewModel
    
    @StateObject var bubble:Bubble
    private let bubbleColor:Color
    
    @Binding var predicate:NSPredicate?
    @State private var scale: CGFloat = 1.4
    
    @Binding var showDetail:(show:Bool, rank:Int?)
    @Binding var showDeleteAction:(show:Bool, rank:Int?)
    
    private var isRunning:Bool { bubble.state == .running }
    @State private var isSecondsTapped = false
    
    private var sec:Int = 0
    private var min:Int = 0
    private var hr:Int = 0
    
    init(_ bubble:Bubble,
         _ showDetail:Binding<(show:Bool, rank:Int?)>,
         _ predicate:Binding<NSPredicate?>,
         _ showDeleteAction:Binding<(show:Bool, rank:Int?)>) {
        _bubble = StateObject(wrappedValue: bubble)
        _showDetail = Binding(projectedValue: showDetail)
        _predicate = Binding(projectedValue: predicate)
        _showDeleteAction = Binding(projectedValue: showDeleteAction)
        self.bubbleColor = Color.bubble(for: bubble.color!)
        
        switch bubble.kind {
            case .stopwatch: sec = 0
            default: break
        }
        if !bubble.isObservingBackgroundTimer { bubble.observeBackgroundTimer() }
    }
    
    private let spacing:CGFloat = -30
    
    //⚠️ this property determines how many bubbles on screen to fit
    private static var edge:CGFloat = {
        print(UIScreen.main.bounds.height)
        return dic[UIScreen.size.height] ?? 140
    }()
    
    ///component padding
    private let padding = CGFloat(0)
    
    private var minOpacity:Double {
        bubble.bubbleCellComponents.min > "0" || bubble.bubbleCellComponents.hr > "0" ? 1 : 0.001
    }
    private var hrOpacity:Double { bubble.bubbleCellComponents.hr > "0" ? 1 : 0.001 }
        
    // MARK: -
    var body: some View {
        ZStack {
            let putTransparentGeometryReaderView = condition()
            if putTransparentGeometryReaderView {
                Circle().fill(Color.clear)
                    .background {
                        GeometryReader {
                            let value = BubbleCellLowKey.RankFrame(rank: Int(bubble.rank), frame: $0.frame(in: .global))
                            Color.clear.preference(key: BubbleCellLowKey.self, value: value)
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
            if !bubble.isNoteHidden { noteView }
        }
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            
            //pin
            Button { viewModel.togglePin(bubble) }
        label: { Label { Text(bubble.isPinned ? "Unpin" : "Pin") }
            icon: { Image(systemName: bubble.isPinned ? "pin.slash.fill" : "pin.fill") } }
        .tint(bubble.isPinned ? .gray : .orange)
            
            //calendar
            Button { viewModel.toggleCalendar(bubble) }
        label: { Label { Text(bubble.hasCalendar ? "Cal OFF" : "Cal ON") }
            icon: { Image(systemName: bubble.hasCalendar ? "calendar" : "calendar")
            } }
        .tint(bubble.hasCalendar ? .calendarOff : .calendar)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            //delete
            Button { showDeleteAction = (true, Int(bubble.rank))}
        label: { Label { Text("Delete") }
            icon: { Image.trash } }.tint(.red)
            
            //more options
            Button { viewModel.showMoreOptions(bubble) }
        label: { Label { Text("More") }
            icon: { Image(systemName: "ellipsis.circle.fill") } }.tint(.lightGray)
        }
    }
    
    private var timeComponentsViews:some View {
        ZStack {
            //HOURS
            Push(.leading) {
                Text(bubble.bubbleCellComponents.hr)
                    .modifier(TextModifier())
                //background
                    .background { circleBackground.zIndex(-2) }
                    .opacity(hrOpacity)
                //gestures
                    .onTapGesture(count: 2) { print("edit duration") }
                    .onTapGesture { print("add note") }
            }
            //MINUTES
            Push(.middle) {
                Text(bubble.bubbleCellComponents.min)
                    .modifier(TextModifier())
                //background
                    .background { circleBackground.zIndex(-1) }
                    .opacity(minOpacity)
                //gestures
                    .onTapGesture { withAnimation {
                        toggleDetailView()
                        //also viewModel.userTogglesDetail called within toggleDetailView()
                    } }
            }
            //SECONDS
            Push(.trailing) {
                Text(bubble.bubbleCellComponents.sec)
                    .modifier(TextModifier())
                //background
                    .background { circleBackground }
                //animations
                    .scaleEffect(isSecondsTapped ? 0.6 : 1.0)
                    .animation(.secondsTapped, value: isSecondsTapped)
                //gestures
                    .onTapGesture {
                        isSecondsTapped = true
                        delayExecution(.now() + 0.1) { isSecondsTapped = false }
                        UserFeedback.singleHaptic(.heavy)
                        viewModel.toggleStart(bubble)
                    }
                    .onLongPressGesture {
                        UserFeedback.doubleHaptic(.heavy)
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
                Text(bubble.bubbleCellComponents.cents)
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
            .onEnded {
                print("Double tap")
            }
            .simultaneously(with: TapGesture(count: 1)
                                .onEnded {
                                    print("Single Tap")
                                })
    }
    
    static let dic:[CGFloat:CGFloat] = [ /* 12mini */728:140, /* 8 */667:150,  /* ipdo */568:125,  /* 13 pro max */926:163,  /* 13 pro */844:147,  /* 11 pro max */896:158, 812:130,  /* 8max */736:167]
    
    // MARK: - Methods
    ///show/hide DetailView
    fileprivate func toggleDetailView() {
        UserFeedback.singleHaptic(.medium)
        let condition = predicate == nil
        
        //%i integer, %f float, %@ object??
        predicate = condition ? NSPredicate(format: "rank == %i", bubble.rank) : nil
        showDetail = condition ? (true, Int(bubble.rank)) : (false, nil)
        
        //ask viewModel
        let rank = Int(bubble.rank)
        viewModel.userTogglesDetail(rank, showDetail.show)
    }
    
    private func condition() -> Bool {
        showDeleteAction.show && bubble.rank == showDeleteAction.rank!
    }
}

//struct BubbleCell1_Previews: PreviewProvider {
//    static var previews: some View {
//        BubbleCell(PersistenceController.preview.)
//    }
//}
