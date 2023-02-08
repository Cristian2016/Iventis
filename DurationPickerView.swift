//
//  DurationPickerView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 02.02.2023.
// Pickers https://www.youtube.com/watch?v=2pSDE56u2F0

import SwiftUI
import MyPackage

struct DurationPickerView: View {
    private let secretary = Secretary.shared
    @State private var color:Color?
    
    @EnvironmentObject private var viewModel:ViewModel
    
    @State private var hr:Int = 0
    @State private var min:Int = 0
    @State private var sec:Int = 0
    
    private let hrValues:Range<Int> = 0..<49
    private let minValues:Range<Int> = 0..<60
    private let secValues:Range<Int> = 0..<60
            
    private let columns = Array(repeating: GridItem(), count: 3)
    private let digits = ["7", "8", "9", "4", "5", "6", "1", "2", "3", "00", "0", "✕"]
    
    let metrics = Metrics()
    
    struct Metrics {
        let digitFont = Font.system(size: 45, weight: .regular, design: .rounded)
        let pickerFont = Font.system(size: 22)
    }
    
    var body: some View {
        ZStack {
            if let color = color {
                ZStack {
                    HStack {
                        Color
                            .background.standardShadow()
                        Rectangle().frame(width: 60)
                            .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .global)
                                .onEnded { _ in
                                    withAnimation {
                                        secretary.durationPicker_OfColor = nil
                                    }
                                }
                            )
                    }
                    
                    VStack {
                        let white = Color.white
                        
                        Rectangle()
                            .fill(.background)
                            .overlay {
                                HStack {
                                    DualTextView(content: .init(text1: "\(hr)", text2: "h"), metrics: .durationPicker)
                                    DualTextView(content: .init(text1: "\(min)", text2: "m"), metrics: .durationPicker)
                                    DualTextView(content: .init(text1: "\(sec)", text2: "s"), metrics: .durationPicker)
                                }
                                //                            .fontDesign(.rounded)
                                .allowsTightening(true)
                            }
                        
                        LazyVGrid(columns: columns) {
                            ForEach(digits, id:\.self) { symbol in
                                Circle().fill(symbol == "✕" ? .red : color)
                                    .overlay {
                                        Text(symbol)
                                            .font(metrics.digitFont)
                                            .foregroundColor(white)
                                    }
                                    .onTapGesture {
                                        print("Digit tapped")
                                    }
                            }
                        }
                    }
                    .padding(3)
                }
                .ignoresSafeArea()
                .gesture(swipeGesture)
                .transition(.move(edge: .leading))
            }
        }
        .onReceive(secretary.$durationPicker_OfColor) { color = $0 }
    }
    
    // MARK: - Lego
    private var pickers:some View {
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
    }
    
    // MARK: -
    private var swipeGesture:some Gesture {
        DragGesture()
            .onChanged { value in
                print(value)
            }
    }
}

struct DurationPickerView_Previews: PreviewProvider {
    static var previews: some View {
        DurationPickerView()
    }
}
