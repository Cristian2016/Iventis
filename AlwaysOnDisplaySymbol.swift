//
//  DisplayAlwaysOnSymbol.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 13.07.2022.
//
import SwiftUI

struct AlwaysOnDisplaySymbol: View {
    @EnvironmentObject var vm:ViewModel
    let fontSize = CGFloat(30)
    
    var body: some View {
        HStack {
            Button { vm.showAlert_AlwaysOnDisplay.toggle() }
        label: {
            Label {
                Text(vm.showAlert_AlwaysOnDisplay ? "Exit" : "")
                    .font(.system(size:20).weight(.bold))
            } icon: {
                if vm.showAlert_AlwaysOnDisplay { exitAlwaysONDisplay_Symbol }
                else { displayONSymbol }
            }
        }
        .tint(.red)
        .padding([.leading, .trailing], 12)
        .background {
            if vm.showAlert_AlwaysOnDisplay {
                RoundedRectangle(cornerRadius: 10).stroke(.red, lineWidth: 4)
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
        AlwaysOnDisplaySymbol()
    }
}
