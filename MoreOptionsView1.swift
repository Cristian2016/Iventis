//
//  MoreOptionsView1.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 06.02.2023.
//

import SwiftUI
import MyPackage

struct MoreOptionsView1: View {
    var body: some View {
        GeometryReader { geo in
            let isLandscape = geo.size.width > geo.size.height
            
            if isLandscape {
                Circle()
            } else {
                RoundedRectangle(cornerRadius: 30)
            }
        }
        .ignoresSafeArea()
    }
    
    // MARK: - Lego
    private var colors:some View {
        ScrollView {
            
            
        }
    }
    
    // MARK: -
    private let columns = Array(repeating: GridItem(), count: 3)
}

struct MoreOptionsView1_Previews: PreviewProvider {
    static var previews: some View {
        MoreOptionsView1()
    }
}
