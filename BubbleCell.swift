import SwiftUI
import MyPackage

struct BubbleCell: View {
    private let bubble:Bubble
    private let coordinator:BubbleCellCoordinator
    
    @Environment(Secretary.self) private var secretary
    
    init(_ bubble:Bubble) {
        self.bubble = bubble
        self.coordinator = bubble.coordinator
    }
    
    //MARK: -
    @Environment(ViewModel.self) private var viewModel
    @Environment(\.scenePhase) private var phase
    
    //MARK: -
    var body: some View {
        @Bindable var nvm = viewModel
        ZStack {
            //Three Circles
            circle //Sec
                .frame(maxWidth: .infinity, alignment: .trailing)
                .aspectRatio(2.1, contentMode: .fit)
                .background {
                    circle
                        .opacity(coordinator.timeComponentsOpacity.min)
                        .onTapGesture { toggleBubbleDetail() }
                        .onLongPressGesture { showBubbleNotes() }
                } //Min
                .overlay(alignment: .leading){
                    circle
                        .opacity(coordinator.timeComponentsOpacity.hr)
                        .onTapGesture { toggleBubbleDetail() }
                        .onLongPressGesture { showBubbleNotes() }
                } //Hr
                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                    favoriteButton
                    calButton
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    controlButton
                    moreOptionsButton
                }
                .overlay(alignment: .topLeading) {
                    CalendarSticker().environmentObject(bubble)
                }
                .gesture(tap)
                .gesture(longPress)
            
            //Three Labels (Hr, Min, Sec)
            Color.clear //frame
                .frame(maxWidth: .infinity, alignment: .trailing)
                .aspectRatio(2.1, contentMode: .fit)
                .overlay {
                    Circle().fill(.clear)
                        .overlay {
                            minLabel.opacity(coordinator.timeComponentsOpacity.min)
                        }
                }
                .overlay(alignment: .leading){
                    Circle().fill(.clear)
                        .overlay {
                            hrLabel.opacity(coordinator.timeComponentsOpacity.hr)
                        }
                }
                .overlay(alignment: .trailing) {
                    Circle().fill(.clear)
                        .overlay(alignment: .bottomTrailing) {
                            HundredthsLabel(bubble: bubble)
                                .allowsHitTesting(false)
                        }
                        .overlay { secondsLabel }
                        .overlay(alignment: .top) { TimerProgressView(bubble: bubble) }
                        .overlay { StartDelayButton(bubble) }
                }
        }
        .padding(.init(top: -4, leading: -10, bottom: -4, trailing: -10))
        .overlay(alignment: .topLeading) { stickyNote }
        .foregroundStyle(.white)
        .overlay(alignment: .topTrailing) { WidgetSymbol(rank: bubble.rank) }
        .onAppear {
            coordinator.refresh(.onAppear)
        }
        .onChange(of: phase) { oldPhase, newPhase in
            let isInactive = newPhase == .inactive
            let wasBackground = oldPhase == .background
            
            if isInactive && wasBackground {
                coordinator.refresh(.onPhaseChange)
            }
        }
    }
    
    private var tap:some Gesture { TapGesture().onEnded { _ in userTappedSeconds() }}
    
    private var longPress: some Gesture {
        LongPressGesture().onEnded { _ in endSession() }
    }
    
    private func userTappedSeconds() {
        //user intent model
        viewModel.toggleStart(bubble)
    }
    
    private func endSession() {
        //feedback
        UserFeedback.doubleHaptic(.heavy)
        
        //user intent model
        viewModel.endSession(bubble)
    }
    
    //MARK: -
    private var circle:some View {
        Circle()
            .fill(coordinator.color)
    }
    
    private var secondsLabel:some View {
        return Text(coordinator.timeComponents.sec)
            .modifier(LabelModifier())
    }
    
    private var favoriteButton:some View {
        Button { viewModel.togglePin(bubble) }
    label: { Label { Text(bubble.isPinned ? "Unpin" : "Pin") }
        icon: { Image(systemName: bubble.isPinned ? "pin.slash.fill" : "pin.fill") } }
    .tint(bubble.isPinned ? .gray : .orange)
    }
    
    private var calButton:some View {
        CalendarButton {
            viewModel.toggleCalendar(bubble)
        }
        .environmentObject(bubble)
    }
    
    //trailing Swipe actions 2
    private var controlButton:some View {
        Button {
            secretary.controlBubble(.show(bubble.rank))
            HelpOverlay.Model.shared.topmostView(.control)
        } label: {
            Label("Control", systemImage: "slider.vertical.3")
        }
        .tint(.red)
    }
    
    private var moreOptionsButton:some View {
        Button { viewModel.moreOptionsSheetBubble = bubble }
    label: { Label { Text("More") } icon: { Image.more } }.tint(.lightGray)
    }
    
    private var noteButtonContent:some View { BubbleNote().environmentObject(bubble) }
    
    private var stickyNote:some View {
        StickyNote (alignment: .leading) { noteButtonContent }
    dragAction: { viewModel.deleteStickyNote(for: bubble) }
        tapAction : { handleNoteTap() }
            .offset(x: -10, y: -16)
    }
    
    private var hrLabel:some View {
        Text(coordinator.timeComponents.hr)
            .opacity(coordinator.timeComponentsOpacity.hr)
            .modifier(LabelModifier())
    }
    
    private var minLabel:some View {
        Text(coordinator.timeComponents.min)
            .opacity(coordinator.timeComponentsOpacity.min)
            .modifier(LabelModifier())
    }
    
    func handleNoteTap() {
        let bContext = PersistenceController.shared.bContext
        let objID = bubble.objectID
        
        bContext.perform {
            UserFeedback.singleHaptic(.light)
            let thisBubble = PersistenceController.shared.grabObj(objID) as! Bubble
            thisBubble.isNoteHidden.toggle()
            PersistenceController.shared.save(bContext)
        }
    }
    
    private func toggleBubbleDetail() {
        viewModel.path = viewModel.path.isEmpty ? [bubble] : []
    }
    
    private func showBubbleNotes() {
        UserFeedback.singleHaptic(.light)
        HelpOverlay.Model.shared.topmostView(.bubbleNotes)
        viewModel.notes_Bubble = bubble
    }
}

extension BubbleCell {
    struct LabelModifier:ViewModifier {
        func body(content: Content) -> some View {
            content
                .allowsHitTesting(false)
                .font(.system(size: 400, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.1)
                .aspectRatio(2.3, contentMode: .fit)
        }
    }
    
    struct TimerProgressView:View {
        var bubble:Bubble
        
        var body: some View {
            ZStack {
                if bubble.coordinator.isTimer {
                    Color.clear
                        .aspectRatio(7.5, contentMode: .fit)
                        .overlay {
                            Text(bubble.coordinator.timerProgress)
                                .font(.system(size: 30, weight: .semibold))
                                .foregroundStyle(.black)
                                .minimumScaleFactor(0.1)
                                .padding([.leading, .trailing], 4)
                                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 4))
                                .environment(\.colorScheme, .light)
                        }
                        .allowsHitTesting(false)
                        .padding(.top)
                        .padding(.top, 6)
                }
            }
        }
    }
}
