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
    @Environment(ViewModel.self) var viewModel
    let manager = Manager.shared
    
    // MARK: - Mode [either 1. create a timerBubble with color or 2. edit a timerBubble]
    @State private var tricolor:Color.Tricolor? //1
    @State private var bubble:Bubble?
    @State private var reason:Secretary.DurationPickerReason = .none
    
    @AppStorage("showDPVHint", store: .shared) var showDPInfo = true
    
    let radii = RectangleCornerRadii(topLeading: 0, bottomLeading: 40, bottomTrailing: 40, topTrailing: 0)
    
    private let twoDDigits = [["7", "8", "9"], ["4", "5", "6"], ["1", "2", "3"], ["*", "0", "✕"]]
        
    var body: some View {
        let show = tricolor != nil
        let reasonPublisher = Secretary.shared.$durationPickerReason
        
        ZStack {
            if show {
                Background()
                    .gesture(swipeToClearDisplay)
                    .onTapGesture { dismiss() }
                
              VStack(spacing: 0) {
                    Display(reason) { dismiss() }
                    digitsGrid
                        .overlay { DPOKCircle { dismiss() }}
                }
                .padding([.leading, .trailing, .bottom])
                .padding(6)
                .background { vRectangle }
                .onChange(of: tricolor) { handle(tricolor: $1) }
                .frame(maxHeight: 700)
            }
        }
        .onReceive(reasonPublisher) { reason = $0 }
        .onChange(of: reason) { reasonChanged($1) }
        .overlay { Info() }
    }

    // MARK: - Lego
    private var vRectangle: some View {
        UnevenRoundedRectangle(cornerRadii: radii, style: .continuous)
            .fill(.thickMaterial)
            .padding([.leading, .trailing])
            .padding([.bottom], 4) //2
            .standardShadow()
            .onTapGesture { dismiss() }
            .gesture(swipeToClearDisplay)
    }
    
    private var digitsGrid:some View {
        Grid(horizontalSpacing: 1.0, verticalSpacing: 1.0) {
            ForEach(twoDDigits, id: \.self) { digits in
                GridRow { ForEach(digits, id: \.self) { Digit($0, tricolor!) }}
            }
        }
        .clipShape(UnevenRoundedRectangle(cornerRadii: radii, style: .continuous))
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
    
    private func reasonChanged(_ newReason:Secretary.DurationPickerReason) {
        switch newReason {
            case .createTimer(let tricolor):
                self.tricolor = tricolor
                
            case .editExistingTimer(let bubble):
                self.tricolor = Color.tricolor(forName: bubble.color)
                manager.digits = [1, 2, 3, 4]
                
            default:
                break
        }
    }
    
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
        @AppStorage("showDPVHint", store: .shared) var showDPInfo = true
        
        var body: some View {
            let publisher = Secretary.shared.$showDurationPickerInfo
            
            ZStack {
                if showDPInfo {
                    Background(.dark())
                    MaterialLabel(title, subtitle) { InfoView() } _: { dismiss() } _: { moreInfo() }
                }
            }
            .onReceive(publisher) { output in withAnimation { showDPInfo = output }}
        }
        
        // MARK: -
        private func dismiss() {
            showDPInfo = false
            Secretary.shared.showDurationPickerInfo = false
        }
        private func moreInfo() { Secretary.shared.showInfoVH = true }
        
        // MARK: -
        private let title = "Timer Duration"
        private let subtitle:LocalizedStringKey = "\(Image(systemName: "checkmark.circle.fill")) checkmark means duration is valid"
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