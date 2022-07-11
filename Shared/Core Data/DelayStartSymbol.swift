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
            ZStack {
                Image(systemName: "clock.arrow.circlepath")
                    .foregroundColor(.white)
                    .font(.system(size: 40))
                Text("\(startValue)")
                    .foregroundColor(.red)
                    .font(.system(size: 16).weight(.medium))
                    .padding(2)
                    .background {
                        Circle().fill(Color.white)
                    }
            }
            .background {
                RoundedRectangle(cornerRadius: 50)
                    .fill(Color.clear)
            }
            Spacer()
        }
    }
}

struct DelayStartSymbol_Previews: PreviewProvider {
    static var previews: some View {
        DelayStartSymbol(startValue: .constant(60))
    }
}
