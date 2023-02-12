//
//  ThreeLabels.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 11.02.2023.
//

import SwiftUI
import MyPackage

//hr min sec cents (4 labels in total)
struct FourLabels: View {
    let bubble:Bubble
    let spacing:CGFloat
    let timeComponentsFontSize:CGFloat
    let hundredthsFontSize:CGFloat
    
    @EnvironmentObject private var viewModel:ViewModel
    
    @State private var hr = String()
    @State private var min = String()
    @State private var sec = String()
    @State private var cents = String()
    
    @Binding private var isSecondsTapped:Bool
    @Binding private var isSecondsLongPressed:Bool
    
    @GestureState var isDetectingLongPress = false
    
    private let startDelayBubble:StartDelayBubble
    
    init(_ spacing: CGFloat,
         _ timeComponentsFontSize:CGFloat,
         _ hundredthsFontSize:CGFloat,
         _ startDelayBubble:StartDelayBubble,
         _ isSecondsTapped:Binding<Bool>,
         _ isSecondsLongPressed:Binding<Bool>,
         _ bubble:Bubble
    ) {
        self.spacing = spacing
        self.timeComponentsFontSize = timeComponentsFontSize
        self.hundredthsFontSize = hundredthsFontSize
        self.startDelayBubble = startDelayBubble
        _isSecondsTapped = isSecondsTapped
        _isSecondsLongPressed = isSecondsLongPressed
        self.bubble = bubble
    }
    
    @State private var time = String()
    
    var body: some View {
        HStack (spacing: spacing) {
            //HOURS
            Circle().fill(Color.clear)
                .overlay { Text(hr) }
                .opacity(hrOpacity)
            //animations
                .scaleEffect(isSecondsLongPressed ? 0.2 : 1.0)
                .offset(x: isSecondsLongPressed ? 20 : 0.0, y: 0)
                .animation(.secondsLongPressed.delay(0.2), value: isSecondsLongPressed)
            //gestures
                .onTapGesture { toggleBubbleDetail() }
                .onLongPressGesture { showNotesList() }
            
            //MINUTES
            Circle().fill(Color.clear)
                .overlay { Text(min) }
                .opacity(minOpacity)
            //animations
                .scaleEffect(isSecondsLongPressed ? 0.2 : 1.0)
                .offset(x: isSecondsLongPressed ? 10 : 0.0, y: 0)
                .animation(.secondsLongPressed.delay(0.1), value: isSecondsLongPressed)
            //gestures
                .onTapGesture { toggleBubbleDetail() }
            
            //SECONDS
            Circle().fill(Color.clear)
                .contentShape(Circle())
                .overlay { Text(sec) }
            //            //animations
                .scaleEffect(isSecondsLongPressed ? 0.2 : 1.0)
                .animation(.secondsLongPressed, value: isSecondsLongPressed)
            //            //gestures
                .gesture(tap)
                .gesture(longPress)
            //            //overlays
                .overlay {
                    if startDelayBubble.referenceDelay > 0 { SDButton(bubble.sdb) }
                }
        }
        .overlay { if !isBubbleRunning { hundredthsView }}
        //font
        .font(.system(size: timeComponentsFontSize))
        .fontDesign(.rounded)
        .foregroundColor(.white)
        .onReceive(bubble.coordinator.secPublisher) { sec = $0 }
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
            //animations:scale, offset and opacity
                .scaleEffect(isSecondsTapped && !isBubbleRunning ? 2 : 1.0)
                .offset(x: isSecondsTapped && !isBubbleRunning ? -20 : 0,
                        y: isSecondsTapped && !isBubbleRunning ? -20 : 0)
                .opacity(isSecondsTapped && !isBubbleRunning ? 0 : 1)
                .animation(.spring(response: 0.3, dampingFraction: 0.2), value: isSecondsTapped)
                .zIndex(1)
                .onTapGesture { userTappedHundredths() }
        }
    }
    
    // MARK: - Gestures
    private var tap:some Gesture { TapGesture().onEnded { _ in userTappedSeconds() }}
    
    private var longPress: some Gesture {
        LongPressGesture(minimumDuration: 0.3)
            .updating($isDetectingLongPress, body: { currentState, gestureState, _ in
                /* ⚠️ it does not work on .gesture(longPress) modifier. use maybe .simultaneousGesture or .highPriority */
                gestureState = currentState
                print("updating")
            })
            .onEnded { _ in
                endSession()
            }
    }
    
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
    /* 2 */private func userTappedSeconds() {
        isSecondsTapped = true
        delayExecution(.now() + 0.1) { isSecondsTapped = false }
        
        //feedback
        UserFeedback.singleHaptic(.heavy)
        
        //user intent model
        viewModel.toggleBubbleStart(bubble)
    }
    
    /* 1 */private func userTappedHundredths() {
        UserFeedback.singleHaptic(.heavy)
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
    
    // MARK: - Small Helpers
    private var hrOpacity:Double { (hr > "0") ? 1 : 0.001 }
    
    private var minOpacity:Double { (min > "0" || hr > "0") ? 1 : 0.0 }
    
    private var isBubbleRunning:Bool { bubble.state == .running }
}
