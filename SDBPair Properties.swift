//
//  SDBPair+CoreDataProperties.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 10.03.2023.
//
//

import Foundation
import CoreData


extension SDBPair {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SDBPair> {
        return NSFetchRequest<SDBPair>(entityName: "SDBPair")
    }

    @NSManaged public var start: Date
    @NSManaged public var pause: Date?
    @NSManaged public var sdBubble: StartDelayBubble!

}

extension SDBPair : Identifiable {

}
