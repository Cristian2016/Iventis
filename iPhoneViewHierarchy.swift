//
//  iPhoneViewHierarchy.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 26.01.2023.
//

import SwiftUI

struct iPhoneViewHierarchy: View {
    @EnvironmentObject private var viewModel:ViewModel
    var body: some View {
        ZStack {
            NavigationStack(path: $viewModel.path) { ViewHierarchy() }
            if viewModel.showPaletteView { PaletteView().transition(.move(edge: .leading)) }
            DurationPickerView().transition(.move(edge: .leading))
        }
        .tint(.label)
    }
    
    init() {
        print(#function, "iPhoneViewHierarchy")
    }
}

struct iPhoneViewHierarchy_Previews: PreviewProvider {
    static var previews: some View {
        iPhoneViewHierarchy()
    }
}
