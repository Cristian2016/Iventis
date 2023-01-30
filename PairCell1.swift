//
//  PairCell1.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 30.01.2023.
//1 ex: if it's not @StateObject it will not update stickyNote content
// pair is actually the wrapped value. _pair is the StateObject struct
// @StateObject var pair:Pair means struct StateObject has a wrapped value of type Pair

import SwiftUI
import MyPackage

struct PairCell1: View {
    @EnvironmentObject var viewModel:ViewModel
    @StateObject var pair:Pair //1
    let pairNumber:Int
    let duration:Float.TimeComponentsAsStrings?
    
    var body: some View {
        ZStack {
            Push(.topRight) { separatorLine.overlay { pairNumberView }}
            
            VStack {
                
            }
        }
    }
    
    // MARK: - Lego
    private var separatorLine: some View {
        Rectangle()
            .fill(Color.label)
            .frame(width: 30, height: 2)
            .offset(y: -4)
    }
    
    private var pairNumberView:some View {
        Text(String(pairNumber))
            .font(.system(size: 20))
            .offset(x: 6, y: 10)
    }
      
    // MARK: -
    init(_ pair:Pair, _ pairNumber:Int) {
        _pair = StateObject(wrappedValue: pair)
        let decoder = JSONDecoder()
        let result = try? decoder.decode(Float.TimeComponentsAsStrings.self, from: pair.durationAsStrings ?? Data())
        self.duration = result
        self.pairNumber = pairNumber
    }
}
