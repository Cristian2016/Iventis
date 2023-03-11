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


extension StartDelayBubble {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StartDelayBubble> {
        return NSFetchRequest<StartDelayBubble>(entityName: "StartDelayBubble")
    }

    @NSManaged public var created: Date?
    @NSManaged public var initialClock: Float
    
    @NSManaged public var totalDuration: Float //1
    
    @NSManaged public var bubble: Bubble?
    
    @NSManaged public var currentClock: Float
    @NSManaged public var pairs: NSOrderedSet?

}

// MARK: Generated accessors for pairs
extension StartDelayBubble {

    @objc(insertObject:inPairsAtIndex:)
    @NSManaged public func insertIntoPairs(_ value: SDBPair, at idx: Int)

    @objc(removeObjectFromPairsAtIndex:)
    @NSManaged public func removeFromPairs(at idx: Int)

    @objc(insertPairs:atIndexes:)
    @NSManaged public func insertIntoPairs(_ values: [SDBPair], at indexes: NSIndexSet)

    @objc(removePairsAtIndexes:)
    @NSManaged public func removeFromPairs(at indexes: NSIndexSet)

    @objc(replaceObjectInPairsAtIndex:withObject:)
    @NSManaged public func replacePairs(at idx: Int, with value: SDBPair)

    @objc(replacePairsAtIndexes:withPairs:)
    @NSManaged public func replacePairs(at indexes: NSIndexSet, with values: [SDBPair])

    @objc(addPairsObject:)
    @NSManaged public func addToPairs(_ value: SDBPair)

    @objc(removePairsObject:)
    @NSManaged public func removeFromPairs(_ value: SDBPair)

    @objc(addPairs:)
    @NSManaged public func addToPairs(_ values: NSOrderedSet)

    @objc(removePairs:)
    @NSManaged public func removeFromPairs(_ values: NSOrderedSet)

}

extension StartDelayBubble : Identifiable {

}
