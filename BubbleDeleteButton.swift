//
//  DeleteActionAlert.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 01.02.2023.
//

import SwiftUI
import MyPackage

extension BubbleDeleteButton {
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

struct BubbleDeleteButton: View {
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
        ZStack(alignment: .topLeading) {
//            Image(systemName: "info.circle.fill")
//                .fontWeight(.medium)
//                .contentShape(Rectangle())
//                .padding(-14)
//                .font(.system(size: 24))
            RoundedRectangle(cornerRadius: metrics.radius)
                .frame(width: metrics.width, height: metrics.height)
                .standardShadow()
        }
        .foregroundColor(metrics.backgroundColor)
        .onTapGesture { secretary.showBubbleDeleteInfo = true }
    }
    
    private var titleLabel:some View {
        Text("\(Image.info) **Delete**")
            .foregroundColor(.red)
            .padding(.bottom, 6)
            .allowsHitTesting(false)
            .font(.system(size: 23))
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
                secretary.deleteAction_bRank = nil
                removeFiveSecondsBar()
            }
        } label: {
            vRoundedRectangle(corners: [.bottomLeft, .bottomRight], radius: metrics.butonRadius)
                .fill(bubble.sessions_.isEmpty ? metrics.bubbleColor.opacity(0.4) : metrics.bubbleColor)
                .frame(width: 208, height: 84)
                .overlay {
                    let count = bubble.sessions_.count
                    let text:LocalizedStringKey = count > 0 ? "^[\(bubble.sessions_.count) Entry](inflect: true)" : "0 Entries"
                    
                    Text(text)
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
        let metrics = Metrics(bubbleColor: bubbleColor)
        self.metrics = metrics
    }
    
    struct Metrics {
        let bubbleColor:Color
        let titleColor = Color("silverText")
        
        let ratio = CGFloat(0.90)
        let width = CGFloat(220)
        var height:CGFloat { width / ratio }
        
        let radius = CGFloat(40)
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

extension BubbleDeleteButton {
    struct Info:View {
        @State private var show = false
        private let title = "Delete Bubble/Activity Entries"
        let subtitle = "Calendar Events are safe! Delete actions do not remove events in the Calendar App"
        
        var body: some View {
            ZStack {
                if show {
                    Color.black.opacity(0.6).ignoresSafeArea()
                    
                    ThinMaterialLabel(title, subtitle) { content } action: { dismiss() }
                        .font(.system(size: 20))
                }
            }
            .onReceive(Secretary.shared.$showBubbleDeleteInfo) { output in
                withAnimation { show = output }
            }
        }
        
        // MARK: - Lego
        private var content:some View {
            HStack {
                Image("BubbleDelete")
                    .thumbnail(150)
                VStack(alignment: .leading) {
                    Text("**Dismiss** \(Image.tap) Tap")
                    Text("*outside Gray Shape*")
                    Button("show more") {
                        Secretary.shared.bubbleDeleteButtonShowMore = true
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        
        // MARK: -
        private func dismiss() { Secretary.shared.showBubbleDeleteInfo = false }
    }
}
