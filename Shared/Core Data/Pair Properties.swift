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
    @NSManaged public var history: NSOrderedSet?
}

// MARK: Generated accessors for history
extension Pair {

    @objc(insertObject:inHistoryAtIndex:)
    @NSManaged public func insertIntoHistory(_ value: PairSavedNote, at idx: Int)

    @objc(removeObjectFromHistoryAtIndex:)
    @NSManaged public func removeFromHistory(at idx: Int)

    @objc(insertHistory:atIndexes:)
    @NSManaged public func insertIntoHistory(_ values: [PairSavedNote], at indexes: NSIndexSet)

    @objc(removeHistoryAtIndexes:)
    @NSManaged public func removeFromHistory(at indexes: NSIndexSet)

    @objc(replaceObjectInHistoryAtIndex:withObject:)
    @NSManaged public func replaceHistory(at idx: Int, with value: PairSavedNote)

    @objc(replaceHistoryAtIndexes:withHistory:)
    @NSManaged public func replaceHistory(at indexes: NSIndexSet, with values: [PairSavedNote])

    @objc(addHistoryObject:)
    @NSManaged public func addToHistory(_ value: PairSavedNote)

    @objc(removeHistoryObject:)
    @NSManaged public func removeFromHistory(_ value: PairSavedNote)

    @objc(addHistory:)
    @NSManaged public func addToHistory(_ values: NSOrderedSet)

    @objc(removeHistory:)
    @NSManaged public func removeFromHistory(_ values: NSOrderedSet)

}
