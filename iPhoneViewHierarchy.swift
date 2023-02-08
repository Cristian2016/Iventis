//
//  iPhoneViewHierarchy.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 26.01.2023.
//

import SwiftUI

struct iPhoneViewHierarchy: View {
    @EnvironmentObject private var viewModel:ViewModel
    private let secretary = Secretary.shared
    
    var body: some View {
        let _ = print("iPhoneViewHierarchy body")
        ZStack {
            NavigationStack(path: $viewModel.path) { ViewHierarchy() }
            PaletteView().transition(.move(edge: .leading))
            DurationPickerView()
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
