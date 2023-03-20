//
//  DPV.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 16.03.2023.
// DurationPickerView
// Pickers https://www.youtube.com/watch?v=2pSDE56u2F0
//1 self.color:Color? because self will appear when the user has chosen a color for the timer to be created. self will init with no values

import SwiftUI
import MyPackage

struct DurationPickerView: View {
    private let digits = [["7", "8", "9"], ["4", "5", "6"], ["1", "2", "3"], ["*", "0", "✕"]]
    
    @EnvironmentObject private var viewModel:ViewModel
    let manager = Manager.shared
    
    // MARK: - Mode [either 1. create a timerBubble with color or 2. edit a timerBubble]
    @State private var tricolor:Color.Tricolor? //1
    @State private var bubble:Bubble?
    
    @State private var hr:String?
    @State private var min:String?
    @State private var sec:String?
    
    let gridSpacing = CGFloat(1)
    
    private var swipeToClearDisplay:some Gesture {
        DragGesture(minimumDistance: 4)
            .onEnded { _ in clearDisplay() }
    }
    
    private func clearDisplay() {
        if !manager.digits.isEmpty {
            UserFeedback.singleHaptic(.heavy)
            manager.removeAllDigits()
        }
    }
    
    var body: some View {
        ZStack {
            if tricolor != nil {
                translucentBackground
                    .gesture(swipeToClearDisplay)
                    .onTapGesture { dismiss() }
                VStack(spacing: 0) {
                    Display { dismiss() }
                    digitsGrid
                }
                .padding([.leading, .trailing, .bottom])
                .padding(6)
                .background {
                    ZStack(alignment: .topTrailing) {
                        background
                        DPCheckmark()
                    }
                }
            }
        }
        .onReceive(Secretary.shared.$durationPickerMode) { output in
            if let mode = output {
                switch mode {
                    case .create(let tricolor):
                        self.tricolor = tricolor
                    case .edit(let bubble):
                        self.bubble = bubble
                }
            }
        }
    }
    
    private var swipe: some Gesture {
        DragGesture(minimumDistance: 5)
            .onEnded {
                let xTranslation = $0.translation.width
                
                if xTranslation > 0 {
                    print("advance right")
                } else {
                    print("advance left")
                }
            }
    }
    
    // MARK: - Lego
    private var translucentBackground:some View {
        Rectangle()
            .fill(.thinMaterial)
            .ignoresSafeArea()
    }
    
    private var background: some View {
        vRoundedRectangle(corners: [.bottomLeft, .bottomRight], radius: 40)
            .fill(.background)
            .padding([.leading, .trailing])
            .standardShadow()
            .onTapGesture { dismiss() }
            .gesture(swipeToClearDisplay)
    }
    
    private func componentView(_ value:String, _ keyPath:KeyPath<DurationPickerView, String>) -> some View {
        
        var abbreviation:String = "ok"
        switch keyPath {
            case \.hr: abbreviation = "h"
            case \.min: abbreviation = "m"
            case \.sec: abbreviation = "s"
            default: abbreviation = ""
        }
        
        return HStack(alignment: .firstTextBaseline, spacing: 2) {
            Text(value)
                .font(.system(size: 80, design: .rounded))
                .minimumScaleFactor(0.1)
            Text(abbreviation)
                .font(.system(size: 20, design: .rounded))
                .fontWeight(.medium)
        }
    }
    
    private var digitsGrid:some View {
        Grid(horizontalSpacing: gridSpacing, verticalSpacing: gridSpacing) {
            ForEach(digits, id: \.self) { subarray in
                GridRow {
                    ForEach(subarray, id: \.self) { title in
                        Digit(title: title, tricolor: self.tricolor!)
                    }
                }
            }
        }
        .background()
        .gesture(swipe)
    }
    
    // MARK: -
    func dismiss() {
        self.tricolor = nil
        if manager.digits.count%2 == 0 {
            print("create timers and remove all digits")
        } else {
            print("do not create timer, remove all digits")
        }
        manager.removeAllDigits()
    }
}

struct DPV_Previews: PreviewProvider {
    static var previews: some View {
        DurationPickerView()
    }
}
