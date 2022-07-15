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
    let colorsGridHeight = CGFloat(320)
    var display_StartDelayGrid:Bool { bubble.state != .running }
    
    // MARK: - Gestures
    var longPress:some Gesture {
        LongPressGesture(minimumDuration: 0.3)
            .onEnded { _ in resetStartDelay() }
    }
    
    // MARK: -
    var body: some View {
        ZStack {
            screenBackground
                .onTapGesture { handleTap() }
            
            VStack {
                StartDelaySubview(sdb: bubble.sdb!)
                colorsViewTitle
                colorsGrid
            }
            .frame(width: 280)
            .padding(8)
            .background { whiteBackground }
            .padding()
            .padding()
            
            //2 Confirmation Labels
            if vm.startDelayWasReset {
                //reset delay confirmation
                ConfirmationLabel(isDestructive: true)
                { zeroStartDelayText } action: { vm.startDelayWasReset = false }
            }
            if vm.startDelayWasSet && bubble.sdb!.referenceDelay != 0 {
                ConfirmationLabel()
                { startDelayText } action: { vm.startDelayWasSet = false }
            }
        }
        .highPriorityGesture(longPress)
    }
    
    // MARK: - Lego
    
    private var screenBackground:some View {
        Color.alertScreenBackground.opacity(0.9)
            .ignoresSafeArea()
    }
    
    private var whiteBackground:some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.white)
            .standardShadow()
            .onTapGesture { dismiss() }
    }
    
    private var colorsViewTitle:some View {
        HStack (alignment: .bottom) {
            Text("\(Color.userFriendlyBubbleColorName(for: bubble.color))")
                .textModifier(Color.bubbleColor(forName: bubble.color!))
                .layoutPriority(1)
//            Text("Color")
//                .font(.system(size: 22).weight(.medium))
//                .foregroundColor(.gray)
            Spacer()
        }
        .allowsHitTesting(false) //ignore touches [which are delivered to superview]
    }
    
    private var colorsGrid:some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(spacing: MoreOptionsView.itemSpacing), GridItem(spacing: MoreOptionsView.itemSpacing), GridItem()], spacing: MoreOptionsView.itemSpacing) {
                ForEach(Color.bubbleThrees.map{$0.description},id:\.self) { colorName in
                    
                    let color = Color.bubbleColor(forName: colorName)
                    ZStack {
                        Rectangle()
                            .fill(color)
                            .aspectRatio(1.6, contentMode: .fit)
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
        .frame(height: UIScreen.deviceNotTallEnough ? colorsGridHeight : 420)
        .scrollIndicators(.hidden)
    }
    
    private var startDelayText: some View {
        VStack {
            Text("\(Image(systemName: "clock.arrow.circlepath")) \(bubble.sdb!.referenceDelay)s")
                .font(.system(size: 40).weight(.medium))
            Text("Start Delay")
                .font(.system(size: 20))
        }
    }
    
    private var zeroStartDelayText: some View {
        VStack {
            Text("\(Image(systemName: "clock.arrow.circlepath")) 0s")
                .font(.system(size: 40).weight(.medium))
            Text("Start Delay")
                .font(.system(size: 20))
        }
    }
    
    // MARK: - User Intents
    //long press outside table
    func resetStartDelay() {
        vm.setDelayBackToZero(for: bubble)
        vm.startDelayWasReset = true
        bubble.sdb?.toggleStart()
        
        delayExecution(.now() + 1) { vm.startDelayWasReset = false }
    }
    
    func dismiss() { vm.sdb = nil }
    
    func handleTap() {
        let userChangedStartDelay = bubble.sdb!.referenceDelay != 0
        
        if userChangedStartDelay {
            vm.startDelayWasSet = true
            delayExecution(.now() + 1) { vm.startDelayWasSet = false }
                                }
        vm.saveAndDismissMoreOptionsView(bubble)
    }
}

struct TextModifier: ViewModifier {
    let color:Color
    let fontSize:CGFloat
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(.white)
            .font(.system(size: fontSize))
            .padding(MoreOptionsView.insets)
            .background(RoundedRectangle(cornerRadius: 4).fill(color))
    }
}

extension View {
    func textModifier(_ backgroundColor:Color, _ fontSize:CGFloat = 30) -> some View {
        modifier(TextModifier(color: backgroundColor, fontSize: fontSize))
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
