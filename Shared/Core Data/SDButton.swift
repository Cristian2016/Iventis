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
    @StateObject private var  sdb:StartDelayBubble
    
    @State var offset:CGSize = .zero //drag view around
    @State var isTapped = false
    
    let deleteTriggerOffset = CGFloat(180)
    var deleteLabelVisible:Bool { abs(offset.width) > 120 }
    var shouldDelete:Bool { abs(offset.width) >= deleteTriggerOffset }
    @State var deleteTriggered = false
    
    let metrics = BubbleCell.Metrics()
    
    var body: some View {
        ZStack {
            content
            //layout
                .overlay {
                    Rectangle().fill(.clear)
                        .aspectRatio(2.2, contentMode: .fit)
                        .overlay {
                            Text("-\(sdb.currentClock.shortString(by: 0))")
                                .font(.system(size: 400))
                                .lineLimit(1)
                                .minimumScaleFactor(0.1)
                                .foregroundColor(.black)
                        }
                }
            
                .offset(offset)
            //animated property and animation
                .scaleEffect(isTapped ? 0.9 : 1.0)
                .animation(.spring(response: 0.5).repeatForever(), value: isTapped)
            //gestures
                .gesture(dragGesture)
                .gesture(longPressGesture)
                .onTapGesture { toggleStart() }
        }
        .scaleEffect(x: metrics.circleScale * 0.85, y: metrics.circleScale * 0.85)
    }
    
    // MARK: - Lego
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
                    viewModel.removeStartDelay(for: sdb.bubble!)
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
                
                isTapped = false
            }
    }
    func toggleStart() {
        isTapped.toggle()
    }
    
    init?(_ bubble:Bubble?) {
        guard
            let bubble = bubble,
            bubble.startDelayBubble != nil
        else { return nil }
        
        _sdb = StateObject(wrappedValue: bubble.startDelayBubble!)
    }
}

//struct StartDelayView_Previews: PreviewProvider {
//    static var previews: some View {
//        StartDelayView(startDelay: .constant(59))
//    }
//}
