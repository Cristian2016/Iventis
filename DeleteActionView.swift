//
//  DeleteActionView.swift
//  Timers
//
//  Created by Cristian Lapusan on 04.05.2022.
// markdown https://swiftuirecipes.com/user/pages/01.blog/markdown-in-swiftui-text/preview.gif

import SwiftUI

///same size on each device
struct DeleteActionView: View {
    let bubble:Bubble?
    let bubbleColor:Color
    
    @EnvironmentObject private var viewModel:ViewModel
    @EnvironmentObject private var layoutViewModel:LayoutViewModel
    
    //internal properties
    let ratio = CGFloat(0.8037)
    let width = CGFloat(200)
    static let height = CGFloat(250)
    let backgroundColor = Color("deleteActionViewBackground")
    let backgroundRadius = CGFloat(30)
    let buttonRadius = CGFloat(13)
    
    var body: some View {
            ZStack {
                Color.white.opacity(0.01)
                    .onTapGesture {
                        viewModel.deleteAction_bRank = nil
                        layoutViewModel.deleteActionViewOffset = nil
                    }
                RoundedRectangle(cornerRadius: backgroundRadius)
                    .fill(backgroundColor)
                    .frame(width: width, height: width/ratio)
                    .overlay {
                        VStack (spacing:6) {
                            trashView
                            
                            VStack {
                                deleteBubbleView
                                    .onTapGesture { withAnimation {
                                        viewModel.delete(bubble!)
                                        viewModel.deleteAction_bRank = nil
                                    } }
                                deleteHistoryView
                                    .onTapGesture { withAnimation {
                                        if !bubble!.sessions_.isEmpty {
                                            viewModel.reset(bubble!)
                                            viewModel.deleteAction_bRank = nil
                                        }
                                    } }
                            }
                            .font(.system(size: 30).weight(.medium))
                            .padding([.bottom], 6)
                        }
                        .padding()
                    }
            }
            .offset(x: 0, y: layoutViewModel.deleteActionViewOffset ?? 0)
    }
    
    // MARK: - Init
    init(_ bubble:Bubble?) {
        self.bubbleColor = Color.bubbleColor(forName: bubble?.color ?? "mint")
        self.bubble = bubble
    }
    
    // MARK: - Legos
    private var trashView:some View {
        HStack (alignment:.firstTextBaseline, spacing:2) {
            Image(systemName: "trash")
            Text("Delete")
        }
        .modifier(TrashModifier())
    }
    
    private var deleteBubbleView:some View {
        RoundedRectangle(cornerRadius: buttonRadius)
            .foregroundColor(bubbleColor)
            .overlay { Text("Bubble").foregroundColor(.white) }
    }
    
    private var deleteHistoryView: some View {
        let historyAvailable = bubble?.sessions_.isEmpty ?? false
        return RoundedRectangle(cornerRadius: buttonRadius)
            .foregroundColor(historyAvailable ? bubbleColor.opacity(0.3) : bubbleColor)
            .overlay { Text("History \(bubble?.sessions_.count ?? 0)")
                .foregroundColor(historyAvailable ? .white.opacity(0.3) :  .white) }
    }
    
    // MARK: - Modifiers
    struct TrashModifier : ViewModifier {
        func body(content: Content) -> some View {
            content
                .padding([.top], 0)
                .offset(x: -11, y: 0)
                .font(.system(size: 30).weight(.medium))
                .foregroundColor(.red)
        }
    }
}
