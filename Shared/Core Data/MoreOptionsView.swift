//
//  MoreOptionsView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 11.07.2022.
//

import SwiftUI

struct MoreOptionsView: View {
    let bubble: Bubble
    @EnvironmentObject var vm:ViewModel
    
    var body: some View {
        ZStack {
            Color.white.opacity(0.8)
                .ignoresSafeArea()
                .onTapGesture { vm.rankOfMoreOptionsBubble = nil  /* dismiss */ }
            VStack {
                VStack (spacing: 6) {
                    Text("Choose New Color")
                        .font(.system(size: 30))
                    Text("\(Color.userFriendlyBubbleColorName(for: bubble.color))")
                        .foregroundColor(.white)
                        .font(.system(size: 24).weight(.medium))
                        .padding(.all, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.bubbleColor(forName: bubble.color!))
                        )
                }
               
                LazyVGrid(columns: [GridItem(spacing: 0), GridItem(spacing: 0), GridItem()], spacing: 0) {
                    ForEach(Color.bubbleThrees.map { $0.description }, id: \.self) { colorName in
                        
                        let color = Color.bubbleColor(forName: colorName)
                        ZStack {
                            Rectangle()
                                .fill(color)
                                .aspectRatio(contentMode: .fit)
                            if colorName == bubble.color {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.white)
                                    .font(.system(size: 40).weight(.medium))
                            }
                        }
                        .onTapGesture {
                            vm.changeColor(for: bubble, to: colorName)
                            vm.rankOfMoreOptionsBubble = nil //dismiss
                        }
                    }
                }
            }
            .padding(8)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .standardShadow(false)
                    .onTapGesture { vm.rankOfMoreOptionsBubble = nil  /* dismiss */ }
            }
            .padding()
            .padding()
        }
    }
}

struct MoreOptionsView_Previews: PreviewProvider {
    
    static var previews: some View {
        let bubble:Bubble = {
            let bubble = Bubble(context: PersistenceController.shared.viewContext)
            bubble.color = "green"
            return bubble
        }()
        MoreOptionsView(bubble: bubble)
    }
}
