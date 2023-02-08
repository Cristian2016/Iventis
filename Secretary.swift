//
//  Secretary.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 01.02.2023.
// Secretary knows shit on anybody! For example it knows how many pinned bubbles exist at any given time. It collects varous data from various parts of the App

import Foundation

class Secretary {
    private init() { }
    static let shared = Secretary()
    
    // MARK: - Shit it knows :)
    var pinnedBubblesCount:Int {
       let context = PersistenceController.shared.backgroundContext
        let request = Bubble.fetchRequest()
        request.predicate = NSPredicate(format: "isPinned == true")
        if let count = try? context.count(for: request) {
            return count
        }
        return 0
    }
    
    var unpinnedBubblesCount:Int {
       let context = PersistenceController.shared.backgroundContext
        let request = Bubble.fetchRequest()
        request.predicate = NSPredicate(format: "isPinned == false")
        if let count = try? context.count(for: request) {
            return count
        }
        return 0
    }
    
    // MARK: - Publishers
    ///bubbleCell rank and frame. Frame will not be set if DetailView shows
    @Published var deleteAction_bRank:Int64?
    
    @Published var addNoteButton_bRank:Int? {didSet {
        if addNoteButton_bRank != nil {
            print("add timer")
            self.timer = Timer.scheduledTimer( timeInterval: 5.0, target: self,
                                               selector: #selector(self.handleFiveSecondsTimer),
                                               userInfo: nil, repeats: true
            )
        }
        else {
            self.timer?.invalidate()
            self.timer = nil
        }
    }}
    
    private var timer:Timer?
    
    @objc private func handleFiveSecondsTimer() {
        print(#function)
        if addNoteButton_bRank != nil {
            addNoteButton_bRank = nil
        }
    }
}
