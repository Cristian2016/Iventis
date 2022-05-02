//
//  Pair+CoreDataProperties.swift
//  Timers
//
//  Created by Cristian Lapusan on 23.04.2022.
//
//

import Foundation
import CoreData


extension Pair {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Pair> {
        return NSFetchRequest<Pair>(entityName: "Pair")
    }

    @NSManaged public var duration: Float
    @NSManaged public var isNoteVisible: Bool
    @NSManaged public var note: String?
    @NSManaged public var pause: Date?
    @NSManaged public var start: Date?
    @NSManaged public var session: Session?

}

extension Pair : Identifiable {

}
