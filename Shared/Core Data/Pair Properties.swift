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

    //1. creation
    @NSManaged public var start: Date?
    
    //2. pause
    @NSManaged public var pause: Date?
    @NSManaged public var duration: Float
    @NSManaged public var durationAsStrings: Data?
    
    //3. optionally
    @NSManaged public var isNoteVisible: Bool
    @NSManaged public var note: String?

    //4. other
    @NSManaged public var session: Session?
}

extension Pair : Identifiable {

}
