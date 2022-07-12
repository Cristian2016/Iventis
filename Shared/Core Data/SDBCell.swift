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
    
    @State var offset:CGSize = .zero
    @EnvironmentObject var vm:ViewModel
    
    var body: some View {
        Circle()
            .fill(.thinMaterial)
            .overlay (
                HStack(spacing: 2) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 20).weight(.bold))
                    Text("\(sdb.delay)")
                        .font(.system(size: 60))
                }.foregroundColor(.black)
            )
            .offset(offset)
        //gestures
            .gesture(dragGesture)
            .highPriorityGesture(longPressGesture)
            .onTapGesture { vm.toggle(sdb) }
            .onReceive(NotificationCenter.Publisher(center: .default, name: .sdbTimerSignal)) {
                
                let receivedRank = $0.userInfo?["rank"] as? Int64
                guard receivedRank! == sdb.bubble!.rank else { return }
                
                if sdb.delay > 0 {
                    sdb.delay -= 1
                    
                    if sdb.delay == 0 {
                        sdb.backgroundTimer?.perform(.pause)
                        vm.sdb = nil
                        vm.toggleStart(sdb.bubble!)
                    }
                }
            }
    }
    
    private var longPressGesture:some Gesture {
        LongPressGesture(minimumDuration: 0.3)
            .onEnded { _ in
                print("long pressed")
            }
    }
    
    private var dragGesture:some Gesture {
        DragGesture()
            .onChanged { value in offset = value.translation }
            .onEnded { _ in withAnimation { offset = .zero } }
    }
}

//struct StartDelayView_Previews: PreviewProvider {
//    static var previews: some View {
//        StartDelayView(startDelay: .constant(59))
//    }
//}
