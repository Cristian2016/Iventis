//
//  Action1View.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 20.05.2023.
//

import SwiftUI
import MyPackage

struct Action1View: View {
    let bubble:Bubble
    @EnvironmentObject private var viewModel:ViewModel
    
    let metrics = Metrics()
    
    var body: some View {
        ZStack {
            screenDarkBackground
                .onTapGesture { dismiss() }
            
            VStack {
                HStack(spacing: 6) {
                    deleteButton
                    resetButton
                }
                .labelStyle(.titleOnly) //looks for labels inside HStack
                
                vRoundedRectangle(corners: [.bottomLeft, .bottomRight], radius: 40)
                    .fill(.white)
                    .overlay {
                        TabView {
                            Grid(horizontalSpacing: 2, verticalSpacing: 2) {
                                HStack {
                                    Text("*\(Image.timer) Choose Timer*")
                                        .font(.system(size: 20 ))
                                        .padding([.top, .bottom], 6)
                                    Text("*Minutes*")
                                        .font(.system(size: 18))
                                        .foregroundColor(.gray)
                                }
                                .font(.system(size: 20))
                                
                                ForEach(0..<3) { number in
                                    GridRow {
                                        ForEach(0..<4) { item in
                                            Color.red
                                        }
                                    }
                                }
                            }
                            Grid(horizontalSpacing: 2, verticalSpacing: 2) {
                                Text("*\(Image.timer) Durations*")
                                    .font(.system(size: 20))
                                    .padding([.top, .bottom], 6)
                                ForEach(0..<4) { number in
                                    GridRow {
                                        ForEach(0..<2) { item in
                                            Rectangle()
                                        }
                                    }
                                }
                            }
                        }
                        .clipShape(vRoundedRectangle(corners: [.bottomLeft, .bottomRight], radius: 30))
                        .padding([.leading, .trailing], 6)
                        .padding([.bottom])
                        .tabViewStyle(.page(indexDisplayMode: .never))
                    }
            }
            .compositingGroup()
            .standardShadow()
            .frame(width: metrics.size.width, height: metrics.size.height)
        }
    }
    
    private var deleteButton:some View {
        Button {
            deleteBubble()
        } label: {
            Label("Delete", systemImage: "trash")
                .padding()
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(BStyle(position: .left(.red)))
        .foregroundColor(.white)
    }
    
    private var resetButton:some View {
        Button {
            resetBubble()
        } label: {
            Label("Reset", systemImage: "arrow.counterclockwise.circle")
                .padding()
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(BStyle(position: .right(Color("deleteActionAlert1"))))
    }
    
    private var screenDarkBackground:some View {
        Color.black
            .opacity(0.5)
            .ignoresSafeArea()
    }
    
    
    // MARK: - Methods
    private func resetBubble() {
        hapticFeedback()
        viewModel.reset(bubble)
        Secretary.shared.deleteAction_bRank = nil
    }
    
    private func deleteBubble() {
        hapticFeedback()
        viewModel.deleteBubble(bubble)
        dismiss()
    }
    
    private func dismiss() { Secretary.shared.deleteAction_bRank = nil }
    
    // MARK: -
    private func hapticFeedback() { UserFeedback.singleHaptic(.heavy) }
}

extension Action1View {
    struct Metrics {
        let size = CGSize(width: 310, height: 350)
        let buttonHeight = CGFloat(80)
    }
}

extension Action1View {
    struct BStyle:ButtonStyle {
        
        let position:Position
        
        func makeBody(configuration: Configuration) -> some View {
            let scale = configuration.isPressed ? CGFloat(0.8) : 1.0
            
            configuration.label
                .foregroundColor(.white)
                .font(.system(size: 30, weight: .medium, design: .rounded))
                .background {
                    switch position {
                        case .left(let color):
                            vRoundedRectangle(corners: [.topLeft], radius: 20)
                                .fill(color)
                        case .right(let color):
                            vRoundedRectangle(corners: [.topRight], radius: 20)
                                .fill(color)
                    }
                }
                .opacity(configuration.isPressed ? 0.5 : 1.0)
                .scaleEffect(x: scale, y: scale)
        }
        
        enum Position {
            case left(Color)
            case right(Color)
        }
    }
}

struct Action1View_Previews: PreviewProvider {
    static var previews: some View {
        Action1View(bubble: BubbleDeleteButton1_Previews.bubble)
    }
}
