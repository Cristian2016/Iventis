//
//  Secretary.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 01.02.2023.
// Secretary knows shit on anybody! For example it knows how many pinned bubbles exist at any given time. It collects varous data from various parts of the App

import SwiftUI

class Secretary {
    private init() { }
    static let shared = Secretary()
    
    // MARK: - Publishers
//    @Published var confirm_ColorChange = false
    
    ///allow user to drag and drop tableView cells
    ///.onMove view modifier will not be nil
//    @Published var allowOnMove = false
    
    @Published var sessionToDelete:(session:Session, sessionRank:String)?
    
    @Published var showAlert_AlwaysOnDisplay = false
            
    @Published var displayAutoLockConfirmation = false
    
    @Published var confirm_CalEventCreated: Int64?
    
    @Published var confirm_CalEventRemoved: Int64?
    
    @Published var theOneAndOnlyEditedSDB:StartDelayBubble?
    
    @Published var showFavoritesOnly = false
    
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
    
    @Published var shouldScrollToTop = false
    
    func scrollToTop() {
        if !shouldScrollToTop { shouldScrollToTop = true }
    }
}
