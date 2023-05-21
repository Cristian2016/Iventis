//
//  Action1View.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 20.05.2023.
//

import SwiftUI
import MyPackage

struct Action1View: View {
    let bubble:Bubble
    @EnvironmentObject private var viewModel:ViewModel
    @State private var selectedTab:String
    
    let metrics = Metrics()
    
    var body: some View {
        ZStack {
            screenDarkBackground
                .onTapGesture { dismiss() }
            
            VStack {
                HStack(spacing: 7) {
                    deleteButton
                    if !bubble.sessions_.isEmpty { resetButton }
                }
                .labelStyle(.titleOnly) //looks for labels inside HStack
                .clipShape(vRoundedRectangle(corners: [.topLeft, .topRight], radius: 20))
                
                vRoundedRectangle(corners: [.bottomLeft, .bottomRight], radius: 40)
                    .fill(.white)
                    .overlay {
                        TabView(selection: $selectedTab) {
                            MinutesGrid(bubble, $selectedTab)
                                .tag("MinutesGrid")
                            HistoryGrid(bubble, $selectedTab)
                                .tag("HistoryGrid")
                        }
                        .clipShape(vRoundedRect)
                        .padding(EdgeInsets(top: 0, leading: 5, bottom: 4, trailing: 5))
                        .padding([.bottom])
                        .tabViewStyle(.page(indexDisplayMode: .never))
                    }
            }
            .compositingGroup()
            .standardShadow()
            .frame(width: metrics.size.width, height: metrics.size.height)
        }
    }
    
    private var vRoundedRect:some Shape {
        vRoundedRectangle(corners: [.bottomLeft, .bottomRight], radius: 30)
    }
    
    private var deleteButton:some View {
        Button {
            deleteBubble()
        } label: {
            Label("Delete", systemImage: "trash")
                .padding()
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(BStyle(position: .left(.red)))
        .foregroundColor(.white)
    }
    
    private var resetButton:some View {
        Button {
            resetBubble()
        } label: {
            Label("Reset", systemImage: "arrow.counterclockwise.circle")
                .padding()
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(BStyle(position: .right(Color("deleteActionAlert1"))))
    }
    
    private var screenDarkBackground:some View {
        Color.black
            .opacity(0.6)
            .ignoresSafeArea()
    }
    
    
    // MARK: - Methods
    private func resetBubble() {
        hapticFeedback()
        viewModel.reset(bubble)
        Secretary.shared.deleteAction_bRank = nil
    }
    
    private func deleteBubble() {
        hapticFeedback()
        viewModel.deleteBubble(bubble)
        dismiss()
    }
    
    private func dismiss() {
        Secretary.shared.deleteAction_bRank = nil
        
        let bContext = PersistenceController.shared.bContext
        let objID = bubble.objectID
                
        bContext.perform {
            let theBubble = PersistenceController.shared.grabObj(objID) as? Bubble
            theBubble?.selectedTab = selectedTab
            PersistenceController.shared.save(bContext)
        }
    }
    
    // MARK: -
    private func hapticFeedback() { UserFeedback.singleHaptic(.heavy) }
    
    // MARK: - Init
    init(_ bubble: Bubble) {
        self.bubble = bubble
        self.selectedTab = bubble.selectedTab ?? "Pula"
    }
}

extension Action1View {
    struct Metrics {
        let size = CGSize(width: 290, height: 370)
        let buttonHeight = CGFloat(80)
        let padding = CGFloat(6)
    }
}

extension Action1View {
    struct BStyle:ButtonStyle {
        
        let position:Position
        
        func makeBody(configuration: Configuration) -> some View {
            let scale = configuration.isPressed ? CGFloat(0.8) : 1.0
            
            configuration.label
                .foregroundColor(.white)
                .font(.system(size: 30, weight: .medium, design: .rounded))
                .background {
                    switch position {
                        case .left(let color):
                                color
                        case .right(let color):
                                color
                    }
                }
                .opacity(configuration.isPressed ? 0.5 : 1.0)
                .scaleEffect(x: scale, y: scale)
        }
        
        enum Position {
            case left(Color)
            case right(Color)
        }
    }
}

extension Action1View {
    struct MinutesGrid:View {
        private let bubble:Bubble
        @Binding var selectedTab:String
        @EnvironmentObject private var viewModel:ViewModel
        let minutes = [[1, 2, 3, 4], [5, 10, 15, 20], [25, 30, 45, 60]]
        
        var body: some View {
            let color = Color.bubbleColor(forName: bubble.color)
            
            Grid(horizontalSpacing: 2, verticalSpacing: 2) {
                GridRow {
                    if bubble.isTimer {
                        color
                            .overlay {
                                Button("\(Image.stopwatch)") {
                                    viewModel.change(bubble, to:.stopwatch)
                                    UserFeedback.singleHaptic(.heavy)
                                    dismiss()
                                }
                            }
                            .padding([.top], 5)
                            .disabled(bubble.isTimer ? false : true)
                    }
                    
                    Text("*\(Image.timer) Choose Minutes*")
                        .font(.system(size: 22))
                        .padding([.top, .bottom], 10)
                        .foregroundColor(.black)
                        .gridCellColumns(bubble.isTimer ? 3 : 4)
                }
                
                ForEach(minutes, id: \.self) { row in
                    GridRow {
                        ForEach(row, id: \.self) { digit in
                            color
                                .overlay {
                                    Button(String(digit)) {
                                        viewModel.change(bubble, to: .timer(Float(digit) * 60))
                                        UserFeedback.singleHaptic(.heavy)
                                        dismiss()
                                    }
                                }
                        }
                    }
                }
            }
            .accentColor(.white)
            .font(.system(size: 32, weight: .medium, design: .rounded))
        }
        
        private func dismiss() {
            Secretary.shared.deleteAction_bRank = nil
            
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
    
    struct HistoryGrid:View {
        private let bubble:Bubble
        @EnvironmentObject private var viewModel:ViewModel
        @Binding private var selectedTab:String
        @FetchRequest(entity: TimerDuration.entity(), sortDescriptors: [NSSortDescriptor(key: "date", ascending: false)])
        private  var durations:FetchedResults<TimerDuration>
        
        private let columns = Array(repeating: GridItem(spacing: 4), count: 2)
        
        var body: some View {
            VStack {
                Grid(horizontalSpacing: 2, verticalSpacing: 2) {
                    let color = Color.bubbleColor(forName: bubble.color)
                    Text("*\(Image.timer) Recent Durations*")
                        .font(.system(size: 22))
                        .padding([.top, .bottom], 10)
                        .foregroundColor(.black)
                    
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 2) {
                            ForEach(durations) { timerDuration in
                                color
                                    .frame(idealHeight: 51)
                                    .overlay {
                                        Text(timerDuration.value.timeComponentsAbreviatedString)
                                    }
                                    .onTapGesture {
                                        viewModel.change(bubble, to: .timer(timerDuration.value))
                                        dismiss()
                                    }
                                    .onLongPressGesture { viewModel.delete(timerDuration) }
                            }
                        }
                    }
                    .foregroundColor(.white)
                    .font(.system(size: 28, weight: .medium))
                    .minimumScaleFactor(0.01)
                    .lineLimit(1)
                }
            }
            .padding([.leading], 1)
        }
        
        private func dismiss() {
            UserFeedback.singleHaptic(.heavy)
            Secretary.shared.deleteAction_bRank = nil
            
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
}

struct Action1View_Previews: PreviewProvider {
    static let bubble:Bubble = {
        let context = PersistenceController.preview.viewContext
        let bubble = Bubble(context: context)
        bubble.color = "orange"
        bubble.initialClock = 0
//        bubble.currentClock = 10
        let session = Session(context: context)
        bubble.addToSessions(session)
        return bubble
    }()
    
    static var previews: some View {
        Action1View(Self.bubble)
    }
}
