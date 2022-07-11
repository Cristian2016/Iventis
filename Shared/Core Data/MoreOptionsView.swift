//
//  MoreOptionsView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 11.07.2022.
//

import SwiftUI

struct MoreOptionsView: View {
    @ObservedObject var bubble: Bubble
    @EnvironmentObject var vm:ViewModel
    
    // MARK: -
    static let insets = EdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 10)
    
    // MARK: -
    var body: some View {
        ZStack {
            Color("notesListScreenBackground").opacity(0.9)
                .ignoresSafeArea()
                .onTapGesture { vm.rankOfMoreOptionsBubble = nil  /* dismiss */ }
            ScrollView {
                colorOption
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
                    .textModifier(Color.bubbleColor(forName: bubble.color!))
                Text("Choose New Color")
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
            
            HStack (alignment: .bottom) {
                Text("\(Int(bubble.startDelay))")
                    .textModifier(.black)
                Text("Sec")
                    .font(.system(size: 24).weight(.medium))
                    .foregroundColor(.gray)
            }
            
            Text("\(Image(systemName: "clock.arrow.circlepath")) Start Delay")
                .font(.system(size: 24).weight(.medium))
                .foregroundColor(.gray)
            
            HStack (spacing: 4) {
                ForEach(Bubble.startDelayValues, id: \.self) { value in
                    Rectangle()
                        .fill(Color.black)
                        .aspectRatio(contentMode: .fit)
                        .overlay {
                        Button("\(value)") {
                            vm.computeStartDelay(for: bubble, value: 5)
                        }
                    }
                }
            }
            .font(.system(size: 26))
            .foregroundColor(.white)
            .buttonStyle(.borderedProminent)
        }
    }
}

struct TextModifier: ViewModifier {
    let color:Color
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(.white)
            .font(.system(size: 30))
            .padding(MoreOptionsView.insets)
            .background(RoundedRectangle(cornerRadius: 4).fill(color))
    }
}

extension View {
    func textModifier(_ backgroundColor:Color) -> some View {
        modifier(TextModifier(color: backgroundColor))
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
