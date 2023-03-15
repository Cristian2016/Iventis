//
//  DeleteConfirmationLabel.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 14.03.2023.
// Text that fits a given frame see notes
//1 is StartDelayBubble removed
//2 is DeleteConfirmationLabel visible

import SwiftUI
import MyPackage

struct DeleteConfirmationLabel: View {
    private var coordinator:BubbleCellCoordinator?
    
    @State private var isRemoved = false //1
    @State private var isVisible = false //2
    
    // .transaction { $0.animation = nil } //1
    
    var body: some View {
        ZStack {
            if let coordinator = coordinator {
                rectangle
                    .aspectRatio(3.0, contentMode: .fit)
                    .padding([.leading, .trailing], -20)
                    .overlay (text)
                    .opacity(isVisible ? 1 : 0)
                    .onReceive(coordinator.$sdButtonYOffset) { isVisible = $0 < -120 }
                    .onReceive(coordinator.$sdbDeleteTriggered) { isRemoved = $0 }
            }
        }
        .allowsHitTesting(false)
    }
    
    struct DeleteConfirmationLabel_Previews: PreviewProvider {
        static var previews: some View {
            DeleteConfirmationLabel()
        }
    }
    
    // MARK: - Lego
    private var rectangle: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(isRemoved ? .green : .red)
    }
    
    private var text: some View {
        Text(isRemoved ? "Done" : "Delete")
            .font(.system(size: 200))
            .minimumScaleFactor(0.1)
            .foregroundColor(.white)
    }
    
    init(_ coordinator: BubbleCellCoordinator? = nil) {
        self.coordinator = coordinator
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
