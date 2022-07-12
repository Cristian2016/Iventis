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
    let itemSpacing = CGFloat(4)
    
    // MARK: - Gestures
    var dragGesture:some Gesture {
        LongPressGesture(minimumDuration: 0.3)
            .onEnded { _ in resetStartDelay() }
    }
    
    // MARK: -
    var body: some View {
        ZStack {
            Color("notesListScreenBackground").opacity(0.9)
                .ignoresSafeArea()
                .onTapGesture {
                    if vm.moreOptionsData!.startDelay != bubble.startDelay {
                        vm.startDelayWasSet = true
                        delayExecution(.now() + 1) { vm.startDelayWasSet = false }
                    }
                    vm.saveAndDismissMoreOptionsView(bubble)
                }
            VStack {
                startDelayOption
                Divider()
                colorOption
            }
            .padding(8)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .standardShadow()
                    .onTapGesture { vm.moreOptionsData = nil  /* dismiss */ }
            }
            .padding()
            .padding()
            
            if vm.startDelayWasReset {
                //reset delay confirmation
                ConfirmationLabel(isDestructive: true)
                { zeroStartDelayText } action: { vm.startDelayWasReset = false }
            }
            
            if vm.startDelayWasSet && bubble.startDelay != 0 {
                ConfirmationLabel()
                { startDelayText } action: { vm.startDelayWasSet = false }
            }
        }
        .highPriorityGesture(dragGesture)
    }
    
    // MARK: - Lego
    private var startDelayText: some View {
        VStack {
            Text("Start Delay").font(.system(size: 24))
            Text("\(Image(systemName: "clock.arrow.circlepath")) \(bubble.startDelay)s")
                .font(.system(size: 40).weight(.medium))
        }
    }
    
    private var zeroStartDelayText: some View {
        VStack {
            Text("No Start Delay").font(.system(size: 24))
            Text("\(Image(systemName: "clock.arrow.circlepath")) 0s")
                .font(.system(size: 40).weight(.medium))
        }
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
           
            LazyVGrid(columns: [GridItem(spacing: itemSpacing), GridItem(spacing: itemSpacing), GridItem(spacing: itemSpacing), GridItem()], spacing: itemSpacing) {
                ForEach(Color.bubbleThrees.map{$0.description},id:\.self) { colorName in
                    
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
                    .onTapGesture { vm.changeColor(for: bubble, to: colorName) }
                }
            }
        }
    }
    
    private var startDelayOption: some View {
        VStack (alignment: .leading) {
            HStack (alignment: .bottom) {
                Text("\(Int(bubble.startDelay))s")
                    .textModifier(Color.bubbleColor(forName: bubble.color!))
                Text("\(Image(systemName: "clock.arrow.circlepath")) Start Delay")
                    .font(.system(size: 22).weight(.medium))
                    .foregroundColor(.gray)
            }
            
            //buttons row 3
            HStack (spacing: itemSpacing) {
                ForEach(Bubble.startDelayValues, id: \.self) { delay in
                    Rectangle()
                        .fill(Color.bubbleColor(forName: bubble.color!))
                        .aspectRatio(contentMode: .fit)
                        .overlay {
                            Button("\(delay)") { vm.computeStartDelay(bubble, delay) }
                                .font(.system(size: 30).weight(.medium))
                        }
                }
            }
            .background(Color.white.opacity(0.001)) //prevent gestures from underlying view
            .font(.system(size: 26))
            .foregroundColor(.white)
        }
    }
    
    // MARK: - User Intents
    //long press outside table
    func resetStartDelay() {
        vm.resetStartDelay(for: bubble)
        vm.startDelayWasReset = true
        
        delayExecution(.now() + 1) { vm.startDelayWasReset = false }
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
