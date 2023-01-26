//
//  iPadViewHierarchy.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 18.01.2023.
//

import SwiftUI

struct iPadViewHierarchy: View {
    @EnvironmentObject private var viewModel:ViewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
        if showIPadViewHierarchy { iPadViewHierarchy() }
        else { iPhoneViewHierarchy() }
    }
    
    // MARK: - Helpers
    //make code a bit nicer looking
    private var showIPadViewHierarchy:Bool { horizontalSizeClass == .regular }
    
    // MARK: -
}
