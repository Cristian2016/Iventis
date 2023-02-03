//
//  DurationPickerView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 02.02.2023.
// Pickers https://www.youtube.com/watch?v=2pSDE56u2F0

import SwiftUI

struct DurationPickerView: View {
    @EnvironmentObject private var viewModel:ViewModel
    
    @State private var hr:Int = 0
    @State private var min:Int = 0
    @State private var sec:Int = 0
    
    private let hrValues:Range<Int> = 0..<49
    private let minValues:Range<Int> = 0..<60
    private let secValues:Range<Int> = 0..<60
        
    let color:Color
    
    private let columns = Array(repeating: GridItem(), count: 3)
    private let digits = ["7", "8", "9", "4", "5", "6", "1", "2", "3", "00", "0", "✕"]
    
    let metrics = Metrics()
    
    struct Metrics {
        let digitFont = Font.system(size: 45, weight: .regular, design: .rounded)
        let pickerFont = Font.system(size: 22)
    }
    
    var body: some View {
        HStack(spacing:0) {
            ZStack {
                Color.background.standardShadow()
                VStack {
                    let white = Color.white
                    
                    Rectangle()
                        .fill(.background)
                        .frame(height: 60)
                        .overlay {
                            HStack {
                                DualTextView(content: .init(text1: "\(hr)", text2: "h"), metrics: .durationPicker)
                                DualTextView(content: .init(text1: "\(min)", text2: "m"), metrics: .durationPicker)
                                DualTextView(content: .init(text1: "\(sec)", text2: "s"), metrics: .durationPicker)
                            }
                        }
                    
                    HStack {
                        Picker(selection: $hr) {
                            ForEach(hrValues, id: \.self) { number in
                                Text("\(number)").font(metrics.pickerFont)
                            }
                        } label: { }
                        Picker(selection: $min) {
                            ForEach(minValues, id: \.self) { number in
                                Text("\(number)")
                                    .font(metrics.pickerFont)
                            }
                        } label: { }
                        Picker(selection: $sec) {
                            ForEach(secValues, id: \.self) { number in
                                Text("\(number)")
                                    .font(metrics.pickerFont)
                            }
                        } label: { }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 160)
                
                    LazyVGrid(columns: columns) {
                        ForEach(digits, id:\.self) { symbol in
                            Button {
                                
                            } label: {
                                Circle().fill(symbol == "✕" ? .red : color)
                                    .overlay {
                                        Text(symbol)
                                            .font(metrics.digitFont)
                                            .foregroundColor(white)
                                    }
                            }
                        }
                    }
                }
                .padding(3)
            }
            Rectangle()
                .fill(Color.clear)
                .frame(width: 40)
                .contentShape(Rectangle()) //use if color clear otherwise gesture will not work
                .ignoresSafeArea()
                .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .global)
                    .onEnded { _ in
                        withAnimation {
                            viewModel.durationPicker_OfColor = nil
                        }
                    }
                )
        }
        .ignoresSafeArea()
    }
    
    // MARK: - Lego
}

struct DurationPickerView_Previews: PreviewProvider {
    static var previews: some View {
        DurationPickerView(color: .yellow)
    }
}
