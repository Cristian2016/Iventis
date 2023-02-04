//
//  PaletteViewModel.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 04.02.2023.
//

import SwiftUI

class PaletteViewModel: ObservableObject {
    @AppStorage("showPaletteHint", store: .shared) var showPaletteHint = true
}
