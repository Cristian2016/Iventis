//
//  HelpViewModel.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 21.12.2023.
//

import SwiftUI
import MyPackage

struct CircleLabel:LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.icon
            .padding(12)
            .background(Circle().fill(.background))
    }
}

struct HintOverlay:View {
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @State private var contentOffset = CGFloat(0)
    @State private var accumulatedOffset = CGFloat(0)
    @State private var containerOffset = initialContainerOffset
    @Environment(Secretary.self) private var secretary
    
    private var content = HintOverlay.HintCell.Content.all[HintOverlay.Model.shared.topmostView]
    
    static private let initialContainerOffset = CGFloat(128)
    
    private var symbol:String {
        if containerOffset == Self.initialContainerOffset {
            return contentOffset == .zero ? "arrow.up.to.line" : "arrow.uturn.backward"
        } else {
            return contentOffset == .zero ? "arrow.down.to.line" : "arrow.uturn.backward"
            
        }
    }
    
    var body: some View {
        if HintOverlay.Model.shared.helpOverlayShows && verticalSizeClass == .regular {
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
                .onTapGesture { secretary.helpVH(.show()) }
            Label("Move", systemImage: symbol)
                .labelStyle(.iconOnly)
                .onTapGesture { handleTap() }
            
            Spacer()
            
            Label("Dismiss", systemImage: "xmark")
                .labelStyle(.iconOnly)
                .onTapGesture { HintOverlay.Model.shared.helpOverlay(.hide) }
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
extension HintOverlay {
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
                    secretary.helpVH(.show(animate: true))
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
            VStack(spacing: 6) {
                if let title2 = content.title2 { Text(title2).foregroundStyle(.secondary) }
                
                Text(content.description)
                    .font(.system(size: 22))
                    .environment(\.openURL, OpenURLAction {
                        let receivedStringURL = $0.absoluteString
                        let content =
                        HelpCellContent.all.filter { $0.title.description == receivedStringURL }.first
                        
                        if let content = content {
                            secretary.helpVH(.show())
                            delayExecution(.now() + 0.001) {
                                HintOverlay.Model.shared.path = [content]
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
                        .frame(height: 120)
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
                .palette : .init("Colors", "Create Tracker", description: "Touch and hold color for timer. Tap for stopwatch. \(Image.leftSwipe) Swipe left to dismiss", example: "e.g., Create yellow timer: tap and hold color, then choose desired duration"),
                .durationPicker : .init("Duration", "48 Hr Max", description: "Timer duration is valid if \(Text("\(Image.roundCheckmark)").foregroundStyle(.green)) shows.\n・drag down to save duration\n・\(Image.leftSwipe) swipe to clear display", example: "e.g., 02h = 2hr, 01h 05m = 1hr 5min, etc."),
                .control : .init("Control", "Delete, Reset, Change", description: "Control actions \(Text("do not remove").foregroundStyle(.red)) calendar events! Reset empties tracker activity.\nTap \(Image.stopwatch) to change to stopwatch.\nTap \(Image.timer), 5, 10, etc. to change to timer.\nSwipe to '\(Image.clock) Recents'"),
                .moreOptions : .init("More Options", "Start Delay", description: "...counts down to zero, then tracker starts automatically. Only visible if tracker is not running. Drag start delay circle to remove", example: "Useful if hands are busy. E.g., at the gym, warming up before workout", image: "start.delay"),
                .bubbleNotes : .init("Tracker Notes", description: "Tether tracker to calendar. Add note and create a calendar in Calendar App with identical names and events will be added automatically to the calendar with identical name", example: "Add calendar with name '☀️ Outdoor' and choose tracker note with same name"),
                .lapNotes : .init("Lap Notes", description: "Maximum length 12 characters"),
                .bubbleList : .init("Trackers", "...are stopwatches and timers", description: "Tracker areas: hr, min, sec. Areas react to touch-and-hold and tap gestures", example: "e.g., \(Image.one) Tap sec to start/pause. Touch and hold to \(Image.closed) close session. \(Image.two) Tap min to show activity. Touch and hold to add name"),
                .sessionDelete : .init("", "Delete Session", description: "\(Text("If session has a corresponding calendar event, the event will also be removed").foregroundStyle(.red))"),
                .detail : .init("Activity", "...contains Sessions",  description: "Sessions are like calendar events. Touch and hold seconds to \(Image.closed) close session. [Save closed sessions](eventify://saveActivity) as events. Touch and hold session to delete")
            ]
        }
    }
}

extension HintOverlay {
    @Observable
    class Model {
        //MARK: - Publishers
        private(set) var topmostView = TopMostView.bubbleList
        
        private(set) var helpOverlayShows = false
        
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
            DispatchQueue.main.async {
                self.topmostView = value
            }
        }
        
        func helpOverlay(_ state:BoolState) {
            DispatchQueue.main.async {
                withAnimation {
                    self.helpOverlayShows = state == .show ? true : false
                }
            }
        }
        
        func helpButton(_ state:BoolState) {
            DispatchQueue.main.async {
                withAnimation {
                    self.helpButtonShows = state == .show ? true : false
                }
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
        }
    }
    
    struct HelpButton: View {
        var body: some View {
            if HintOverlay.Model.shared.helpButtonShows {
                Button {
                    UserFeedback.singleHaptic(.light)
                    HintOverlay.Model.shared.helpButton(.hide)
                    HintOverlay.Model.shared.helpOverlay(.show)
                } label: {
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.ultraLightGray1, lineWidth: 2)
                        .fill(.white)
                        .frame(width: 90, height: 90)
                        .standardShadow()
                        .overlay {
                            Circle()
                                .fill(.white.shadow(.inner(color: .black.opacity(0.2), radius: 2.5, x: 1, y: 1)))
                                .padding(4)
                                .overlay {
                                    Image(systemName: "questionmark.circle.fill")
                                        .font(.system(size: 64))
                                        .foregroundStyle(.blue)
                                }
                        }
                }
                .padding(4)
                .transition(.asymmetric(insertion: .slide, removal: .move(edge: .leading)))
            }
        }
    }
}

extension UIViewController {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        let model = HintOverlay.Model.shared
        
        if motion == .motionShake && !model.helpOverlayShows {
            if !model.helpButtonShows {
                model.helpButton(.show)
            }
        }
    }
}

#Preview(body: {
    HelpCell(content: .init("Basics", "calendar.badge.plus", .saveActivity, "Save Activity", "First make sure tracker is [calendar-enabled](eventify://enableCalendar). As soon as you end a session, it will be saved as an event in the Calendar App. Touch and hold seconds to end a session", image: "", image2: "bubble.save.activity"))
})
