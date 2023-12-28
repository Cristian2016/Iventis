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
//6 DurationPickerView can be dismissed in 3 ways: user drags down the sheet, taps outsite sheet, dismiss.callAsFunction()
//7 reason is retained as copy because timer is created when view disappears, not when a button is tapped or other reason. If duration is valid, a timer will be created/edited when Self disappears

import SwiftUI
import MyPackage

extension DurationPickerOverlay {
    typealias Reason = ViewModel.DurationPicker.Reason
    typealias Kind = ControlOverlay.BubbleLabel.Kind
}

struct DurationPickerOverlay: View {
    @Environment(ViewModel.self) var viewModel
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    let model = HintOverlay.Model.shared
    
    private var isPortrait:Bool { verticalSizeClass == .regular }
    
    private let manager = Manager()
    
    // MARK: - Mode [either 1. create a timerBubble with color or 2. edit a timerBubble]
    @State private var tricolor:Color.Tricolor? //1
    @State private var bubble:Bubble?
    
    private let kind:Kind
    
    @AppStorage("showDPVHint", store: .shared) var showDPInfo = true
    @AppStorage("showHint") var showHint = true
    
    private let twoDDigits = [["7", "8", "9"], ["4", "5", "6"], ["1", "2", "3"], ["*", "0", "✕"]]
    
    // MARK: - Init and its variables
    private var reason:Reason!
    
    init?(reason:Reason?) {
        guard let reason = reason else { return nil }
        
        self.reason = reason
        
        switch reason {
            case .createTimer(let tricolor):
                _tricolor = .init(wrappedValue: tricolor)
                self.kind = .noBubble(tricolor)
                
            case .changeToTimer(let bubble):
                _bubble = .init(wrappedValue: bubble)
                _tricolor = .init(wrappedValue: Color.tricolor(forName: bubble.color))
                self.kind = .hasBubble(bubble)
                
            case .editExistingTimer(let bubble):
                _bubble = .init(wrappedValue: bubble)
                _tricolor = .init(wrappedValue: Color.tricolor(forName: bubble.color))
                self.kind = .hasBubble(bubble)
        }
        ScheduledNotificationsManager.shared.requestAuthorization()
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            Background(.dark(.Opacity.overlay))
                .onTapGesture {
                    handleReason()
                    dismiss()
                }
                .overlay(alignment: .top) { ControlOverlay.BubbleLabel(kind) }
            
            let layout = isPortrait ? AnyLayout(VStackLayout(spacing: 0)) : AnyLayout(HStackLayout(alignment: .top))
            
            OverlayScrollView {
                layout {
                    VStack {
                        Display(reason: reason, manager: manager)
                            .onTapGesture {
                                handleReason()
                                dismiss()
                            }
                            .overlay(alignment: .bottom) { if !isPortrait { Separator() }}
                        
//                        if !isPortrait { InfoView2(manager: manager) }
                    }
                    
                    let edges = isPortrait ? [.leading, .trailing, .bottom] : Edge.Set.all
                    
                    digitsGrid
                        .overlay {
                            BigCheckmark(manager: manager) {
                                handleReason()
                                dismiss()
                            }
                        }
                        .padding(edges, 8)
                        .aspectRatio(1.28, contentMode: .fit)
                }
                .frame(maxWidth: isPortrait ? 360 : .infinity)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10))
                .compositingGroup()
                .standardShadow()
            } action: {
                handleReason()
                dismiss()
            }
            .gesture(swipeToClearDisplay)
        }
    }
    
    // MARK: - Lego
    private var digitsGrid:some View {
        Grid(horizontalSpacing: 2, verticalSpacing: 2) {
            ForEach(twoDDigits, id: \.self) { digits in
                GridRow {
                    ForEach(digits, id: \.self) { digit in
                        Digit(digit, tricolor, manager)
                    }
                }
            }
        }
        .scrollTargetBehavior(.paging)
    }
    
    // MARK: - Gesture
    private var swipeToClearDisplay:some Gesture {
        DragGesture(minimumDistance: 4)
            .onEnded { _ in clearDisplay() }
    }
    
    // MARK: -
    private func clearDisplay() {
        if !manager.digits.isEmpty {
            UserFeedback.singleHaptic(.medium)
            manager.reset()
        }
    }
    
    ///create/edit/change to timer
    private func handleReason() {
        guard manager.isDurationValid else {
            switch reason {
                case .createTimer(_):
                    model.topmostView(.palette)
                case .changeToTimer(_):
                    model.topmostView(viewModel.path.isEmpty ? .bubbleList : .detail)
                case .editExistingTimer(_):
                    model.topmostView(viewModel.path.isEmpty ? .bubbleList : .detail)
                case .none: break
            }
            
            return
        }
        
        //duration is valid
        switch reason {
            case .createTimer(let tricolor):
                manager.shouldComputeInitialClock(color: tricolor.description)
                
            case .editExistingTimer(let bubble):
                manager.shouldEditDuration(bubble)
                
            case .changeToTimer(let bubble):
                UserFeedback.singleHaptic(.medium)
                let initialClock = zip(manager.digits, manager.matrix).reduce(0) { $0 + $1.0 * $1.1 }
                viewModel.change(bubble, to: .timer(Float(initialClock)))
            case .none : break
        }
    }
    
    private func dismiss() {
        viewModel.durationPicker.reason = nil
    }
}
