//
//  DeleteActionAlert.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 01.02.2023.
//

import SwiftUI
import MyPackage

extension BubbleDeleteActionAlert {
    struct DeleteButtonStyle:ButtonStyle {
        var disabled:Bool = false
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .scaleEffect(x: configuration.isPressed ? 0.9 : 1.0, y: configuration.isPressed ? 0.9 : 1.0)
                .animation(.spring(), value: configuration.isPressed)
                .disabled(disabled ? true : false)
        }
    }
}

struct BubbleDeleteActionAlert: View {
    @EnvironmentObject private var viewModel:ViewModel
    @EnvironmentObject private var layoutViewModel:LayoutViewModel
    
    let bubble:Bubble
    
    let metrics:Metrics
    
    var body: some View {
        ZStack {
            
            transparentBackground
            roundedBackground
                .overlay( Push(.bottomMiddle) { buttons } .padding([.bottom], 18) )
                .overlay { deleteLabel }
        }
    }
    
    // MARK: - Lego
    
    private var transparentBackground: some View {
        Color.white.opacity(0.01).onTapGesture { cancelDeleteAction() }
    }
    
    private var roundedBackground:some View {
        RoundedRectangle(cornerRadius: metrics.radius)
            .fill(metrics.backgroundColor)
            .frame(width: metrics.width, height: metrics.height)
            .standardShadow()
    }
    
    private var deleteLabel:some View {
        Push(.topMiddle) {
            Text("\(Image.trash) Delete")
                .foregroundColor(.red)
                .font(.system(size: 26, weight: .medium))
        }
        .padding([.top])
        .padding([.top], 6)
    }
    
    //delete bubble action
    private var topButton:some View {
        Button {
            UserFeedback.singleHaptic(.light)
            removeAddTagButton()
            withAnimation {
                viewModel.delete(bubble)
                viewModel.deleteAction_bRank = nil
                removeFiveSecondsBar()
            }
        } label: {
            RoundedCornersShape(corners: [.topLeft, .topRight], radius: 28)
                .fill(metrics.bubbleColor)
                .frame(width: 208, height: 84)
                .overlay {
                    Text("Bubble")
                        .font(.system(size: 32, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                }
        }
        .buttonStyle(DeleteButtonStyle())
    }
    
    //delete History action
    private var bottomButton:some View {
        Button {
            if !bubble.sessions_.isEmpty { UserFeedback.singleHaptic(.light) }
            removeAddTagButton()
            if !bubble.sessions_.isEmpty {
                viewModel.reset(bubble)
                viewModel.deleteAction_bRank = nil
                
                removeFiveSecondsBar()
            }
        } label: {
            RoundedCornersShape(corners: [.bottomLeft, .bottomRight], radius: 28)
                .fill(bubble.sessions_.isEmpty ? metrics.bubbleColor.opacity(0.25) : metrics.bubbleColor)
                .frame(width: 208, height: 84)
                .overlay {
                    Text("History \(bubble.sessions_.count)")
                        .font(.system(size: 32, weight: .medium, design: .rounded))
                        .foregroundColor(bubble.sessions_.isEmpty ? .black : .white)
                }
        }
        .buttonStyle(DeleteButtonStyle(disabled: bubble.sessions_.isEmpty))
    }
    
    //top and bottom buttons
    private var buttons:some View {
        VStack(spacing: 4) {
            topButton
            bottomButton
        }
    }
    
    // MARK: -
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

struct BlurryBackground:View {
    var material:Material = .ultraThinMaterial
    var body: some View {
        Color.clear
            .background(material, in: Rectangle())
            .ignoresSafeArea()
    }
}
