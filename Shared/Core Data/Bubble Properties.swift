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

    @NSManaged public var color: String?
    @NSManaged public var created: Date?
    @NSManaged public var currentClock: Float
    @NSManaged public var hasCalendar: Bool
    @NSManaged public var initialClock: Float
    @NSManaged public var isNoteHidden: Bool
    @NSManaged public var isPinned: Bool
    @NSManaged public var note: String?
    @NSManaged public var rank: Int64
    @NSManaged public var sessions: NSOrderedSet?

}

// MARK: Generated accessors for sessions
extension Bubble {

    @objc(insertObject:inSessionsAtIndex:)
    @NSManaged public func insertIntoSessions(_ value: Session, at idx: Int)

    @objc(removeObjectFromSessionsAtIndex:)
    @NSManaged public func removeFromSessions(at idx: Int)

    @objc(insertSessions:atIndexes:)
    @NSManaged public func insertIntoSessions(_ values: [Session], at indexes: NSIndexSet)

    @objc(removeSessionsAtIndexes:)
    @NSManaged public func removeFromSessions(at indexes: NSIndexSet)

    @objc(replaceObjectInSessionsAtIndex:withObject:)
    @NSManaged public func replaceSessions(at idx: Int, with value: Session)

    @objc(replaceSessionsAtIndexes:withSessions:)
    @NSManaged public func replaceSessions(at indexes: NSIndexSet, with values: [Session])

    @objc(addSessionsObject:)
    @NSManaged public func addToSessions(_ value: Session)

    @objc(removeSessionsObject:)
    @NSManaged public func removeFromSessions(_ value: Session)

    @objc(addSessions:)
    @NSManaged public func addToSessions(_ values: NSOrderedSet)

    @objc(removeSessions:)
    @NSManaged public func removeFromSessions(_ values: NSOrderedSet)

}

extension Bubble : Identifiable {

}
