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
        NavigationStack(path: $viewModel.path) {
            ViewHierarchy()
        }
            .tint(.label)
    }
}

struct iPhoneViewHierarchy_Previews: PreviewProvider {
    static var previews: some View {
        iPhoneViewHierarchy()
    }
}
