//
//  SDBPair+CoreDataProperties.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 10.03.2023.
//
//

import Foundation
import CoreData


extension DelayBubblePair {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DelayBubblePair> {
        return NSFetchRequest<DelayBubblePair>(entityName: "SDBPair")
    }

    @NSManaged public var start: Date
    @NSManaged public var pause: Date?
    @NSManaged public var duration: Float
    @NSManaged public var sdBubble: DelayBubble!

}

extension DelayBubblePair : Identifiable {

}
