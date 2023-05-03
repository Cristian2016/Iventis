//
//  ActionsView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 03.05.2023.
//

import SwiftUI

struct ActionsView: View {
    let bubble:Bubble
    
    var body: some View {
        VStack {
            let color = Color.bubbleColor(forName: bubble.color)
            
            Text("\(Image.trash) Delete")
                .foregroundColor(.red)
                .font(.system(.title3).weight(.medium))
            
            VStack(spacing: 2) {
                vRoundedRectangle(corners: [.topLeft, .topRight], radius: 30)
                    .fill(color)
                    .frame(height: 70)
                    .overlay {
                        Button {
                            
                        } label: {
                            Text("Bubble")
                                .frame(maxWidth: .infinity)
                                .font(.system(size: 28, weight: .medium, design: .rounded))
                        }
                        .tint(.white)
                    }
                
                vRoundedRectangle(corners: [.bottomLeft, .bottomRight], radius: 30)
                    .fill(color)
                    .frame(height: 70)
                    .overlay {
                        Button {
                            
                        } label: {
                            Text("Activity")
                                .frame(maxWidth: .infinity)
                                .font(.system(size: 28, weight: .medium, design: .rounded))
                        }
                        .tint(.white)
                    }
            }
            .padding([.leading, .trailing], 4)
        }
        .padding([.top, .bottom])
        .background {
            RoundedRectangle(cornerRadius: 40)
                .fill(.regularMaterial)
        }
        
        .padding([.leading, .trailing], 4)
    }
}

struct ActionsView_Previews: PreviewProvider {
    static let bubble:Bubble = {
        let context = PersistenceController.preview.viewContext
        let bubble = Bubble(context: context)
        bubble.color = "silver"
        return bubble
    }()
    
    static var previews: some View {
        ActionsView(bubble: Self.bubble)
    }
}
