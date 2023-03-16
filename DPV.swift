//
//  DPV.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 16.03.2023.
// DurationPickerView
//1 self.color:Color? because self will appear when the user has chosen a color for the timer to be created. self will init with no values

import SwiftUI

struct DPV: View {
    private let digits = [["7", "8", "9"], ["4", "5", "6"], ["1", "2", "3"], ["00", "0", "✕"]]
    
    @EnvironmentObject private var viewModel:ViewModel
    @State private var color:Color? //1
    let gridSpacing = CGFloat(4)
    
    var body: some View {
        ZStack {
            if let color = color {
                ZStack(alignment: .trailing) {
                    VStack(spacing: 2) {
                        display
                        digitsGrid
                    }
                    .padding(6)
                    .background()
                    RightStrip { self.color = nil }
                }
            }
        }
        .onReceive(Secretary.shared.$durationPicker_OfColor) { color = $0 }
    }
    
    // MARK: - Lego
    private var display: some View {
        Text("12:56:89")
            .foregroundColor(.black)
            .font(.system(size: 90, design: .rounded))
            .frame(height: 100)
            .onTapGesture {
                self.color = nil
            }
    }
    
    private var digitsGrid:some View {
        Grid(horizontalSpacing: gridSpacing, verticalSpacing: gridSpacing) {
            ForEach(digits, id: \.self) { subarray in
                GridRow {
                    ForEach(subarray, id: \.self) { digit in
                        Rectangle()
                            .fill(color!)
                            .overlay {
                                Text(digit)
                                    .font(.system(size: 65, design: .rounded))
                                    .minimumScaleFactor(0.1)
                                    .foregroundColor(.white)
                            }
                    }
                }
            }
        }
        .clipShape(vRoundedRectangle(corners: [.bottomLeft, .bottomRight], radius: 30))
    }
}

extension DPV {
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
        DPV()
    }
}
