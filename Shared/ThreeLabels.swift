//
//  ThreeLabels.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 11.02.2023.
//

import SwiftUI
import MyPackage

//hr min sec cents (4 labels in total actually)
struct ThreeLabels: View {
    var bubble:Bubble?
    let timeComponentsFontSize:CGFloat
    
    let circleScale = CGFloat(1.8)
    let hstackScale = CGFloat(0.833)
    let ratio = CGFloat(2.05)
    
    @EnvironmentObject private var viewModel:ViewModel
    
    @State private var hr:String
    @State private var min:String
    @State private var hundredths:String
    
    @State private var isSecondsLongPressed:Bool = false
    
    @GestureState var isDetectingLongPress = false
    
    private let sDelayBubble:StartDelayBubble
    
    init?(_ timeComponentsFontSize:CGFloat,
         _ startDelayBubble:StartDelayBubble,
         _ bubble:Bubble?) {
        
        guard let bubble = bubble else { return nil }
        
        self.timeComponentsFontSize = timeComponentsFontSize
        self.sDelayBubble = startDelayBubble
        self.bubble = bubble
                
        if bubble.color == nil { return nil }
        
        let components = bubble.coordinator.components
        hr = components.hr
        min = components.min
        hundredths = components.hundredths
    }
    
    var body: some View {
        if let bubble = bubble  {
            Rectangle().fill(.clear)
                .aspectRatio(ratio, contentMode: .fit)
                .overlay {
                    HStack {
                        clearCircle //Hr
                            .overlay {
                                Rectangle().fill(.clear)
                                    .aspectRatio(1.2, contentMode: .fit)
                                    .overlay {
                                        Text(hr).allowsHitTesting(false)
                                            .font(.system(size: 400))
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.1)
                                    }
                            }
                            .opacity(hrOpacity)
                            .scaleEffect(isSecondsLongPressed ? 0.2 : 1.0)
                            .offset(x: isSecondsLongPressed ? 20 : 0.0, y: 0)
                            .animation(.secondsLongPressed.delay(0.2), value: isSecondsLongPressed)
                            .onTapGesture { toggleBubbleDetail() }
                            .onLongPressGesture { showNotesList() }
                        
                        clearCircle //Min
                            .overlay {
                                Rectangle().fill(.clear)
                                    .aspectRatio(1.2, contentMode: .fit)
                                    .overlay {
                                        Text(min).allowsHitTesting(false)
                                            .font(.system(size: 400))
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.1)
                                    }
                            }
                            .opacity(minOpacity)
                            .scaleEffect(isSecondsLongPressed ? 0.2 : 1.0)
                            .offset(x: isSecondsLongPressed ? 10 : 0.0, y: 0)
                            .animation(.secondsLongPressed.delay(0.1), value: isSecondsLongPressed)
                            .onTapGesture { toggleBubbleDetail() }
                        
                        SecondsLabel(bubble: bubble,
                                     isSecondsLongPressed: $isSecondsLongPressed)
                        .overlay { if sDelayBubble.referenceDelay > 0 { SDButton(bubble.sdb) }}
                    }
                    .scaleEffect(x: hstackScale, y: hstackScale)
                }
                .font(.system(size: timeComponentsFontSize))
                .fontDesign(.rounded)
                .foregroundColor(.white)
                .onReceive(bubble.coordinator.$components) { min = $0.min }
                .onReceive(bubble.coordinator.$components) { hr = $0.hr }
        }
        
    }
    
    // MARK: - User Intents
    private func toggleBubbleDetail() {
        guard let bubble = bubble else { return }
        viewModel.path = viewModel.path.isEmpty ? [bubble] : []
    }
    
    func showNotesList() {
        UserFeedback.singleHaptic(.light)
        viewModel.notesForBubble.send(bubble)
        PersistenceController.shared.save()
    }
    
    // MARK: -
    
    /* 1 */private func userTappedHundredths() {
        guard let bubble = bubble else { return }
        UserFeedback.singleHaptic(.heavy)
        viewModel.toggleBubbleStart(bubble)
    }
    
    // MARK: - Small Helpers
    private var hrOpacity:Double { (hr > "0") ? 1 : 0.001 }
    
    private var minOpacity:Double { (min > "0" || hr > "0") ? 1 : 0.0 }
    
    private var isBubbleRunning:Bool {
        guard let bubble = bubble else { return false }
        return bubble.state == .running
    }
}

struct SecondsLabel: View {
    let bubble:Bubble
    @EnvironmentObject private var viewModel:ViewModel
    
    @Binding var isSecondsLongPressed:Bool
    
    @State private var sec:String
    
    var body: some View {
        Circle().fill(Color.clear)
            .overlay {
                Rectangle().fill(.clear)
                    .aspectRatio(1.2, contentMode: .fit)
                    .overlay {
                        Text(sec)
                            .font(.system(size: 400))
                            .lineLimit(1)
                            .minimumScaleFactor(0.1)
                    }
            }
            .scaleEffect(isSecondsLongPressed ? 0.2 : 1.0)
            .animation(.secondsLongPressed, value: isSecondsLongPressed)
            .gesture(tap)
            .gesture(longPress)
            .onReceive(bubble.coordinator.$components) { sec = $0.sec }
    }
    
    init(bubble: Bubble, isSecondsLongPressed: Binding<Bool>) {
        self.bubble = bubble
        _isSecondsLongPressed = isSecondsLongPressed
        self.sec = bubble.coordinator.components.sec
    }
    
    // MARK: - Gestures
    private var tap:some Gesture { TapGesture().onEnded { _ in userTappedSeconds() }}
    
    private var longPress: some Gesture {
        LongPressGesture(minimumDuration: 0.3).onEnded { _ in endSession() }
    }
    
    // MARK: -
    private func userTappedSeconds() {
        //feedback
        UserFeedback.singleHaptic(.heavy)
        
        //user intent model
        viewModel.toggleBubbleStart(bubble)
    }
    
    private func endSession() {
        isSecondsLongPressed = true
        delayExecution(.now() + 0.25) { isSecondsLongPressed = false }
        
        //feedback
        UserFeedback.doubleHaptic(.heavy)
        
        //user intent model
        viewModel.endSession(bubble)
    }
}

extension ThreeLabels {
    private var clearCircle:some View {
        Circle()
            .fill(.clear)
            .scaleEffect(x: circleScale, y: circleScale)
    }
}
