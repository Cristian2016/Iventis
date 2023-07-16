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
    let bubble:Bubble
    
    var body: some View {
        ZStack {
            circle //Sec
                .frame(maxWidth: .infinity, alignment: .trailing)
                .aspectRatio(2.1, contentMode: .fit)
                .background { circle }
                .overlay(alignment: .leading){ circle }
                .compositingGroup()
                .shadow(color: .black.opacity(0.13), radius: 4, x: 1, y: 2)
                .padding(8)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 35))
            PairBubbleCell.ThreeLabels(bubble: bubble)
        }
    }
    
    // MARK: - Lego
    private var circle:some View {
        Circle().fill(.white)
    }
    
    init?(bubble: Bubble?) {
        guard let bubble = bubble else { return nil }
        self.bubble = bubble
    }
}

extension PairBubbleCell {
    private var isBubbleRunning:Bool { bubble.state == .running }
}

extension PairBubbleCell {
    struct ThreeLabels : View {
        var bubble:Bubble?
        
        var body: some View {
            if let coordinator = bubble?.pairBubbleCellCoordinator {
                Color.clear //frame
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .aspectRatio(2.1, contentMode: .fit)
                    .overlay(alignment: .leading){
                        Circle().fill(.clear)
                            .overlay {
                                Text(coordinator.components.hr)
                                    .modifier(LabelModifier())
                            }
                    } //Hr
                    .overlay {
                        Circle().fill(.clear)
                            .overlay {
                                Text(coordinator.components.min)
                                    .modifier(LabelModifier())
                            }
                    } //Min
                    .overlay(alignment: .trailing) {
                        Circle().fill(.clear).overlay {
                            Text(coordinator.components.sec)
                                .modifier(LabelModifier())
                        }
                    } //Sec
            }
        }
    }
    
    struct LabelModifier: ViewModifier {
        func body(content: Content) -> some View {
            content
                .allowsHitTesting(false)
                .font(.system(size: 400, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.1)
                .foregroundStyle(.black)
                .aspectRatio(2.3, contentMode: .fit)
        }
    }
}
