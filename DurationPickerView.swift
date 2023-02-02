//
//  DurationPickerView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 02.02.2023.
//

import SwiftUI

struct DurationPickerView: View {
    let color:Color
    
    private let columns = Array(repeating: GridItem(), count: 3)
    private let digits = ["7", "8", "9", "4", "5", "6", "1", "2", "3", "00", "0", "✕"]
    
    var body: some View {
        VStack {
            let font = Font.system(size: 60, weight: .medium, design: .rounded)
            vRoundedRectangle(corners: [.topLeft, .topRight], radius: 40)
            LazyVGrid(columns: columns) {
                ForEach(digits, id:\.self) { symbol in
                    digit.overlay { Text(symbol).font(font) }
                }
            }
        }
        .padding(3)
    }
    
    // MARK: - Lego
    private var digit:some View {
        Circle().fill(color)
    }
}

struct DurationPickerView_Previews: PreviewProvider {
    static var previews: some View {
        DurationPickerView(color: .blue)
    }
}
