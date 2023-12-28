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
    @State private var contentOffset = CGSize.zero
    @State private var accumulatedOffset = CGSize.zero
    @State private var containerOffset = initialContainerOffset
    @Environment(Secretary.self) private var secretary
    
    private var content = HintOverlay.HintCell.Content.all[HintOverlay.Model.shared.topmostView]
    
    static private let initialContainerOffset = CGSize(width: 0, height: 140)
    
    private var symbol:String {
        if containerOffset == Self.initialContainerOffset {
            return contentOffset == .zero ? "arrow.up.to.line" : "arrow.uturn.backward"
        } else {
            return contentOffset == .zero ? "arrow.down.to.line" : "arrow.uturn.backward"
            
        }
    }
    
    var body: some View {
        if HintOverlay.Model.shared.showHelpOverlay && verticalSizeClass == .regular {
            Color.clear
                .overlay(alignment: .bottom) {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(.regularMaterial)
                        .strokeBorder(.quaternary)
                        .frame(height: 350)
                        .standardShadow()
                        .overlay {
                            VStack {
                                toolbar
                                
                                ScrollView {
                                    VStack {
                                        HintCell(content: content)
                                            .padding(.init(top: 10, leading: 4, bottom: 10, trailing: 4))
                                        Color.clear
                                            .frame(height: 200)
                                    }
                                }
                                .background()
                            }
                            .padding(8)
                            .onTapGesture {
                                //blocks drag gesture to work when user touches VStack. drag will only work on the RoundedRect ⚠️
                            }
                        }
                        .offset(contentOffset)
                        .gesture(drag)
                }
                .offset(containerOffset)
                .ignoresSafeArea()
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
    }
    
    //MARK: -
    private var drag:some Gesture {
        DragGesture()
            .onChanged {
                contentOffset.width = accumulatedOffset.width + $0.translation.width
                contentOffset.height = accumulatedOffset.height + $0.translation.height
            }
            .onEnded { _ in
                accumulatedOffset = CGSize(width: contentOffset.width, height: contentOffset.height)
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
//            HStack {
                Button {
                    openYouTubeTutorial()
                } label: {
                    Label("Tutorial", systemImage: "safari")
                }
//                Divider()
//                Button {
//                    secretary.helpVH(.show())
//                } label: {
//                    Label("Help", systemImage: "questionmark.circle")
//                }
//            }
//            .labelStyle(.titleOnly)
            .foregroundStyle(.blue)
        }
        
        private func openYouTubeTutorial() {
            if let url = URL(string: "https://www.youtube.com/shorts/SBSt06RrlLk") {
                openURL(url)
            }
        }
    }
    
    struct HintCell:View {
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
            
            init(_ title1: LocalizedStringKey, _ title2: String? = nil, description: LocalizedStringKey, example: LocalizedStringKey? = nil) {
                self.title1 = title1
                self.title2 = title2
                self.description = description
                self.example = example
            }
            
            //a dictionary with all contents
            static let all:[Model.TopMostView : Content] = [
                .palette : .init("\(Image(systemName: "swatchpalette")) Palette", "Create Stopwatch or Timer", description: "Tap a color for stopwatch. Touch and hold for timer. \(Image.swipeLeft) Swipe to dismiss"),
                .durationPicker : .init("\(Image(systemName: "hourglass")) Duration", "Max 48 Hr", description: "Duration is valid if \(Text("\(Image.roundCheckmark)").foregroundStyle(.green)) symbol shows.\n・Save: drag down to dismiss\n・Clear duration: \(Image.swipeLeft) swipe", example: "ex: 02h = 2hr, 01h 05m = 1hr 5min, etc."),
                .control : .init("\(Image(systemName: "slider.vertical.3")) Control", "Delete, Reset, Change", description: "Delete and reset \(Text("do not delete").foregroundStyle(.red)) calendar events! Reset keeps the bubble, but deletes its sessions.\n・Change to stopwatch: tap \(Image.stopwatch)\n・Change to timer: tap \(Image.timer), 5, 10, etc.\n・Show recent durations: \(Image.leftSwipe) swipe"),
                .moreOptions : .init("\(Image.more) More Options", "Set Delay or Change Color", description: "Start delay is nice"),
                .bubbleNotes : .init("\(Image(systemName: "text.alignleft")) Bubble Notes", description: "Tether bubble to calendar. Add note and create a calendar in Calendar App with identical names and events will be added automatically to the calendar with identical name", example: "Add calendar with name '☀️ Outdoor' and choose bubble note with same name"),
                .lapNotes : .init("\(Image(systemName: "text.alignleft")) Lap Notes", description: "Maximum length 12 characters"),
                .bubbleList : .init("\(Image(systemName: "list.bullet")) Bubbles", description: "Stopwatches and Timers"),
                .sessionDelete : .init("\(Image.trash) Delete Session", description: "\(Text("If session has a corresponding calendar event, the event will also be removed").foregroundStyle(.red))"),
                .detail : .init("\(Image(systemName: "pencil.and.list.clipboard")) Activity", "...contains Sessions",  description: "Sessions are similar to calendar events. Easily [save activity](fused://saveActivity) to Calendar App! Touch and hold on a session to delete")
            ]
        }
    }
}

extension HintOverlay {
    @Observable
    class Model {
        //MARK: - Publishers
        private(set) var topmostView = TopMostView.bubbleList
        
        private(set) var showHelpOverlay = false
        
        private(set) var showHelpButton = false {
            didSet {
                if !oldValue {
                    let fiveSeconds = DispatchTime.now() + 5
                    
                    //main
                    fiveSecTimer.executeAction(after: fiveSeconds) { [weak self] in
                        DispatchQueue.main.async {
                            withAnimation {
                                self?.showHelpButton = false
                            }
                        }
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
                    self.showHelpOverlay = state == .show ? true : false
                }
            }
        }
        
        func helpButton(_ state:BoolState) {
            DispatchQueue.main.async {
                withAnimation {
                    self.showHelpButton = state == .show ? true : false
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
            if HintOverlay.Model.shared.showHelpButton {
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
                .transition(.scale)
            }
        }
    }
}

extension UIViewController {
    open override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake && !HintOverlay.Model.shared.showHelpOverlay {
            if !HintOverlay.Model.shared.showHelpButton {
                HintOverlay.Model.shared.helpButton(.show)
            }
        }
    }
}

#Preview(body: {
    HelpCell(content: .init("Basics", "calendar.badge.plus", .saveActivity, "Save Activity", "First make sure bubble is [calendar-enabled](fused://enableCalendar). As soon as you end a session, it will be saved as an event in the Calendar App. Touch and hold on seconds to end a session", image: "", image2: "bubble.save.activity"))
})
