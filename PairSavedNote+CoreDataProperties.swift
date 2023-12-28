//
//  PairSavedNote+CoreDataProperties.swift
//  Timers (iOS)
//
//  Created by Cristian Lapusan on 05.01.2024.
//
//

import Foundation
import CoreData


extension PairSavedNote {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PairSavedNote> {
        return NSFetchRequest<PairSavedNote>(entityName: "PairSavedNote")
    }

    @NSManaged public var date: Date?
    @NSManaged public var note: String?
    @NSManaged public var bubble: Bubble?

}

extension PairSavedNote : Identifiable {

}
