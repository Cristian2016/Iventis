//
//  DisplayAlwaysOnSymbol.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 13.07.2022.
//

import SwiftUI

struct DisplayAlwaysOnSymbol: View {
    @State private var isDisplayAlwaysON = false
    @EnvironmentObject var vm:ViewModel
    let fontSize = CGFloat(30)
    
    func toggleDisplayIsAlwaysOn() {
        isDisplayAlwaysON.toggle()
        UIApplication.shared.isIdleTimerDisabled = isDisplayAlwaysON ? true : false
    }
    
    var body: some View {
        HStack {
            Button {
                toggleDisplayIsAlwaysOn()
                vm.showAlwaysOnDisplayAlert = true
            }
        label: {
            Label {
                Text("")
            } icon: {
                if isDisplayAlwaysON { turnOffDisplaySymbol }
                else { displayONSymbol }
            }
        }
        .tint(.red)
        }
    }
    
    // MARK: -
    private var turnOffDisplaySymbol:some View {
        HStack {
            Text("Exit ON")
                .font(.system(size: 20).weight(.medium))
            ZStack {
                Image(systemName: "sun.max.fill")
                Image(systemName: "line.diagonal")
                    .foregroundColor(.black)
            }
        }
        .padding([.top, .bottom], 3)
        .padding([.leading, .trailing], 10)
        .background {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.red.opacity(0.3))
        }
        
        .font(.system(size: fontSize))
    }
    
    private var displayONSymbol:some View {
        Image(systemName: "sun.max.fill")
            .foregroundColor(.label)
            .font(.system(size: fontSize))
    }
}

struct DisplayAlwaysOnSymbol_Previews: PreviewProvider {
    static var previews: some View {
        DisplayAlwaysOnSymbol()
    }
}
