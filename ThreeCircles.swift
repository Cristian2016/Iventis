//
//  ThreeCircles.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 10.02.2023.
// it shows bubble.color and shows or hide minutes and hours bubble. that's it!

import SwiftUI
import Combine
import MyPackage

struct ThreeCircles: View {
    let coordinator = BubbleCellCoordinator()
    
    let spacing = CGFloat(-40)
    let color = Color.red
    
    @State private var showMin = false
    @State private var showHr = false
    
    var body: some View {
        VStack {
            Button("Ok") {
                coordinator.publisher.send(.min(showMin ? false : true))
            }
            HStack(spacing: spacing) {
                circle(.hr)
                circle(.min)
                circle(.sec)
            }
        }
        .onReceive(coordinator.publisher) {
            switch $0 {
                case .none: break
                case .min(let show):
                    withAnimation(animation) { showMin = show }
                case .hr(let show):
                    withAnimation(animation) { showHr = show }
            }
        }
    }
    
    // MARK: -
    private let animation = Animation.spring(response: 0.5, dampingFraction: 0.6)
    
    // MARK: - Lego
    @ViewBuilder
    private func circle(_ kind:Kind) -> some View {
        switch kind {
            case .hr:
                Circle()
                    .fill(color)
                    .scaleEffect(showHr ? 1 : 0)
            case .min:
                Circle()
                    .fill(color)
                    .scaleEffect(showMin ? 1 : 0)
            case .sec:
                Circle()
                    .fill(color)
        }
    }
    
    // MARK: -
    enum Kind {
        case sec
        case min
        case hr
    }
}

class BubbleCellCoordinator: ObservableObject {
    var publisher:CurrentValueSubject<Show, Never> = .init(.none)
    
    private var show = Show.none
    enum Show {
        case min(Bool)
        case hr(Bool)
        case none
    }
}

struct ThreeCircles_Previews: PreviewProvider {
    static var previews: some View {
        ThreeCircles()
    }
}
