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
    let timeComponentsFontSize:CGFloat
    let metrics = BubbleCell.Metrics()
    
    @EnvironmentObject private var viewModel:ViewModel
    
    @State private var hr:String
    @State private var min:String
    @State private var hundredths:String
    
    @GestureState var isDetectingLongPress = false
        
    init?(_ timeComponentsFontSize:CGFloat, _ bubble:Bubble?) {
        guard
            bubble?.color != nil,
            let coordinator = bubble?.coordinator
        else { return nil }
        
        self.timeComponentsFontSize = timeComponentsFontSize
        self.bubble = bubble!
                        
        let components = coordinator.components
        hr = components.hr
        min = components.min
        hundredths = components.hundredths
    }
    
    var body: some View {
        Rectangle().fill(.clear)
            .aspectRatio(metrics.ratio, contentMode: .fit)
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
                    SecondsLabel(bubble: bubble)
                    //                        .overlay { if sDelayBubble.referenceDelay > 0 { SDButton(bubble.sdb) }}
                }
                .scaleEffect(x: metrics.hstackScale, y: metrics.hstackScale)
            }
            .font(.system(size: timeComponentsFontSize))
            .fontDesign(.rounded)
            .foregroundColor(.white)
            .onReceive(bubble.coordinator.$components) { min = $0.min }
            .onReceive(bubble.coordinator.$components) { hr = $0.hr }
    }
    
    // MARK: -
    
    /* 1 */private func userTappedHundredths() {
        UserFeedback.singleHaptic(.heavy)
        viewModel.toggleBubbleStart(bubble)
    }
    
    // MARK: - Small Helpers
    private var hrOpacity:Double { (hr > "0") ? 1 : 0.001 }
    
    private var minOpacity:Double { (min > "0" || hr > "0") ? 1 : 0.0 }
    
    private var isBubbleRunning:Bool {
        return bubble.state == .running
    }
}

struct SecondsLabel: View {
    let bubble:Bubble
    @EnvironmentObject private var viewModel:ViewModel
        
    @State private var sec:String
    
    var body: some View {
        if bubble.coordinator != nil {
            Circle().fill(Color.clear)
                .overlay {
                    Rectangle().fill(.clear)
                        .aspectRatio(1.2, contentMode: .fit)
                        .overlay {
                            Text(sec).allowsHitTesting(false)
                                .font(.system(size: 400))
                                .lineLimit(1)
                                .minimumScaleFactor(0.1)
                        }
                }
                .onReceive(bubble.coordinator.$components) { sec = $0.sec }
        }
    }
    
    init?(bubble: Bubble?) {
        guard let bubble = bubble, !bubble.isFault else { return nil }
        self.bubble = bubble
        self.sec = bubble.coordinator.components.sec
    }
}

extension ThreeLabels {
    private var clearCircle:some View {
        Circle()
            .fill(.clear)
            .scaleEffect(x: metrics.circleScale, y: metrics.circleScale)
    }
}
