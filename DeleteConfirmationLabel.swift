//
//  DeleteConfirmationLabel.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 14.03.2023.
//

import SwiftUI

struct DeleteConfirmationLabel: View {
    @State private var deleteOffsetReached = false
    @State private var deleteLabelVisible = false
    
    // .transaction { $0.animation = nil } //1
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(deleteOffsetReached ? .green : .red)
                .aspectRatio(3.5, contentMode: .fit)
                .overlay {
                    Text("Delete").allowsHitTesting(false)
                        .font(.system(size: 300))
                        .minimumScaleFactor(0.1)
                        .foregroundColor(.white)
                }
                .frame(height: 100)
                .opacity(deleteLabelVisible ? 1 : 1)
        }
    }
    
    struct DeleteConfirmationLabel_Previews: PreviewProvider {
        static var previews: some View {
            DeleteConfirmationLabel()
        }
    }
}
