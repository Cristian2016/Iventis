//
//  iPhoneViewHierarchy.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 26.01.2023.
//1 show in DetailView only back button without any title 🟪Feature

import SwiftUI

struct iPhoneViewHierarchy: View {
    @Environment(ViewModel.self) private var viewModel
    @Environment(Secretary.self) private var secretary
        
    var body: some View {
        @Bindable var nvm = viewModel
        
        ZStack {
            NavigationStack(path: $nvm.path) {
                BubbleList(secretary)
                    .navigationTitle("") //1
                    .navigationBarTitleDisplayMode(.inline) //1
            }
            .tint(.label)
        }
    }
}
