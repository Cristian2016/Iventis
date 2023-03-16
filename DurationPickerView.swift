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
    private let digits = [["7", "8", "9"], ["4", "5", "6"], ["1", "2", "3"], ["00", "0", "✕"]]
    
    @EnvironmentObject private var viewModel:ViewModel
    @State private var color:Color? //1
    let gridSpacing = CGFloat(4)
    
    var body: some View {
        ZStack {
            if color != nil {
                ZStack {
                    VStack(spacing: 2) {
                        display
                        digitsGrid
                    }
                    .offset(y: -4)
                    .padding([.leading, .trailing, .bottom])
                    .padding(4)
                    .background {
                        vRoundedRectangle(corners: [.bottomLeft, .bottomRight], radius: 40)
                            .fill(.background)
                            .padding([.leading, .trailing])
                    }
                }
                .padding(4)
                .background(.ultraThinMaterial)
                .gesture(swipe)
                .transition(.move(edge: .leading))
            }
        }
        .onReceive(Secretary.shared.$durationPicker_OfColor) { color = $0 }
    }
    
    private var swipe: some Gesture {
        DragGesture(minimumDistance: 0)
            .onEnded { _ in
                dismiss()
            }
    }
    
    // MARK: - Lego
    private var display: some View {
        Text("12:56:89")
            .font(.system(size: 80, design: .rounded))
            .minimumScaleFactor(0.1)
            .frame(height: 100)
            .background()
            .onTapGesture { dismiss() }
    }
    
    private var digitsGrid:some View {
        Grid(horizontalSpacing: gridSpacing, verticalSpacing: gridSpacing) {
            ForEach(digits, id: \.self) { subarray in
                GridRow {
                    ForEach(subarray, id: \.self) { title in
                        Digit(title: title, color: self.color!)
                    }
                }
            }
        }
    }
    
    // MARK: -
    func dismiss() {
        withAnimation {
            self.color = nil
        }
    }
}

extension DurationPickerView {
    struct Digit:View {
        @State private var isTapped = false
        let title:String
        let color:Color
        
        @ViewBuilder
        private var shape:some View {
            switch title {
                case "✕":
                    vRoundedRectangle(corners: .bottomRight, radius: 32)
                        .fill(color)
                case "00":
                    vRoundedRectangle(corners: .bottomLeft, radius: 32)
                        .fill(color)
                default:
                    Rectangle()
                        .fill(color)
            }
        }
        
        var body: some View {
            shape
                .overlay {
                    Text(title)
                        .font(.system(size: 50, design: .rounded))
                        .minimumScaleFactor(0.1)
                        .foregroundColor(.white)
                }
                .opacity(isTapped ? 0.6 : 1.0)
                .onTapGesture {
                    UserFeedback.singleHaptic(.light)
                    withAnimation(.easeIn(duration: 0.1)) {
                        isTapped = true
                    }
                    delayExecution(.now() + 0.12) {
                        isTapped = false
                    }
                }
        }
    }
    
    struct RightStrip:View {
        var body: some View {
            Rectangle()
                .opacity(0.01)
                .frame(width: 6)
                .gesture(swipe)
        }
        
        private var swipe: some Gesture {
            DragGesture(minimumDistance: 0)
                .onEnded { _ in
                    action()
                }
        }
        
        let action: () -> ()
    }
}

struct DPV_Previews: PreviewProvider {
    static var previews: some View {
        DurationPickerView()
    }
}
