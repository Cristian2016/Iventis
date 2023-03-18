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
                    if !min.isEmpty { componentView(min, \.min) }
                    if !sec.isEmpty { componentView(sec, \.sec) }
                }
                .padding([.leading, .trailing], 4)
            }
        }
        .frame(height: 100)
        .background(.red)
        .allowsHitTesting(false)
        .onReceive(manager.$digits) { output in
            print("out from manager \(output)")
            switch output.count {
                case 0:
                    hr = ""
                    min = ""
                    sec = ""
                case 1, 2: hr = output.reduce("") { String($0) + String($1) }
                case 3, 4: min = output.dropFirst(2).reduce("") { String($0) + String($1) }
                case 5, 6: sec = output.dropFirst(4).reduce("") { String($0) + String($1) }
                default: break
            }
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
