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

struct HelpOverlay:View {
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @State private var contentOffset = CGSize.zero
    @State private var accumulatedOffset = CGSize.zero
    @State private var containerOffset = initialContainerOffset
    
    private var content = HelpOverlay.HintCell.Content.all[HelpOverlay.Model.shared.topmostView]
    
    static private let initialContainerOffset = CGSize(width: 0, height: 140)
    
    private var symbol:String {
        if containerOffset == Self.initialContainerOffset {
            return contentOffset == .zero ? "arrow.up.to.line" : "arrow.uturn.backward"
        } else {
            return contentOffset == .zero ? "arrow.down.to.line" : "arrow.uturn.backward"
            
        }
    }
    
    var body: some View {
        if HelpOverlay.Model.shared.showHelpOverlay && verticalSizeClass == .regular {
            Color.clear
                .overlay(alignment: .bottom) {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(.regularMaterial)
                        .strokeBorder(.quaternary)
                        .frame(height: 350)
                        .standardShadow()
                        .overlay {
                            VStack {
                                controls
                                
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
    private var controls:some View {
        HStack {
//            Image(systemName: "questionmark.circle")
            Label("Dismiss Help", systemImage: symbol)
                .labelStyle(.iconOnly)
                .onTapGesture { handleTap() }
                
            Spacer()
            Text(content?.title1 ?? "")
                .font(.system(size: 24))
                .allowsHitTesting(/*@START_MENU_TOKEN@*/false/*@END_MENU_TOKEN@*/)
            Spacer()
            Label("Dismiss Help", systemImage: "xmark")
                .labelStyle(.iconOnly)
                .onTapGesture { HelpOverlay.Model.shared.helpOverlay(.hide) }
        }
        .frame(height: 44) //minimum touch area
        .font(.system(size: 24))
        .padding([.leading, .trailing], 4)
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
extension HelpOverlay {
    struct ButtonStack:View {
        @Environment(Secretary.self) private var secretary
        
        var body: some View {
            HStack {
                Button {
                    openYouTubeTutorial()
                } label: {
                    Label("Tutorial", systemImage: "globe")
                }
                Divider()
                Button {
                    secretary.helpViewHiewHierarchy(.show)
                } label: {
                    Label("Basics", systemImage: "book")
                }
            }
            .labelStyle(.titleOnly)
            .foregroundStyle(.blue)
        }
        
        private func openYouTubeTutorial() {
            if let url = URL(string: "https://www.youtube.com/shorts/SBSt06RrlLk") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    struct HintCell:View {
        let content:Content
        
        var body: some View {
            VStack(spacing: 6) {
                if let title2 = content.title2 { Text(title2).foregroundStyle(.secondary) }
                
                Text(content.description)
                    .font(.system(size: 20))
                
                if let example = content.example {
                    Text(example)
                        .font(.system(size: 20))
                        .foregroundStyle(.secondary)
                }
                
                ButtonStack()
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
                .palette : .init("\(Image(systemName: "swatchpalette")) Palette", "Create Stopwatch or Timer", description: "Tap a color for stopwatch. Touch and hold for timer. Swipe left to dismiss"),
                .durationPicker : .init("\(Image(systemName: "hourglass")) Duration", "Choose Timer Duration", description: "Duration is valid if \(Text("\(Image.roundCheckmark)").foregroundStyle(.green)) checkmark shows.\n・Save duration: drag down to dismiss\n・Clear duration: swipe left or right\nMax duration is 48 hours", example: "ex: 02h means 2hr, 10h 05m means 10hr 5min, etc."),
                .control : .init("\(Image(systemName: "slider.vertical.3")) Control", "Delete, Reset, Change", description: "Delete and reset \(Text("do not delete").foregroundStyle(.red)) existing calendar events! Reset keeps the bubble, but deletes its history.\n・Change to stopwatch: tap \(Image.stopwatch)\n・Change to timer: tap \(Image.timer), 5, 10, etc.\n・Show recent durations: \(Image.leftSwipe) swipe left"),
                .moreOptions : .init("\(Image.more) More Options", "Set Delay or Change Color", description: "Start delay is nice"),
                .bubbleNotes : .init("\(Image(systemName: "text.alignleft")) Bubble Notes", description: "Tether bubble to calendar. Add note and create a calendar in Calendar App with identical names and events will be added automatically to the calendar with identical name", example: "Add calendar with name '☀️ Outdoor' and choose bubble note with same name"),
                .lapNotes : .init("\(Image(systemName: "text.alignleft")) Lap Notes", description: "Maximum length 12 characters"),
                .bubbleList : .init("\(Image(systemName: "list.bullet")) Bubbles", description: "Stopwatches and Timers"),
                .sessionDelete : .init("\(Image.trash) Delete Session", description: "\(Text("If session has a corresponding calendar event, the event will also be removed").foregroundStyle(.red))"),
                .detail : .init("\(Image(systemName: "magnifyingglass")) Detail",  description: "Sessions are made up of laps. A lap is the duration between a start and a pause.\n\(Text("Tap seconds to start and then tap again to pause. You've created a lap! 🥳").foregroundStyle(.secondary))\nIf a bubble is \(Text("[calendar-enabled](https://example.com)").foregroundStyle(.blue)), all its sessions are saved as events in the Calendar App")
            ]
        }
    }
}

extension HelpOverlay {
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
            if HelpOverlay.Model.shared.showHelpButton {
                Button {
                    UserFeedback.singleHaptic(.light)
                    HelpOverlay.Model.shared.helpButton(.hide)
                    HelpOverlay.Model.shared.helpOverlay(.show)
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
                                        .font(.system(size: 64, weight: .light))
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
        if motion == .motionShake && !HelpOverlay.Model.shared.showHelpOverlay {
            if !HelpOverlay.Model.shared.showHelpButton {
                HelpOverlay.Model.shared.helpButton(.show)
            }
        }
    }
}

