//
//  Secretary.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 01.02.2023.
// Secretary knows shit on anybody! For example it knows how many pinned bubbles exist at any given time. It collects varous data from various parts of the App
//1 scrolls top top in DetailView when user pulls down on the table [PairCellList]
//2 background timer, does not repeat, in 5 seconds it removes BlueInfoButton
//3 used when user taps a notification. programmatically scoll in BubbleList to BubbleCell with id == scrollRank

import SwiftUI
import MyPackage
import CoreData
import WidgetKit

class Secretary {
    static let shared = Secretary()
    
    func widgetsCount(completion: @escaping (Int) -> Void) {
        WidgetCenter.shared.getCurrentConfigurations { result in
            if let infos = try? result.get() { completion(infos.count) }
            else { completion(0) }
        }
    }
    
    @Published var calendarAccessGranted = CalendarManager.shared.calendarAccessStatus == .granted
    
    //used by the widget
    @Published var mostRecentlyUsedBubble:Int64? {didSet{ saveMostRecentlyUsedBubble() }}
    @Published private(set) var widgetsExist = false
    
    // MARK: - Show More Info
    @Published var bubbleDeleteButtonShowMore = false
    
    // MARK: - Publishers
    @Published var scrollRank:Int64? //3
    
    @Published var showCalendarAccessDeniedWarning = false
    
    private var fiveSecTimer = PrecisionTimer() //2
    
    @Published var showBlueInfoButton = false {didSet{
        if !oldValue {
            let fiveSeconds = DispatchTime.now() + 5
            
            //main
            fiveSecTimer.executeAction(after: fiveSeconds) { [weak self] in
                DispatchQueue.main.async { self?.showBlueInfoButton = false }
            }
        }
    }}
    
    var topMostView:TopMostView = .bubble
    
    @Published var showInfoVH = false
    
    @Published var showBubbleInfo = false
    
    @Published var showBubbleDeleteInfo = false
    
    @Published var showPaletteInfo = false
    
    @Published var showDurationPickerInfo = false
    
    @Published var showMoreOptionsInfo = false
    
    @Published var pairBubbleCellNeedsDisplay = false
    
    @Published var sessionToDelete:(session:Session, sessionRank:Int)? {didSet{
        topMostView = sessionToDelete?.sessionRank != nil ? .sessionDeleteActionView :.bubble
    }}
    
    @Published var showAlert_AlwaysOnDisplay = false
            
    @Published var displayAutoLockConfirmation = false
    
    @Published var confirm_CalEventCreated: Int64?
    
    @Published var confirm_CalEventRemoved: Int64?
    
    @Published var moreOptionsBuble:Bubble? {didSet{
        topMostView = moreOptionsBuble != nil ? .moreOptionsView : .bubble
    }}
    
    @Published var showDetail_bRank:Int64?
    
    @Published var showAlert_closeSession = false
    
    func toggleDetail(_ rank:Int64?) {
        showDetail_bRank = showDetail_bRank == nil ? rank : nil
    }
        
    ///bubbleCell rank and frame. Frame will not be set if DetailView shows
    @Published var deleteAction_bRank:Int64? {didSet{
        topMostView = deleteAction_bRank == nil ? .bubble : .bubbleDeleteActionView
    }}
    
    @Published var addNoteButton_bRank:Int? {didSet { handleAddNoteButton_bRank() }}
    
    @Published var showPaletteView = false {didSet{
        Secretary.shared.topMostView = showPaletteView ? .palette : .bubble
    }}
    
    func togglePaletteView() { withAnimation { showPaletteView.toggle() }}
    
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
    
    @Published var showScrollToTopButton = false
    
    @Published var shouldScrollToTop = false
    
    @Published var showDetailViewInfoButton = false {didSet{
        if showDetailViewInfoButton {
            delayExecution(.now() + 5.0) { [weak self] in
                self?.showDetailViewInfoButton.toggle()
            }
        }
    }}
    
    @Published var showDetailViewInfo = false
    
    @Published var showSessionDeleteInfo = false
    
    func scrollToTop() {
        if !shouldScrollToTop { shouldScrollToTop = true }
    } //1
    
    // MARK: - Toggle Favorites [Pinned versus Ordinary bubbles]
    @Published var showFavoritesOnly = false
    
    @Published var isBubblesReportReady = false
    
    private(set) var bubblesReport = BubblesReport()
    
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
    
    // MARK: - Observers
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
    
    // MARK: - Init/Deinit
    private init() {
        setMostRecentlyUsedBubble()
        observe_ApplicationActive()
    }
    
    // MARK: - DurationPicker
//    @Published var durationPickerMode: Mode?
//
//    enum Mode {
//        case create(Color.Tricolor) //timer
//        case edit(Bubble) //existing timer
//    }
    
    @Published var durationPickerReason = DurationPickerReason.none
    
    enum DurationPickerReason : Hashable {
        case createTimer(Color.Tricolor) //create timer in PaletteView
        case editExistingTimer(Bubble) //edit an existing timer
        case changeToTimer(Bubble) //change stopwatch to timer
        case none //not set. DPV not visible
        
        var description:String {
            switch self {
                case .changeToTimer(let bubble):
                    return "reason change to \(bubble.color ?? "pula") timer"
                case .createTimer(let tricolor):
                    return "reason create \(tricolor.description) timer"
                case .editExistingTimer(let bubble):
                    return "reason edit existing timer \(bubble.color ?? "pula")"
                case .none:
                    return "reason none"
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

extension Secretary {
    enum TopMostView {
        case palette
        case durationPicker
        case moreOptionsView
        case bubbleDeleteActionView
        case sessionDeleteActionView
        case bubble
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
}
