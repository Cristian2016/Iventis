//
//  HelpViewModel.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 21.12.2023.
//

import SwiftUI
import MyPackage


struct SwipeGestureModifier:ViewModifier {
    var action: () -> ()
    
    func body(content: Content) -> some View {
        content
            .gesture(DragGesture()
                .onEnded {
                    if abs($0.translation.width) > 40 {
                        UserFeedback.singleHaptic(.heavy)
                        action()
                    }
                })
    }
}

extension View {
    func swipeToClear(_ action: @escaping () -> ()) -> some View {
        self.modifier(SwipeGestureModifier(action: action))
    }
}

struct CircleLabel:LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.icon
            .padding(12)
            .background(Circle().fill(Color.background))
    }
}

struct SmallHelpOverlay:View {
    @Environment(Secretary.self) private var secretary
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    @State private var contentOffset = CGFloat(0)
    @State private var accumulatedOffset = CGFloat(0)
    @State private var containerOffset = initialContainerOffset
    
    private var content = SmallHelpOverlay.HintCell.Content.all[SmallHelpOverlay.Model.shared.topmostView]
    
    static private let initialContainerOffset = CGFloat(128)
    
    private var symbol:String {
        if containerOffset == Self.initialContainerOffset {
            return contentOffset == .zero ? "arrow.up.to.line" : "arrow.uturn.backward"
        } else {
            return contentOffset == .zero ? "arrow.down.to.line" : "arrow.uturn.backward"
            
        }
    }
    
    var body: some View {
        if SmallHelpOverlay.Model.shared.showSmallHelpOverlay && verticalSizeClass == .regular {
            Color.clear
                .overlay(alignment: .bottom) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.regularMaterial)
                        .frame(height: 350)
                        .standardShadow()
                        .environment(\.colorScheme, .dark)
                        .overlay {
                            VStack {
                                toolbar
                                    .environment(\.colorScheme, .dark)
                                
                                ScrollView {
                                    VStack {
                                        HintCell(content: content)
                                            .padding(.init(top: 10, leading: 8, bottom: 10, trailing: 8))
                                        Color.clear
                                            .frame(height: 200)
                                    }
                                }
                                .background()
                            }
                            .padding(.init(top: 8, leading: 4, bottom: 20, trailing: 4))
                            .onTapGesture { /* blocks drag gesture */ }
                        }
                        .offset(x: 0.0, y: contentOffset)
                        .gesture(drag)
                }
                .offset(x: 0.0, y: containerOffset)
                .ignoresSafeArea()
                .padding([.leading, .trailing], 2)
        }
    }
    
    //MARK: - LEGO
    private var toolbar:some View {
        HStack {
            Label("Help", systemImage: "questionmark.circle")
                .font(.system(size: 30))
                .labelStyle(.iconOnly)
                .onTapGesture { secretary.bigHelpOverlay(.show()) }
            Label("Move", systemImage: symbol)
                .labelStyle(.iconOnly)
                .onTapGesture { handleTap() }
            
            Spacer()
            
            Label("Dismiss", systemImage: "xmark")
                .labelStyle(.iconOnly)
                .onTapGesture { SmallHelpOverlay.Model.shared.helpOverlay(.hide) }
        }
        .frame(height: 44) //minimum touch area
        .font(.system(size: 26))
        .overlay {
            Text(content?.title1 ?? "")
                .font(.system(size: 24))
                .allowsHitTesting(/*@START_MENU_TOKEN@*/false/*@END_MENU_TOKEN@*/)
        }
        .foregroundStyle(.secondary)
        .padding([.leading, .trailing], 10)
    }
    
    //MARK: -
    private var drag:some Gesture {
        DragGesture()
            .onChanged {
                //                contentOffset.width = accumulatedOffset.width + $0.translation.width
                contentOffset = accumulatedOffset + $0.translation.height
            }
            .onEnded { _ in
                accumulatedOffset = contentOffset
                //do not use value! ⚠️
            }
    }
    
    //MARK: -
    private func handleTap() {
        withAnimation {
            if containerOffset == .zero {
                contentOffset = .zero
                accumulatedOffset = .zero
                containerOffset = Self.initialContainerOffset
                return
            }
            if contentOffset == .zero {
                containerOffset = .zero //move up
            } else {
                contentOffset = .zero
                accumulatedOffset = .zero
                containerOffset = Self.initialContainerOffset //move up
            }
        }
    }
}

//MARK: -
extension SmallHelpOverlay {
    struct ButtonStack:View {
        @Environment(Secretary.self) private var secretary
        @Environment(\.openURL) private var openURL
        
        var body: some View {
            HStack {
                Button {
                    openYouTubeTutorial()
                } label: {
                    Label("Watch Tutorial", systemImage: "safari")
                }
                Divider()
                Button {
                    SmallHelpOverlay.Model.shared.helpOverlay(.show)
                } label: {
                    Label("Help", systemImage: "questionmark.circle")
                }
            }
            .foregroundStyle(.blue)
            .labelStyle(.titleOnly)
        }
        
        private func openYouTubeTutorial() {
            if let url = URL.watchTutorial {
                openURL(url)
            }
        }
    }
    
    struct HintCell:View {
        @Environment(\.colorScheme) private var scheme
        @Environment(Secretary.self) private var secretary
        let content:Content
        
        var body: some View {
            VStack(alignment: .leading, spacing: 6) {
                if let title2 = content.title2 { Text(title2).foregroundStyle(.secondary) }
                
                Text(content.description)
                    .font(.system(size: 22))
                    .environment(\.openURL, OpenURLAction {
                        let receivedStringURL = $0.absoluteString
                        let content =
                        HelpCellContent.all.filter { $0.title.description == receivedStringURL }.first
                        
                        if let content = content {
                            secretary.bigHelpOverlay(.show())
                            delayExecution(.now() + 0.001) {
                                SmallHelpOverlay.Model.shared.path = [content]
                            }
                        }
                        
                        return .handled
                    })
                
                if let example = content.example {
                    Text(example)
                        .font(.system(size: 22))
                        .foregroundStyle(.secondary)
                }
                
                if let image = content.image {
                    Image(scheme == .dark ? image + ".dark" : image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 150)
                }
            }
            .font(.system(size: 24))
        }
        
        init?(content: Content?) {
            guard let content = content else { return nil }
            self.content = content
        }
        
        struct Content {
            let title1:LocalizedStringKey
            var title2:String?
            let description:LocalizedStringKey
            var example:LocalizedStringKey?
            var image:String?
            
            init(_ title1: LocalizedStringKey, _ title2: String? = nil, description: LocalizedStringKey, example: LocalizedStringKey? = nil, image:String? = nil) {
                self.title1 = title1
                self.title2 = title2
                self.description = description
                self.example = example
                self.image = image
            }
            
            //a dictionary with all contents
            static let all:[Model.TopMostView : Content] = [
                .palette : .init("Colors", "Create Bubble", description: "Touch and hold color for timer. Tap for stopwatch.\n\(Image.leftSwipe) Swipe left to dismiss"),
                .durationPicker : .init("Duration", "48 Hr Max", description: "Timer duration is valid if \(Text("\(Image.roundCheckmark)").foregroundStyle(.green)) shows.\n・\(Image.dragDown) drag down to save duration\n・\(Image.swipeBidirectional) swipe to clear display", example: "e.g., 02h = 2hr, 01h 05m = 1hr 5min, etc."),
                .control : .init("Control", "Delete, Reset, Change", description: "Control actions \(Text("do not remove").foregroundStyle(.red)) calendar events! Reset empties bubble activity.\nTap \(Image.stopwatch) to change to stopwatch.\nTap \(Image.timer), 5, 10, etc. to change to timer.\nSwipe to '\(Image.clock) Recents'"),
                .moreOptions : .init("More Options", "Start Delay", description: "...counts down to zero, then bubble starts automatically. Only visible if bubble is not running. \(Image.swipeBidirectional) Swipe to clear display. Drag start delay circle to remove", example: "Useful if hands are busy. E.g., at the gym, warming up before workout", image: "start.delay"),
                .bubbleNotes : .init("Names", description: "・\(Image.dragDown) drag down to save\n・\(Image.swipeBidirectional) swipe to clear display\n[Tether bubble](eventify://tetherBubbleCal) to calendar: Bubble automatically adds events to calendar with same name.", example: "e.g., In Calendar App add new calendar. Name both bubble and new calendar 'Outdoor'. From now on bubble creates events in 'Outdoor' calendar"),
                .lapNotes : .init("Notes", description: "・\(Image.dragDown) drag down to save\n・\(Image.swipeBidirectional) swipe to clear display\n・touch and hold lap to add note"),
                .bubbleList : .init("Bubbles", "...are colorful stopwatches and timers", description: "Hr, min and sec areas react to touch-and-hold and tap gestures", example: "e.g., \(Image.one) Tap sec to start/pause. Touch and hold to \(Image.closed) close session. \(Image.two) Tap min to show activity. Touch and hold to add name", image: "bubble.areas"),
                .sessionDelete : .init("", "Delete Session", description: "\(Text("If session has a corresponding calendar event, the event will also be removed").foregroundStyle(.red))"),
                .detail : .init("Activity", "...contains Sessions",  description: "Sessions are like calendar events. [Save sessions](eventify://saveActivity) as events. Touch and hold seconds to \(Image.closed) close session. Touch and hold session to delete. Touch and hold lap to add note"),
                .assistUser : .init("\(Image.three) Steps", description:
"""
\(Image.one) Enable Calendar.
Swipe right on stopwatch > Tap 'Cal ON' > Choose 'Allow Full Access'
\(Text("'\(Names.testBubbleName)' is now allowed to create events").foregroundStyle(.secondary))

\(Image.two) Open Session.
Tap seconds. A new session \(Image.opened) opens, which creates an event in Calendar App. Tap seconds a couple of times...

\(Image.three) Close Session.
Touch and hold seconds. Session and event are now \(Image.closed) closed. Check out updated event in Calendar App

...and one last thing.
\(Image(systemName: "iphone.radiowaves.left.and.right")) Shake device for help. At any time!
""")
            ]
        }
    }
}

extension SmallHelpOverlay {
    @Observable
    class Model {
        //MARK: - Publishers
        private(set) var topmostView = TopMostView.bubbleList
        
        private(set) var showSmallHelpOverlay = false
        
        private(set) var helpButtonShows = false {
            didSet {
                if !oldValue {
                    let fiveSeconds = DispatchTime.now() + 5
                    
                    //main
                    fiveSecTimer.executeAction(after: fiveSeconds) { [weak self] in
                        self?.helpButton(.hide)
                    }
                }
            }
        }
        
        var path = [HelpCellContent]()
        
        func topmostView(_ value:TopMostView) {
            if topmostView == .assistUser && value != .bubbleList { return }
            
            DispatchQueue.main.async {
                self.topmostView = value
            }
        }
        
        func helpOverlay(_ state:BoolState) {
            DispatchQueue.main.async {
                withAnimation {
                    self.showSmallHelpOverlay = state == .show ? true : false
                }
            }
        }
        
        func helpButton(_ state:BoolState) {
            DispatchQueue.main.async {
                self.helpButtonShows = state == .show ? true : false
            }
        }
        
        enum BoolState {
            case show
            case hide
        }
        
        //MARK: -
        private var fiveSecTimer = PrecisionTimer() //2
        
        private init() { }
        
        static let shared = Model()
        
        enum TopMostView:String {
            case palette
            case durationPicker
            case moreOptions
            case control
            case sessionDelete
            case bubbleList
            case detail
            case bubbleNotes
            case lapNotes
            case assistUser
        }
    }
    
    struct ShakeHelpButton: View {
        @Environment(Secretary.self) private var secretary
        
        var body: some View {
            if SmallHelpOverlay.Model.shared.helpButtonShows {
                Button {
                    UserFeedback.singleHaptic(.light)
                    SmallHelpOverlay.Model.shared.helpButton(.hide)
                    SmallHelpOverlay.Model.shared.helpOverlay(.show)
                } label: {
                    Image(systemName: "questionmark.circle")
                }
                .buttonStyle(HelpButtonStyle())
                .padding(4)
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color("helpButtonBackground"))
                        .strokeBorder(.tertiary, lineWidth: 1)
                }
                .padding(.leading, 10)
                .compositingGroup()
                .standardShadow()
            }
        }
    }
}

struct HelpButtonStyle : ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 60))
            .foregroundStyle(.blue)
            .frame(width: 70, height: 70)
            .background(Color("helpButtonBackground"))
    }
}

extension UIViewController {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        let model = SmallHelpOverlay.Model.shared
        
        if motion == .motionShake && !model.showSmallHelpOverlay {
            if !model.helpButtonShows {
                model.helpButton(.show)
            }
        }
    }
}

#Preview {
    SmallHelpOverlay.ShakeHelpButton()
}
