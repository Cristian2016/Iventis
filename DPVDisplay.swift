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
                VStack(spacing: 0) {
                    Spacer()
                    Text("Enter Duration")
                        .font(.largeTitle)
                        .fontDesign(.rounded)
                        .fontWeight(.semibold)
                    Text("Maximum 48 hours")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .minimumScaleFactor(0.1)
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
        .background()
        .allowsHitTesting(false)
        .onReceive(manager.$digits) {
            switch $0.count {
                case 0:
                    hr = ""
                    min = ""
                    sec = ""
                case 1:
                    hr = $0.reduce("") { String($0) + String($1) } + "_"
                case 2:
                    hr = $0.reduce("") { String($0) + String($1) }
                case 3:
                    min = $0.dropFirst(2).reduce("") { String($0) + String($1) } + "_"
                case 4:
                    min = $0.dropFirst(2).reduce("") { String($0) + String($1) }
                case 5:
                    sec = $0.dropFirst(4).reduce("") { String($0) + String($1) } + "_"
                case 6:
                    sec = $0.dropFirst(4).reduce("") { String($0) + String($1) }
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
                .fontWeight(.bold)
        }
    }
}

struct DPVDisplay_Previews: PreviewProvider {
    static var previews: some View {
        DPVDisplay { }
    }
}
