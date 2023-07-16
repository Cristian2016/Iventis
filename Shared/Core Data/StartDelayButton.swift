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
struct StartDelayButton: View {
    
    @Environment(ViewModel.self) var viewModel
    
    @State var offset:CGFloat = 0 //drag view around
        
    let deleteTriggerOffset = CGFloat(180)
    var shouldDelete:Bool { abs(offset) >= deleteTriggerOffset }
    @State var deleteTriggered = false
        
    //MARK: -
    @StateObject private var  bubble:Bubble
    
    init?(_ bubble:Bubble?) {
        guard let bubble = bubble else { return nil }
        
        _bubble = StateObject(wrappedValue: bubble)
    }
    
    //MARK: -
    var body: some View {
        ZStack {
            if let sdb = bubble.startDelayBubble, let coordinator = sdb.coordinator {
                translucentCircle
                    .scaleEffect(x: coordinator.animate ? 0.9 : 1.0, y: coordinator.animate ? 0.9 : 1.0)
                    .overlay { textStiffRect.overlay {
                        Text("-\(coordinator.valueToDisplay.shortString(by: 0))")
                            .font(.system(size: 150, design: .rounded))
                            .lineLimit(1)
                            .minimumScaleFactor(0.1)
                            .foregroundStyle(.black)
                    }} //5
                    .overlay(alignment: .top) {
                        if !coordinator.animate {
                            let title = coordinator.animate ? "Pause" : "OK"
                            SmallFusedLabel(content: .init(title: title, color: .black))
                                .padding(.top)
                        }
                    }
                    .offset(x: offset) //1
                    .gesture(dragGesture) //3
                    .onTapGesture { toggleStart() } //3
                    .onChange(of: offset) { coordinator.offset = $1 }
            }
        }
        .padding(4)
    }
    
    // MARK: - Lego
    private var textStiffRect: some View {
        Rectangle()
            .fill(.clear)
            .aspectRatio(2.2, contentMode: .fit)
    } //5
    
    private var translucentCircle:some View {
        Circle()
            .fill(.ultraThinMaterial)
            .background {
                Circle()
                    .fill(Color.white)
                    .padding()
            }
    }
    
    // MARK: - handle gestures
    private var dragGesture:some Gesture {
        DragGesture(minimumDistance: 4)
            .onChanged { value in
                guard !deleteTriggered else { return }
                
                offset = value.translation.width
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
        viewModel.toggleSDBubble(bubble)
    }
}
