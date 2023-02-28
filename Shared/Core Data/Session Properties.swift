//
//  Session+CoreDataProperties.swift
//  Timers
//
//  Created by Cristian Lapusan on 23.04.2022.
//
//

import Foundation
import CoreData


extension Session {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Session> {
        return NSFetchRequest<Session>(entityName: "Session")
    }

    @NSManaged public var created: Date?
    @NSManaged public var isEnded: Bool
    @NSManaged public var totalDuration: Float
    
    @NSManaged public var bubble: Bubble?
    @NSManaged public var pairs: NSOrderedSet?

    @NSManaged public var eventID: String?
    
    ///does the Session have a corresponding Calendar Event
    ///to avoid duplicating events
    @NSManaged public var isEventified: Bool
}

// MARK: Generated accessors for pairs
extension Session {

    @objc(insertObject:inPairsAtIndex:)
    @NSManaged public func insertIntoPairs(_ value: Pair, at idx: Int)

    @objc(removeObjectFromPairsAtIndex:)
    @NSManaged public func removeFromPairs(at idx: Int)

    @objc(insertPairs:atIndexes:)
    @NSManaged public func insertIntoPairs(_ values: [Pair], at indexes: NSIndexSet)

    @objc(removePairsAtIndexes:)
    @NSManaged public func removeFromPairs(at indexes: NSIndexSet)

    @objc(replaceObjectInPairsAtIndex:withObject:)
    @NSManaged public func replacePairs(at idx: Int, with value: Pair)

    @objc(replacePairsAtIndexes:withPairs:)
    @NSManaged public func replacePairs(at indexes: NSIndexSet, with values: [Pair])

    @objc(addPairsObject:)
    @NSManaged public func addToPairs(_ value: Pair)

    @objc(removePairsObject:)
    @NSManaged public func removeFromPairs(_ value: Pair)

    @objc(addPairs:)
    @NSManaged public func addToPairs(_ values: NSOrderedSet)

    @objc(removePairs:)
    @NSManaged public func removeFromPairs(_ values: NSOrderedSet)

}

extension Session : Identifiable {

}
