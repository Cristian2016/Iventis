//
//  DurationsView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 08.05.2023.
//

import SwiftUI

struct DurationsView: View {
    private let digits = [["1", "2", "3", "4"], ["5", "10", "15", "20"], ["30", "45", "60", "120"]]
    
    @EnvironmentObject private var viewModel:ViewModel
    
    // MARK: - Mode [either 1. create a timerBubble with color or 2. edit a timerBubble]
    @State private var bubble:Bubble?
        
    let gridSpacing = CGFloat(1)
    
    var body: some View {
        ZStack {
                VStack(spacing: 0) {
                    Text("Timer Duration in Minutes")
                        .padding(10)
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
                    ForEach(subarray, id: \.self) {
                        Digit(title: $0)
                    }
                }
            }
        }
    }
    
    // MARK: -
    
    init() {
        ScheduledNotificationsManager.shared.requestAuthorization()
    }
}

extension DurationsView {
    struct Digit:View {
        @State private var isTapped = false
        let title:String
        
        var body: some View {
            Color("deleteActionAlert1")
                .overlay {
                    Text(title)
                        .font(.system(size: 35, design: .rounded))
                        .minimumScaleFactor(0.1)
                        .foregroundColor(.white)
                }
                .onTapGesture {  } //1
        }
    }
}

struct DurationsView_Previews: PreviewProvider {
    static var previews: some View {
        DurationsView()
    }
}
