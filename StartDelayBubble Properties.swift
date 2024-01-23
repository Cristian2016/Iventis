//
//  StartDelayBubble+CoreDataProperties.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 10.03.2023.
//
//1 combined duration of duration of each pair for all pairs.
//1 totalDuration = pair(0).duration + pair(1).duration + ... + pair(n).duration

import Foundation
import CoreData


extension DelayBubble {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DelayBubble> {
        return NSFetchRequest<DelayBubble>(entityName: "StartDelayBubble")
    }

    @NSManaged public var created: Date?
    
    @NSManaged public var initialDelay: Float
    @NSManaged public var currentDelay: Float
    
    @NSManaged public var totalDuration: Float //1
    @NSManaged public var pairs: NSOrderedSet?
    
    @NSManaged public var bubble: Bubble?
}

// MARK: Generated accessors for pairs
extension DelayBubble {

    @objc(insertObject:inPairsAtIndex:)
    @NSManaged public func insertIntoPairs(_ value: DelayBubblePair, at idx: Int)

    @objc(removeObjectFromPairsAtIndex:)
    @NSManaged public func removeFromPairs(at idx: Int)

    @objc(insertPairs:atIndexes:)
    @NSManaged public func insertIntoPairs(_ values: [DelayBubblePair], at indexes: NSIndexSet)

    @objc(removePairsAtIndexes:)
    @NSManaged public func removeFromPairs(at indexes: NSIndexSet)

    @objc(replaceObjectInPairsAtIndex:withObject:)
    @NSManaged public func replacePairs(at idx: Int, with value: DelayBubblePair)

    @objc(replacePairsAtIndexes:withPairs:)
    @NSManaged public func replacePairs(at indexes: NSIndexSet, with values: [DelayBubblePair])

    @objc(addPairsObject:)
    @NSManaged public func addToPairs(_ value: DelayBubblePair)

    @objc(removePairsObject:)
    @NSManaged public func removeFromPairs(_ value: DelayBubblePair)

    @objc(addPairs:)
    @NSManaged public func addToPairs(_ values: NSOrderedSet)

    @objc(removePairs:)
    @NSManaged public func removeFromPairs(_ values: NSOrderedSet)

}

extension DelayBubble : Identifiable {

}
