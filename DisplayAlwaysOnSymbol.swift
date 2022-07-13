//
//  DisplayAlwaysOnSymbol.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 13.07.2022.
//

import SwiftUI

struct DisplayAlwaysOnSymbol: View {
    
    var body: some View {
        HStack {
            Button { toggleAlwaysONDisplay() }
        label: {
            Label {
                Text("")
            } icon: {
                displayOffSymbol
            }
        }
        .tint(.red)
        }
    }
    
    func toggleAlwaysONDisplay() {
        
    }
    
    // MARK: -
    private var displayOffSymbol:some View {
        ZStack {
            Image(systemName: "sun.max.fill")
            Image(systemName: "line.diagonal")
                .foregroundColor(.black)
        }
        .font(.system(size: 25))
    }
    
    private var displayONSymbol:some View {
        Image(systemName: "sun.max.fill")
            .foregroundColor(.black)
            .font(.system(size: 25))
    }
}

struct DisplayAlwaysOnSymbol_Previews: PreviewProvider {
    static var previews: some View {
        DisplayAlwaysOnSymbol()
    }
}
