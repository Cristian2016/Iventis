//
//  DeleteActionAlert.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 01.02.2023.
//

import SwiftUI
import MyPackage

struct DeleteActionAlert: View {
    
    @EnvironmentObject private var viewModel:ViewModel
    @EnvironmentObject private var layoutViewModel:LayoutViewModel
    
    let bubble:Bubble
    
    let metrics:Metrics
    
    var body: some View {
        ZStack {
            Color.white.opacity(0.01)
                .onTapGesture { cancelDeleteAction() }
            
            RoundedRectangle(cornerRadius: metrics.radius)
                .fill(metrics.backgroundColor)
                .frame(width: metrics.width, height: metrics.height)
                .standardShadow()
                .overlay(
                    Push(.bottomMiddle) {
                        VStack(spacing: 4) {
                            RoundedCornersShape(corners: [.topLeft, .topRight], radius: 28)
                                .fill(.red)
                                .frame(width: 208, height: 84)
                                .overlay {
                                    Text("Bubble")
                                        .font(.system(size: 32, weight: .medium, design: .rounded))
                                        .foregroundColor(.white)
                                }
                                .onTapGesture {
                                    removeAddTagButton()
                                    withAnimation {
                                        viewModel.delete(bubble)
                                        viewModel.deleteAction_bRank = nil
                                        removeFiveSecondsBar()
                                    }
                                }
                            RoundedCornersShape(corners: [.bottomLeft, .bottomRight], radius: 28)
                                .fill(.red)
                                .frame(width: 208, height: 84)
                                .overlay {
                                    Text("Session")
                                        .font(.system(size: 32, weight: .medium, design: .rounded))
                                        .foregroundColor(.white)
                                }
                                .onTapGesture {
                                    removeAddTagButton()
                                    if !bubble.sessions_.isEmpty {
                                        viewModel.reset(bubble)
                                        viewModel.deleteAction_bRank = nil
                                        removeFiveSecondsBar()
                                    }
                                }
                        }
                    }
                        .padding([.bottom], 18)
                )
                .overlay {
                    Push(.topMiddle) {
                        Text("\(Image.trash) Delete")
                            .foregroundColor(.red)
                            .font(.system(size: 26, weight: .medium))
                    }
                    .padding([.top])
                    .padding([.top], 6)
                }
        }
    }
    
    init(_ bubble:Bubble) {
        self.bubble = bubble
        
        let bubbleColor = Color.bubbleColor(forName: bubble.color ?? "mint")
        let metrics = Metrics(bubbleColor: bubbleColor)
        self.metrics = metrics
    }
    
    struct Metrics {
        let bubbleColor:Color
        
        let ratio = CGFloat(0.88)
        let width = CGFloat(220)
        var height:CGFloat { width / ratio }
        let radius = CGFloat(40)
        let backgroundColor = Color("deleteActionAlert")
    }
    
    // MARK: -
    ///dismiss view
    private func cancelDeleteAction() {
        viewModel.deleteAction_bRank = nil
        layoutViewModel.deleteActionViewOffset = nil
    }
    
    //ViewModel 1
    private func removeFiveSecondsBar() {
        if viewModel.fiveSeconds_bRank == Int(bubble.rank) { viewModel.fiveSeconds_bRank = nil }
    }
    
    private func removeAddTagButton() { viewModel.removeAddTagButton(bubble) }
}

//struct DeleteActionAlert_Previews: PreviewProvider {
//    static var previews: some View {
//        DeleteActionAlert()
//    }
//}
