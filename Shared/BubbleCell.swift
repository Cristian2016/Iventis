//
//  BubbleCell1.swift
//  BubblesSwiftUI
//
//  Created by Cristian Lapusan on 13.04.2022.
//

import SwiftUI

struct BubbleCell: View {
    @State private var scale: CGFloat = 1.4
    
    @StateObject var bubble:Bubble
    @Binding var showDetailView:Bool
    @EnvironmentObject private var viewModel:ViewModel
    @Binding var predicate:NSPredicate?
    
    private var isRunning:Bool { bubble.state == .running }
    
    private var sec:Int = 0
    private var min:Int = 0
    private var hr:Int = 0
    
    init(_ bubble:Bubble, _ showDetail:Binding<Bool>, _ predicate:Binding<NSPredicate?>) {
        _bubble = StateObject(wrappedValue: bubble)
        _showDetailView = Binding(projectedValue: showDetail)
        _predicate = Binding(projectedValue: predicate)
        
        switch bubble.kind {
            case .stopwatch: sec = 0
            default: break
        }
        if !bubble.isObservingBackgroundTimer { bubble.observeBackgroundTimer() }
    }
    
    private let spacing:CGFloat = -30
    private let fontSize = Ratio.bubbleToFontSize * UIScreen.size.width * 0.85
    
    //⚠️ this property determines how many bubbles on screen to fit
    private static var edge:CGFloat = {
        print(UIScreen.main.bounds.height)
        return dic[UIScreen.size.height] ?? 140
    }()
    
    ///component padding
    private let padding = CGFloat(0)
    
    private var minOpacity:Double {
        bubble.timeComponentsString.min > "0" || bubble.timeComponentsString.hr > "0" ? 1 : 0.001
    }
    private var hrOpacity:Double { bubble.timeComponentsString.hr > "0" ? 1 : 0.001 }
        
    // MARK: -
    var body: some View {
        let colors = bubbleColors(bubble.color)
        
        ZStack {
            hoursView
                .foregroundColor(colors.sec)
                .opacity(hrOpacity)
                .onTapGesture(count: 2, perform: {
                    print("edit duration")
                })
                .onTapGesture(count: 1) {
                    print("add note")
                }
            minutesView
                .foregroundColor(colors.sec)
                .opacity(minOpacity)
                .onTapGesture {
                    withAnimation {
                        UserFeedback.triggerSingleHaptic(.medium)
                        let condition = predicate == nil
                        //%i integer, %f float, %@ object??
                        predicate = condition ? NSPredicate(format: "rank == %i", bubble.rank) : nil
                        showDetailView = condition ? true : false
                    }
                }

            secondsView
                .foregroundColor(colors.sec)
                .onTapGesture {
                    UserFeedback.triggerSingleHaptic(.heavy)
                    viewModel.toggleStart(bubble)
                }
                .onLongPressGesture {
                    UserFeedback.triggerDoubleHaptic(.heavy)
                    viewModel.endSession(bubble)
                }
            if bubble.state != .running { hundredthsView }
            if bubble.hasCalendar { calendarView }
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
            icon: { Image(systemName: bubble.hasCalendar ? "calendar" : "calendar") } }
        .tint(bubble.hasCalendar ? .calendarOff : .calendar)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            //delete
            Button {
                viewModel.delete(bubble)
                //set predicate to nil in case any filtered search is going on
                predicate = nil
            }
        label: { Label { Text("Delete") }
            icon: { Image.trash } }.tint(.red)
            
            //more options
            Button { viewModel.showMoreOptions(bubble) }
        label: { Label { Text("More") }
            icon: { Image(systemName: "ellipsis.circle.fill") } }.tint(.lightGray)
        }
    }
    
    // MARK: - Legoes
    private var hoursView:some View {
        HStack {
            ZStack {
                Circle()
                    .frame(width: BubbleCell.edge, height: BubbleCell.edge)
                    .padding(padding)
                Text(bubble.timeComponentsString.hr)
                    .font(.system(size: fontSize))
                    .foregroundColor(.white)
            }
            Spacer()
        }
    }
    
    private var minutesView:some View {
        HStack {
            Spacer()
            ZStack {
                Circle()
                    .frame(width: BubbleCell.edge, height: BubbleCell.edge)
                    .padding(padding)
                Text(bubble.timeComponentsString.min)
                    .font(.system(size: fontSize))
                    .foregroundColor(.white)
            }
            Spacer()
        }
    }
    
    private var secondsView:some View {
        HStack {
            Spacer()
            ZStack {
                Circle()
                    .frame(width: BubbleCell.edge, height: BubbleCell.edge)
                    .padding(padding)
//                    .overlay(pauseLine)
                Text(bubble.timeComponentsString.sec)
                    .font(.system(size: fontSize))
                    .foregroundColor(.white)
            }
        }
    }
    
    private var hundredthsView:some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Text(bubble.hundredths)
                    .background(Circle()
                        .foregroundColor(Color("pauseStickerColor"))
                        .padding(-12))
                    .foregroundColor(Color("pauseStickerFontColor"))
                    .font(.system(size: 24, weight: .semibold, design: .default))
            }
        }
        .padding(EdgeInsets(top: 0, leading: 0, bottom: 6, trailing: 8))
    }
    
    private var calendarView:some View {
        VStack {
            HStack {
                Image(systemName: "calendar")
                    .font(.system(size: 45))
                    .foregroundColor(.calendar)
                    .offset(x: -10, y: 0)
                Spacer()
            }
            Spacer()
        }
    }
    
    @ViewBuilder
    private var pauseLine:some View {
        if bubble.state != .running {
            Rectangle()
                .frame(height: 10)
                .foregroundColor(.white.opacity(0.4))
                .padding()
        } else {
            EmptyView()
        }
    }
    
    // MARK: -
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
    
    private func bubbleColors(_ description:String) -> Color.Three {
        Color.bubbleThrees.filter { $0.description == description }.first ?? Color.Bubbles.mint
    }
    
    static let dic:[CGFloat:CGFloat] = [ /* 12mini */728:140, /* 8 */667:150,  /* ipdo */568:125,  /* 13 pro max */926:163,  /* 13 pro */844:147,  /* 11 pro max */896:158, 812:130,  /* 8max */736:167]
}

//struct BubbleCell1_Previews: PreviewProvider {
//    static var previews: some View {
//        BubbleCell(PersistenceController.preview.)
//    }
//}
