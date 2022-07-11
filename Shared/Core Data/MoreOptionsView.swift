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
            Color("notesListScreenBackground").opacity(0.8)
                .ignoresSafeArea()
                .onTapGesture { vm.rankOfMoreOptionsBubble = nil  /* dismiss */ }
            ScrollView {
                colorOption
                Divider()
                startDelayOption
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
    
    // MARK: - Lego
    private var colorOption:some View {
        VStack {
            VStack (spacing: 6) {
                Text("\(Color.userFriendlyBubbleColorName(for: bubble.color))")
                    .foregroundColor(.white)
                    .font(.system(size: 30))
                    .padding(EdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 10))
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.bubbleColor(forName: bubble.color!))
                    )
                Text("Choose Different Color")
                    .font(.system(size: 24).weight(.medium))
                    .foregroundColor(.gray)
            }
            .allowsHitTesting(false) //ignore touches
           
            LazyVGrid(columns: [GridItem(spacing: 4), GridItem(spacing: 4), GridItem(spacing: 4), GridItem()], spacing: 4) {
                ForEach(Color.bubbleThrees.map { $0.description }, id: \.self) { colorName in
                    
                    let color = Color.bubbleColor(forName: colorName)
                    ZStack {
                        Rectangle()
                            .fill(color)
                            .aspectRatio(contentMode: .fit)
                        if colorName == bubble.color {
                            Image(systemName: "checkmark")
                                .foregroundColor(.white)
                                .font(.system(size: 40))
                        }
                    }
                    .onTapGesture {
                        vm.changeColor(for: bubble, to: colorName)
                        vm.rankOfMoreOptionsBubble = nil //dismiss
                    }
                }
            }
        }
    }
    
    private var startDelayOption: some View {
        VStack {
            Text("\(Image(systemName: "clock.arrow.circlepath")) Start Delay")
                .font(.system(size: 24).weight(.medium))
                .foregroundColor(.gray)
            
            HStack {
                Text("30 seconds")
            }
            
            HStack {
                Button("5") {
                    print("5")
                }
                Button("10") {
                    print("10")
                }
                Button("15") {
                    print("15")
                }
                Button("30") {
                    print("30")
                }
            }
            .font(.system(size: 26))
            .foregroundColor(.white)
            .buttonStyle(.borderedProminent)
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
