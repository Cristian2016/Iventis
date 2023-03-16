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
    
    var body: some View {
        ZStack {
            if let color = color {
                VStack(spacing: 2) {
                    Rectangle()
                        .frame(height: 100)
                        .onTapGesture {
                            self.color = nil
                        }
                    Grid(horizontalSpacing: 2, verticalSpacing: 2) {
                        ForEach(digits, id: \.self) { subarray in
                            GridRow {
                                ForEach(subarray, id: \.self) { digit in
                                    Rectangle()
                                        .fill(color)
                                        .overlay {
                                            Text(digit)
                                                .font(.system(size: 200, design: .rounded))
                                                .minimumScaleFactor(0.1)
                                                .foregroundColor(.white)
                                        }
                                }
                            }
                        }
                    }
                }
                .padding(2)
                .background()
            }
        }
        .onReceive(Secretary.shared.$durationPicker_OfColor) { color = $0 }
    }
}

struct DPV_Previews: PreviewProvider {
    static var previews: some View {
        DPV()
    }
}
