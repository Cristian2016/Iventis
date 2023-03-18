//
//  DPVDisplay.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 18.03.2023.
// DurationPickerView Display

import SwiftUI

struct DPVDisplay: View {
    let manager = DurationPickerView.Manager.shared
    
    @State private var hr = String()
    @State private var min = String()
    @State private var sec = String()
    
    let action: () -> ()
        
    var body: some View {
        ZStack {
            if hr.isEmpty {
                Text("Choose Duration")
            } else {
                HStack {
                    componentView(hr, \.hr)
                    componentView(min, \.min)
                    componentView(sec, \.sec)
                }
                .padding([.leading, .trailing], 4)
            }
        }
        .allowsHitTesting(false)
        .frame(height: 100)
        .background(.red)
        .onReceive(manager.$digits) { output in
            print("out from manager \(output)")
        }
    }
    
    // MARK: - Lego
    private func componentView(_ value:String, _ keyPath:KeyPath<DPVDisplay, String>) -> some View {
        
        var abbreviation:String = "ok"
        switch keyPath {
            case \.hr: abbreviation = "h"
            case \.min: abbreviation = "m"
            case \.sec: abbreviation = "s"
            default: abbreviation = ""
        }
        
        return HStack(alignment: .firstTextBaseline, spacing: 2) {
            Text(value)
                .font(.system(size: 80, design: .rounded))
                .minimumScaleFactor(0.1)
            Text(abbreviation)
                .font(.system(size: 20, design: .rounded))
                .fontWeight(.medium)
        }
    }
}

struct DPVDisplay_Previews: PreviewProvider {
    static var previews: some View {
        DPVDisplay { }
    }
}
