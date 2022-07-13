//
//  DisplayAlwaysOnSymbol.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 13.07.2022.
//

import SwiftUI

struct DisplayAlwaysOnSymbol: View {
    @State private var isDisplayAlwaysON = false
    
    func toggleDisplayIsAlwaysOn() {
        isDisplayAlwaysON.toggle()
        UIApplication.shared.isIdleTimerDisabled = isDisplayAlwaysON ? true : false
    }
    
    var body: some View {
        HStack {
            Button {
                toggleDisplayIsAlwaysOn()
                
            }
        label: {
            Label {
                Text("")
            } icon: {
                if isDisplayAlwaysON { turnOffDisplaySymbol }
                else { displayONSymbol }
            }
        }.tint(.red)
        }
    }
        
    // MARK: -
    private var turnOffDisplaySymbol:some View {
        ZStack {
            Image(systemName: "sun.max.fill")
            Image(systemName: "line.diagonal")
                .foregroundColor(.black)
        }
        .font(.system(size: 30))
    }
    
    private var displayONSymbol:some View {
        Image(systemName: "sun.max.fill")
            .foregroundColor(.black)
            .font(.system(size: 30))
    }
}

struct DisplayAlwaysOnSymbol_Previews: PreviewProvider {
    static var previews: some View {
        DisplayAlwaysOnSymbol()
    }
}
