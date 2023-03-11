//
//  StartDelayView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 12.07.2022.
//

import SwiftUI
import MyPackage

///StartDelayBubbleCell
struct SDButton: View {
    @EnvironmentObject var viewModel:ViewModel
    @StateObject private var  bubble:Bubble
    
    @State var offset:CGSize = .zero //drag view around
    @State var isTapped = false
        
    let deleteTriggerOffset = CGFloat(180)
    var deleteLabelVisible:Bool { abs(offset.width) > 120 }
    var shouldDelete:Bool { abs(offset.width) >= deleteTriggerOffset }
    @State var deleteTriggered = false
    @State private var sdbCurrentClock = Float(0)
    
    let metrics = BubbleCell.Metrics()
    
    var body: some View {
        ZStack {
            if let sdb = bubble.startDelayBubble {
                content
                //layout
                    .overlay {
                        Rectangle()
                            .fill(.clear)
                            .aspectRatio(2.2, contentMode: .fit)
                            .overlay { text }
                    }
                    .offset(offset)
                //animated property and animation
                    .scaleEffect(isTapped ? 0.9 : 1.0)
                    .animation(.spring(response: 0.5).repeatForever(), value: isTapped)
                //gestures
                    .gesture(dragGesture)
                    .onTapGesture { toggleStart() }
                //observing publishers
                    .onReceive(sdb.coordinator.$currentClock) { sdbCurrentClock = $0 }
            }
        }
        .scaleEffect(x: metrics.circleScale * 0.93, y: metrics.circleScale * 0.93)
    }
    
    // MARK: - Lego
    private var text:some View {
        Text("-\(sdbCurrentClock.shortString(by: 0))")
            .font(.system(size: 400))
            .lineLimit(1)
            .minimumScaleFactor(0.1)
            .foregroundColor(.black)
    }
    
    private var content:some View {
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
            .onEnded { _ in withAnimation { offset = .zero } }
    }
    private var longPressGesture:some Gesture {
        LongPressGesture()
            .onEnded { _ in
                //UserFeedback
                UserFeedback.doubleHaptic(.heavy)
                viewModel.resetSDB(bubble)
                isTapped = false
            }
    }
    
    func toggleStart() {
        isTapped.toggle()
        viewModel.toggleSDBubble(bubble)
    }
    
    init?(_ bubble:Bubble?) {
        guard let bubble = bubble else { return nil }
        
        _bubble = StateObject(wrappedValue: bubble)
    }
}

//struct StartDelayView_Previews: PreviewProvider {
//    static var previews: some View {
//        StartDelayView(startDelay: .constant(59))
//    }
//}
