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
    
    // MARK: - Gestures
    var dragGesture:some Gesture {
        LongPressGesture(minimumDuration: 0.3)
            .onEnded { _ in
                resetStartDelay()
            }
    }
    
    // MARK: -
    var body: some View {
        ZStack {
            Color("notesListScreenBackground").opacity(0.9)
                .ignoresSafeArea()
                .onTapGesture { vm.saveAndDismissMoreOptionsView() }
                .highPriorityGesture(dragGesture)
            VStack {
                colorOption
                Divider()
                startDelayOption
            }
            .padding(8)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .standardShadow()
                    .onTapGesture { vm.rankOfMoreOptionsBubble = nil  /* dismiss */ }
            }
            .padding()
            .padding()
        }
    }
    
    // MARK: - Lego
    private var colorOption:some View {
        VStack (alignment: .leading) {
            HStack (alignment: .bottom) {
                Text("\(Color.userFriendlyBubbleColorName(for: bubble.color))")
                    .textModifier(Color.bubbleColor(forName: bubble.color!))
                    .layoutPriority(1)
                Text("Choose Color")
                    .font(.system(size: 22).weight(.medium))
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
                    }
                }
            }
        }
    }
    
    private var startDelayOption: some View {
        VStack (alignment: .leading) {
            HStack (alignment: .bottom) {
                Text("\(Int(bubble.startDelay)) s")
                    .textModifier(Color.bubbleColor(forName: bubble.color!))
                Text("\(Image(systemName: "clock.arrow.circlepath")) Start Delay")
                    .font(.system(size: 22).weight(.medium))
                    .foregroundColor(.gray)
            }
            
            //buttons row 3
            HStack (spacing: 4) {
                ForEach(Bubble.startDelayValues, id: \.self) { value in
                    Rectangle()
                        .fill(Color.bubbleColor(forName: bubble.color!))
                        .aspectRatio(contentMode: .fit)
                        .overlay {
                            Button("\(value)") {
                                vm.computeStartDelay(for: bubble, value: value)
                            }
                        .font(.system(size: 30).weight(.medium))
                    }
                }
            }
            .font(.system(size: 26))
            .foregroundColor(.white)
        }
    }
    
    // MARK: - User Intents
    //long press outside table
    func resetStartDelay() {
        UserFeedback.doubleHaptic(.medium)
        vm.resetStartDelay(for: bubble)
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
