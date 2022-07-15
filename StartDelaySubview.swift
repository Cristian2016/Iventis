import SwiftUI

///StartDelayBubbleView
///its data dependency is SDB [StartDelayBubble] in the model
struct StartDelaySubview:View {
    @EnvironmentObject var vm:ViewModel
    @StateObject var sdb:SDB
    
    var body: some View {
        if sdb.bubble?.state != .running {
            VStack (alignment: .leading) {
                HStack (alignment: .bottom) {
                    startDelayDisplay.layoutPriority(1)
                    startDelaylabel
                }
                
                //buttons row 3
                HStack (spacing: MoreOptionsView.itemSpacing) {
                    ForEach(Bubble.startDelayValues, id: \.self) { delay in
                        Rectangle()
                            .fill(Color.bubbleColor(forName: sdb.bubble!.color!))
                            .aspectRatio(contentMode: .fit)
                            .overlay {
                                Button("\(delay)") {
                                    vm.computeReferenceDelay(sdb, delay)
                                    
                                    //pause sdb if it's running
                                    if sdb.state == .running { sdb.toggleStart() }
                                }
                                .font(.system(size: 30).weight(.medium))
                            }
                    }
                }
                .background(Color.white.opacity(0.001)) //prevent gestures from underlying view
                .font(.system(size: 26))
                .foregroundColor(.white)
                
                Divider()
            }
        }
    }
    
    // MARK: - LEGO
    ///SDDisplay
    private var startDelayDisplay:some View {
        HStack {
            Text("\(Image(systemName: "clock.arrow.circlepath"))")
                .font(.system(size: 22).weight(.bold))
            HStack (alignment: .lastTextBaseline, spacing: 0) {
                Text("\(Int(sdb.referenceDelay))")
                Text("s")
                    .font(.system(size: 22).weight(.bold))
            }
        }
        .textModifier(Color.bubbleColor(forName: sdb.bubble!.color!), 40)
    }
    
    @ViewBuilder
    private var startDelaylabel:some View {
        if sdb.referenceDelay == 0 {
            Text("Start Delay")
                .font(.system(size: 22).weight(.medium))
                .foregroundColor(.gray)
        }
    }
}
