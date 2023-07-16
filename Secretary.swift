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
    private(set) var controlActionBubble:Int64?
    
    private(set) var showPaletteView = false
    
    private(set) var showHelpViewHierarchy = false
    
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
                    HelpOverlay.Model.shared.topmostView(.palette)
                case .hide:
                    showPaletteView = false
                    HelpOverlay.Model.shared.topmostView(.bubbleList)
            }
        }
    }
    
    func helpViewHiewHierarchy(_ state:BoolState) {
        withAnimation {
            switch state {
                case .show: showHelpViewHierarchy = true
                case .hide: showHelpViewHierarchy = false
            }
        }
    }
    
    enum Kind {
        case show(Int64)
        case hide
    }
    
    enum BoolState {
        case show
        case hide
    }
    
    //MARK: -
    init() {
        setMostRecentlyUsedBubble()
        observe_ApplicationActive()
    }
    
    private(set) var widgetsExist = false
    
    var mostRecentlyUsedBubble:Int64? {didSet{ saveMostRecentlyUsedBubble() }}
    
    var calendarAccessGranted = CalendarManager.shared.calendarAccessStatus == .granted //4
    
    var showCalendarAccessDeniedWarning = false
        
    var sessionToDelete: SessionToDelete? { didSet {
        let sessionDeleteButtonShows = sessionToDelete?.sessionRank != nil
        HelpOverlay.Model.shared.topmostView(sessionDeleteButtonShows ? .sessionDelete :.detail)
    }}
    
    enum PaletteState {
        case show
        case hide
    }
    
    var showAlert_AlwaysOnDisplay = false
    
    var displayAutoLockConfirmation = false
    
    var addNoteButton_bRank:Int? {didSet { handleAddNoteButton_bRank() }}
    
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
    
    var confirm_CalEventRemoved: Int64?
    
    var showAlert_closeSession = false
    
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
    
    //
    var showFavoritesOnly = false
    
    var showScrollToTopButton = false
    
    var shouldScrollToTop = false
    
    func scrollToTop() {
        if !shouldScrollToTop { shouldScrollToTop = true }
    } //1
    
    var isBubblesReportReady = false
    
    func updateBubblesReport(_ updateKind: UpdateKind) {
        switch updateKind {
            case .appLaunch:
                let bContext = PersistenceController.shared.bContext
                
                bContext.perform { //no need to use [weak self]
                    let request = Bubble.fetchRequest()
                    guard let bubbles = try? bContext.fetch(request) else { fatalError() }
                    
                    let bubblesCount = bubbles.count
                    
                    let ordinaryBubbles = bubbles
                        .filter { !$0.isPinned } //filter out pinned bubbles
                    
                    let ordinaryBubbleColors = ordinaryBubbles
                        .compactMap {
                            idColor(id: $0.rank, color: Color.bubbleColor(forName: $0.color))
                        } //get colors of ordinary bubbles
                    
                    let ordinaryBubbleRanks = ordinaryBubbles
                        .map { Int($0.rank) }
                    
                    self.bubblesReport.ordinary = ordinaryBubbleColors.count
                    self.bubblesReport.pinned = bubblesCount - self.bubblesReport.ordinary
                    self.bubblesReport.colors = ordinaryBubbleColors
                    self.bubblesReport.ordinaryRanks = ordinaryBubbleRanks
                    
                    self.isBubblesReportReady = true
                }
            case .create(let bubble):
                bubblesReport.ordinary += 1
                bubblesReport.colors.append(idColor(id: bubble.rank, color: Color.bubbleColor(forName: bubble.color)))
                bubblesReport.ordinaryRanks.append(Int(bubble.rank))
                
                DispatchQueue.main.async { self.isBubblesReportReady = true }
                
            case .delete(let bubble):
                if bubble.isPinned {
                    bubblesReport.pinned -= 1
                } else {
                    bubblesReport.ordinary -= 1
                    bubblesReport.colors.removeAll { $0.id == bubble.rank }
                    bubblesReport.ordinaryRanks.removeAll { $0 == Int(bubble.rank) }
                }
                
                DispatchQueue.main.async { self.isBubblesReportReady = true }
                
            case .pin(let bubble):
                if bubble.isPinned {
                    bubblesReport.pinned += 1
                    
                    bubblesReport.ordinary -= 1
                    bubblesReport.ordinaryRanks.removeAll { $0 == Int(bubble.rank) }
                    bubblesReport.colors.removeAll { $0.id == bubble.rank }
                } else {
                    bubblesReport.pinned -= 1
                    bubblesReport.ordinary += 1
                    bubblesReport.colors.append(idColor(id: bubble.rank, color: Color.bubbleColor(forName: bubble.color)))
                    bubblesReport.ordinaryRanks.append(Int(bubble.rank))
                }
                
                DispatchQueue.main.async { self.isBubblesReportReady = true }
                
            case .colorChange(let bubble):
                if bubble.isPinned {
                    
                } else {
                    guard
                        let index = bubblesReport
                            .colors.firstIndex (where: { $0.id == bubble.rank })
                    else { fatalError() }
                    
                    bubblesReport.colors[index] = idColor(id: bubble.rank, color: Color.bubbleColor(forName: bubble.color))
                    
                    DispatchQueue.main.async { self.isBubblesReportReady = true }
                }
        }
    }
    
    func widgetsCount(completion: @escaping (Int) -> Void) {
        WidgetCenter.shared.getCurrentConfigurations { result in
            if let infos = try? result.get() { completion(infos.count) }
            else { completion(0) }
        }
    }
    
    private(set) var bubblesReport = BubblesReport()
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
    
    struct BubblesReport {
        var colors = [idColor]() //ordinary colors
        var ordinary = 0 //ordinary bubbles
        var pinned = 0 //pinned bubbles
        var ordinaryRanks = [Int]()
        
        var all:Int { pinned + ordinary }
    }
    
    enum UpdateKind {
        case appLaunch
        case delete(Bubble) //bubble
        case create(Bubble) //bubble
        case pin(Bubble) //pin/unpin bubble
        case colorChange(Bubble) //change bubble color [MoreOptionsView]
    }
}
