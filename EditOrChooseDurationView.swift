//
//  EditOrChooseDurationView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 23.05.2023.
//

import SwiftUI

struct EditOrChooseDurationView: View {
    var body: some View {
        HStack {
            Button {
                
            } label: {
                Label("Stopwatch", systemImage: "stopwatch")
                    .labelStyle(.iconOnly)
            }
            
            Divider()
            
            Button {
                
            } label: {
                Label("Edit", systemImage: "slider.horizontal.3")
                    .labelStyle(.iconOnly)
            }
            
            Divider()

            Text("Choose Minutes")
        }
        .frame(height: 30)
    }
}

struct EditOrChooseDurationView_Previews: PreviewProvider {
    static var previews: some View {
        EditOrChooseDurationView()
    }
}
