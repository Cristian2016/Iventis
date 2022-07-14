//
//  DSB+CoreDataProperties.swift
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
        return NSFetchRequest<SDB>(entityName: "DSB")
    }

    @NSManaged public var referenceDelay: Int64
    @NSManaged public var currentDelay: Int64
    
    @NSManaged public var pairs: NSSet?
    @NSManaged public var bubble: Bubble?
    
}

// MARK: Generated accessors for pairs
extension SDB {

    @objc(addPairsObject:)
    @NSManaged public func addToPairs(_ value: SDBPair)

    @objc(removePairsObject:)
    @NSManaged public func removeFromPairs(_ value: SDBPair)

    @objc(addPairs:)
    @NSManaged public func addToPairs(_ values: NSSet)

    @objc(removePairs:)
    @NSManaged public func removeFromPairs(_ values: NSSet)

}

extension SDB : Identifiable {

}
