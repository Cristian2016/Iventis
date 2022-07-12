//
//  StartDelayView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 12.07.2022.
//

import SwiftUI

struct StartDelayView: View {
    @Binding var startDelay:Int64
    @State var offset:CGSize = .zero
    
    var body: some View {
        Circle()
            .fill(.thinMaterial)
            .overlay (
                HStack(spacing: 2) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 20).weight(.bold))
                    Text("\(startDelay)")
                        .font(.system(size: 60))
                }.foregroundColor(.black)
            )
            .offset(offset)
        //gestures
            .gesture(dragGesture)
            .highPriorityGesture(longPressGesture)
            .onTapGesture {
                print("tapped")
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

struct StartDelayView_Previews: PreviewProvider {
    static var previews: some View {
        StartDelayView(startDelay: .constant(59))
    }
}
