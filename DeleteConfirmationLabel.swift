//
//  DeleteConfirmationLabel.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 14.03.2023.
// Text that fits a given frame see notes

import SwiftUI

struct DeleteConfirmationLabel: View {
    @State private var deleteOffsetReached = false
    @State private var deleteLabelVisible = false
    private var coordinator:BubbleCellCoordinator?
    
    // .transaction { $0.animation = nil } //1
    
    var body: some View {
        ZStack {
            if let coordinator = coordinator {
                rectangle
                    .aspectRatio(2.8, contentMode: .fit)
                    .padding([.leading, .trailing], -20)
                    .overlay (text)
                    .opacity(deleteLabelVisible ? 1 : 0)
                    .onReceive(coordinator.$sdButtonOffset) { yOffset in
                        print("new yOffset \(yOffset)")
                        deleteLabelVisible = abs(yOffset) > 120
                    }
            }
        }
    }
    
    struct DeleteConfirmationLabel_Previews: PreviewProvider {
        static var previews: some View {
            DeleteConfirmationLabel()
        }
    }
    
    // MARK: - Lego
    private var rectangle: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(deleteOffsetReached ? .green : .red)
    }
    
    private var text: some View {
        Text(deleteOffsetReached ? "\(Image.checkmark) Done" : "\(Image.trash) Delete")
            .allowsHitTesting(false)
            .font(.system(size: 300))
            .minimumScaleFactor(0.1)
            .foregroundColor(.white)
    }
}

//RoundedRectangle()
//    .aspectRatio(3.5, contentMode: .fit)
//    .frame(height: 100)
//    .overlay {
//        Text("Delete")
//            .font(.system(size: 300))
//            .minimumScaleFactor(0.1)
//    }
