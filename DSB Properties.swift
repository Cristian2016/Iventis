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
extension DSB {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DSB> {
        return NSFetchRequest<DSB>(entityName: "DSB")
    }

    @NSManaged public var delay: Int64
    @NSManaged public var pairs: NSSet?
    @NSManaged public var bubble: Bubble?

}

// MARK: Generated accessors for pairs
extension DSB {

    @objc(addPairsObject:)
    @NSManaged public func addToPairs(_ value: DSBPair)

    @objc(removePairsObject:)
    @NSManaged public func removeFromPairs(_ value: DSBPair)

    @objc(addPairs:)
    @NSManaged public func addToPairs(_ values: NSSet)

    @objc(removePairs:)
    @NSManaged public func removeFromPairs(_ values: NSSet)

}

extension DSB : Identifiable {

}
