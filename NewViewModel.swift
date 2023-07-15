//
//  MoreOptionsViewModel.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 08.07.2023.
//1 might change in future builds, so that it will not need an intial value like that
// @Observable requires property 'bubble' to have an initial value (from macro 'Observable')
//2 //grab background context Bubble object
//make sure its startDelay is set
//set bBubble.sdb to nil
//ask background context to delete the bubble
//back on mainQueue do visual updates
//save changes on bContext
//1 example user taps More Button and that sets 1 to whatever bubble (bubbleCell.bubble)

import Foundation
import Observation

///The new vieModel that will eventually replace old ViewModel
@Observable
class NewViewModel {
    var moreOptionsBubble:Bubble? = nil {didSet{
        Secretary.shared.topMostView = moreOptionsBubble != nil ? .moreOptionsView : .bubble
}} //1
    
    
    var userEnteredStartDelay = Float(0)
    
    // MARK: - Methods
    func removeStartDelay() {
        guard let bubble = moreOptionsBubble else { return }
        
        var controller = PersistenceController.shared
        
        let bContext = controller.bContext
        let objID = bubble.objectID
        
        bContext.perform {
            //2
            
            guard
                let thisBubble = controller.grabObj(objID) as? Bubble,
                let startDelayBubble = thisBubble.startDelayBubble
            else { return }
            
            thisBubble.startDelayBubble = nil //sdb removed from memory
            bContext.delete(startDelayBubble) //sdb removed from database
            
            DispatchQueue.main.async {
                bubble.startDelayBubble?.coordinator.update(.user(.pause))
                bubble.startDelayBubble?.coordinator = nil
            }
            
            controller.save(bContext)
        }
    }
    
    func setStartDelay() {
        guard let bubble = moreOptionsBubble else { return }
        
        let initialStartDelay = bubble.startDelayBubble?.initialClock ?? 0
        guard userEnteredStartDelay != 0 && userEnteredStartDelay != initialStartDelay else { return }
        
        var controller = PersistenceController.shared
        
        let bContext = controller.bContext
        let objID = bubble.objectID
        
        bContext.perform {
            let thisBubble = controller.grabObj(objID) as! Bubble
            
            if let sdb = thisBubble.startDelayBubble {
                //startDelay exists already
                //remove existing startDelay
                
                DispatchQueue.main.async {
                    bubble.startDelayBubble?.coordinator.update(.user(.reset))
                }
                thisBubble.startDelayBubble = nil
                bContext.delete(sdb)
            }
            
            //create SDB
            let sdb = StartDelayBubble(context: bContext)
            sdb.created = Date()
            sdb.initialClock = self.userEnteredStartDelay
            sdb.currentClock = self.userEnteredStartDelay
            thisBubble.startDelayBubble = sdb
            
            controller.save(bContext)
            
            DispatchQueue.main.async {
                let coordinator = bubble.startDelayBubble?.coordinator
                if let cancellabble = coordinator?.cancellable, !cancellabble.isEmpty {
                    coordinator?.update(.user(.reset))
                }
                coordinator?.valueToDisplay = self.userEnteredStartDelay
            }
        }
    }
}
