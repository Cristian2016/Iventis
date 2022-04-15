//
//  Bubble+CoreDataProperties.swift
//  Timers
//
//  Created by Cristian Lapusan on 15.04.2022.
//
//

import Foundation
import CoreData


extension Bubble {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Bubble> {
        return NSFetchRequest<Bubble>(entityName: "Bubble")
    }

    @NSManaged public var created: Date
    @NSManaged public var state: Int16
    @NSManaged public var initialClock: Float
    @NSManaged public var color: String
    
    @NSManaged public var currentClock: Float
    @NSManaged public var isFavorite: Bool

}

extension Bubble : Identifiable {

}
