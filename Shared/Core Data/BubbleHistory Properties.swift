//
//  BubbleHistory+CoreDataProperties.swift
//  Timers
//
//  Created by Cristian Lapusan on 19.05.2022.
//
//

import Foundation
import CoreData


extension BubbleHistory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BubbleHistory> {
        return NSFetchRequest<BubbleHistory>(entityName: "BubbleHistory")
    }

    @NSManaged public var date: Date?
    @NSManaged public var note: String?
    @NSManaged public var bubble: Bubble?

}

extension BubbleHistory : Identifiable {

}
