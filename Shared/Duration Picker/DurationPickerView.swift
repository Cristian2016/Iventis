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
//4 this is how app knows topMostView displayed to the user is the DurationPickerView
//5 either create new timer or edit duration of existing timer

import SwiftUI
import MyPackage

struct DurationPickerView: View {
    @EnvironmentObject private var viewModel:ViewModel
    let manager = Manager.shared
    
    // MARK: - Mode [either 1. create a timerBubble with color or 2. edit a timerBubble]
    @State private var tricolor:Color.Tricolor? //1
    @State private var bubble:Bubble?
    @State private var reason:Secretary.DurationPickerReason = .none
    
    private let twoDDigits = [["7", "8", "9"], ["4", "5", "6"], ["1", "2", "3"], ["*", "0", "✕"]]
    
    let gridSpacing = CGFloat(1)
    
    var body: some View {
        ZStack {
            if tricolor != nil {
                translucentBackground
                    .gesture(swipeToClearDisplay)
                    .onTapGesture { dismiss() }
                VStack(spacing: 0) {
                    Display(reason) { dismiss() }
                    digitsGrid
                        .overlay { DPOKCircle { dismiss() } }
                }
                .padding([.leading, .trailing, .bottom])
                .padding(6)
                .background { vRectangle }
                .overlay { Info() }
            }
        }
        .onChange(of: tricolor) { handle(tricolor: $0) }
        .onReceive(Secretary.shared.$durationPickerReason) { reason = $0 }
        .onChange(of: reason) { newReason in
            switch newReason {
                case .editExistingTimer(let bubble):
                    print("initiaClock \(bubble.initialClock)")
                    manager.digits = [1, 2, 3, 4, 5, 6]
                case .createTimer(let tricolor):
                    self.tricolor = tricolor
                default:
                    break
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
    
    private var digitsGrid:some View {
        Grid(horizontalSpacing: gridSpacing, verticalSpacing: gridSpacing) {
            ForEach(twoDDigits, id: \.self) { digits in
                GridRow { ForEach(digits, id: \.self) { Digit($0, tricolor!) }}
            }
        }
        .background()
    }
    
    // MARK: - Gesture
    private var swipeToClearDisplay:some Gesture {
        DragGesture(minimumDistance: 4)
            .onEnded { _ in clearDisplay() }
    }
    
    // MARK: -
    private func clearDisplay() {
        if !manager.digits.isEmpty {
            UserFeedback.singleHaptic(.heavy)
            manager.removeAllDigits()
        }
    }
    
    private func dismiss() {
        let reason = Secretary.shared.durationPickerReason
        
        switch reason {
//            case .edit(let bubble):
//                manager.shouldEditDuration(bubble)
//
//            case .none:
//                break
                
            case .createTimer(let tricolor):
                manager.shouldComputeInitialClock(color: tricolor.description)
            default: break
        }
        
        self.tricolor = nil //dismiss Self
        manager.removeAllDigits()
        Secretary.shared.durationPickerReason = .none
    }
    
//    private func handle(mode: Secretary.Mode?) {
//        guard let mode = mode else {
//            if self.tricolor != nil { self.tricolor = nil }
//            return
//        }
//
//        switch mode {
//            case .create(let tricolor):
//                self.tricolor = tricolor
//
//            case .edit(let bubble):
//                self.bubble = bubble
//                self.tricolor = Color.tricolor(forName: bubble.color)
//
//                if bubble.isTimer { self.manager.digits = [] }
//                else {
//
//                }
//        }
//    } //5
    
    private func handle(tricolor:Color.Tricolor?) {
        guard tricolor != nil else { return }
        Secretary.shared.topMostView = .durationPicker
    } //4
    
    init() {
        ScheduledNotificationsManager.shared.requestAuthorization()
    }
}

extension DurationPickerView {
    struct Info:View {
        @State private var show = false
        private let title = "Timer Duration"
        private let subtitle:LocalizedStringKey = "\(Image(systemName: "checkmark.circle.fill")) checkmark means timer's duration is ok"
        
        var body: some View {
            ZStack {
                if show {
                    Color.black
                        .opacity(0.6)
                        .ignoresSafeArea()
                    
                    ThinMaterialLabel(title, subtitle) { InfoView() } action: { dismiss() } moreInfo: { moreInfo() }
                        .font(.system(size: 20))
                }
            }
            .onReceive(Secretary.shared.$showDurationPickerInfo) { output in
                withAnimation { show = output }
            }
        }
        
        private func dismiss() { Secretary.shared.showDurationPickerInfo = false }
        
        private func moreInfo() { Secretary.shared.showInfoVH = true }
    }
}

extension DurationPickerView {
    struct InfoView: View {
        var body: some View {
            HStack(alignment: .top) {
                Image.dpv.thumbnail()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("*Use Yellow Areas to*")
                        .foregroundColor(.secondary)
                    Divider()
                    InfoUnit(.dpCreate)
                    InfoUnit(.dpDismiss)
                    InfoUnit(.dpClear)
                }
            }
            .font(.system(size: 22))
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
