//
//  MoreOptionsView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 11.07.2022.
//

import SwiftUI

///Used to change 1.startDelay or 2.bubble's color
struct MoreOptionsView: View {
    @ObservedObject var bubble: Bubble
    @EnvironmentObject var viewModel:ViewModel
    
    ///referenceDelay when the user opens MoreOptionsView
    ///user may or may not edit referenceDelay
    let storedDelay:Int
    
    // MARK: -
    init(for bubble:Bubble) {
        _bubble = ObservedObject(wrappedValue: bubble)
        self.storedDelay = Int(bubble.sdb!.referenceDelay)
    }
        
    // MARK: -
    static let insets = EdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 10)
    static let itemSpacing = CGFloat(4)
    let colorsGridHeight = CGFloat(320)
    var show_StartDelayOption:Bool { bubble.state != .running }
    
    // MARK: -
    var body: some View {
        ZStack {
            screenBackground.onTapGesture {
                saveDelayIfNeeded()
                dismiss()
            }
            
            VStack {
                StartDelaySubview(sdb: bubble.sdb!)
                colorsViewTitle
                colorsTable
            }
            .frame(width: 280)
            .padding(8)
            .background { whiteBackground }
            .padding()
            .padding()
            
            //2 Confirmation Labels
            if viewModel.confirm_NoDelay {
                //reset delay confirmation
                ConfirmationView(titleSymbol: "clock.arrow.circlepath",
                                 title: "Start Delay",
                                 isOn: false
                )
            }
            if viewModel.confirm_DelayWasSet && bubble.sdb!.referenceDelay != 0 {
                ConfirmationView(extraText: String(bubble.sdb!.referenceDelay) + "s",
                                 titleSymbol: "clock.arrow.circlepath",
                                 title: "Start Delay",
                                 isOn: true
                )
            }
        }
        .gesture(longPress)
    }
    
    // MARK: - Lego
    
    private var screenBackground:some View {
        Color.alertScreenBackground.opacity(0.9)
            .ignoresSafeArea()
    }
    
    private var whiteBackground:some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .standardShadow()
                .onTapGesture { dismiss() }
            Push(.topRight) {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.gray)
                    .font(.system(size: 26))
                    .padding()
                    .background {
                        Circle()
                            .fill(Color.transparent)
                            .onTapGesture { handleInfoLabelTap() }
                    }
            }
            .padding(-6)
        }
    }
    
    private var colorsViewTitle:some View {
        HStack (alignment: .bottom) {
            Text("\(Color.userFriendlyBubbleColorName(for: bubble.color))")
                .textModifier(Color.bubbleColor(forName: bubble.color!))
                .layoutPriority(1)
            Text("Color")
                .font(.system(size: 22).weight(.medium))
                .foregroundColor(.gray)
            Spacer()
        }
        .allowsHitTesting(false) //ignore touches [which are delivered to superview]
    }
    
    private var colorsTable:some View {
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
                    .onTapGesture { viewModel.changeColor(for: bubble, to: colorName) }
                }
            }
        }
        .frame(height: UIScreen.deviceNotTallEnough ? colorsGridHeight : 420)
        .scrollIndicators(.hidden)
    }
    
    // MARK: - User Intents
    func dismiss() { viewModel.theOneAndOnlyEditedSDB = nil }
    
    func saveDelayIfNeeded() {
        /*
         if user sets a new start delay
         save delay
         save CoreData context*/
        
        let delayWasModified = bubble.sdb!.referenceDelay != storedDelay
        guard delayWasModified else { return }
                
        UserFeedback.singleHaptic(.medium)
        viewModel.saveDelay(for: bubble)
        PersistenceController.shared.save()
    }
    
    func handleInfoLabelTap() {
        viewModel.showMoreOptionsInfo = true
    }
    
    var longPress:some Gesture {
        LongPressGesture(minimumDuration: 0.3)
            .onEnded { _ in
                viewModel.removeDelay(for: bubble)
                
                //show 0s red alert and hide after 0.7 seconds
                viewModel.confirm_NoDelay = true
                delayExecution(.now() + 1) { viewModel.confirm_NoDelay = false }
                UserFeedback.doubleHaptic(.heavy)
            }
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
        MoreOptionsView(for: bubble)
    }
}
