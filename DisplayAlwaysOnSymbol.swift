//
//  DisplayAlwaysOnSymbol.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 13.07.2022.
//

import SwiftUI

struct DisplayAlwaysOnSymbol: View {
    @AppStorage(UserDefaults.Key.displayIsAlwaysON, store: UserDefaults.shared)
    var displayIsAlwaysON = false
    
    var body: some View {
        HStack {
            Button { displayIsAlwaysON.toggle() }
        label: {
            Label {
                Text("")
            } icon: {
                if displayIsAlwaysON { displayOffSymbol }
                else { displayONSymbol }
            }
        }.tint(.red)
        }
    }
        
    // MARK: -
    private var displayOffSymbol:some View {
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
