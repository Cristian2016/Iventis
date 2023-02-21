//
//  PairRunningCell.swift
//  Timers
//
//  Created by Cristian Lapusan on 09.05.2022.
//⚠️ if I don't add task modifier View does not update components from PairBubbleCellCoordinator
// if I add onTap{ } it will have no effect! what the fuck!!!!

import SwiftUI
import MyPackage

///it's the small bubble cell in the PairCell of BottomDetaiulView that only shows up when bubble is running and detailMode is active
struct PairBubbleCell: View {
    let bubble:Bubble //dependecy
    
    let metrics = BubbleCell.Metrics()
    
    var body: some View {
        ZStack {
            Rectangle().fill(.clear)
                .aspectRatio(metrics.ratio, contentMode: .fit)
                .background {
                    RoundedRectangle(cornerRadius: 35)
                        .fill(.thinMaterial)
                        .scaleEffect(x: 1.12, y: 1.17)
                }
                .overlay {
                    HStack {
                        circle
                        circle
                        circle
                    }
                    .compositingGroup()
                    .shadow(color: .black.opacity(0.13), radius: 4, x: 1, y: 2)
                    .scaleEffect(x: metrics.hstackScale, y: metrics.hstackScale)
                }
            PairBubbleCell.ThreeLabels(metrics.timeComponentsFontSize, bubble)
        }
        .padding(10)
        .task {
            
        }
    }
    
    // MARK: - Lego
    private var circle:some View {
        Circle()
            .fill(.white)
            .scaleEffect(x: metrics.circleScale, y: metrics.circleScale)
    }
    
    init?(bubble: Bubble?) {
        guard let bubble = bubble else { return nil }
        self.bubble = bubble
    }
}

extension PairBubbleCell {
    struct ThreeLabels : View {
        var bubble:Bubble?
        let timeComponentsFontSize:CGFloat
        let metrics = BubbleCell.Metrics()
        
        @State private var hr:String
        @State private var min:String
        @State private var sec:String
        
        var body: some View {
            Rectangle().fill(.clear)
                .aspectRatio(metrics.ratio, contentMode: .fit)
                .overlay {
                    HStack {
                        clearCircle
                            .overlay {
                                clearRectangle
                                    .overlay { Text(hr).componentsTextStyle() }
                            }
                        clearCircle
                            .overlay {
                                clearRectangle
                                    .overlay { Text(min).componentsTextStyle() }
                            }
                        clearCircle
                            .overlay {
                                clearRectangle
                                    .overlay {  Text(sec).componentsTextStyle() }
                            }
                    }
                    .scaleEffect(x: metrics.hstackScale, y: metrics.hstackScale)
                    .onReceive(bubble!.pairBubbleCellCoordinator.$components) {
                        hr = $0.hr
                        min = $0.min
                        sec = $0.sec
                    }
                    .task { } //⚠️
                }
        }
        
        // MARK: - Lego
        private var clearCircle:some View {
            Circle()
                .fill(.clear)
                .scaleEffect(x: metrics.circleScale, y: metrics.circleScale)
        }
        
        private var clearRectangle:some View {
            Rectangle().fill(.clear)
                .aspectRatio(1.2, contentMode: .fit)
        }
        
        // MARK: -
        init?(_ timeComponentsFontSize:CGFloat,
             _ bubble:Bubble?) {
            
            guard let bubble = bubble else { return nil }
            
            self.timeComponentsFontSize = timeComponentsFontSize
                                
            let components = bubble.pairBubbleCellCoordinator.components
            hr = components.hr
            min = components.min
            sec = components.sec
            
            self.bubble = bubble
        }
    }
}

struct ComponentsTextStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .allowsHitTesting(false)
                .font(.system(size: 400))
                .fontDesign(.rounded)
                .lineLimit(1)
                .minimumScaleFactor(0.1)
                .foregroundColor(.black)
    }
}

extension View {
    func componentsTextStyle() -> some View {
        modifier(ComponentsTextStyle())
    }
}
