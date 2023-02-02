//
//  MoreOptionsView.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 11.07.2022.
//

import SwiftUI
import MyPackage

///Used to change 1.startDelay or 2.bubble's color
struct MoreOptionsView: View {
    @ObservedObject var bubble: Bubble
    @EnvironmentObject var viewModel:ViewModel
    
    ///referenceDelay when the user opens MoreOptionsView
    ///user may or may not edit referenceDelay
    let storedReferenceDelay:Int
    
    // MARK: -
    init(for bubble:Bubble) {
        _bubble = ObservedObject(wrappedValue: bubble)
        self.storedReferenceDelay = Int(bubble.sdb!.referenceDelay)
    }
        
    // MARK: -
    static let insets = EdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 10)
    static let itemSpacing = CGFloat(4)
    let colorsTableHeight = CGFloat(320)
    var show_StartDelayOption:Bool { bubble.state != .running }
    
    static let colorTitleSize = CGFloat(40)
    let checkmarkFont = Font.system(size: 40).weight(.medium)
    
    func dismiss() { viewModel.theOneAndOnlyEditedSDB = nil }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            BlurryBackground()
                .onTapGesture { saveDelay() }
                .highPriorityGesture(swipeLeft)
            VStack {
                StartDelaySubview(sdb: bubble.sdb!)
                colorsViewTitle
                colorsTable
            }
            .overlay {
                if viewModel.confirm_ColorChange {
                    ColorConfirmationView(colorName: bubble.color!, color: Color.bubbleColor(forName: bubble.color!))
                }
            }
            .frame(width: 280)
            .padding(8)
            .background { tableBackground /* contains info button */ }
            .padding()
            .padding()
            
            Push(.bottomMiddle) {
                Text("\(Image(systemName: "hand.tap")) Tap background to dismiss")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding([.bottom])
            .padding([.bottom])
        }
        .ignoresSafeArea()
    }
    
    // MARK: - Lego
    private var delayRemovedConfirmation:some View {
        Push(.topMiddle) { ConfirmView(content: .startDelayRemoved) { dismiss() }}
        .padding([.top])
    }
    
    private var delayCreatedConfirmation:some View {
        Push(.topMiddle) {
            ConfirmView(content: .startDelayCreated) { dismiss() }
        }
        .padding([.top])
    }
    
    private var tableBackground:some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .standardShadow()
//            Push(.topRight) { InfoButton { handleInfoButtonTap() } }
//                .padding(-8)
        }
    }
    
    private var colorsViewTitle:some View {
        HStack {
            Text("\(Color.userFriendlyBubbleColorName(for: bubble.color))")
                .textModifier(Color.bubbleColor(forName: bubble.color!))
            Spacer()
        }
        
        .layoutPriority(1)
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
                            Image.checkmark
                                .foregroundColor(.white)
                                .font(checkmarkFont)
                        }
                    }
                    .onTapGesture {
                        saveColor(for: bubble, to: colorName)
                        // FIXME: try to get rid of if statement and fix both flashes
                        if storedReferenceDelay != bubble.sdb!.referenceDelay {
                            saveDelay()
                        }
                    }
                }
            }
        }
        .frame(height: UIScreen.deviceNotTallEnough ? colorsTableHeight : 420)
        .scrollIndicators(.hidden)
    }
    
    // MARK: - User Intents
    func saveColor(for bubble:Bubble, to colorName: String) {
        viewModel.saveColor(for: bubble, to: colorName)
    }
    
    func saveDelay() {
        /*
         if user sets a new start delay
         save delay
         save CoreData context*/
                
        UserFeedback.singleHaptic(.medium)
        viewModel.saveDelay(for: bubble, storedReferenceDelay)
    }
    
    func handleInfoButtonTap() {
        viewModel.showMoreOptionsInfo = true
    }
    
    var swipeLeft:some Gesture {
        DragGesture(minimumDistance: 10)
            .onEnded { value in
                viewModel.removeDelay(for: bubble)
                
                //show 0s red alert and hide after 0.7 seconds
                viewModel.confirm_DelayRemoved = true
                delayExecution(.now() + 1) { viewModel.confirm_DelayRemoved = false }
                UserFeedback.doubleHaptic(.heavy)
            }
    }
    
//    var longPress:some Gesture {
//        LongPressGesture(minimumDuration: 0.3)
//            .onEnded { _ in
//                viewModel.removeDelay(for: bubble)
//
//                //show 0s red alert and hide after 0.7 seconds
//                viewModel.confirm_NoDelay = true
//                delayExecution(.now() + 1) { viewModel.confirm_NoDelay = false }
//                UserFeedback.doubleHaptic(.heavy)
//            }
//    }
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
    func textModifier(_ backgroundColor:Color, _ fontSize:CGFloat = MoreOptionsView.colorTitleSize) -> some View {
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
