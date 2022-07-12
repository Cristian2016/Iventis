//
//  BubbleHistory+CoreDataProperties.swift
//  Timers
//
//  Created by Cristian Lapusan on 19.05.2022.
//
//

import Foundation
import CoreData


extension BubbleSavedNote {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BubbleSavedNote> {
        return NSFetchRequest<BubbleSavedNote>(entityName: "BubbleHistory")
    }

    @NSManaged public var date: Date?
    @NSManaged public var note: String?
    @NSManaged public var bubble: Bubble?

}

extension BubbleSavedNote : Identifiable {

}
