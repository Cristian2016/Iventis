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
            VStack {
                moreInfo
                    .onTapGesture {
                        print("show more info")
                    }
                Divider()
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
    private var moreInfo:some View {
        Label("Info", systemImage: "info.circle.fill")
            .font(.system(size: Global.FontSize.help))
            .foregroundColor(.gray)
    }
    
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
                        vm.rankOfMoreOptionsBubble = nil //dismiss
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
            
//            Text("Ex: Delay Bubble Start by\n1 Min: Tap \(Image(systemName: "30.square.fill")) Twice\n45 Sec: Tap \(Image(systemName: "15.square.fill")) and \(Image(systemName: "30.square.fill"))")
//                .foregroundColor(.gray)
//                .padding(.leading, 4)
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
