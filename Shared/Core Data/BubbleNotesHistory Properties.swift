//
//  BubbleNotesHistory+CoreDataProperties.swift
//  Timers
//
//  Created by Cristian Lapusan on 18.05.2022.
//
//

import Foundation
import CoreData


extension BubbleNotesHistory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BubbleNotesHistory> {
        return NSFetchRequest<BubbleNotesHistory>(entityName: "BubbleNotesHistory")
    }

    @NSManaged public var value: String?
    @NSManaged public var bubble: Bubble?

}

extension BubbleNotesHistory : Identifiable {

}
