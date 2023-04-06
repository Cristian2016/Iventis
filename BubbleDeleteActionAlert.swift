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
            let isPressed = configuration.isPressed
            let scale = isPressed ? 0.8 : 1.0
            
            configuration.label
                .scaleEffect(x: scale, y: scale)
                .disabled(disabled ? true : false)
        }
    }
}

struct BubbleDeleteActionAlert: View {
    @EnvironmentObject private var viewModel:ViewModel
    @EnvironmentObject private var layoutViewModel:LayoutViewModel
    private let secretary = Secretary.shared
    
    let bubble:Bubble
    
    let metrics:Metrics
    
    var body: some View {
        ZStack {
            transparentBackground
            roundedBackground
                .overlay( Push(.bottomMiddle) {
                    VStack(spacing: 4) {
                        titleLabel
                        topButton
                        bottomButton
                    }
                }
                    .padding([.bottom], 18) )
        }
    }
    
    // MARK: - Lego
    private var transparentBackground: some View {
        Color.white.opacity(0.01).onTapGesture { cancelDeleteAction() }
    }
    
    private var roundedBackground:some View {
        RoundedRectangle(cornerRadius: metrics.backgroundRadius)
            .fill(metrics.backgroundColor)
            .frame(width: metrics.width, height: metrics.height)
            .standardShadow()
            .overlay {
                Push(.topLeft) {
                    Image.info
                        .font(.system(size: 26))
                        .foregroundColor(metrics.backgroundColor)
                        .padding(-20)
                }
            }
            .onTapGesture { secretary.showDeleteActionViewInfo = true }
    }
    
    private var titleLabel:some View {
        let condition = bubble.sessions_.count > 0
        let text1:LocalizedStringKey = "^[\(bubble.sessions_.count) Session](inflect: true)"
        let content:LocalizedStringKey = condition ? text1 : "No Sessions"
        
        return Text(content)
            .font(.system(size: 18, weight: .medium, design: .monospaced))
            .foregroundColor(metrics.titleColor)
            .padding(.bottom, 4)
            .allowsHitTesting(false)
    }
    
    //delete bubble action
    private var topButton:some View {
        Button {
            UserFeedback.singleHaptic(.light)
            removeAddTagButton()
            withAnimation {
                viewModel.deleteBubble(bubble)
                
                //make BubbleDAAlert go away after 0.3 seconds, so that user sees button tapped animation
                delayExecution(.now() + 0.25) { secretary.deleteAction_bRank = nil }
                removeFiveSecondsBar()
            }
        } label: {
            vRoundedRectangle(corners: [.topLeft, .topRight], radius: metrics.butonRadius)
                .fill(metrics.bubbleColor)
                .frame(width: 208, height: 84)
                .overlay {
                    Text("Delete")
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
                secretary.deleteAction_bRank = nil
                removeFiveSecondsBar()
            }
        } label: {
            vRoundedRectangle(corners: [.bottomLeft, .bottomRight], radius: metrics.butonRadius)
                .fill(bubble.sessions_.isEmpty ? metrics.bubbleColor.opacity(0.4) : metrics.bubbleColor)
                .frame(width: 208, height: 84)
                .overlay {
                    Text("Reset")
                        .font(.system(size: 32, weight: .medium, design: .rounded))
                        .foregroundColor(bubble.sessions_.isEmpty ? .black : .white)
                }
        }
        .buttonStyle(DeleteButtonStyle(disabled: bubble.sessions_.isEmpty))
        .disabled(!bubble.sessions_.isEmpty ? false : true)
    }
    
    // MARK: -
    init(_ bubble:Bubble) {
        self.bubble = bubble
        let bubbleColor = Color.bubbleColor(forName: bubble.color ?? "mint")
        let metrics = Metrics(bubbleColor: bubbleColor, titleColor: Color("silverText"))
        self.metrics = metrics
    }
    
    struct Metrics {
        let bubbleColor:Color
        let titleColor:Color
        
        let ratio = CGFloat(0.94)
        let width = CGFloat(220)
        var height:CGFloat { width / ratio }
        
        let backgroundRadius = CGFloat(40)
        let butonRadius = CGFloat(28)
        let backgroundColor = Color("deleteActionAlert1")
    }
    
    // MARK: -
    ///dismiss view
    private func cancelDeleteAction() {
        secretary.deleteAction_bRank = nil
        layoutViewModel.deleteActionViewOffset = nil
    }
    
    //ViewModel 1
    private func removeFiveSecondsBar() {
        if secretary.addNoteButton_bRank == Int(bubble.rank) { secretary.addNoteButton_bRank = nil }
    }
    
    private func removeAddTagButton() { viewModel.removeAddNoteButton(bubble) }
}

//struct DeleteActionAlert_Previews: PreviewProvider {
//    static var previews: some View {
//        DeleteActionAlert()
//    }
//}

extension BubbleDeleteActionAlert {
    struct Info:View {
        @State private var show = false
        private let title = "Delete/Reset Bubble"
        let subtitle = "Associated Calendar Events are safe! They will not be removed from the Calendar App"
        
        var body: some View {
            ZStack {
                if show {
                    Color.black.opacity(0.6).ignoresSafeArea()
                    
                    ThinMaterialLabel(title, subtitle) { content } action: { dismiss() }
                        .font(.system(size: 20))
                }
            }
            .onReceive(Secretary.shared.$showDeleteActionViewInfo) { output in
                withAnimation { show = output }
            }
        }
        
        // MARK: - Lego
        private var content:some View {
            HStack(alignment: .top) {
                Image("BubbleDelete")
                    .thumbnail(150)
                VStack(alignment: .leading, spacing: 8) {
                    VStack(alignment: .leading) {
                        Text("**Delete/Reset** \(Image.tap) Tap")
                        Text("*Yellow Button*")
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("**Dismiss** \(Image.tap) Tap")
                        Text("*Outside Gray Rectangle*")
                            .foregroundColor(.secondary)
                    }
                    .forceMultipleLines()
                }
            }
        }
        
        // MARK: -
        private func dismiss() { Secretary.shared.showDeleteActionViewInfo = false }
    }
}
