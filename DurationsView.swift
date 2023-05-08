//
//  DurationsView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 08.05.2023.
//

import SwiftUI
import MyPackage

struct DurationsView: View {
    private let digits = [["1", "2", "3", "4"], ["5", "10", "15", "20"], ["30", "45", "60", "120"]]
    
    @EnvironmentObject private var viewModel:ViewModel
    
    // MARK: - Mode [either 1. create a timerBubble with color or 2. edit a timerBubble]
    let bubble:Bubble
    let color:Color
        
    let gridSpacing = CGFloat(1)
    
    var body: some View {
        ZStack {
                VStack(spacing: 0) {
                    Text("\(Image.timer) Change Duration")
                        .padding(10)
                        .font(.system(size: 22))
                    digitsGrid.clipShape(clipShape)
                }
                .padding([.leading, .trailing, .bottom])
                .padding(6)
                .background { vRectangle }
        }
        .frame(height: 300)
    }
    
    // MARK: - Lego
    private var clipShape:some Shape {
        vRoundedRectangle(corners: [.bottomLeft, .bottomRight], radius: 30)
    }
    
    private var translucentBackground:some View {
        Rectangle()
            .fill(.thinMaterial)
            .ignoresSafeArea()
    }
    
    private var vRectangle: some View {
        vRoundedRectangle(corners: [.bottomLeft, .bottomRight], radius: 40)
            .fill(.background)
            .padding([.leading, .trailing])
            .padding([.bottom], 4) //2
            .standardShadow()
    }
    
    private var digitsGrid:some View {
        Grid(horizontalSpacing: gridSpacing, verticalSpacing: gridSpacing) {
            ForEach(digits, id: \.self) { subarray in
                GridRow {
                    ForEach(subarray, id: \.self) { value in
                        Digit(title: value, color) {
                            viewModel.change(bubble, into: .timer(Float(value)! * 60))
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
                    Text(title)
                        .font(.system(size: 35, weight: .medium, design: .rounded))
                        .minimumScaleFactor(0.1)
                        .foregroundColor(.white)
                }
                .onTapGesture { action() }
        }
    }
}

//struct DurationsView_Previews: PreviewProvider {
//    static var previews: some View {
//        DurationsView(<#Bubble#>)
//    }
//}
