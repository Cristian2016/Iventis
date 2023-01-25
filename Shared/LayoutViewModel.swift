//
//  LayoutViewModel.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 24.01.2023.
//

import SwiftUI
import MyPackage

class LayoutViewModel: ObservableObject {
    ///DeleteActionView uses bubbleCellFrame to position itself within the ViewHierarchy. bubbleCellFrame is set using .readFrame($bubbleCellFrame) modifier
    @Published var bubbleCellFrame:CGRect? {didSet{
        print("bubbleCellFrame \(bubbleCellFrame)")
    }}
}
