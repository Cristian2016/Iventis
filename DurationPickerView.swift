//
//  DurationPickerView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 02.02.2023.
// Pickers https://www.youtube.com/watch?v=2pSDE56u2F0

import SwiftUI

struct DurationPickerView: View {
    @State private var hr:Int = 0
    @State private var min:Int = 0
    @State private var sec:Int = 0
    
    private let hrValues:Range<Int> = 0..<49
    private let minValues:Range<Int> = 0..<60
    private let secValues:Range<Int> = 0..<60
        
    let bubbleColor:Color
    
    private let columns = Array(repeating: GridItem(), count: 3)
    private let digits = ["7", "8", "9", "4", "5", "6", "1", "2", "3", "00", "0", "✕"]
    
    var body: some View {
        VStack {
            let font = Font.system(size: 60, weight: .regular, design: .rounded)
            let white = Color.white
            
            HStack {
                Picker(selection: $hr) {
                    ForEach(hrValues, id: \.self) { number in
                        Text("\(number)")
                    }
                } label: { }
                Picker(selection: $min) {
                    ForEach(minValues, id: \.self) { number in
                        Text("\(number)")
                    }
                } label: { }
                Picker(selection: $sec) {
                    ForEach(secValues, id: \.self) { number in
                        Text("\(number)")
                    }
                } label: { }
            }
            .pickerStyle(.wheel)
            
            Rectangle()
                .fill(.background)
                .frame(height: 60)
                .overlay {
                    Text("\(hr)Hr \(min)Min \(sec)Sec")
                        .font(.largeTitle)
                }
            LazyVGrid(columns: columns) {
                ForEach(digits, id:\.self) { symbol in
                    digit.overlay {
                        Text(symbol)
                            .font(font)
                            .foregroundColor(white)
                    }
                }
            }
        }
        .padding(3)
    }
    
    // MARK: - Lego
    private var digit:some View {
        Circle().fill(bubbleColor)
    }
}

struct DurationPickerView_Previews: PreviewProvider {
    static var previews: some View {
        DurationPickerView(bubbleColor: .blue)
    }
}
