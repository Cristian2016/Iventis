//
//  SDB+CoreDataProperties.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 12.07.2022.
//
//

import Foundation
import CoreData

///DelayStartBubble Properties
extension SDB {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SDB> {
        return NSFetchRequest<SDB>(entityName: "SDB")
    }

    //⚠️ if referenceDelay > 0, SDBCell must be visible
    @NSManaged public var referenceDelay: Int64
    
    @NSManaged public var currentDelay: Float
    
    @NSManaged public var pairs: NSOrderedSet?
    @NSManaged public var bubble: Bubble?
    
    var pairs_:[SDBPair] {
        get { pairs?.array as? [SDBPair] ?? [] }
        set { pairs = NSOrderedSet(arrayLiteral: newValue) }
    }
    
    var lastPair:SDBPair? { pairs_.last }
}

// MARK: Generated accessors for pairs
extension SDB {

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

extension SDB : Identifiable {

}
