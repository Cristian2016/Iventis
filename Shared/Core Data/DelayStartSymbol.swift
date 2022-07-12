//
//  DelayStartSymbol.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 11.07.2022.
//

import SwiftUI

struct DelayStartSymbol: View {
    @Binding var startValue:Int64
    
    var body: some View {
        VStack {
            HStack (spacing: 2) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 12).weight(.bold))
                Text("\(startValue)")
                    .font(.system(size: 18).weight(.medium))
            }
            .foregroundColor(.white)
            Spacer()
        }
        .offset(y:6)
    }
}

struct DelayStartSymbol_Previews: PreviewProvider {
    static var previews: some View {
        DelayStartSymbol(startValue: .constant(60))
    }
}
