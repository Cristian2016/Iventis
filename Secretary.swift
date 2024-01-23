//
//  Secretary1.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 01.12.2023.
//

import Foundation
import SwiftUI
import WidgetKit
import MyPackage

@Observable
class Secretary {
    //MARK: - Publishers
    var showFavoritesOnly:Bool {
        get {
           UserDefaults.shared.bool(forKey: "pula")
        }
        
        set {
            UserDefaults.shared.set(newValue, forKey: "pula") //⚠️ .standard not ok!!!
            refresh.toggle()
        }
    }
    
    var refresh = false //⚠️ insane!!!!
    
    private(set) var controlActionBubble:Int64?
    
    private(set) var showPaletteView = false
    
    private(set) var showBigHelpOverlay = false
    
    func controlBubble(_ kind:Kind) {
        DispatchQueue.main.async {
            switch kind {
                case .show(let rank) : self.controlActionBubble = rank
                case .hide: self.controlActionBubble = nil
            }
        }
    }
    
    func palette(_ state:PaletteState) {
        withAnimation(.easeOut(duration: 0.23)) {
            switch state {
                case .show:
                    showPaletteView = true
                    SmallHelpOverlay.Model.shared.topmostView(.palette)
                case .hide:
                    showPaletteView = false
                    SmallHelpOverlay.Model.shared.topmostView(.bubbleList)
            }
        }
    }
    
    ///show/hide Help View Hierarchy
    func bigHelpOverlay(_ state:BoolState) {
        var animation:Animation?
        switch state {
            case .show(animate: let animate):
                animation = animate ? .default : nil
            default:
                animation = .default
        }
        withAnimation(animation) {
            switch state {
                case .show:
                    showBigHelpOverlay = true
                case .hide:
                    showBigHelpOverlay = false
            }
        }
    }
    
    enum Kind {
        case show(Int64)
        case hide
    }
    
    enum BoolState {
        case show(animate:Bool = true)
        case hide
    }
    
    //MARK: -
    init() {
        setMostRecentlyUsedBubble()
        observe_ApplicationActive()
    }
    
    private(set) var widgetsExist = false
    
    //ysed by the round w widget symbol
    private(set) var mostRecentlyUsedBubble:Int64? { didSet {
        saveMostRecentlyUsedBubble()
    }}
    
    func setMostRecentlyUsedBubble(to rank:Int64?) {
        DispatchQueue.main.async {
            self.mostRecentlyUsedBubble = rank
        }
    }
    
    var calendarAccessGranted = CalendarManager.shared.calendarAccessStatus == .granted //4
    
    var showCalendarAccessDeniedWarning = false
    
    var sessionToDelete: SessionToDelete? { didSet {
        let sessionDeleteButtonShows = sessionToDelete?.sessionRank != nil
        SmallHelpOverlay.Model.shared.topmostView(sessionDeleteButtonShows ? .sessionDelete :.detail)
    }}
    
    enum PaletteState {
        case show
        case hide
    }
    
    var showCaffeinatedHint = false
    
    var confirmCaffeinated = false
    
    private(set) var confirmAddLapNote = false
    func showConfirmAddLapNote() {
        confirmAddLapNote = true
        delayExecution(.now() + 1.0) {
            self.confirmAddLapNote = false
        }
    }
    
    private(set) var addNoteButton_bRank:Int? { didSet {
        handleAddNoteButton_bRank()
    }}
    
    func setAddNoteButton_bRank(to rank:Int?) {
        DispatchQueue.main.async {
            self.addNoteButton_bRank = rank
        }
    }
    
    private var timer:Timer?
    
    private func handleAddNoteButton_bRank() {
        //set or remove 'five seconds timer'
        if addNoteButton_bRank != nil {
            self.timer = Timer.scheduledTimer( timeInterval: 5.0,
                                               target: self,
                                               selector: #selector(handleFiveSecondsTimer),
                                               userInfo: nil,
                                               repeats: true
            )
        }
        else {
            self.timer?.invalidate()
            self.timer = nil
        }
    }
    
    @objc private func handleFiveSecondsTimer() {
        if addNoteButton_bRank != nil { addNoteButton_bRank = nil }
    }
    
    var confirm_CalEventCreated: Int64?
    
    func showConfirmEventCreated(_ rank:Int64?) {
        confirm_CalEventCreated = rank
        delayExecution(.now() + 3) {
            self.confirm_CalEventCreated = nil
        }
    }
    
    var confirm_CalEventRemoved: Int64?
    
    //DetailView
    var showDetail_bRank:Int64?
    func toggleDetail(_ rank:Int64?) {
        showDetail_bRank = showDetail_bRank == nil ? rank : nil
    }
    var showDetailViewInfoButton = false {didSet{
        if showDetailViewInfoButton {
            delayExecution(.now() + 5.0) { [weak self] in
                self?.showDetailViewInfoButton.toggle()
            }
        }
    }}
    var showDetailViewInfo = false
    
    var showScrollToTopButton = false
    var shouldScrollToTop = false
    func scrollToTop() {
        if !shouldScrollToTop { shouldScrollToTop = true }
    } //1
}

extension Secretary {
    enum TopMostView {
        case palette
        case durationPicker
        case moreOptions
        case control
        case sessionDelete
        case bubble
        case bubbleDetail
    }
    
    struct SessionToDelete : Equatable {
        var session:Session
        var sessionRank:Int
    }
}

extension Secretary {
    // MARK: - Widgets
    ///writes rank of the most recently used bubble to the shared databased, so that widgets can read it
    private func saveMostRecentlyUsedBubble() {
        //write each time regardless if there is a widget or not [?]
        let rank = mostRecentlyUsedBubble != nil ? String(mostRecentlyUsedBubble!) : "Deleted"
        try? rank.write(to: URL.objectIDFileURL, atomically: true, encoding: .utf8)
    }
    
    private func setMostRecentlyUsedBubble() {
        if let string = try? String(contentsOf: URL.objectIDFileURL) {
            mostRecentlyUsedBubble = Int64(string)
        }
    }
    
    private func observe_ApplicationActive() {
        NotificationCenter.default.addObserver(forName: .didBecomeActive, object: nil, queue: nil) { [weak self] _ in
            
            WidgetCenter.shared.getCurrentConfigurations { [self] result in
                guard let infos = try? result.get() else { return }
                
                let condition = infos.map({ $0.kind }).contains("Fused")
                
                DispatchQueue.main.async {
                    self?.widgetsExist = condition ? true : false
                }
            }
        }
    }
}

extension Secretary {
    ///it's a Color with an ID so that it plays nicely with ForEach views
    struct idColor:Identifiable {
        let id:Int64 //bubble rank
        let color:Color
    }
    
    enum UpdateKind {
        case appLaunch
        case delete(Bubble) //bubble
        case create(Bubble) //bubble
        case pin(Bubble) //pin/unpin bubble
        case colorChange(Bubble) //change bubble color [MoreOptionsView]
    }
}
