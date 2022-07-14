//
//  StartDelayView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 12.07.2022.
//

import SwiftUI

///StartDelayBubbleCell
struct SDBCell: View {
    @StateObject var sdb:SDB
    @State var offset:CGSize = .zero //drag view around
    @EnvironmentObject var vm:ViewModel
    @State var isTapped = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .scaleEffect(x:0.8, y:0.8)
            Circle()
                .fill(.ultraThinMaterial)
        }
        .padding(6)
        //animated value
        .scaleEffect(isTapped ? 0.9 : 1.0)
        //
        .overlay (
            HStack(spacing: 2) {
                Text("-\(sdb.currentDelay)")
                    .font(.system(size: 60))
                    .minimumScaleFactor(0.3)
                    .padding()
            }
                .foregroundColor(.black)
        )
        .offset(offset)
        //gestures
        .gesture(dragGesture)
        .highPriorityGesture(longPressGesture)
        .onTapGesture { handleTap() }
    }
    
    // MARK: - handle gestures
    private var dragGesture:some Gesture {
        DragGesture()
            .onChanged { value in offset = value.translation }
            .onEnded { _ in withAnimation { offset = .zero } }
    }
    private var longPressGesture:some Gesture {
        LongPressGesture(minimumDuration: 0.3)
            .onEnded { _ in }
    }
    func handleTap() {
        vm.toggleStart(sdb)
        withAnimation (.spring(response: 0.5).repeatForever()) {
            isTapped.toggle()
        }
    }
}

//struct StartDelayView_Previews: PreviewProvider {
//    static var previews: some View {
//        StartDelayView(startDelay: .constant(59))
//    }
//}
