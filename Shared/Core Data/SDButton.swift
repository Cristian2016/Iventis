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
    init?(_ sdb:StartDelayBubble?) {
        guard let sdb = sdb else { return nil }
        _sdb = StateObject(wrappedValue: sdb)
    }
    
    @EnvironmentObject var viewModel:ViewModel
    @StateObject var sdb:StartDelayBubble
    
    @State var offset:CGSize = .zero //drag view around
    @State var isTapped = false
    
    let deleteTriggerOffset = CGFloat(180)
    var deleteLabelVisible:Bool { abs(offset.width) > 120 }
    var shouldDelete:Bool { abs(offset.width) >= deleteTriggerOffset }
    @State var deleteTriggered = false
    
    var body: some View {
        ZStack {
            deleteText
            content
            //layout
                .padding(6)
                .overlay (
                    Text("-\(sdb.currentDelay.shortString(by: 0))")
                        .font(.system(size: 60))
                        .minimumScaleFactor(0.3)
                        .padding()
                        .foregroundColor(.black)
                )
                .offset(offset)
            //animated property and animation
                .scaleEffect(isTapped ? 0.9 : 1.0)
                .animation(.spring(response: 0.5).repeatForever(), value: isTapped)
            //gestures
                .gesture(dragGesture)
                .gesture(longPressGesture)
                .onTapGesture { toggleStart() }
        }
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
                }
            }
            .onEnded { _ in withAnimation { offset = .zero } }
    }
    private var longPressGesture:some Gesture {
        LongPressGesture()
            .onEnded { _ in
                
                //UI and haptic
                UserFeedback.doubleHaptic(.heavy)
                isTapped = false
            }
    }
    func toggleStart() {
        viewModel.toggleSDBStart(sdb)
        isTapped.toggle()
    }
}

//struct StartDelayView_Previews: PreviewProvider {
//    static var previews: some View {
//        StartDelayView(startDelay: .constant(59))
//    }
//}
