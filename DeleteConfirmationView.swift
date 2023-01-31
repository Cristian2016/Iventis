//
//  DeleteConfirmationView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 31.01.2023.
//  replaces DeleteActionView

import SwiftUI

struct DeleteConfirmationView: View {
    @EnvironmentObject private var viewModel:ViewModel
    @EnvironmentObject private var layoutViewModel:LayoutViewModel
    
    let bubble:Bubble
    let metrics:Metrics
    
    struct Metrics {
        let backgroundRadius = CGFloat(30)
        let backgroundColor = Color("deleteActionViewBackground")
        let width = CGFloat(170)
        let buttonRadius = CGFloat(13)
        let bubbleColor:Color
        let buttonHeight:CGFloat = 74
    }
    
    init(_ bubble:Bubble) {
        self.bubble = bubble
        
        let bubbleColor = Color.bubbleColor(forName: bubble.color ?? "mint")
        let metrics = Metrics(bubbleColor: bubbleColor)
        self.metrics = metrics
        
    }
    
    // MARK: -
    ///dismiss view
    private func cancelDeleteAction() {
        viewModel.deleteAction_bRank = nil
        layoutViewModel.deleteActionViewOffset = nil
    }
    
    //// MARK: -
    var body: some View {
        ZStack {
            Color.white.opacity(0.01)
                .onTapGesture { cancelDeleteAction() }
            VStack (spacing:8) {
                trashView
                deleteBubbleView
                    .onTapGesture {
                        withAnimation {
                            viewModel.delete(bubble)
                            viewModel.deleteAction_bRank = nil
                        }
                    }
                if !bubble.sessions_.isEmpty {
                    deleteHistoryView
                        .onTapGesture {
                            if !bubble.sessions_.isEmpty {
                                viewModel.reset(bubble)
                                viewModel.deleteAction_bRank = nil
                            }
                        }
                }
            }
            .font(.system(size: 30).weight(.medium))
            .frame(width: metrics.width)
            .padding()
            .background {
                RoundedRectangle(cornerRadius: metrics.backgroundRadius)
                    .fill(metrics.backgroundColor)
            }
        }
//        .offset(x: 0, y: layoutViewModel.deleteActionViewOffset ?? 0)
    }
    
    // MARK: - Legos
    private var trashView:some View {
        HStack (spacing:2) {
            Image.trash
            Text("Delete")
        }
        .font(.system(size: 30).weight(.medium))
        .foregroundColor(.red)
    }
    
    private var deleteBubbleView:some View {
        RoundedRectangle(cornerRadius: metrics.buttonRadius)
            .foregroundColor(metrics.bubbleColor)
            .overlay { Text("Bubble").foregroundColor(.white) }
            .frame(height: metrics.buttonHeight)
    }
    
    private var deleteHistoryView: some View {
        let historyAvailable = bubble.sessions_.isEmpty
        return RoundedRectangle(cornerRadius: metrics.buttonRadius)
            .foregroundColor(historyAvailable ? metrics.bubbleColor.opacity(0.3) : metrics.bubbleColor)
            .overlay { Text("History \(bubble.sessions_.count)")
                .foregroundColor(historyAvailable ? .white.opacity(0.3) :  .white) }
            .frame(height: metrics.buttonHeight)
    }
    
    // MARK: - Modifiers
}

struct DeleteConfirmationView_Previews: PreviewProvider {
    static let bubble:Bubble = {
        let bubble = Bubble(context: PersistenceController.preview.viewContext)
        bubble.color = "orange"
        
        let session = Session(context: PersistenceController.preview.viewContext)
        bubble.sessions_ = [session]
        return bubble
    }()
    static var previews: some View {
        DeleteConfirmationView(bubble)
    }
}
