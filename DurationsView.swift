//
//  DurationsView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 08.05.2023.
//

import SwiftUI
import MyPackage

struct DurationsView: View {
    private let durations = [["1", "2", "3", "4"], ["5", "10", "15", "20"], ["30", "45", "60", "120"]]
    
    @EnvironmentObject private var viewModel:ViewModel
    
    // MARK: - Mode [either 1. create a timerBubble with color or 2. edit a timerBubble]
    let bubble:Bubble
    let color:Color
        
    let gridSpacing = CGFloat(1)
    
    var body: some View {
        ZStack {
                VStack(spacing: 0) {
                    digitsGrid.clipShape(clipShape)
                }
                .padding([.bottom])
                .padding(6)
                .background { vRectangle }
        }
        .frame(height: 290)
    }
    
    // MARK: - Lego
    private var clipShape:some Shape {
        vRoundedRectangle(corners: [.bottomLeft, .bottomRight], radius: 30)
    }
    
    private var vRectangle: some View {
        vRoundedRectangle(corners: [.bottomLeft, .bottomRight], radius: 40)
            .fill(.white)
            .padding([.bottom], 4) //2
    }
    
    private var digitsGrid:some View {
        Grid(horizontalSpacing: gridSpacing, verticalSpacing: gridSpacing) {
            GridRow {
                if bubble.isTimer {
                    Rectangle()
                        .fill(color)
                        .overlay {
                            Image.stopwatch
                                .foregroundColor(.white)
                                .font(.system(size: 32, weight: .medium))
                        }
                        .onTapGesture {
                            UserFeedback.singleHaptic(.light)
                            viewModel.change(bubble, to: .stopwatch)
                            dismiss()
                        }
                }
                
                Rectangle()
                    .fill(.clear)
                    .gridCellColumns(bubble.isTimer ? 3 : 4)
                    .overlay {
                        let title:LocalizedStringKey = bubble.isTimer ? "\(Image.timer) Change Duration" : "*\(Image.timer) Convert to Timer*"
                        let smallText:LocalizedStringKey = bubble.isTimer ? "*Minutes*" : "*Choose Minutes*"
                        VStack(spacing: 0) {
                            Text(title)
                                .font(.system(size: 22, weight: .medium))
                                .foregroundColor(.black)
                            Text("*Minutes*")
                                .foregroundColor(.secondary)
                                .font(.system(size: 18))
                        }
                    }
            }
            ForEach(durations, id: \.self) { subarray in
                GridRow {
                    ForEach(subarray, id: \.self) { value in
                        Digit(title: value, color) {
                            viewModel.change(bubble, to: .timer(Float(value)! * 60))
                            UserFeedback.singleHaptic(.light)
                            dismiss()
                        }
                    }
                }
            }
        }
    }
    
    // MARK: -
    
    init(_ bubble:Bubble) {
        self.bubble = bubble
        self.color = Color.bubbleColor(forName: bubble.color)
        ScheduledNotificationsManager.shared.requestAuthorization()
    }
    
    // MARK: -
    private func dismiss() {
        withAnimation {
            Secretary.shared.deleteAction_bRank = nil
        }
    }
}

extension DurationsView {
    struct Digit:View {
        let title:String
        let color:Color
        let action:() -> ()
        
        init(title: String, _ color:Color, _ action: @escaping () -> Void) {
            self.title = title
            self.color = color
            self.action = action
        }
        
        var body: some View {
            color
                .overlay {
                    symbol
                        .font(.system(size: 32, weight: .medium, design: .rounded))
                        .minimumScaleFactor(0.1)
                        .foregroundColor(.white)
                }
                .onTapGesture { action() }
        }
        
        @ViewBuilder
        private var symbol:some View {
            if title == "stopwatch" {
                Image.stopwatch
            } else {
                Text(title)
            }
        }
    }
}

struct DurationsView_Previews: PreviewProvider {
    
    static var previews: some View {
        DurationsView(BubbleDeleteButton1_Previews.bubble)
    }
}
