//
//  StartDelayView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 12.07.2022.
//1 offset is mutated by the drag gesture
//2 animated property and animation
//3 gestures
//4 observing publishers
//5 textCage because it prevents text expanding too much

import SwiftUI
import MyPackage

///StartDelayBubbleCell
struct SDButton: View {
    @EnvironmentObject var viewModel:ViewModel
    @StateObject private var  bubble:Bubble
    
    @State var offset:CGSize = .zero //drag view around
    @State var shouldPulsate = false
        
    let deleteTriggerOffset = CGFloat(180)
    var deleteLabelVisible:Bool { abs(offset.width) > 120 }
    var shouldDelete:Bool { abs(offset.width) >= deleteTriggerOffset }
    @State var deleteTriggered = false
    @State private var sdbCurrentClock = Float(0)
    
    let metrics = BubbleCell.Metrics()
    
    var body: some View {
        ZStack {
            if let sdb = bubble.startDelayBubble, sdb.coordinator != nil {
                background
                    .overlay { textCage.overlay { text }} //5
                    .offset(offset) //1
                    .scaleEffect(shouldPulsate ? 0.9 : 1.0) //2
                    .animation(.spring(response: 0.5).repeatForever(), value: shouldPulsate) //2
                    .gesture(dragGesture) //3
                    .onTapGesture { toggleStart() } //3
                    .onReceive(sdb.coordinator.$valueToDisplay) { sdbCurrentClock = $0 } //4
            }
        }
        .scaleEffect(x: metrics.circleScale * 0.93, y: metrics.circleScale * 0.93)
    }
    
    // MARK: - Lego
    private var textCage: some View {
        Rectangle()
            .fill(.clear)
            .aspectRatio(2.2, contentMode: .fit)
    } //5
    
    private var text:some View {
        Text("-\(sdbCurrentClock.shortString(by: 0))")
            .font(.system(size: 400))
            .lineLimit(1)
            .minimumScaleFactor(0.1)
            .foregroundColor(.black)
    }
    
    private var background:some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .scaleEffect(x:0.8, y:0.8)
            Circle()
                .fill(.ultraThinMaterial)
        }
    }
    
    private var deleteText:some View {
        Text(shouldDelete ?
             "\(Image(systemName: "checkmark")) Done"
             : "\(Image(systemName: "trash")) Delete"
        )
        .padding()
        .background {
            Circle()
                .fill(deleteTriggered ? .green : .red)
                .transaction { $0.animation = nil } //1
                .padding(-34)
        }
        .opacity(deleteLabelVisible ? 1 : 0)
        .font(.system(size: 24).weight(.medium))
        .foregroundColor(.white)
    }
    
    // MARK: - handle gestures
    private var dragGesture:some Gesture {
        DragGesture(minimumDistance: 4)
            .onChanged { value in
                guard !deleteTriggered else { return }
                
                offset = value.translation
                if shouldDelete {
                    UserFeedback.doubleHaptic(.heavy)
                    deleteTriggered = true
                    viewModel.removeStartDelay(for: bubble)
                    
                    delayExecution(.now() + 0.1) {
                        deleteTriggered = false
                        offset = .zero
                    }
                }
            }
            .onEnded { _ in withAnimation { offset = .zero }}
    }
    
    func toggleStart() {
        shouldPulsate.toggle()
        viewModel.toggleSDBubble(bubble)
    }
    
    init?(_ bubble:Bubble?) {
        guard let bubble = bubble else { return nil }
        _bubble = StateObject(wrappedValue: bubble)
        
//        if bubble.startDelayBubble?.state == .running {
//            shouldPulsate = true
//        }
    }
}

//struct StartDelayView_Previews: PreviewProvider {
//    static var previews: some View {
//        StartDelayView(startDelay: .constant(59))
//    }
//}
