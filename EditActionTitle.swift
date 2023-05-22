//
//  EditActionTitle.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 22.05.2023.
//

import SwiftUI

struct EditActionTitle: View {
    var body: some View {
        VStack {
            Text("\(Image.stopwatch) Orange")
                .font(.title)
            HStack {
                Text("Workout")
                Divider()
                    .frame(height: 20)
                Text("14 Entries")
            }
        }
    }
}

struct EditActionTitle_Previews: PreviewProvider {
    static var previews: some View {
        EditActionTitle()
    }
}
