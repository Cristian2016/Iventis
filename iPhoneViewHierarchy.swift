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
    @State private var showFavoritesOnly = false
    @State private var showDetail_bRank:Int64?
    
    var body: some View {
        ZStack {
            NavigationStack(path: $viewModel.path) {
                BubbleList(showFavoritesOnly, showDetail_bRank)
                    .onReceive(secretary.$showFavoritesOnly) { showFavoritesOnly = $0 }
                    .onReceive(secretary.$showDetail_bRank) { showDetail_bRank = $0 }
            }
            .tint(.label)
            PaletteView()
            DurationPickerView()
        }
    }
}

struct iPhoneViewHierarchy_Previews: PreviewProvider {
    static var previews: some View {
        iPhoneViewHierarchy()
    }
}
