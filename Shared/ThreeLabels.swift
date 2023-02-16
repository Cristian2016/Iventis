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
    let bubble:Bubble
    let spacing:CGFloat
    let timeComponentsFontSize:CGFloat
    let hundredthsFontSize:CGFloat
    
    @EnvironmentObject private var viewModel:ViewModel
    
    @State private var hr = String()
    @State private var min = String()
    @State private var cents = String()
    
    @State private var isSecondsTapped:Bool = false
    @State private var isSecondsLongPressed:Bool = false
    
    @GestureState var isDetectingLongPress = false
    
    private let sDelayBubble:StartDelayBubble
    
    init(_ spacing: CGFloat,
         _ timeComponentsFontSize:CGFloat,
         _ hundredthsFontSize:CGFloat,
         _ startDelayBubble:StartDelayBubble,
         _ bubble:Bubble) {
        
        print("ThreeLabels init \(bubble.color ?? "no color")")
        
        self.spacing = spacing
        self.timeComponentsFontSize = timeComponentsFontSize
        self.hundredthsFontSize = hundredthsFontSize
        self.sDelayBubble = startDelayBubble
        self.bubble = bubble
    }
        
    var body: some View {
        HStack (spacing: spacing) {
            Circle().fill(Color.clear) //Hr
                .overlay { Text(hr).allowsHitTesting(false) }
                .opacity(hrOpacity)
                .scaleEffect(isSecondsLongPressed ? 0.2 : 1.0)
                .offset(x: isSecondsLongPressed ? 20 : 0.0, y: 0)
                .animation(.secondsLongPressed.delay(0.2), value: isSecondsLongPressed)
                .onTapGesture { toggleBubbleDetail() }
                .onLongPressGesture { showNotesList() }
            
            Circle().fill(Color.clear) //Min
                .overlay { Text(min).allowsHitTesting(false) }
                .opacity(minOpacity)
                .scaleEffect(isSecondsLongPressed ? 0.2 : 1.0)
                .offset(x: isSecondsLongPressed ? 10 : 0.0, y: 0)
                .animation(.secondsLongPressed.delay(0.1), value: isSecondsLongPressed)
                .onTapGesture { toggleBubbleDetail() }
            
            SecondsLabel(bubble: bubble,
                         isSecondsTapped: $isSecondsTapped,
                         isSecondsLongPressed: $isSecondsLongPressed)
            .overlay { if sDelayBubble.referenceDelay > 0 { SDButton(bubble.sdb) }}
        }
        .overlay { if !isBubbleRunning { hundredthsView }}
        .font(.system(size: timeComponentsFontSize))
        .fontDesign(.rounded)
        .foregroundColor(.white)
        .onReceive(bubble.coordinator.minPublisher) { min = $0 }
        .onReceive(bubble.coordinator.hrPublisher) { hr = $0 }
    }
    
    // MARK: - Lego
    private var hundredthsView:some View {
        Push(.bottomRight) {
            Text(cents)
                .padding()
                .background(Circle().foregroundColor(.pauseStickerColor))
                .foregroundColor(.pauseStickerFontColor)
                .font(.system(size: hundredthsFontSize, weight: .semibold, design: .rounded))
                .scaleEffect(isSecondsTapped && !isBubbleRunning ? 2 : 1.0)
                .offset(x: isSecondsTapped && !isBubbleRunning ? -20 : 0,
                        y: isSecondsTapped && !isBubbleRunning ? -20 : 0)
                .opacity(isSecondsTapped && !isBubbleRunning ? 0 : 1)
                .animation(.spring(response: 0.3, dampingFraction: 0.2), value: isSecondsTapped)
                .zIndex(1)
                .onTapGesture { userTappedHundredths() }
                .onReceive(bubble.coordinator.centsPublisher) { cents = $0 }
        }
    }
    
    // MARK: - Gestures
    
    
    // MARK: - User Intents
    private func toggleBubbleDetail() {
        viewModel.path = viewModel.path.isEmpty ? [bubble] : []
    }
    
    func showNotesList() {
        UserFeedback.singleHaptic(.light)
        viewModel.notesForBubble.send(bubble)
        PersistenceController.shared.save()
    }
    
    // MARK: -
    
    /* 1 */private func userTappedHundredths() {
        UserFeedback.singleHaptic(.heavy)
        viewModel.toggleBubbleStart(bubble)
    }
    
    // MARK: - Small Helpers
    private var hrOpacity:Double { (hr > "0") ? 1 : 0.001 }
    
    private var minOpacity:Double { (min > "0" || hr > "0") ? 1 : 0.0 }
    
    private var isBubbleRunning:Bool { bubble.state == .running }
}

struct SecondsLabel: View {
    let bubble:Bubble
    @EnvironmentObject private var viewModel:ViewModel
    
    @Binding var isSecondsTapped:Bool
    @Binding var isSecondsLongPressed:Bool
    
    @State private var sec = String()
    
    var body: some View {
        Circle().fill(Color.clear)
            .contentShape(Circle())
            .overlay { Text(sec) }
            .scaleEffect(isSecondsLongPressed ? 0.2 : 1.0)
            .animation(.secondsLongPressed, value: isSecondsLongPressed)
            .gesture(tap)
            .gesture(longPress)
            .onReceive(bubble.coordinator.secPublisher) { sec = $0 }
    }
    
    // MARK: - Gestures
    private var tap:some Gesture { TapGesture().onEnded { _ in userTappedSeconds() }}
    
    private var longPress: some Gesture {
        LongPressGesture(minimumDuration: 0.3).onEnded { _ in endSession() }
    }
    
    // MARK: -
    private func userTappedSeconds() {
        isSecondsTapped = true
        delayExecution(.now() + 0.1) { isSecondsTapped = false }
        
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
