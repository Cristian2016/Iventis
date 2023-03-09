//
//  Secretary.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 01.02.2023.
// Secretary knows shit on anybody! For example it knows how many pinned bubbles exist at any given time. It collects varous data from various parts of the App
//1 scrolls top top in DetailView when user pulls down on the table [PairCellList]

import SwiftUI
import MyPackage

class Secretary {
    private init() {
        print(#function, " Secretary")
    }
    static let shared = Secretary()
    
    // MARK: - Publishers
//    @Published var confirm_ColorChange = false
    
    ///allow user to drag and drop tableView cells
    ///.onMove view modifier will not be nil
//    @Published var allowOnMove = false
    
    @Published var pairBubbleCellNeedsDisplay = false
    
    @Published var sessionToDelete:(session:Session, sessionRank:Int)?
    
    @Published var showAlert_AlwaysOnDisplay = false
            
    @Published var displayAutoLockConfirmation = false
    
    @Published var confirm_CalEventCreated: Int64?
    
    @Published var confirm_CalEventRemoved: Int64?
    
    @Published var theOneAndOnlyEditedSDB:StartDelayBubble?
    
    @Published var showDetail_bRank:Int64?
    
    func toggleDetail(_ rank:Int64?) {
        showDetail_bRank = showDetail_bRank == nil ? rank : nil
    }
        
    ///bubbleCell rank and frame. Frame will not be set if DetailView shows
    @Published var deleteAction_bRank:Int64?
    
    @Published var addNoteButton_bRank:Int? {didSet { handleAddNoteButton_bRank() }}
    
    @Published var durationPicker_OfColor:Color?
    
    @Published var showPaletteView = false
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
    
    func scrollToTop() {
        if !shouldScrollToTop { shouldScrollToTop = true }
    } //1
    
    // MARK: - Pinned versus Ordinary bubbles
    @Published var showFavoritesOnly = false
    
    @Published var isBubblesReportReady = false {didSet{
        if isBubblesReportReady {
            print(bubblesReport)
        }
    }}
    
    var bubblesReport = BubblesReport()
    
    func updateBubblesReport(_ updateKind: UpdateKind) {
        switch updateKind {
            case .appLaunch:
                let bContext = PersistenceController.shared.bContext
                
                bContext.perform { [weak self] in
                    guard let self = self else { return }
                    
                    let request = Bubble.fetchRequest()
                    guard let bubbles = try? bContext.fetch(request) else { fatalError() }
                    
                    let bubblesCount = bubbles.count
                    
                    let colors = bubbles
                        .filter { !$0.isPinned } //filter out pinned bubbles
                        .compactMap { $0.color } //get colors of ordinary bubbles
                    
                    bubblesReport.ordinaryBubbleColors = colors
                    bubblesReport.ordinary = colors.count
                    bubblesReport.pinned = bubblesCount - bubblesReport.ordinary
                    
                    isBubblesReportReady = true
                }
            default: break
        }
    }
}

extension Secretary {
    struct BubblesReport {
        var pinned = 0
        var ordinary = 0 {didSet{
            print("ordinary \(ordinary)")
        }}
        var ordinaryBubbleColors = [String]()
        var all:Int { pinned + ordinary }
    }
    
    enum UpdateKind {
        case appLaunch
        case delete //bubble
        case create //bubble
        case pin //pin/unpin bubble
    }
}
