//
//  ThreeLabels.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 11.02.2023.
//

import SwiftUI
import MyPackage

struct ThreeLabels: View {
    let bubble:Bubble
    let spacing:CGFloat
    let timeComponentsFontSize:CGFloat
    
    @EnvironmentObject private var viewModel:ViewModel
    
    @State private var components:Float.TimeComponentsAsStrings = .init(hr: "-1", min: "-1", sec: "-1", cents: "-1")
    @Binding private var isSecondsTapped:Bool
    @Binding private var isSecondsLongPressed:Bool
    
    @GestureState var isDetectingLongPress = false
    
    private let startDelayBubble:StartDelayBubble
    
    init(_ spacing: CGFloat,
         _ timeComponentsFontSize:CGFloat,
         _ startDelayBubble:StartDelayBubble,
         _ isSecondsTapped:Binding<Bool>,
         _ isSecondsLongPressed:Binding<Bool>,
         _ bubble:Bubble
    ) {
        self.spacing = spacing
        self.timeComponentsFontSize = timeComponentsFontSize
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
                .overlay { Text(components.hr) }
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
                .overlay { Text(components.min) }
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
                .overlay { Text(components.sec) }
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
        //font
        .font(.system(size: timeComponentsFontSize))
        .fontDesign(.rounded)
        .foregroundColor(.white)
        .onReceive(bubble.coordinator.componentsPublisher) { components = $0 }
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
    
    private func endSession() {
        isSecondsLongPressed = true
        delayExecution(.now() + 0.25) { isSecondsLongPressed = false }
        
        //feedback
        UserFeedback.doubleHaptic(.heavy)
        
        //user intent model
        viewModel.endSession(bubble)
    }
    
    // MARK: - Small Helpers
    private var hrOpacity:Double { components.hr > "0" ? 1 : 0.001 }
    
    private var minOpacity:Double {
        components.min > "0" || components.hr > "0" ? 1 : 0.001
    }
}
