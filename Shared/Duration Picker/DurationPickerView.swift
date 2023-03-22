//
//  DPV.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 16.03.2023.
// DurationPickerView
// Pickers https://www.youtube.com/watch?v=2pSDE56u2F0
//1 self.color:Color? because self will appear when the user has chosen a color for the timer to be created. self will init with no values
//2 on iPhone 8 looks bad without a bit of padding
//3 order matters! it is applied before applying the paddings to the vRoundedRect

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
                .background { vRectangle }
                .overlay { Info() }
            }
        }
        .onReceive(Secretary.shared.$durationPickerMode) { handle(mode: $0) }
        .onChange(of: tricolor) { handle(tricolor: $0) }
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
    
    private var vRectangle: some View {
        vRoundedRectangle(corners: [.bottomLeft, .bottomRight], radius: 40)
            .fill(.background)
            .padding([.leading, .trailing])
            .padding([.bottom], 4) //2
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
    private func dismiss() {
        manager.computeInitialClock(color: tricolor!.description)
        self.tricolor = nil
        manager.removeAllDigits()
    }
    
    ///either create new timer or edit duration of existing timer
    private func handle(mode: Secretary.Mode?) {
        if let mode = mode {
            switch mode {
                case .create(let tricolor):
                    self.tricolor = tricolor
                case .edit(let bubble):
                    self.bubble = bubble
            }
        }
    }
    
    private func handle(tricolor:Color.Tricolor?) {
        guard let tricolor = tricolor else { return }
        Secretary.shared.topMostView = .durationPicker
    }
}

extension DurationPickerView {
    struct Info:View {
        @State private var show = false
        
        var body: some View {
            ZStack {
                if show {
                    Rectangle()
                        .fill(Color.label.opacity(0.8))
                        .ignoresSafeArea()
                    
                    ThinMaterialLabel(title: "Timer Duration") {
                        VStack {
                            Text("*Use Yellow Areas to*")
                        }
                        .foregroundColor(.secondary)
                        Divider().frame(maxWidth: 300)
                        DPInfoView()
                    } action: { dismiss() }
                        .font(.system(size: 20))
                }
            }
            .onReceive(Secretary.shared.$showDurationPickerInfo) { output in
                withAnimation { show = output }
            }
        }
        
        private func dismiss() {
            Secretary.shared.showDurationPickerInfo = false
        }
    }
}

extension UIViewController {
    open override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
            if motion == .motionShake {
                if !Secretary.shared.showBlueInfoButton {
                    UserFeedback.singleHaptic(.heavy)
                    Secretary.shared.showBlueInfoButton = true
                }
            }
        }
    }
