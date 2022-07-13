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
    static let itemSpacing = CGFloat(4)
    
    // MARK: - Gestures
    var longPress:some Gesture {
        LongPressGesture(minimumDuration: 0.3)
            .onEnded { _ in resetStartDelay() }
    }
    
    // MARK: -
    var body: some View {
        ZStack {
            Color("notesListScreenBackground").opacity(0.9)
                .ignoresSafeArea()
                .onTapGesture {
                    let userChangedStartDelay = bubble.sdb!.delay != 0
                    
                    if userChangedStartDelay {
                        vm.startDelayWasSet = true
                        delayExecution(.now() + 1) { vm.startDelayWasSet = false }
                    }
                    vm.saveAndDismissMoreOptionsView(bubble)
                }
            
            VStack {
                if bubble.state == .brandNew {
                    StartDelaySubview(sdb: bubble.sdb!)
                    Divider()
                }
                //2 Colors View Components -----
                colorsViewTitle
                ScrollView { colorsView }
                .frame(height: 420)
                .scrollIndicators(.hidden)
                //-------
            }
            .padding(8)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .standardShadow()
                    .onTapGesture { dismiss() }
            }
            .padding()
            .padding()
            
            //2 Confirmation Labels
            if vm.startDelayWasReset {
                //reset delay confirmation
                ConfirmationLabel(isDestructive: true)
                { zeroStartDelayText } action: { vm.startDelayWasReset = false }
            }
            if vm.startDelayWasSet && bubble.sdb!.delay != 0 {
                ConfirmationLabel()
                { startDelayText } action: { vm.startDelayWasSet = false }
            }
        }
        .highPriorityGesture(longPress)
    }
    
    // MARK: - Lego
    
    private var colorsViewTitle:some View {
        HStack (alignment: .bottom) {
            Text("\(Color.userFriendlyBubbleColorName(for: bubble.color))")
                .textModifier(Color.bubbleColor(forName: bubble.color!))
                .layoutPriority(1)
            Text("Choose Color")
                .font(.system(size: 22).weight(.medium))
                .foregroundColor(.gray)
        }
        .allowsHitTesting(false) //ignore touches [which are delivered to superview]
    }
    
    private var startDelayText: some View {
        VStack {
            Text("\(Image(systemName: "clock.arrow.circlepath")) \(bubble.sdb!.delay)s")
                .font(.system(size: 40).weight(.medium))
        }
    }
    
    private var zeroStartDelayText: some View {
        VStack {
            Text("\(Image(systemName: "clock.arrow.circlepath")) 0s")
                .font(.system(size: 40).weight(.medium))
        }
    }
    
    private var colorsView:some View {
        LazyVGrid(columns: [GridItem(spacing: MoreOptionsView.itemSpacing), GridItem(spacing: MoreOptionsView.itemSpacing), GridItem()], spacing: MoreOptionsView.itemSpacing) {
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
    
    // MARK: - User Intents
    //long press outside table
    func resetStartDelay() {
        vm.resetStartDelay(for: bubble)
        vm.startDelayWasReset = true
        bubble.sdb?.toggleStart()
        
        delayExecution(.now() + 1) { vm.startDelayWasReset = false }
    }
    
    func dismiss() { vm.sdb = nil }
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
