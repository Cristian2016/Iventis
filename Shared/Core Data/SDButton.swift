//
//  StartDelayView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 12.07.2022.
//

import SwiftUI

///StartDelayBubbleCell
struct SDButton: View {
    init?(_ sdb:SDB?) {
        guard let sdb = sdb else { return nil }
        _sdb = StateObject(wrappedValue: sdb)
    }
    
    @EnvironmentObject var vm:ViewModel
    @StateObject var sdb:SDB
    
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
                    HStack(spacing: 2) {
                        Text("-\(sdb.currentDelay.shortString(by: 1))")
                            .font(.system(size: 60))
                            .minimumScaleFactor(0.3)
                            .padding()
                    }
                        .foregroundColor(.black)
                )
                .offset(offset)
            //animated property and animation
                .scaleEffect(isTapped ? 0.9 : 1.0)
                .animation(.spring(response: 0.5).repeatForever(), value: isTapped)
            //gestures
                .gesture(dragGesture)
                .highPriorityGesture(longPressGesture)
                .onTapGesture { handleTap() }
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
                    vm.removeDelay(for: sdb.bubble)
                    deleteTriggered = true
                }
            }
            .onEnded { _ in withAnimation { offset = .zero } }
    }
    private var longPressGesture:some Gesture {
        LongPressGesture(minimumDuration: 0.3)
            .onEnded { _ in
                vm.resetDelay(for: sdb)
                
                //UI and haptic
                UserFeedback.doubleHaptic(.heavy)
                isTapped = false
            }
    }
    func handleTap() {
        vm.toggleSDBStart(sdb)
        isTapped.toggle()
    }
}

//struct StartDelayView_Previews: PreviewProvider {
//    static var previews: some View {
//        StartDelayView(startDelay: .constant(59))
//    }
//}
