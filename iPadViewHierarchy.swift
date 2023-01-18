//
//  iPadViewHierarchy.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 18.01.2023.
//

import SwiftUI

struct iPadViewHierarchy: View {
    ///horizontalSizeClass. In compact size class show iPhone like interface. Regular size class show iPad specific
    @Environment(\.horizontalSizeClass) private var sizeClass
    @EnvironmentObject private var viewModel:ViewModel
    
    var body: some View {
        if regularSizeClass { //iPad specific interface
            
        } else { //iPhone-like interface
            NavigationStack(path: $viewModel.path) { ViewHierarchy() }
        }
    }
    
    // MARK: - Helpers
    //make code a bit nicer looking
    private var regularSizeClass:Bool { sizeClass == .regular ? true : false }
    
    // MARK: -
}
