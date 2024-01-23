import SwiftUI
import MyPackage

struct BubbleCell: View {
    private let bubble:Bubble
    private let coordinator:BubbleCellCoordinator
    
    init(_ bubble:Bubble) {
        self.bubble = bubble
        self.coordinator = bubble.coordinator
    }
    
    //MARK: -
    @Environment(ViewModel.self) private var viewModel
    @Environment(Secretary.self) private var secretary
    @Environment(\.scenePhase) private var phase
    @AppStorage(Storagekey.userFavoritedOnce) private var userFavoritedOnce = false
    
    //MARK: -
    var body: some View {
        ZStack {
            //Three Circles
            ZStack {
                circle //Sec
                HundredthsLabel(bubble: bubble)
                    .frame(alignment: .bottomTrailing)
            }
            
            .frame(maxWidth: .infinity, alignment: .trailing)
            .aspectRatio(2.1, contentMode: .fit)
            .background {
                circle
                    .opacity(coordinator.opacity.min)
                    .onTapGesture { toggleBubbleDetail() }
                    .onLongPressGesture { showBubbleNotes() }
            } //Min
            .overlay(alignment: .leading){
                circle
                    .opacity(coordinator.opacity.hr)
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
            .onTapGesture {
                viewModel.toggle(bubble)
            }
            .onLongPressGesture { viewModel.closeSession(bubble) }
            .overlay(alignment: .topTrailing) { WidgetSymbol(rank: bubble.rank) }
            
            //Three Labels (Hr, Min, Sec)
            Color.clear //frame
                .frame(maxWidth: .infinity, alignment: .trailing)
                .aspectRatio(2.1, contentMode: .fit)
                .overlay {
                    Circle().fill(.clear)
                        .overlay {
                            minLabel.opacity(coordinator.opacity.min)
                        }
                }
                .overlay(alignment: .leading){
                    Circle().fill(.clear)
                        .overlay {
                            hrLabel.opacity(coordinator.opacity.hr)
                        }
                }
                .overlay(alignment: .trailing) {
                    Circle().fill(.clear)
                        .overlay { secondsLabel }
                        .overlay(alignment: .top) { TimerProgressLabel(bubble: bubble) }
                        .overlay { DelayButton(bubble) }
                }
        }
        .padding(.init(top: 4, leading: 4, bottom: 4, trailing: 4))
        .overlay(alignment: .topLeading) { nameLabel }
        .foregroundStyle(.white)
        .onAppear {
            coordinator.refreshBubble(on: .appear) //super important
            viewModel.manageExample(bubble)
        }
        .onChange(of: phase) { oldPhase, _ in
            //refresh before bubble enters active phase
            if oldPhase == .background  {
                coordinator.refreshBubble(on: .phaseChange)
            }
        }
    }
    
    //MARK: -
    private var circle:some View {
        Circle()
            .fill(coordinator.color)
    }
    
    private var secondsLabel:some View {
        return Text(coordinator.components.sec)
            .modifier(LabelModifier())
    }
    
    private var favoriteButton:some View {
        Button {
            viewModel.togglePin(bubble)
            
            if !userFavoritedOnce {
                secretary.showFavoritesOnly = true
                userFavoritedOnce = true
            }
        }
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
            SmallHelpOverlay.Model.shared.topmostView(.control)
        } label: {
            Label("Control", systemImage: "slider.vertical.3")
        }
        .tint(.red)
    }
    
    private var moreOptionsButton:some View {
        Button { viewModel.moreOptionsSheetBubble = bubble }
    label: { Label { Text("More") } icon: { Image.more } }.tint(.ultralightGray)
    }
    
    private var noteButtonContent:some View { BubbleNote().environmentObject(bubble) }
    
    private var nameLabel:some View {
        StickyNote (alignment: .leading) { noteButtonContent }
    dragAction: { viewModel.deleteName(of: bubble) }
        tapAction : { handleNoteTap() }
            .padding(.leading, 4)
    }
    
    private var hrLabel:some View {
        Text(coordinator.components.hr)
            .opacity(coordinator.opacity.hr)
            .modifier(LabelModifier())
    }
    
    private var minLabel:some View {
        Text(coordinator.components.min)
            .opacity(coordinator.opacity.min)
            .modifier(LabelModifier())
    }
    
    func handleNoteTap() {
        let bContext = PersistenceController.shared.bContext
        let objID = bubble.objectID
        
        bContext.perform {
            let thisBubble = PersistenceController.shared.grabObj(objID) as? Bubble
            thisBubble?.isNoteHidden.toggle()
            PersistenceController.shared.save(bContext)
        }
    }
    
    private func toggleBubbleDetail() {
        viewModel.path = viewModel.path.isEmpty ? [bubble] : []
    }
    
    private func showBubbleNotes() {
        UserFeedback.singleHaptic(.light)
        SmallHelpOverlay.Model.shared.topmostView(.bubbleNotes)
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
    
    struct TimerProgressLabel:View {
        var bubble:Bubble
        
        var body: some View {
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
