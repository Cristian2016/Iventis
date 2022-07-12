import SwiftUI

///StartDelayBubbleView
///its data dependency is SDB [StartDelayBubble] in the model
struct SDBView:View {
    @EnvironmentObject var vm:ViewModel
    @StateObject var sdb:SDB
    
    var body: some View {
        VStack (alignment: .leading) {
            HStack (alignment: .bottom) {
                startDelayDisplay
                startDelaylabel
            }
            
            //buttons row 3
            HStack (spacing: MoreOptionsView.itemSpacing) {
                ForEach(Bubble.startDelayValues, id: \.self) { delay in
                    Rectangle()
                        .fill(Color.bubbleColor(forName: sdb.bubble!.color!))
                        .aspectRatio(contentMode: .fit)
                        .overlay {
                            Button("\(delay)") { vm.computeStartDelay(sdb, delay) }
                                .font(.system(size: 30).weight(.medium))
                        }
                }
            }
            .background(Color.white.opacity(0.001)) //prevent gestures from underlying view
            .font(.system(size: 26))
            .foregroundColor(.white)
        }
    }
    
    // MARK: - LEGO
    ///SDDisplay
    private var startDelayDisplay:some View {
        Text("\(Int(sdb.delay))s")
            .textModifier(Color.bubbleColor(forName: sdb.bubble!.color!))
    }
    
    private var startDelaylabel:some View {
        Text("\(Image(systemName: "clock.arrow.circlepath")) Start Delay")
            .font(.system(size: 22).weight(.medium))
            .foregroundColor(.gray)
    }
}
