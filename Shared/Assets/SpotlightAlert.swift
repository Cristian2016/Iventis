//
//  SpotlightAlert.swift
//  Timers
//
//  Created by Cristian Lapusan on 30.04.2022.
//

import SwiftUI

struct SpotlightAlert: View {
    
    var body: some View {
        HStack {
            Image(systemName: "rays")
                .font(.title)
            Text("Spotlight")
                .font(.title2)
        }
        .foregroundColor(.secondary)
        .padding()
    }
}

struct SpotlightAlert_Previews: PreviewProvider {
    static var previews: some View {
        SpotlightAlert()
    }
}
