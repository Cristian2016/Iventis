//
//  OldBubbleNote+CoreDataProperties.swift
//  Timers
//
//  Created by Cristian Lapusan on 19.05.2022.
//
//

import Foundation
import CoreData


extension OldBubbleNote {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<OldBubbleNote> {
        return NSFetchRequest<OldBubbleNote>(entityName: "OldBubbleNote")
    }

    @NSManaged public var bubbleID: String?
    @NSManaged public var content: String?
    @NSManaged public var created: Date?

}

extension OldBubbleNote : Identifiable {

}
