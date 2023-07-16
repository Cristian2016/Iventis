//
//  DeleteView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 25.11.2023.
//

import SwiftUI

struct DeleteView: View {
    let name = String.readableName(for: "red")
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Color("controlOverlayBackground")
            .overlay {
                VStack {
                    HStack {
                        Image.stopwatch
                            .font(.system(size: 28))
                            .foregroundStyle(.white)
                            .padding()
                            .background { Circle().fill(.red) }
                        VStack(alignment: .leading) {
                            Text(name).foregroundStyle(.red)
                            Text("Stopwatch")
                        }
                        .font(.system(size: 24))
                    }
                    
                    Divider()
                    
                    Text("Turn into timer")
                        .font(.system(size: 20, weight: .medium))
                    Text("Tap \(Image.timer) or minutes: 5, 10, etc.")
                        .font(.system(size: 20))
                    
                    Image(colorScheme == .light ? "controlOverlay" : "controlOverlayDark")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 70)
                }
                .foregroundStyle(.secondary)
                .padding()
            }
    }
}

#Preview {
    DeleteView()
}
