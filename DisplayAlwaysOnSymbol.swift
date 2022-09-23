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
                vm.showAlert_displayAlwaysOn = true
            }
        label: {
            Label {
                Text(isDisplayAlwaysON ? "Exit" : "")
                    .font(.system(size:20).weight(.bold))
            } icon: {
                if isDisplayAlwaysON { exitAlwaysONDisplay_Symbol }
                else { displayONSymbol }
            }
        }
        .tint(.red)
        .padding([.leading, .trailing], 12)
        .background {
            if isDisplayAlwaysON {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.red, lineWidth: 4)
            }
        }
        }
    }
    
    // MARK: -
    private var exitAlwaysONDisplay_Symbol:some View {
        
        ZStack {
            Image(systemName: "sun.max")
            Image(systemName: "line.diagonal")
                .foregroundColor(.label)
        }
        .fontWeight(.semibold)
        .foregroundColor(.red)
        .padding([.top, .bottom], 3)
        .padding([.leading, .trailing], 10)
        .font(.system(size: fontSize))
    }
    
    private var displayONSymbol:some View {
        Image(systemName: "sun.max")
            .foregroundColor(.label)
            .font(.system(size: fontSize))
    }
}

struct DisplayAlwaysOnSymbol_Previews: PreviewProvider {
    static var previews: some View {
        DisplayAlwaysOnSymbol()
    }
}
