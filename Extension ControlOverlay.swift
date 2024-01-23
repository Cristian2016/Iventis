//
//  Extension ControlOverlay.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 04.12.2023.
//

import SwiftUI
import MyPackage

extension ControlOverlay {
    struct Buttons:View {
        let bubble:Bubble
        
        @Environment(ViewModel.self) private var viewModel
        @Environment(Secretary.self) private var secretary
        
        var body: some View {
            HStack(spacing: 4) {
                Button {
                    delete()
                } label: {
                    Text("Delete")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .buttonStyle(BStyle(color: .red))
                
                if !bubble.sessions_.isEmpty {
                    Button { reset() } label: {
                        Text("Reset")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .buttonStyle(BStyle())
                }
            }
            .frame(maxHeight: 70)
            .aspectRatio(4, contentMode: .fit)
        }
        
        private func dismiss() {
            secretary.controlBubble(.hide)
            SmallHelpOverlay.Model.shared.topmostView(viewModel.path.isEmpty ? .bubbleList : .detail)
        }
        
        private func reset() {
            UserFeedback.singleHaptic(.heavy)
            viewModel.reset(bubble)
            dismiss()
            if Int(bubble.rank) == secretary.addNoteButton_bRank {
                secretary.setAddNoteButton_bRank(to: nil)
            }
        }
        
        private func delete() {
            UserFeedback.singleHaptic(.heavy)
            viewModel.deleteBubble(bubble)
            if Int(bubble.rank) == secretary.addNoteButton_bRank {
                secretary.setAddNoteButton_bRank(to: nil)
            }
            dismiss()
        }
    }
    
    //MARK: -
    struct MinutesGrid:View {
        private let bubble:Bubble
        private let color:Color
        
        //TabView
        @Binding private var selectedTab:String
        
        @Environment(ViewModel.self) private var viewModel
        @Environment(Secretary.self) private var secretary
        
        @AppStorage(Storagekey.controlFirstTime) private var firstTime = true
        
        private let minutes = [[-2, -1, 5, 10], [15, 20, 25, 30], [35, 40, 45, 50]]
        
        var body: some View {
            Grid(horizontalSpacing: 2, verticalSpacing: 2) {
                ForEach(minutes, id: \.self) { row in
                    GridRow {
                        ForEach(row, id: \.self) { digit in
                            Circle()
                                .fill(Color.background)
                                .overlay(alignment: .topTrailing) {
                                    if showCheckmark(digit) { SmallCheckmark() }
                                }
                                .overlay {
                                    Button {
                                        action(for: digit)
                                    } label: {
                                        VanishingUnderlabel {
                                            digitLabel(for: digit)
                                        } bottom: {
                                            if let underlabelText = underLabelText(digit) {
                                                Text(underlabelText)
                                                    .font(.system(size: 14))
                                            }
                                        }
                                    }
                                }
                        }
                    }
                }
                underLabel
            }
            .font(.digitFont)
            .foregroundStyle(Color.label2)
        }
        
        private func showCheckmark(_ digit:Int) -> Bool {
            guard digit < 0 else { return false }
            
            switch digit {
                case -1:
                    return bubble.isTimer ? true : false
                case -2:
                    return !bubble.isTimer ? true : false
                default :
                    return false
            }
        }
        
        init(_ bubble: Bubble, _ color:Color, _ selectedTab:Binding<String> ) {
            self.bubble = bubble
            self.color = color
            _selectedTab = selectedTab
        }
        
        private func dismiss() {
            secretary.controlBubble(.hide)
            SmallHelpOverlay.Model.shared.topmostView(viewModel.path.isEmpty ? .bubbleList : .detail)
        }
        
        private func handleTimerButtonTapped() {
            viewModel.durationPicker.reason = bubble.isTimer ? .editExistingTimer(bubble) : .changeToTimer(bubble)
            UserFeedback.singleHaptic(.heavy)
            dismiss()
        }
        
        private func action(for digit:Int) {
            switch digit {
                case -1:
                    handleTimerButtonTapped()
                    SmallHelpOverlay.Model.shared.topmostView(.durationPicker)
                case -2:
                    //allow stopwatches to reset currentClock, if currentClock > 0
                    if !bubble.isTimer && !bubble.isRunning && bubble.currentClock == 0 { return }
                    
                    viewModel.change(bubble, to:.stopwatch)
                    UserFeedback.singleHaptic(.heavy)
                    dismiss()
                    
                default:
                    viewModel.change(bubble, to: .timer(Float(digit) * 60))
                    UserFeedback.singleHaptic(.heavy)
                    dismiss()
            }
        }
        
        @ViewBuilder
        private func digitLabel(for digit:Int) -> some View {
            switch digit {
                case -2: Image.stopwatch
                case -1: Image.timer
                default: Text(String(digit))
            }
        }
        
        private func underLabelText(_ digit:Int) -> String? {
            guard digit < 6 else { return nil }
            
            switch digit {
                case -2: return nil // "Stopwatch"
                case -1: return nil // "Timer"
                default: return "Min"
            }
        }
        
        struct SmallCheckmark: View {
            var body: some View {
                Label("Tap", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .font(.system(size: 25))
                    .labelStyle(.iconOnly)
                    .allowsHitTesting(false)
            }
        }
        
        @ViewBuilder
        private var underLabel:some View {
            if firstTime {
                Text("Swipe \(Image.leftSwipe)")
                    .font(.system(size: 18))
                    .padding(.top, 4)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    struct HistoryGrid:View {
        @AppStorage(Storagekey.hasUserDeletedRecent) private var hasUserDeletedRecent = false
        let historyDigit = Color("historyDigit")
        private let bubble:Bubble
        
        @Environment(ViewModel.self) var viewModel
        @Environment(Secretary.self) private var secretary
        
        @Binding private var selectedTab:String
        @FetchRequest(entity: TimerDuration.entity(), sortDescriptors: [NSSortDescriptor(key: "date", ascending: false)], animation: .default)
        private  var timerDurations:FetchedResults<TimerDuration>
        
        private let columns = Array(repeating: GridItem(spacing: 1), count: 2)
        
        private var contentUnavailable:some View {
            ContentUnavailableView {
                Text("Empty List")
            } description: {
                Text("Recent timer durations are shown here")
                    .lineLimit(nil)
            } actions: {
                Button {
                    handleTimerButtonTapped()
                } label: {
                    Label("Choose Duration", systemImage: "")
                        .labelStyle(.titleOnly)
                }
            }
            .font(.system(size: 20))
        }
        
        private func handleTimerButtonTapped() {
            viewModel.durationPicker.reason = bubble.isTimer ? .editExistingTimer(bubble) : .changeToTimer(bubble)
            UserFeedback.singleHaptic(.heavy)
            dismiss()
        }
        
        private func handleTap(for duration:TimerDuration) {
            moveToListStart(duration)
            viewModel.change(bubble, to:  .timer(duration.value))
        }
        
        private func handleLongPress(for duration:TimerDuration) {
            UserFeedback.singleHaptic(.light)
            viewModel.delete(duration)
        }
        
        var body: some View {
            ScrollView {
                if timerDurations.isEmpty {
                    contentUnavailable
                } else {
                    LazyVGrid(columns: columns, spacing: 1) {
                        ForEach(timerDurations) { timerDuration in
                            Color.item
                                .frame(height: 44)
                                .overlay {
                                    Text(timerDuration.value.timerTitle)
                                }
                                .onTapGesture {
                                    handleTap(for: timerDuration)
                                    dismiss()
                                }
                                .onLongPressGesture {
                                    if !hasUserDeletedRecent {
                                        hasUserDeletedRecent = true
                                    }
                                    handleLongPress(for: timerDuration)
                                }
                        }
                    }
                }
            }
            .padding(.bottom)
            .scrollIndicators(.hidden)
            .font(.system(size: 29))
            .minimumScaleFactor(0.01)
            .lineLimit(1)
            .overlay(alignment: .bottom) { underLabel }
            .overlay(alignment: .bottom) { deleteNoteHint }
        }
        
        @ViewBuilder
        private var deleteNoteHint:some View {
            if !hasUserDeletedRecent && (1...7).contains(timerDurations.count) {
                Text("Touch and hold to delete")
                    .font(.system(size: 20))
                    .foregroundColor(.secondary)
                    .padding(.bottom)
                    .offset(y: -20)
            }
        }
        
        private var underLabel:some View {
            Text("\(Image.clock) Recents")
                .font(.system(size: 18))
                .foregroundStyle(.secondary)
        }
        
        private func moveToListStart(_ timerDuration:TimerDuration) {
            guard timerDurations.first != timerDuration else { return }
            timerDuration.date = Date()
            PersistenceController.shared.save()
        }
        
        private func dismiss() {
            UserFeedback.singleHaptic(.heavy)
            secretary.controlBubble(.hide)
            SmallHelpOverlay.Model.shared.topmostView(viewModel.path.isEmpty ? .bubbleList : .detail)
            
            let bContext = PersistenceController.shared.bContext
            let bubbleID = bubble.objectID
            bContext.perform {
                let theBubble = PersistenceController.shared.grabObj(bubbleID) as? Bubble
                theBubble?.selectedTab = selectedTab
                PersistenceController.shared.save(bContext)
            }
        }
        
        init(_ bubble: Bubble, _ selectedTab:Binding<String>) {
            self.bubble = bubble
            _selectedTab = selectedTab
        }
    }
    
    //MARK: -
    struct BubbleLabel:View {
        @Environment(ViewModel.self) private var viewModel
        
        private var bubble:Bubble?
        private var color:Color?
        private var colorName = ""
        
        init?(_ kind:Kind) {
            switch kind {
                case .hasBubble(let bubble):
                    guard let bubble = bubble else { return nil }
                    
                    self.bubble = bubble
                    self.color = Color.bubbleColor(forName: bubble.color)
                    
                case .noBubble(let bicolor):
                    guard let bicolor = bicolor else { return nil }
                    
                    self.color = bicolor.color
                    self.colorName = bicolor.description
            }
        }
        
        var body: some View {
            ZStack {
                if viewModel.path.isEmpty {
                    HStack {
                        color
                            .aspectRatio(1.0, contentMode: .fit)
                            .frame(height: 20)
                            .clipShape(RoundedRectangle(cornerRadius: 2))
                        
                        if let bubble = bubble {
                            Text(String.readableName(for: bubble.color))
                        } else {
                            Text(String.readableName(for: colorName))
                        }
                        
                        if let bubble = bubble {
                            if !bubble.sessions_.isEmpty { Text("\(bubble.sessions_.count)") }
                        }
                    }
                    .foregroundStyle(.label2)
                    .font(.system(size: 24))
                    .allowsHitTesting(false)
                    .padding(.init(top: 0, leading: 4, bottom: 0, trailing: 4))
                    .background(Color("background2"), in: RoundedRectangle(cornerRadius: 4))
                    .compositingGroup()
                    .standardShadow()
                }
            }
        }
        
        enum Kind {
            case hasBubble(Bubble?)
            case noBubble(Color.Bicolor?)
        }
    }
    
    //MARK: -
    struct BStyle:ButtonStyle {
        var color = Color("deleteActionAlert")
        
        func makeBody(configuration: Configuration) -> some View {
            let scale = configuration.isPressed ? CGFloat(0.8) : 1.0
            
            configuration.label
                .foregroundStyle(.white)
                .font(.system(size: 30, weight: .medium, design: .rounded))
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(color)
                }
                .scaleEffect(x: scale, y: scale)
        }
        
        enum Position {
            case left(Color)
            case right(Color)
        }
    }
}
