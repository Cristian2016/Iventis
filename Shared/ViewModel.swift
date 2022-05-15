//
//  ViewModel.swift
//  Timers
//
//  Created by Cristian Lapusan on 15.04.2022.
//

import Foundation
import SwiftUI
import Combine


class ViewModel: ObservableObject {
    init() {
        let request = Bubble.fetchRequest()
        let bubbles = try? PersistenceController.shared.viewContext.fetch(request)
        bubbles?.forEach { $0.observeAppLaunch(.start) }
    }
    
    deinit { NotificationCenter.default.removeObserver(self) }
            
    private let timer = BackgroundTimer(DispatchQueue(label: "BackgroundTimer", attributes: .concurrent))
    
    func backgroundTimer(_ action:BackgroundTimer.Action) {
        switch action {
            case .start: timer.perform(.start)
            case .pause: timer.perform(.pause)
        }
    }
    
    // MARK: - User Intents
    //from PaletteView and...
    func createBubble(_ kind:Bubble.Kind, _ color:String) {
        let backgroundContext = PersistenceController.shared.backgroundContext
                
        //bubble
        let newBubble = Bubble(context: backgroundContext)
        newBubble.created = Date()
        
        newBubble.kind = kind
        switch kind {
            case .timer(let initialClock):
                newBubble.initialClock = initialClock
            default: newBubble.initialClock = 0
        }
        
        newBubble.color = color
        newBubble.rank = Int64(UserDefaults.assignRank())
        
        try? backgroundContext.save()
    }
    
    func delete(_ bubble:Bubble) {
        let viewContext = PersistenceController.shared.viewContext
        
        let request = Bubble.fetchRequest()
        let count = try? viewContext.count(for: request)
        let condition = count! > 1
        if condition { viewContext.delete(bubble) } else { return }
        
        try? viewContext.save()
    }
    
    ///delete all sessions and pairs and make it brandNew
    func reset(_ bubble:Bubble) {
        guard !bubble.sessions_.isEmpty else { return }
        
        let viewContext = PersistenceController.shared.viewContext
        bubble.created = Date()
        bubble.currentClock = bubble.initialClock
        bubble.bubbleCell_Components = bubble.initialClock.timComponentsAsStrings
        bubble.sessions?.forEach { viewContext.delete($0 as! Session) }
        try? viewContext.save()
    }
    
    func togglePin(_ bubble:Bubble) {
        bubble.isPinned.toggle()
        PersistenceController.shared.save()
    }
    
    func toggleStart(_ bubble:Bubble) {
        if bubble.currentClock <= 0 && bubble.kind != .stopwatch  { return }
        
        switch bubble.state {
            case .brandNew: /* changes to .running */
                //create first session and add first pair to the session
                let newSession = Session(context: PersistenceController.shared.viewContext)
                let newPair = Pair(context: PersistenceController.shared.viewContext)
                newPair.start = Date()
                bubble.addToSessions(newSession)
                newSession.created = Date()
                newSession.addToPairs(newPair)
                                
            case .paused:  /* changes to running */
                //create new pair, add it to currentSession
                let newPair = Pair(context: PersistenceController.shared.viewContext)
                newPair.start = Date()
                bubble.lastSession?.addToPairs(newPair)
                
            case .running: /* changes to .paused */
                let currentPair = bubble.lastPair
                currentPair?.pause = Date()
                bubble.shouldUpdateSmallBubbleCell = false
                
                //⚠️ closure runs on the main queue. whatever you want the user to see put in that closure otherwise it will fail to update!!!!
                currentPair?.computeDuration(.pause) {
                    //closure runs on main queue
                    currentPair?.duration = $0 //Float
                    currentPair?.durationAsStrings = $1 //Data
                    
                    bubble.lastSession?.computeDuration()
                    
                    //compute and store currentClock
                    bubble.currentClock += currentPair!.duration
                    bubble.bubbleCell_Components = bubble.currentClock.timComponentsAsStrings
                }
                
            case .finished: return
        }
        
        try? PersistenceController.shared.viewContext.save()
    }
    
    func toggleCalendar(_ bubble:Bubble) {
        bubble.hasCalendar.toggle()
        PersistenceController.shared.save()
    }
    
    func showMoreOptions(_ bubble:Bubble) {
        
    }
    
    func reorderRanks(_ source:Int64, _ destination:Int64) {
        let request = Bubble.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "rank", ascending: false)]
        
        let bubbleMovedDown = source > destination
        
        //get bubbles ordered by rank
        var bubbles = try! PersistenceController.shared.viewContext.fetch(request)
    
        let sourceIndex = bubbles.firstIndex(of: bubble(for: Int(source))!)!
        let destIndex = bubbles.firstIndex(of: bubble(for: Int(destination))!)!
        
        print("source \(sourceIndex), dest \(destIndex)")
        
        let removedBubble = bubbles.remove(at: sourceIndex)
        if bubbleMovedDown {
            if destIndex < bubbles.count { bubbles.insert(removedBubble, at: destIndex) }
            else { bubbles.append(removedBubble) }
        } else {
            if destIndex >= 0 {
                bubbles.insert(removedBubble, at: destIndex)
            } else {
                bubbles.insert(removedBubble, at: 0)
            }
        }
        
        //reassign ranks
        for (index, _) in bubbles.enumerated() {
            bubbles[index].rank = Int64(bubbles.count - 1 - index)
        }
        
        PersistenceController.shared.save()
    }
    
    // FIXME: ⚠️ not complete!
    func endSession(_ bubble:Bubble) {
        if bubble.state == .brandNew { return }
        
        bubble.shouldUpdateSmallBubbleCell = false
        
        bubble.currentClock = bubble.initialClock
        bubble.bubbleCell_Components = bubble.currentClock.timComponentsAsStrings
        bubble.lastSession?.isEnded = true
        if bubble.lastPair!.pause == nil {
            bubble.lastPair!.pause = Date()
            bubble.lastPair?.computeDuration(.endSession) {
                bubble.lastPair?.duration = $0
                bubble.lastPair?.durationAsStrings = $1
                
                bubble.lastSession?.computeDuration()
                
                bubble.bubbleCell_Components = bubble.initialClock.timComponentsAsStrings
            }
        }
        
        try? PersistenceController.shared.viewContext.save()
    }
    
    func userTogglesDetail(_ rank:Int?) {
        //identify bubble using rank
        //ask bubble to start/stop updating smallBubbleCellTimeComponents
        guard
            let bubble = bubble(for: rank) else { return }
        bubble.shouldUpdateSmallBubbleCell = rank != nil
    }
    
    // MARK: -
    func bubble(for rank:Int?) -> Bubble? {
        guard let rank = rank else { fatalError() }
        let request = Bubble.fetchRequest()
        request.predicate = NSPredicate(format: "rank = %i", rank)
        let context = PersistenceController.shared.viewContext
        let bubble = try! context.fetch(request).first
        return bubble
    }
}
