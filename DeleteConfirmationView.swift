//
//  DeleteConfirmationView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 31.01.2023.
//  replaces DeleteActionView

import SwiftUI

struct DeleteConfirmationView: View {
    @EnvironmentObject private var viewModel:ViewModel
    
    struct Metrics {
        let backgroundRadius = CGFloat(30)
        let backgroundColor = Color("deleteActionViewBackground")
        let width = CGFloat(200)
        let buttonRadius = CGFloat(13)
        let bubbleColor:Color
        let buttonHeight:CGFloat = 80
    }
    
    let metrics:Metrics
    
    init(_ metrics:Metrics) {
        self.metrics = metrics
    }
    
    // MARK: -
    ///dismiss view
    private func cancelDeleteAction() {
        
    }
    
    //// MARK: -
    var body: some View {
        ZStack {
            Color.white.opacity(0.01)
                .onTapGesture { cancelDeleteAction() }
            VStack (spacing:6) {
                trashView
                
                VStack {
                    deleteBubbleView
                }
            }
            .frame(width: metrics.width)
            .padding()
            .background {
                RoundedRectangle(cornerRadius: metrics.backgroundRadius)
                    .fill(metrics.backgroundColor)
            }
        }
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
    
    // MARK: - Modifiers
}

struct DeleteConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        DeleteConfirmationView(DeleteConfirmationView.Metrics(bubbleColor: .orange))
    }
}
